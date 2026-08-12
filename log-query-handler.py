"""
PostgreSQL Log Query Handler
Routes queries to CloudWatch Logs Insights (real-time) or Athena (historical)
based on the requested time range.
"""

import json
import os
import time
import boto3
from datetime import datetime, timedelta

# Clients
logs_client = boto3.client('logs')
athena_client = boto3.client('athena')

# Configuration
LOG_GROUP = os.environ.get('LOG_GROUP', '/aws/rds/cluster/database-rnd/postgresql')
ATHENA_DATABASE = os.environ.get('ATHENA_DATABASE', 'rds_logs')
ATHENA_TABLE = os.environ.get('ATHENA_TABLE', 'postgresql_logs')
ATHENA_RESULTS_S3 = os.environ.get('ATHENA_RESULTS_S3', '')
ATHENA_WORKGROUP = os.environ.get('ATHENA_WORKGROUP', 'db-audit-ai-workgroup')
ATHENA_TIMEOUT = int(os.environ.get('ATHENA_TIMEOUT', '55'))
CW_RETENTION_DAYS = int(os.environ.get('CW_RETENTION_DAYS', '30'))


def lambda_handler(event, context):
    """Main handler - routes to CloudWatch or Athena based on time range."""
    try:
        # Parse request
        if event.get('body'):
            body = json.loads(event['body'])
        else:
            body = event

        query_type = body.get('type', 'logs')
        time_range = body.get('timeRange', 'last_24h')
        start_time = body.get('startTime')
        end_time = body.get('endTime')
        limit = body.get('limit', 100)
        username = body.get('username', '')

        # Determine routing
        use_athena = should_use_athena(query_type, time_range, start_time)

        if use_athena:
            result = query_athena(query_type, start_time, end_time, limit, username)
            source = 'athena'
        else:
            result = query_cloudwatch(query_type, time_range, start_time, end_time, limit, username)
            source = 'cloudwatch'

        return response(200, {
            'success': True,
            'source': source,
            'data': result,
            'query_type': query_type,
            'count': len(result) if isinstance(result, list) else 0
        })

    except Exception as e:
        return response(500, {
            'success': False,
            'error': str(e)
        })


def should_use_athena(query_type, time_range, start_time):
    """Determine if query should go to Athena (historical) or CloudWatch (real-time)."""
    # Explicitly Athena-prefixed queries
    if query_type.startswith('athena_'):
        return True

    # Quick ranges always use CloudWatch
    if time_range in ['last_hour', 'last_24h', 'last_7d', 'last_30d']:
        return False

    # Custom range — check if start is beyond CW retention
    if start_time:
        try:
            start_dt = datetime.fromisoformat(start_time.replace('Z', '+00:00'))
            cutoff = datetime.now(start_dt.tzinfo) - timedelta(days=CW_RETENTION_DAYS)
            if start_dt < cutoff:
                return True
        except (ValueError, TypeError):
            pass

    return False


def response(status_code, body):
    """Build API Gateway response."""
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'POST, OPTIONS'
        },
        'body': json.dumps(body, default=str)
    }


# ─────────────────────────────────────────────
# CloudWatch Logs Insights Queries
# ─────────────────────────────────────────────

def get_time_range_epoch(time_range, start_time=None, end_time=None):
    """Convert time range to epoch seconds."""
    now = int(time.time())

    if time_range == 'last_hour':
        return now - 3600, now
    elif time_range == 'last_24h':
        return now - 86400, now
    elif time_range == 'last_7d':
        return now - 604800, now
    elif time_range == 'last_30d':
        return now - 2592000, now
    elif start_time and end_time:
        start_dt = datetime.fromisoformat(start_time.replace('Z', '+00:00'))
        end_dt = datetime.fromisoformat(end_time.replace('Z', '+00:00'))
        return int(start_dt.timestamp()), int(end_dt.timestamp())
    else:
        return now - 86400, now


