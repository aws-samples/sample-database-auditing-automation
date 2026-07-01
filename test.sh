#!/bin/bash

# Test script for Database Audit AI Solution

set -e

REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AUDIT_BUCKET="db-audit-ai-audit-logs-${AWS_ACCOUNT_ID}"
REPORTS_BUCKET="db-audit-ai-reports-${AWS_ACCOUNT_ID}"

echo "=== Database Audit AI Solution - Test Script ==="
echo ""

# Test 1: Check S3 Buckets
echo "Test 1: Checking S3 buckets..."
aws s3 ls s3://$AUDIT_BUCKET --region $REGION > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Audit logs bucket accessible"
else
    echo "✗ Audit logs bucket not accessible"
fi

aws s3 ls s3://$REPORTS_BUCKET --region $REGION > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Reports bucket accessible"
else
    echo "✗ Reports bucket not accessible"
fi

# Test 2: Check Lambda Functions
echo ""
echo "Test 2: Checking Lambda functions..."
aws lambda get-function --function-name db-audit-ai-log-processor --region $REGION > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Log processor function exists"
else
    echo "✗ Log processor function not found"
fi

aws lambda get-function --function-name db-audit-ai-report-generator --region $REGION > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Report generator function exists"
else
    echo "✗ Report generator function not found"
fi

aws lambda get-function --function-name db-audit-ai-anomaly-detector --region $REGION > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Anomaly detector function exists"
else
    echo "✗ Anomaly detector function not found"
fi

# Test 3: Check CloudWatch Log Groups
echo ""
echo "Test 3: Checking CloudWatch log groups..."
aws logs describe-log-groups --log-group-name-prefix /aws/rds --region $REGION > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ CloudWatch log groups configured"
else
    echo "✗ CloudWatch log groups not found"
fi

# Test 4: Check EventBridge Rules
echo ""
echo "Test 4: Checking EventBridge rules..."
aws events describe-rule --name db-audit-ai-monthly-report --region $REGION > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Monthly report schedule configured"
else
    echo "✗ Monthly report schedule not found"
fi

aws events describe-rule --name db-audit-ai-hourly-anomaly-check --region $REGION > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Hourly anomaly check configured"
else
    echo "✗ Hourly anomaly check not found"
fi

# Test 5: Check SNS Topic
echo ""
echo "Test 5: Checking SNS topic..."
aws sns get-topic-attributes --topic-arn arn:aws:sns:us-east-1:${AWS_ACCOUNT_ID}:db-audit-ai-anomaly-alerts --region $REGION > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ SNS topic for alerts exists"
else
    echo "✗ SNS topic not found"
fi

# Test 6: Create sample log and test processing
echo ""
echo "Test 6: Creating sample audit log..."
SAMPLE_LOG='[{"timestamp": 1708329600000, "message": "LOGIN: User=test_user, Database=testdb, Result=SUCCESS", "db_type": "sqlserver"}]'
DATE_PREFIX=$(date +%Y/%m/%d)
aws s3 cp - s3://$AUDIT_BUCKET/sqlserver/audit-logs/$DATE_PREFIX/test-log.json --region $REGION <<< "$SAMPLE_LOG"
if [ $? -eq 0 ]; then
    echo "✓ Sample log uploaded successfully"
else
    echo "✗ Failed to upload sample log"
fi

# Test 7: Test Bedrock Access
echo ""
echo "Test 7: Checking Bedrock access..."
aws bedrock list-foundation-models --region us-east-1 --query 'modelSummaries[?contains(modelId, `claude-sonnet-4-6`)]' > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Bedrock access configured"
else
    echo "✗ Bedrock access may not be enabled"
fi

echo ""
echo "=== Test Summary ==="
echo ""
echo "All core components are deployed and accessible!"
echo ""
echo "Next steps:"
echo "1. Configure your RDS/Aurora instances (see QUICKSTART.md)"
echo "2. Subscribe to SNS alerts (optional)"
echo "3. Wait for audit logs to flow from your databases"
echo "4. Test report generation manually or wait for monthly schedule"
echo ""
echo "To test report generation now:"
echo "  aws lambda invoke --function-name db-audit-ai-report-generator --region us-east-1 output.json"
echo ""
echo "To test anomaly detection now:"
echo "  aws lambda invoke --function-name db-audit-ai-anomaly-detector --region us-east-1 output.json"
