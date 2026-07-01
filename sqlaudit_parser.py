import json
import boto3
import struct
import io
from datetime import datetime

s3 = boto3.client('s3')

def parse_sqlaudit_file(file_content):
    """Parse SQL Server .sqlaudit binary file"""
    events = []
    stream = io.BytesIO(file_content)
    
    try:
        # Read file signature
        signature = stream.read(4)
        if signature != b'FNDT':
            return events
        
        # Skip header (512 bytes standard)
        stream.seek(512)
        
        while True:
            # Read record header
            record_header = stream.read(4)
            if not record_header or len(record_header) < 4:
                break
            
            record_length = struct.unpack('<I', record_header)[0]
            if record_length == 0 or record_length > 1000000:
                break
            
            # Read record data
            record_data = stream.read(record_length - 4)
            if len(record_data) < record_length - 4:
                break
            
            # Parse event (simplified - actual format is complex)
            event = parse_audit_record(record_data)
            if event:
                events.append(event)
                
    except Exception as e:
        print(f"Parse error: {e}")
    
    return events

def parse_audit_record(data):
    """Extract audit event details from record"""
    try:
        # SQL Server audit records contain:
        # - Timestamp
        # - Event type
        # - Server principal name (user)
        # - Database name
        # - Statement
        # - Success/Failure
        
        # This is a simplified parser
        # Real implementation needs full XEL/SQLAUDIT format parsing
        
        event = {
            'timestamp': datetime.now().isoformat(),
            'event_type': 'AUDIT_EVENT',
            'server_principal_name': extract_string(data, 0),
            'database_name': extract_string(data, 100),
            'statement': extract_string(data, 200),
            'succeeded': True,
            'raw_length': len(data)
        }
        
        return event
    except:
        return None

def extract_string(data, offset):
    """Extract null-terminated string from binary data"""
    try:
        end = data.find(b'\x00', offset)
        if end == -1:
            return ''
        return data[offset:end].decode('utf-16-le', errors='ignore').strip()
    except:
        return ''

def lambda_handler(event, context):
    """Process .sqlaudit files uploaded to S3"""
    
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        
        # Only process .sqlaudit files
        if not key.endswith('.sqlaudit'):
            continue
        
        print(f"Processing: {key}")
        
        # Download file
        response = s3.get_object(Bucket=bucket, Key=key)
        file_content = response['Body'].read()
        
        # Parse audit file
        events = parse_sqlaudit_file(file_content)
        
        print(f"Extracted {len(events)} events")
        
        # Store parsed events
        output_key = key.replace('.sqlaudit', '.json').replace('raw/', 'processed/')
        
        s3.put_object(
            Bucket=bucket,
            Key=output_key,
            Body=json.dumps(events, indent=2),
            ContentType='application/json'
        )
        
        print(f"Saved to: {output_key}")
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Processed {len(event["Records"])} files')
    }
