# Database Audit AI Solution - Quick Start Guide

## ✅ Deployment Status: COMPLETE

Your infrastructure has been successfully deployed!

## 📦 Deployed Resources

### S3 Buckets
- **Audit Logs**: `db-audit-ai-audit-logs-<YOUR-ACCOUNT-ID>`
- **Reports**: `db-audit-ai-reports-<YOUR-ACCOUNT-ID>`

### Lambda Functions
- **Log Processor**: `db-audit-ai-log-processor`
- **Report Generator**: `db-audit-ai-report-generator`
- **Anomaly Detector**: `db-audit-ai-anomaly-detector`

### SNS Topic
- **Anomaly Alerts**: `arn:aws:sns:us-east-1:<YOUR-ACCOUNT-ID>:db-audit-ai-anomaly-alerts`

### CloudWatch Log Groups
- **SQL Server**: `/aws/rds/sqlserver/audit`
- **PostgreSQL**: `/aws/rds/aurora-postgresql/audit`

### Scheduled Tasks
- **Monthly Reports**: Runs 1st of each month at 2 AM UTC
- **Anomaly Detection**: Runs every hour

## 🚀 Next Steps

### 1. Subscribe to Anomaly Alerts (Optional)

```bash
aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:<YOUR-ACCOUNT-ID>:db-audit-ai-anomaly-alerts \
    --protocol email \
    --notification-endpoint your-email@example.com \
    --region us-east-1
```

Check your email and confirm the subscription.

### 2. Configure Your RDS SQL Server Instances

Connect to each SQL Server instance and run:

```sql
-- Enable SQL Server Audit
USE master;
GO

EXEC msdb.dbo.rds_fn_task_create_audit 
    @audit_name = 'RDSAudit',
    @audit_log_destination = 'CLOUDWATCH';
GO

-- Create Server Audit Specification
CREATE SERVER AUDIT SPECIFICATION LoginAuditSpec
FOR SERVER AUDIT RDSAudit
    ADD (FAILED_LOGIN_GROUP),
    ADD (SUCCESSFUL_LOGIN_GROUP),
    ADD (LOGOUT_GROUP)
WITH (STATE = ON);
GO
```

Then enable CloudWatch Logs export:

```bash
aws rds modify-db-instance \
    --db-instance-identifier YOUR-RDS-INSTANCE-NAME \
    --cloudwatch-logs-export-configuration '{"LogTypesToEnable":["error","agent"]}' \
    --region us-east-1
```

### 3. Configure Your Aurora PostgreSQL Clusters

Connect to each Aurora cluster and run:

```sql
-- Install pgAudit extension
CREATE EXTENSION IF NOT EXISTS pgaudit;

-- Configure audit logging
ALTER SYSTEM SET pgaudit.log = 'all';
ALTER SYSTEM SET pgaudit.log_catalog = on;
ALTER SYSTEM SET pgaudit.log_parameter = on;
ALTER SYSTEM SET pgaudit.log_relation = on;
SELECT pg_reload_conf();

-- Grant audit role to privileged users
CREATE ROLE audit_monitor;
GRANT audit_monitor TO your_dba_user1;
GRANT audit_monitor TO your_dba_user2;
ALTER ROLE audit_monitor SET pgaudit.log = 'all';
```

Then enable CloudWatch Logs export:

```bash
aws rds modify-db-cluster \
    --db-cluster-identifier YOUR-AURORA-CLUSTER-NAME \
    --cloudwatch-logs-export-configuration '{"LogTypesToEnable":["postgresql"]}' \
    --region us-east-1
```

### 4. Test the Solution

#### Test Log Processing
Once logs start flowing, they'll be automatically processed and stored in S3.

#### Test Report Generation (Manual)
```bash
aws lambda invoke \
    --function-name db-audit-ai-report-generator \
    --region us-east-1 \
    output.json

cat output.json
```

#### Test Anomaly Detection (Manual)
```bash
aws lambda invoke \
    --function-name db-audit-ai-anomaly-detector \
    --region us-east-1 \
    output.json

cat output.json
```

#### View Generated Reports
```bash
# List all reports
aws s3 ls s3://db-audit-ai-reports-<YOUR-ACCOUNT-ID>/monthly-reports/ --recursive

# Download latest report
aws s3 cp s3://db-audit-ai-reports-<YOUR-ACCOUNT-ID>/monthly-reports/2026/02/audit-report.txt ./report.txt

# View report
cat report.txt
```

