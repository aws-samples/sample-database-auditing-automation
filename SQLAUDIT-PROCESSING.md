# SQL Audit File Processing

## ✅ SQL Audit Parser Deployed

The solution now supports processing actual SQL Server `.sqlaudit` files like:
`Audit-20230716-141753_CDACA2B9-2917-434E-8C1E-438351ADC0E7_0_133339796730290000.sqlaudit`

## How It Works

1. **Upload** `.sqlaudit` files to S3
2. **Lambda automatically triggers** when files are uploaded
3. **Parser extracts** audit events from binary format
4. **JSON output** saved for AI analysis
5. **Reports include** parsed audit data

## Upload SQL Audit Files

### Single File
```bash
./upload-sqlaudit.sh Audit-20230716-141753.sqlaudit
```

### Multiple Files (Directory)
```bash
./upload-sqlaudit.sh /path/to/audit/files/
```

### Manual Upload
```bash
aws s3 cp your-file.sqlaudit \
    s3://db-audit-ai-audit-logs-<YOUR-ACCOUNT-ID>/raw/sqlserver/ \
    --region us-east-1
```

## What Gets Extracted

From each `.sqlaudit` file:
- **Timestamp** - When the event occurred
- **Event Type** - Type of audit event
- **Server Principal Name** - User who performed the action
- **Database Name** - Target database
- **Statement** - SQL statement executed
- **Success/Failure** - Whether the action succeeded

## File Locations

**Raw files:** `s3://db-audit-ai-audit-logs-<YOUR-ACCOUNT-ID>/raw/sqlserver/`
**Processed JSON:** `s3://db-audit-ai-audit-logs-<YOUR-ACCOUNT-ID>/processed/sqlserver/`

## View Processed Files

```bash
# List processed files
aws s3 ls s3://db-audit-ai-audit-logs-<YOUR-ACCOUNT-ID>/processed/sqlserver/ --region us-east-1

# Download a processed file
aws s3 cp s3://db-audit-ai-audit-logs-<YOUR-ACCOUNT-ID>/processed/sqlserver/Audit-20230716.json . --region us-east-1

# View content
cat Audit-20230716.json | jq .
```

## Integration with AI Reports

The parsed JSON files are automatically included in:
- Monthly compliance reports
- Anomaly detection analysis
- Dashboard statistics

## Example Workflow

1. Export `.sqlaudit` files from SQL Server
2. Upload using the script: `./upload-sqlaudit.sh *.sqlaudit`
3. Lambda processes files automatically (< 1 minute)
4. View parsed data in S3 or dashboard
5. Generate AI report: Click "Generate Report Now" in dashboard
6. Report includes analysis of your audit files

## Monitoring

Check Lambda logs:
```bash
aws logs tail /aws/lambda/db-audit-ai-sqlaudit-parser --follow --region us-east-1
```

## Supported Format

- SQL Server `.sqlaudit` files (binary format)
- Extended Events `.xel` files (coming soon)
- CloudWatch Logs (already supported)

## Notes

- Files are processed asynchronously
- Large files (>100MB) may take longer
- Parser handles corrupted files gracefully
- Original files are preserved in `raw/` folder

## Troubleshooting

**File not processing?**
- Check file extension is `.sqlaudit`
- Verify file is uploaded to `raw/sqlserver/` folder
- Check Lambda logs for errors

**No events extracted?**
- File may be corrupted
- Check file format (must be SQL Server audit format)
- Verify file size > 0 bytes

**Parser errors?**
- Some audit file formats may need custom parsing
- Contact support with sample file
