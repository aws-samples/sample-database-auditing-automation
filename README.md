# Database Audit AI Solution

> **Note:** This is sample code for non-production usage. You should work with your security and legal teams to meet your organizational security, regulatory and compliance requirements before deployment.

AI-powered database audit and compliance automation for Amazon RDS SQL Server and Aurora PostgreSQL.

## Features

- **Automated Log Collection**: Streams audit logs from RDS/Aurora to S3 via CloudWatch
- **AI-Powered Analysis**: Uses Amazon Bedrock (Claude 3) for intelligent log analysis
- **Anomaly Detection**: Hourly checks for suspicious activities
- **Monthly Reports**: Automated compliance reports generated on the 1st of each month
- **Real-time Alerts**: SNS notifications for high-severity anomalies
- **Privileged Access Monitoring**: Tracks DBA user activities
- **Change Pattern Analysis**: Monitors schema changes and CR executions

## Architecture

```
RDS/Aurora → CloudWatch Logs → Lambda (Processor) → S3 (Audit Logs)
                                                      ↓
                                            Lambda (AI Analyzer)
                                                      ↓
                                            Bedrock (Claude 3)
                                                      ↓
                                            S3 (Reports) + SNS (Alerts)
```

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Amazon Bedrock access (Claude 3 Sonnet model)
- RDS SQL Server and/or Aurora PostgreSQL instances

## One-Click Deploy

Upload `infrastructure.yaml` to an S3 bucket in your account, then click:

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=db-audit-ai&templateURL=REPLACE_WITH_YOUR_S3_TEMPLATE_URL)

**Quick steps:**
```bash
# 1. Upload template to your S3 bucket
aws s3 cp infrastructure.yaml s3://YOUR-BUCKET/db-audit-ai/infrastructure.yaml

# 2. Launch via console (replace YOUR-BUCKET and REGION)
echo "https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=db-audit-ai&templateURL=https://YOUR-BUCKET.s3.amazonaws.com/db-audit-ai/infrastructure.yaml"
```

Or deploy directly via CLI:
```bash
aws cloudformation deploy \
    --template-file infrastructure.yaml \
    --stack-name db-audit-ai \
    --capabilities CAPABILITY_IAM \
    --region us-east-1
```

## Deployment (Manual)

### 1. Enable Bedrock Model Access

Go to AWS Console → Bedrock → Model access → Enable "Claude 3 Sonnet"

### 2. Update Configuration

Edit `deploy.sh` and set your email:
```bash
EMAIL_FOR_ALERTS="your-email@example.com"
```

### 3. Deploy Infrastructure

```bash
cd db-audit-ai
chmod +x deploy.sh
./deploy.sh
```

### 4. Configure Database Audit Logging

**For RDS SQL Server:**
```bash
# Connect to your SQL Server instance and run:
sqlcmd -S your-instance.region.rds.amazonaws.com -U admin -P password -i rds-sqlserver-audit-setup.sql
```

**For Aurora PostgreSQL:**
```bash
# Connect to your Aurora cluster and run:
psql -h your-cluster.region.rds.amazonaws.com -U postgres -f aurora-postgresql-audit-setup.sql
```

### 5. Enable CloudWatch Logs Export

**SQL Server:**
```bash
aws rds modify-db-instance \
    --db-instance-identifier your-rds-instance \
    --cloudwatch-logs-export-configuration '{"LogTypesToEnable":["error","agent"]}' \
    --region us-east-1
```

**PostgreSQL:**
```bash
aws rds modify-db-cluster \
    --db-cluster-identifier your-aurora-cluster \
    --cloudwatch-logs-export-configuration '{"LogTypesToEnable":["postgresql"]}' \
    --region us-east-1
```

## Usage

### Manual Report Generation

```bash
aws lambda invoke \
    --function-name db-audit-ai-report-generator \
    --region us-east-1 \
    output.json

cat output.json
```

### Manual Anomaly Detection

```bash
aws lambda invoke \
    --function-name db-audit-ai-anomaly-detector \
    --region us-east-1 \
    output.json
```

### View Reports

```bash
# List all reports
aws s3 ls s3://db-audit-ai-reports-{account-id}/monthly-reports/ --recursive

# Download latest report
aws s3 cp s3://db-audit-ai-reports-{account-id}/monthly-reports/2026/02/audit-report.txt .
```

### View Audit Logs

```bash
# List audit logs
aws s3 ls s3://db-audit-ai-audit-logs-{account-id}/sqlserver/audit-logs/ --recursive
aws s3 ls s3://db-audit-ai-audit-logs-{account-id}/postgresql/audit-logs/ --recursive
```

## Monitoring

### CloudWatch Logs

- SQL Server: `/aws/rds/sqlserver/audit`
- PostgreSQL: `/aws/rds/aurora-postgresql/audit`

### Lambda Functions

- `db-audit-ai-log-processor`: Processes and stores logs
- `db-audit-ai-report-generator`: Generates monthly reports (runs 1st of month at 2 AM)
- `db-audit-ai-anomaly-detector`: Detects anomalies (runs hourly)

### SNS Alerts

Subscribe to `db-audit-ai-anomaly-alerts` topic for real-time notifications

## Anomaly Detection

The system monitors for:

1. **Failed Login Attempts**: >3 failures in 10 minutes
2. **Unusual Login Times**: Access outside business hours (9 AM - 6 PM)
3. **Privileged User Activities**: DBA user actions (configurable via environment variable)
4. **Suspicious Query Patterns**: Unusual data access or modifications
5. **Unauthorized Changes**: Schema changes without CR correlation

## Compliance Features

- **7-Year Retention**: Reports stored with S3 Object Lock (COMPLIANCE mode)
- **Immutable Audit Trail**: Versioned S3 buckets with encryption
- **Audit Evidence**: All logs and reports timestamped and traceable
- **Access Logging**: CloudTrail tracks all access to audit data

## Cost Optimization

- Audit logs transition to S3-IA after 90 days, Glacier after 180 days
- CloudWatch Logs retention: 90 days
- Lambda functions use minimal memory and timeout settings

## Troubleshooting

### Bedrock Access Denied

Enable model access in AWS Console → Bedrock → Model access

### No Logs Appearing

1. Verify CloudWatch Logs export is enabled on RDS/Aurora
2. Check Lambda function logs in CloudWatch
3. Verify audit configuration in database

### Reports Not Generated

1. Check EventBridge rule is enabled
2. Verify Lambda has sufficient timeout (900s)
3. Check S3 bucket permissions

## Security Best Practices

- All S3 buckets have encryption enabled
- IAM roles follow least privilege principle
- No public access to audit data
- CloudTrail logs all API calls

## Customization

### Add More Privileged Users

Edit Lambda environment variable:
```bash
aws lambda update-function-configuration \
    --function-name db-audit-ai-anomaly-detector \
    --environment Variables={PRIVILEGED_USERS='user1,user2,user3'} \
    --region us-east-1
```

### Change Report Schedule

Modify EventBridge rule cron expression in `infrastructure.yaml`

### Adjust Anomaly Detection Sensitivity

Edit the prompt in `AnomalyDetectorFunction` Lambda code

## Support

For issues or questions, check:
- CloudWatch Logs for Lambda execution logs
- S3 buckets for stored data
- SNS topic for alert history

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the [LICENSE](LICENSE) file.