#### View Audit Logs
```bash
# List SQL Server logs
aws s3 ls s3://db-audit-ai-audit-logs-<YOUR-ACCOUNT-ID>/sqlserver/audit-logs/ --recursive

# List PostgreSQL logs
aws s3 ls s3://db-audit-ai-audit-logs-<YOUR-ACCOUNT-ID>/postgresql/audit-logs/ --recursive
```

## 🔍 Monitoring

### CloudWatch Logs
Monitor Lambda execution:
```bash
# Log Processor
aws logs tail /aws/lambda/db-audit-ai-log-processor --follow --region us-east-1

# Report Generator
aws logs tail /aws/lambda/db-audit-ai-report-generator --follow --region us-east-1

# Anomaly Detector
aws logs tail /aws/lambda/db-audit-ai-anomaly-detector --follow --region us-east-1
```

### Check Scheduled Tasks
```bash
# View EventBridge rules
aws events list-rules --name-prefix db-audit-ai --region us-east-1
```

## 🎯 What the Solution Does

### Automated Log Collection
- Streams audit logs from RDS/Aurora to CloudWatch
- Processes and stores logs in S3 with date partitioning
- Retains logs for 90 days in CloudWatch, longer in S3

### AI-Powered Analysis
- Uses Amazon Bedrock (Claude Sonnet 4.6) for intelligent analysis
- Generates natural language insights from log data
- Creates compliance-ready reports with evidence

### Anomaly Detection (Hourly)
- Failed login attempts (>3 in 10 minutes)
- Unusual login times (outside business hours)
- Privileged user activities (DBA users)
- Suspicious query patterns
- Unauthorized schema changes

### Monthly Reports (Automated)
- Executive summary
- Login activity analysis
- Privileged access monitoring
- Change pattern analysis
- Compliance findings
- Recommendations

### Real-time Alerts
- SNS notifications for high-severity anomalies
- Email/SMS alerts (after subscription)
- Immediate notification of suspicious activities

## 🔐 Security Features

- All S3 buckets encrypted (AES-256)
- Reports stored with 7-year retention (Object Lock)
- IAM roles follow least privilege
- No public access to audit data
- CloudTrail logs all API calls

## 💰 Cost Optimization

- Audit logs transition to S3-IA after 90 days
- Glacier storage after 180 days
- Lambda functions use minimal resources
- Pay only for what you use

## 🛠️ Customization

### Add More Privileged Users
```bash
aws lambda update-function-configuration \
    --function-name db-audit-ai-anomaly-detector \
    --environment Variables={PRIVILEGED_USERS='user1,user2,user3',AUDIT_LOGS_BUCKET='db-audit-ai-audit-logs-<YOUR-ACCOUNT-ID>',SNS_TOPIC_ARN='arn:aws:sns:us-east-1:<YOUR-ACCOUNT-ID>:db-audit-ai-anomaly-alerts'} \
    --region us-east-1
```

### Change Report Schedule
Edit the EventBridge rule:
```bash
aws events put-rule \
    --name db-audit-ai-monthly-report \
    --schedule-expression 'cron(0 2 1 * ? *)' \
    --region us-east-1
```

## 📊 Sample Use Cases

1. **Monthly Compliance Audit**: Automated report generation on 1st of each month
2. **Real-time Threat Detection**: Hourly anomaly checks with instant alerts
3. **DBA Activity Monitoring**: Track all privileged user actions
4. **Change Management**: Correlate CR requests with actual database changes
5. **Audit Evidence**: Immutable logs and reports for auditors

## 🆘 Troubleshooting

### No Logs Appearing
1. Verify CloudWatch Logs export is enabled on RDS/Aurora
2. Check Lambda function logs for errors
3. Verify audit configuration in database

### Reports Not Generated
1. Check EventBridge rule is enabled
2. Verify Lambda has sufficient permissions
3. Check Bedrock model access

### Anomaly Alerts Not Received
1. Confirm SNS subscription
2. Check spam folder
3. Verify Lambda execution logs

## 📚 Additional Resources

- Full setup scripts: `rds-sqlserver-audit-setup.sql`, `aurora-postgresql-audit-setup.sql`
- Deployment script: `deploy.sh`
- Infrastructure template: `infrastructure.yaml`
- Complete documentation: `README.md`

## 🎉 You're All Set!

Your database audit AI solution is now running. It will:
- ✅ Collect audit logs automatically
- ✅ Detect anomalies every hour
- ✅ Generate monthly compliance reports
- ✅ Alert you to suspicious activities
- ✅ Provide auditable evidence for compliance

**Next**: Configure your RDS/Aurora instances to start sending audit logs!