def query_cloudwatch(query_type, time_range, start_time, end_time, limit, username):
    """Execute CloudWatch Logs Insights query."""
    start_epoch, end_epoch = get_time_range_epoch(time_range, start_time, end_time)

    # Build query based on type
    query = build_cw_query(query_type, limit, username)

    # Start query
    response = logs_client.start_query(
        logGroupName=LOG_GROUP,
        startTime=start_epoch,
        endTime=end_epoch,
        queryString=query,
        limit=limit
    )
    query_id = response['queryId']

    # Poll for results
    while True:
        result = logs_client.get_query_results(queryId=query_id)
        if result['status'] in ['Complete', 'Failed', 'Cancelled', 'Timeout']:
            break
        time.sleep(0.5)

    if result['status'] != 'Complete':
        raise Exception(f"CloudWatch query failed: {result['status']}")

    # Format results
    return format_cw_results(result['results'], query_type)


def build_cw_query(query_type, limit, username):
    """Build CloudWatch Logs Insights query string."""

    if query_type == 'logs':
        return f"""
fields @timestamp, @message
| sort @timestamp desc
| limit {limit}
"""

    elif query_type == 'slow_queries':
        return f"""
fields @timestamp, @message
| filter @message like /duration:/
| parse @message "duration: * ms" as duration_ms
| filter duration_ms > 1000
| sort duration_ms desc
| limit {limit}
"""

    elif query_type == 'active_users':
        return """
fields @timestamp, @message
| filter @message like /connection authorized/
| parse @message "*:*:*@*:[*]:" as ts, host, user, db, pid
| stats count(*) as connections, max(@timestamp) as last_seen by user
| sort connections desc
| limit 50
"""

    elif query_type == 'top_cpu_queries':
        return f"""
fields @timestamp, @message
| filter @message like /duration:/
| parse @message "*:*:*@*:[*]:*duration: * ms" as ts, host, user, db, pid, prefix, duration_ms
| sort duration_ms desc
| limit {limit}
"""

    elif query_type == 'user_activity':
        if username:
            return f"""
fields @timestamp, @message
| filter @message like /{username}/
| sort @timestamp desc
| limit {limit}
"""
        else:
            return f"""
fields @timestamp, @message
| filter @message like /statement:/
| sort @timestamp desc
| limit {limit}
"""

    elif query_type == 'failed_logins':
        return f"""
fields @timestamp, @message
| filter @message like /authentication failed/
| sort @timestamp desc
| limit {limit}
"""

    elif query_type == 'schema_changes':
        return f"""
fields @timestamp, @message
| filter @message like /CREATE|ALTER|DROP/
| filter @message not like /CREATE TEMP/
| sort @timestamp desc
| limit {limit}
"""

    else:
        return f"""
fields @timestamp, @message
| sort @timestamp desc
| limit {limit}
"""


def format_cw_results(results, query_type):
    """Format CloudWatch query results into clean JSON."""
    formatted = []
    for row in results:
        entry = {}
        for field in row:
            entry[field['field']] = field['value']
        formatted.append(entry)
    return formatted


# ─────────────────────────────────────────────
# Athena Queries (Historical)
# ─────────────────────────────────────────────

def query_athena(query_type, start_time, end_time, limit, username):
    """Execute Athena query for historical data."""
    query = build_athena_query(query_type, start_time, end_time, limit, username)

    # Start query execution
    execution = athena_client.start_query_execution(
        QueryString=query,
        QueryExecutionContext={'Database': ATHENA_DATABASE},
        WorkGroup=ATHENA_WORKGROUP
    )
    execution_id = execution['QueryExecutionId']

    # Poll for completion
    timeout = time.time() + ATHENA_TIMEOUT
    while time.time() < timeout:
        status = athena_client.get_query_execution(QueryExecutionId=execution_id)
        state = status['QueryExecution']['Status']['State']

        if state == 'SUCCEEDED':
            break
        elif state in ['FAILED', 'CANCELLED']:
            reason = status['QueryExecution']['Status'].get('StateChangeReason', 'Unknown')
            raise Exception(f"Athena query {state}: {reason}")

        time.sleep(1)
    else:
        raise Exception("Athena query timed out")

    # Get results
    results = athena_client.get_query_results(QueryExecutionId=execution_id)
    return format_athena_results(results)


