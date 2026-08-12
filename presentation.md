# Database Audit AI Solution
## AI-Powered Database Auditing & Compliance Automation

---

## Slide 1: Problem Statement

### Current Challenges

- **Manual Audit Log Review** — DBAs spend hours manually reviewing database logs
- **Delayed Anomaly Detection** — Suspicious activities discovered days or weeks later
- **Compliance Burden** — Generating monthly compliance reports is time-consuming and error-prone
- **Lack of Centralized Visibility** — Audit data scattered across multiple databases and formats
- **No Proactive Alerts** — Teams react to breaches instead of preventing them

### Business Risk

- Regulatory non-compliance (SOX, PCI-DSS, HIPAA)
- Undetected unauthorized access
- No immutable audit trail for auditors
- Manual processes don't scale

---

## Slide 2: Solution Overview

### Database Audit AI Solution

An **AI-powered, serverless** solution that automates database audit log collection, analysis, anomaly detection, and compliance reporting for Amazon RDS SQL Server and Aurora PostgreSQL.

### Key Capabilities

| Capability | Description |
|-----------|-------------|
| Automated Log Collection | Streams audit logs from RDS/Aurora → CloudWatch → S3 |
| AI-Powered Analysis | Amazon Bedrock (Claude 3) for intelligent log analysis |
| Real-Time Anomaly Detection | Hourly checks for suspicious activities |
| Monthly Compliance Reports | Auto-generated on the 1st of each month |
| Instant Alerts | SNS notifications for high-severity anomalies |
| Web Dashboard | Real-time visibility into audit status and reports |
| Immutable Audit Trail | 7-year retention with S3 Object Lock (COMPLIANCE mode) |

---

## Slide 3: Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│   ┌──────────────┐     ┌──────────────┐     ┌──────────────────────┐   │
│   │  RDS SQL     │     │  CloudWatch  │     │   S3 - Audit Logs    │   │
│   │  Server      │────▶│  Logs        │────▶│   (Encrypted, LC)    │   │
│   └──────────────┘     └──────────────┘     └──────────┬───────────┘   │
│                                                         │               │
│   ┌──────────────┐     ┌──────────────┐                │               │
│   │  Aurora      │     │  CloudWatch  │                ▼               │
│   │  PostgreSQL  │────▶│  Logs        │────▶  Lambda (Log Processor)   │
│   └──────────────┘     └──────────────┘                │               │
│                                                         │               │
│                              ┌──────────────────────────┤               │
│                              │                          │               │
│                              ▼                          ▼               │
│                  ┌──────────────────┐     ┌──────────────────────┐     │
│                  │  Lambda          │     │  Lambda              │     │
│                  │  (Anomaly        │     │  (Report Generator)  │     │
│                  │   Detector)      │     │  Monthly @ 2AM UTC   │     │
│                  │  Hourly          │     └──────────┬───────────┘     │
│                  └────────┬─────────┘                │               │
│                           │                          │               │
│                           ▼                          ▼               │
│                  ┌──────────────────┐     ┌──────────────────────┐     │
│                  │  Amazon Bedrock  │     │  Amazon Bedrock      │     │
│                  │  (Claude 3)      │     │  (Claude 3)          │     │
│                  └────────┬─────────┘     └──────────┬───────────┘     │
│                           │                          │               │
│                           ▼                          ▼               │
│                  ┌──────────────────┐     ┌──────────────────────┐     │
│                  │  SNS Alerts      │     │  S3 - Reports        │     │
│                  │  (Real-time)     │     │  (7-yr Object Lock)  │     │
│                  └──────────────────┘     └──────────────────────┘     │
│                                                                         │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │  Web Dashboard (S3 + CloudFront + API Gateway + Lambda)         │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Slide 4: Supported Database Engines

### Amazon RDS SQL Server

- SQL Server Audit (.sqlaudit files)
- Login tracking (success/failure)
- Statement-level auditing
- Binary file parsing with custom Lambda parser

### Amazon Aurora PostgreSQL

- pgAudit extension
- All DDL/DML/DCL statement logging
- Role-based audit configuration
- Parameter and relation logging

### Log Flow

```
Database → CloudWatch Logs → Lambda (Processor) → S3 (Partitioned by date)
                                                      ↕
                              .sqlaudit files → Lambda (Parser) → S3 (JSON)
```

---

## Slide 5: AI-Powered Anomaly Detection

### What We Monitor (Hourly)

| Anomaly Type | Trigger |
|-------------|---------|
| Failed Login Attempts | >3 failures in 10 minutes |
| Unusual Login Times | Access outside business hours (9 AM – 6 PM) |
| Privileged User Activities | DBA user actions (configurable list) |
| Suspicious Query Patterns | Unusual data access or bulk modifications |
| Unauthorized Schema Changes | DDL without CR correlation |

### How It Works

1. **Lambda** pulls last hour's audit logs from S3
2. **Bedrock (Claude 3)** analyzes patterns against baseline
3. **Severity scoring** — Low / Medium / High / Critical
4. **SNS notification** sent for High/Critical findings
5. **All findings** stored in S3 for historical analysis

---

## Slide 6: Monthly Compliance Reports

### Auto-Generated on 1st of Each Month at 2 AM UTC

**Report Sections:**

1. **Executive Summary** — Overall compliance posture
2. **Login Activity Analysis** — Successful/failed logins, patterns
3. **Privileged Access Monitoring** — DBA user actions audit
4. **Change Pattern Analysis** — Schema changes, CR correlation
5. **Anomaly Summary** — All detected anomalies for the month
6. **Compliance Findings** — Gaps and violations
7. **Recommendations** — AI-generated actionable improvements

### Compliance Standards Addressed

- SOX (Sarbanes-Oxley)
- PCI-DSS (Payment Card Industry)
- HIPAA (Healthcare)
- General audit readiness

---

## Slide 7: Web Dashboard

### Real-Time Visibility

**Dashboard Tab:**
- SQL Server logs count (today)
- PostgreSQL logs count (today)
- Total reports generated
- Quick action: Generate report now

**Reports Tab:**
- List of all compliance reports
- View/download report content
- Sort by date

### Access

- Served via **CloudFront** (HTTPS)
- Private S3 bucket (not publicly accessible)
- API Gateway backend with CORS
- IAM roles with least privilege

---

## Slide 8: Security & Compliance Features

| Feature | Implementation |
|---------|---------------|
| Encryption at Rest | AES-256 on all S3 buckets |
| Immutable Audit Trail | S3 Object Lock (COMPLIANCE mode) — 7-year retention |
| Versioning | All S3 buckets versioned |
| No Public Access | Public access blocked on all buckets |
| Least Privilege IAM | Minimal permissions per Lambda function |
| Access Logging | CloudTrail tracks all API calls to audit data |
| Data Lifecycle | Logs → S3-IA (90d) → Glacier (180d) |

---

## Slide 9: Infrastructure & Deployment

### Fully Serverless — No Servers to Manage

| Component | AWS Service |
|-----------|-------------|
| Compute | AWS Lambda (3 functions) |
| Storage | Amazon S3 (2 buckets) |
| AI/ML | Amazon Bedrock (Claude 3 Sonnet) |
| Notifications | Amazon SNS |
| Scheduling | Amazon EventBridge |
| Logging | Amazon CloudWatch Logs |
| Frontend | S3 + CloudFront |
| API | Amazon API Gateway + Lambda |
| IaC | AWS CloudFormation |

### One-Click Deployment

```bash
aws cloudformation deploy \
    --template-file infrastructure.yaml \
    --stack-name db-audit-ai \
    --capabilities CAPABILITY_IAM \
    --region us-east-1
```

---

## Slide 10: Cost Optimization

### Pay-Per-Use Model

| Resource | Cost Driver | Optimization |
|----------|-------------|--------------|
| Lambda | Invocations + Duration | Minimal memory, 900s timeout |
| S3 | Storage + Requests | Lifecycle policies (IA → Glacier) |
| Bedrock | Input/Output tokens | Summarized logs, efficient prompts |
| CloudWatch | Log ingestion + retention | 90-day retention |
| SNS | Notifications sent | Alerts only for High/Critical |

### Estimated Monthly Cost

For a typical environment (2-3 DB instances, moderate activity):
- **~$15–50/month** depending on log volume and Bedrock usage

---

## Slide 11: Deployment Steps

### Step 1: Deploy Infrastructure
```bash
./deploy.sh
```

### Step 2: Enable Bedrock Model Access
AWS Console → Bedrock → Model Access → Enable Claude 3 Sonnet

### Step 3: Configure Database Auditing

**SQL Server:**
```sql
EXEC msdb.dbo.rds_fn_task_create_audit @audit_name='RDSAudit', @audit_log_destination='CLOUDWATCH';
```

**PostgreSQL:**
```sql
CREATE EXTENSION IF NOT EXISTS pgaudit;
ALTER SYSTEM SET pgaudit.log = 'all';
```