def build_athena_query(query_type, start_time, end_time, limit, username):
    """Build Athena SQL query."""

    # Build time filter
    time_filter = ""
    if start_time and end_time:
        # Extract partition values
        start_dt = datetime.fromisoformat(start_time.replace('Z', '+00:00'))
        end_dt = datetime.fromisoformat(end_time.replace('Z', '+00:00'))
        time_filter = f"""
        AND year >= '{start_dt.year}'
        AND month >= '{start_dt.month:02d}'
        AND day >= '{start_dt.day:02d}'
        AND year <= '{end_dt.year}'
        AND month <= '{end_dt.month:02d}'
        AND day <= '{end_dt.day:02d}'
        """

    table = f"{ATHENA_DATABASE}.{ATHENA_TABLE}"

    if query_type in ('athena_logs', 'logs'):
        return f"""
        SELECT timestamp, message, logStream
        FROM {table}
        WHERE message != ''
        {time_filter}
        ORDER BY timestamp DESC
        LIMIT {limit}
        """

    elif query_type in ('athena_slow_queries', 'slow_queries'):
        return f"""
        SELECT timestamp, message,
               CAST(regexp_extract(message, 'duration: ([0-9.]+) ms', 1) AS DOUBLE) as duration_ms
        FROM {table}
        WHERE message LIKE '%duration:%'
        AND CAST(regexp_extract(message, 'duration: ([0-9.]+) ms', 1) AS DOUBLE) > 1000
        {time_filter}
        ORDER BY duration_ms DESC
        LIMIT {limit}
        """

    elif query_type in ('athena_active_users', 'active_users'):
        return f"""
        SELECT regexp_extract(message, ':([^@]+)@', 1) as username,
               COUNT(*) as connection_count,
               MAX(timestamp) as last_seen
        FROM {table}
        WHERE message LIKE '%connection authorized%'
        {time_filter}
        GROUP BY regexp_extract(message, ':([^@]+)@', 1)
        ORDER BY connection_count DESC
        LIMIT 50
        """

    elif query_type in ('athena_top_cpu', 'top_cpu_queries'):
        return f"""
        SELECT timestamp, message,
               regexp_extract(message, ':([^@]+)@', 1) as username,
               CAST(regexp_extract(message, 'duration: ([0-9.]+) ms', 1) AS DOUBLE) as duration_ms
        FROM {table}
        WHERE message LIKE '%duration:%'
        {time_filter}
        ORDER BY CAST(regexp_extract(message, 'duration: ([0-9.]+) ms', 1) AS DOUBLE) DESC
        LIMIT {limit}
        """

    elif query_type in ('athena_user_activity', 'user_activity'):
        user_filter = f"AND message LIKE '%{username}%'" if username else ""
        return f"""
        SELECT timestamp, message
        FROM {table}
        WHERE message LIKE '%statement:%'
        {user_filter}
        {time_filter}
        ORDER BY timestamp DESC
        LIMIT {limit}
        """

    elif query_type == 'athena_failed_logins':
        return f"""
        SELECT timestamp, message
        FROM {table}
        WHERE message LIKE '%authentication failed%'
        {time_filter}
        ORDER BY timestamp DESC
        LIMIT {limit}
        """

    elif query_type == 'athena_schema_changes':
        return f"""
        SELECT timestamp, message
        FROM {table}
        WHERE (message LIKE '%CREATE %' OR message LIKE '%ALTER %' OR message LIKE '%DROP %')
        AND message NOT LIKE '%CREATE TEMP%'
        {time_filter}
        ORDER BY timestamp DESC
        LIMIT {limit}
        """

    else:
        return f"""
        SELECT timestamp, message
        FROM {table}
        WHERE message != ''
        {time_filter}
        ORDER BY timestamp DESC
        LIMIT {limit}
        """


def format_athena_results(results):
    """Format Athena query results into clean JSON."""
    rows = results['ResultSet']['Rows']
    if len(rows) <= 1:
        return []

    # First row is headers
    headers = [col['VarCharValue'] for col in rows[0]['Data']]

    formatted = []
    for row in rows[1:]:
        entry = {}
        for i, col in enumerate(row['Data']):
            entry[headers[i]] = col.get('VarCharValue', '')
        formatted.append(entry)

    return formatted