### Step 4: Enable CloudWatch Log Export
```bash
aws rds modify-db-instance --db-instance-identifier <instance> \
    --cloudwatch-logs-export-configuration '{"LogTypesToEnable":["error","agent"]}'
```

### Step 5: Subscribe to Alerts
```bash
aws sns subscribe --topic-arn <topic-arn> --protocol email --notification-endpoint your@email.com
```

---

## Slide 12: SQL Audit File Processing

### For Existing .sqlaudit Files

Upload historical or exported `.sqlaudit` files for retroactive analysis:

```bash
./upload-sqlaudit.sh /path/to/audit/files/
```

### Processing Pipeline

```
.sqlaudit (binary) → Lambda Parser → JSON (structured) → S3 → AI Analysis
```

### Extracted Data Points

- Timestamp
- Event Type
- Server Principal Name (user)
- Database Name
- SQL Statement
- Success/Failure status

---

## Slide 13: Use Cases

| Use Case | How It Helps |
|----------|-------------|
| Monthly Compliance Audit | Automated report generation — zero manual effort |
| Real-Time Threat Detection | Hourly anomaly checks with instant email/SMS alerts |
| DBA Activity Monitoring | Track all privileged user actions automatically |
| Change Management | Correlate schema changes with approved CRs |
| Audit Evidence for Regulators | Immutable, timestamped logs and reports (7-year retention) |
| Incident Investigation | Searchable, structured audit trail in S3 |
| Cost-Effective Compliance | Serverless = pay only for what you use |

---

## Slide 14: Customization Options

### Configurable Parameters

| Parameter | How to Change |
|-----------|---------------|
| Privileged Users List | Lambda environment variable |
| Report Schedule | EventBridge cron expression |
| Anomaly Sensitivity | Bedrock prompt tuning |
| Business Hours Definition | Lambda configuration |
| Alert Recipients | SNS subscription |
| Log Retention | S3 lifecycle + CloudWatch retention |

### Extensibility

- Add more database engines (MySQL, MariaDB)
- Integrate with ticketing systems (Jira, ServiceNow)
- Custom anomaly rules
- Multi-account, multi-region support

---

## Slide 15: Benefits Summary

### Before vs After

| Before (Manual) | After (Automated) |
|-----------------|-------------------|
| Hours reviewing logs | Automatic — zero effort |
| Weekly/monthly checks | Hourly anomaly detection |
| Manual report creation | AI-generated reports on schedule |
| Reactive (post-breach) | Proactive (real-time alerts) |
| Scattered logs | Centralized, searchable audit trail |
| No immutability guarantee | 7-year immutable retention |
| High operational cost | Serverless, pay-per-use |

### Key Outcomes

✅ **90%+ reduction** in manual audit effort  
✅ **Real-time detection** vs days/weeks delay  
✅ **Compliance-ready** reports for auditors  
✅ **Immutable evidence** chain for regulators  
✅ **<$50/month** for typical environments  

---

## Slide 16: Demo

### Live Demo Flow

1. **Show Dashboard** — Real-time stats and report list
2. **Upload .sqlaudit file** — Watch it get processed
3. **Trigger Anomaly Detection** — Run manually, show findings
4. **Generate Report** — Click "Generate Report Now"
5. **View Report** — AI-generated compliance report with insights
6. **Show Alert** — Sample SNS notification for high-severity anomaly

### Demo URLs

- **Dashboard**: https://d13g0jl9x6z65n.cloudfront.net
- **API**: https://hbahedp2dd.execute-api.us-east-1.amazonaws.com/prod

---

## Slide 17: Next Steps & Roadmap

### Immediate

- [ ] Deploy in target AWS account
- [ ] Configure RDS/Aurora audit logging
- [ ] Subscribe team to anomaly alerts
- [ ] Validate first monthly report

### Future Enhancements

- [ ] Multi-account support (AWS Organizations)
- [ ] Multi-region deployment
- [ ] MySQL/MariaDB engine support
- [ ] Extended Events (.xel) file support
- [ ] Integration with AWS Security Hub
- [ ] Custom compliance frameworks
- [ ] Slack/Teams notifications
- [ ] Role-based dashboard access (Cognito)

---

## Slide 18: Q&A

### Resources

| Resource | Link |
|----------|------|
| Source Code | https://gitlab.aws.dev/bbhavini/database-auditing-automation-solution |
| Dashboard | https://d13g0jl9x6z65n.cloudfront.net |
| Documentation | README.md in repository |
| Quick Start Guide | QUICKSTART.md |

### Contact

**Bhavini Bhatia**  
AWS Support Engineer

---

*Thank you!*
