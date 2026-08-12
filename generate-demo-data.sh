#!/bin/bash
# generate-demo-data.sh
# Generates realistic synthetic audit logs for demo purposes

BUCKET="db-audit-logs-375747409238"
REGION="us-east-1"
TODAY=$(date -u +%Y-%m-%d)
YEAR_MONTH=$(date -u +%Y/%m)
DAY=$(date -u +%Y/%m/%d)

echo "=== Generating Demo Audit Data ==="
echo "Bucket: $BUCKET"
echo "Date: $TODAY"
echo ""

# --- 1. SQL Server Audit Logs ---
echo "1. Uploading SQL Server audit logs..."

cat > /tmp/sqlserver-demo-logs.json << 'EOF'
[
  {"timestamp": "2026-08-04T04:15:23Z", "event_type": "LOGIN_SUCCESS", "server_principal_name": "app_service_account", "database_name": "production_db", "statement": "LOGIN", "client_ip": "10.0.1.45", "succeeded": true},
  {"timestamp": "2026-08-04T04:15:45Z", "event_type": "LOGIN_FAILED", "server_principal_name": "unknown_user", "database_name": "master", "statement": "LOGIN", "client_ip": "203.45.67.89", "succeeded": false},
  {"timestamp": "2026-08-04T04:16:01Z", "event_type": "LOGIN_FAILED", "server_principal_name": "unknown_user", "database_name": "master", "statement": "LOGIN", "client_ip": "203.45.67.89", "succeeded": false},
  {"timestamp": "2026-08-04T04:16:15Z", "event_type": "LOGIN_FAILED", "server_principal_name": "unknown_user", "database_name": "master", "statement": "LOGIN", "client_ip": "203.45.67.89", "succeeded": false},
  {"timestamp": "2026-08-04T04:16:30Z", "event_type": "LOGIN_FAILED", "server_principal_name": "unknown_user", "database_name": "master", "statement": "LOGIN", "client_ip": "203.45.67.89", "succeeded": false},
  {"timestamp": "2026-08-04T04:20:00Z", "event_type": "LOGIN_SUCCESS", "server_principal_name": "Manishekhar_jha", "database_name": "production_db", "statement": "LOGIN", "client_ip": "10.0.2.100", "succeeded": true},
  {"timestamp": "2026-08-04T04:21:15Z", "event_type": "SCHEMA_CHANGE", "server_principal_name": "Manishekhar_jha", "database_name": "production_db", "statement": "ALTER TABLE customers ADD COLUMN loyalty_tier VARCHAR(50)", "client_ip": "10.0.2.100", "succeeded": true},
  {"timestamp": "2026-08-04T04:22:00Z", "event_type": "GRANT", "server_principal_name": "Manishekhar_jha", "database_name": "production_db", "statement": "GRANT SELECT, INSERT ON customers TO reporting_user", "client_ip": "10.0.2.100", "succeeded": true},
  {"timestamp": "2026-08-04T04:30:00Z", "event_type": "SELECT", "server_principal_name": "app_service_account", "database_name": "production_db", "statement": "SELECT * FROM customer_pii WHERE ssn IS NOT NULL", "client_ip": "10.0.1.45", "succeeded": true},
  {"timestamp": "2026-08-04T04:35:12Z", "event_type": "DELETE", "server_principal_name": "Ankita.kumari", "database_name": "production_db", "statement": "DELETE FROM audit_trail WHERE created_date < '2025-01-01'", "client_ip": "10.0.2.105", "succeeded": true},
  {"timestamp": "2026-08-04T05:00:00Z", "event_type": "LOGIN_SUCCESS", "server_principal_name": "batch_processor", "database_name": "analytics_db", "statement": "LOGIN", "client_ip": "10.0.3.20", "succeeded": true},
  {"timestamp": "2026-08-04T05:01:00Z", "event_type": "BULK_INSERT", "server_principal_name": "batch_processor", "database_name": "analytics_db", "statement": "BULK INSERT staging_table FROM '/data/import_20260804.csv'", "client_ip": "10.0.3.20", "succeeded": true},
  {"timestamp": "2026-08-04T05:15:00Z", "event_type": "LOGIN_SUCCESS", "server_principal_name": "readonly_user", "database_name": "production_db", "statement": "LOGIN", "client_ip": "10.0.4.50", "succeeded": true},
  {"timestamp": "2026-08-04T05:15:30Z", "event_type": "SELECT", "server_principal_name": "readonly_user", "database_name": "production_db", "statement": "SELECT COUNT(*) FROM transactions WHERE amount > 10000", "client_ip": "10.0.4.50", "succeeded": true},
  {"timestamp": "2026-08-04T05:20:00Z", "event_type": "LOGIN_SUCCESS", "server_principal_name": "Manishekhar_jha", "database_name": "production_db", "statement": "LOGIN", "client_ip": "10.0.2.100", "succeeded": true},
  {"timestamp": "2026-08-04T05:20:30Z", "event_type": "SCHEMA_CHANGE", "server_principal_name": "Manishekhar_jha", "database_name": "production_db", "statement": "CREATE INDEX idx_customers_email ON customers(email)", "client_ip": "10.0.2.100", "succeeded": true},
  {"timestamp": "2026-08-04T05:25:00Z", "event_type": "DDL", "server_principal_name": "Manishekhar_jha", "database_name": "production_db", "statement": "DROP TABLE temp_migration_2025", "client_ip": "10.0.2.100", "succeeded": true},
  {"timestamp": "2026-08-04T06:00:00Z", "event_type": "LOGIN_SUCCESS", "server_principal_name": "app_service_account", "database_name": "production_db", "statement": "LOGIN", "client_ip": "10.0.1.46", "succeeded": true},
  {"timestamp": "2026-08-04T06:01:00Z", "event_type": "UPDATE", "server_principal_name": "app_service_account", "database_name": "production_db", "statement": "UPDATE orders SET status='SHIPPED' WHERE order_id IN (SELECT order_id FROM pending_shipments)", "client_ip": "10.0.1.46", "succeeded": true},
  {"timestamp": "2026-08-04T06:30:00Z", "event_type": "LOGIN_SUCCESS", "server_principal_name": "etl_service", "database_name": "datawarehouse", "statement": "LOGIN", "client_ip": "10.0.5.10", "succeeded": true},
  {"timestamp": "2026-08-04T06:31:00Z", "event_type": "INSERT", "server_principal_name": "etl_service", "database_name": "datawarehouse", "statement": "INSERT INTO fact_sales SELECT * FROM staging_sales WHERE load_date = CURRENT_DATE", "client_ip": "10.0.5.10", "succeeded": true},
  {"timestamp": "2026-08-04T02:45:00Z", "event_type": "LOGIN_SUCCESS", "server_principal_name": "Ankita.kumari", "database_name": "production_db", "statement": "LOGIN", "client_ip": "192.168.1.55", "succeeded": true},
  {"timestamp": "2026-08-04T02:45:30Z", "event_type": "SELECT", "server_principal_name": "Ankita.kumari", "database_name": "production_db", "statement": "SELECT * FROM employee_salaries", "client_ip": "192.168.1.55", "succeeded": true},
  {"timestamp": "2026-08-04T02:46:00Z", "event_type": "EXPORT", "server_principal_name": "Ankita.kumari", "database_name": "production_db", "statement": "SELECT * INTO OUTFILE '/tmp/salary_export.csv' FROM employee_salaries", "client_ip": "192.168.1.55", "succeeded": true},
  {"timestamp": "2026-08-04T07:00:00Z", "event_type": "LOGIN_SUCCESS", "server_principal_name": "monitoring_agent", "database_name": "master", "statement": "LOGIN", "client_ip": "10.0.1.1", "succeeded": true},
  {"timestamp": "2026-08-04T07:00:30Z", "event_type": "SELECT", "server_principal_name": "monitoring_agent", "database_name": "master", "statement": "SELECT * FROM sys.dm_exec_sessions", "client_ip": "10.0.1.1", "succeeded": true}
]
EOF

aws s3 cp /tmp/sqlserver-demo-logs.json \
    "s3://$BUCKET/raw/cloudwatch/$TODAY/sqlserver-audit-batch1.json" \
    --region $REGION

echo "   ✓ SQL Server logs uploaded (26 events)"

# --- 2. PostgreSQL Audit Logs ---
echo "2. Uploading PostgreSQL audit logs..."

cat > /tmp/postgresql-demo-logs.json << 'EOF'
[
  {"timestamp": "2026-08-04T04:00:00Z", "user": "postgres", "database": "appdb", "command_tag": "SELECT", "statement": "SELECT version()", "client_addr": "10.0.1.45", "audit_type": "SESSION"},
  {"timestamp": "2026-08-04T04:05:00Z", "user": "app_user", "database": "appdb", "command_tag": "INSERT", "statement": "INSERT INTO user_sessions (user_id, session_token, created_at) VALUES ($1, $2, NOW())", "client_addr": "10.0.1.45", "audit_type": "SESSION"},
  {"timestamp": "2026-08-04T04:10:00Z", "user": "dba_admin", "database": "appdb", "command_tag": "CREATE TABLE", "statement": "CREATE TABLE audit_archive_2026 (id SERIAL PRIMARY KEY, event_data JSONB, created_at TIMESTAMP DEFAULT NOW())", "client_addr": "10.0.2.100", "audit_type": "DDL"},
  {"timestamp": "2026-08-04T04:12:00Z", "user": "dba_admin", "database": "appdb", "command_tag": "ALTER TABLE", "statement": "ALTER TABLE users ADD COLUMN mfa_enabled BOOLEAN DEFAULT false", "client_addr": "10.0.2.100", "audit_type": "DDL"},
  {"timestamp": "2026-08-04T04:15:00Z", "user": "analytics_ro", "database": "analytics", "command_tag": "SELECT", "statement": "SELECT customer_id, SUM(amount) FROM transactions GROUP BY customer_id HAVING SUM(amount) > 50000", "client_addr": "10.0.3.30", "audit_type": "READ"},
  {"timestamp": "2026-08-04T04:20:00Z", "user": "app_user", "database": "appdb", "command_tag": "UPDATE", "statement": "UPDATE users SET last_login = NOW() WHERE user_id = $1", "client_addr": "10.0.1.46", "audit_type": "WRITE"},
  {"timestamp": "2026-08-04T04:25:00Z", "user": "migration_bot", "database": "appdb", "command_tag": "ALTER TABLE", "statement": "ALTER TABLE orders ADD COLUMN delivery_partner VARCHAR(100)", "client_addr": "10.0.5.5", "audit_type": "DDL"},
  {"timestamp": "2026-08-04T04:30:00Z", "user": "app_user", "database": "appdb", "command_tag": "DELETE", "statement": "DELETE FROM user_sessions WHERE expires_at < NOW() - INTERVAL '30 days'", "client_addr": "10.0.1.45", "audit_type": "WRITE"},
  {"timestamp": "2026-08-04T04:35:00Z", "user": "backup_user", "database": "appdb", "command_tag": "SELECT", "statement": "COPY (SELECT * FROM customers) TO STDOUT WITH CSV HEADER", "client_addr": "10.0.6.1", "audit_type": "READ"},
  {"timestamp": "2026-08-04T05:00:00Z", "user": "unknown_ext", "database": "appdb", "command_tag": "SELECT", "statement": "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'", "client_addr": "45.33.22.11", "audit_type": "SESSION"},
  {"timestamp": "2026-08-04T05:01:00Z", "user": "unknown_ext", "database": "appdb", "command_tag": "SELECT", "statement": "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'users'", "client_addr": "45.33.22.11", "audit_type": "SESSION"},
  {"timestamp": "2026-08-04T05:02:00Z", "user": "unknown_ext", "database": "appdb", "command_tag": "SELECT", "statement": "SELECT * FROM users LIMIT 100", "client_addr": "45.33.22.11", "audit_type": "SESSION"},
  {"timestamp": "2026-08-04T05:30:00Z", "user": "dba_admin", "database": "appdb", "command_tag": "GRANT", "statement": "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO new_developer", "client_addr": "10.0.2.100", "audit_type": "ROLE"},
  {"timestamp": "2026-08-04T05:45:00Z", "user": "app_user", "database": "appdb", "command_tag": "INSERT", "statement": "INSERT INTO payment_transactions (user_id, amount, currency, status) VALUES ($1, $2, $3, 'PENDING')", "client_addr": "10.0.1.47", "audit_type": "WRITE"},
  {"timestamp": "2026-08-04T06:00:00Z", "user": "reporting_svc", "database": "analytics", "command_tag": "SELECT", "statement": "SELECT DATE_TRUNC('day', created_at) as day, COUNT(*) as signups FROM users GROUP BY 1 ORDER BY 1 DESC LIMIT 30", "client_addr": "10.0.4.20", "audit_type": "READ"},
  {"timestamp": "2026-08-04T03:00:00Z", "user": "dba_admin", "database": "appdb", "command_tag": "DROP TABLE", "statement": "DROP TABLE IF EXISTS old_migration_data", "client_addr": "10.0.2.100", "audit_type": "DDL"},
  {"timestamp": "2026-08-04T03:01:00Z", "user": "dba_admin", "database": "appdb", "command_tag": "VACUUM", "statement": "VACUUM ANALYZE users", "client_addr": "10.0.2.100", "audit_type": "MAINTENANCE"},
  {"timestamp": "2026-08-04T06:30:00Z", "user": "app_user", "database": "appdb", "command_tag": "UPDATE", "statement": "UPDATE orders SET status = 'DELIVERED', delivered_at = NOW() WHERE tracking_id = $1", "client_addr": "10.0.1.45", "audit_type": "WRITE"},
  {"timestamp": "2026-08-04T07:00:00Z", "user": "cron_cleanup", "database": "appdb", "command_tag": "DELETE", "statement": "DELETE FROM temp_otp_codes WHERE created_at < NOW() - INTERVAL '1 hour'", "client_addr": "10.0.1.1", "audit_type": "WRITE"},
  {"timestamp": "2026-08-04T07:15:00Z", "user": "app_user", "database": "appdb", "command_tag": "SELECT", "statement": "SELECT id, email, phone FROM users WHERE account_status = 'SUSPENDED'", "client_addr": "10.0.1.48", "audit_type": "READ"}
]
EOF

aws s3 cp /tmp/postgresql-demo-logs.json \
    "s3://$BUCKET/raw/cloudwatch/$TODAY/postgresql-audit-batch1.json" \
    --region $REGION

echo "   ✓ PostgreSQL logs uploaded (20 events)"

# --- 3. Generate a fresh anomaly analysis report for today ---
echo "3. Uploading anomaly analysis report..."

cat > /tmp/anomaly-report-today.txt << 'EOF'
# Anomaly Detection Report
**Date:** 2026-08-04
**Scan Window:** 00:00 - 09:30 UTC
**Status:** ⚠️ ANOMALIES DETECTED

## Summary
- Total Events Analyzed: 46
- Anomalies Detected: 5
- High Severity: 2
- Medium Severity: 2
- Low Severity: 1

## High Severity Findings

### 1. Brute Force Login Attempt
- **Time:** 04:15 - 04:16 UTC
- **Source IP:** 203.45.67.89 (External)
- **Target:** master database
- **Details:** 4 consecutive failed login attempts for 'unknown_user' within 60 seconds
- **Action Required:** Block source IP, investigate if any successful access followed

### 2. Sensitive Data Export After Hours
- **Time:** 02:45 UTC (Outside business hours)
- **User:** Ankita.kumari (Privileged User)
- **Details:** Exported entire employee_salaries table to CSV file at 2:45 AM
- **Risk:** Potential data exfiltration of sensitive PII/compensation data
- **Action Required:** Verify authorization, check if data left the network

## Medium Severity Findings

### 3. Suspicious Schema Reconnaissance
- **Time:** 05:00 - 05:02 UTC
- **User:** unknown_ext
- **Source IP:** 45.33.22.11 (External)
- **Details:** Sequential enumeration of table schemas, columns, then data extraction from users table
- **Pattern:** Classic information gathering / SQL injection reconnaissance
- **Action Required:** Review access grants, check application logs for injection attempts

### 4. Broad Privilege Grant
- **Time:** 05:30 UTC
- **User:** dba_admin
- **Details:** Granted ALL PRIVILEGES on all public tables to 'new_developer'
- **Risk:** Violates least-privilege principle, no associated change request found
- **Action Required:** Verify with change management, consider revoking and granting specific permissions

## Low Severity Findings

### 5. After-Hours DBA Activity
- **Time:** 03:00 UTC
- **User:** dba_admin
- **Details:** DROP TABLE and VACUUM operations performed at 3 AM
- **Note:** May be scheduled maintenance, but no maintenance window documented for this time

## Recommendations
1. Implement IP-based rate limiting for login attempts
2. Enable MFA for all privileged database users
3. Set up after-hours access alerts for sensitive tables
4. Review and tighten privilege grants - enforce least privilege
5. Document maintenance windows and correlate with DBA activity
EOF

aws s3 cp /tmp/anomaly-report-today.txt \
    "s3://$BUCKET/analysis/2026/08/04/anomaly-report.txt" \
    --region $REGION

echo "   ✓ Anomaly report uploaded"

# --- 4. Upload processed/structured data for the dashboard stats API ---
echo "4. Uploading processed audit data..."

# SQL Server processed
aws s3 cp /tmp/sqlserver-demo-logs.json \
    "s3://$BUCKET/processed/sqlserver/$TODAY-batch1.json" \
    --region $REGION

# PostgreSQL processed
aws s3 cp /tmp/postgresql-demo-logs.json \
    "s3://$BUCKET/processed/postgresql/$TODAY-batch1.json" \
    --region $REGION

echo "   ✓ Processed data uploaded"

# --- 5. Generate a monthly report for August with actual content ---
echo "5. Uploading August monthly report..."

cat > /tmp/aug-monthly-report.md << 'EOF'
# Database Audit Report
**Period: August 2026 (Week 1)**  
**Generated: 2026-08-04T09:30:00Z**  
**Classification: Confidential**

## 1. Executive Summary

### Overall Compliance Status: ⚠️ NEEDS ATTENTION
The audit for the first week of August 2026 reveals several security concerns requiring immediate attention, particularly around after-hours privileged access and external reconnaissance attempts.

### Key Metrics
| Metric | Value | Trend |
|--------|-------|-------|
| Total Events | 46 | ↑ 15% from last week |
| Unique Users | 12 | Normal |
| Failed Logins | 4 | ↑ Spike detected |
| High-Risk Events | 5 | ↑ Requires attention |
| Privileged Actions | 8 | Normal range |
| Schema Changes | 5 | ↑ Above baseline |

### Critical Issues
1. External brute force attempt from 203.45.67.89
2. Sensitive data export by privileged user after hours
3. Schema reconnaissance from external IP 45.33.22.11
4. Overly broad privilege grants without change requests

## 2. Login Activity Analysis

### Successful Logins: 18
| User | Count | Time Pattern | Risk |
|------|-------|-------------|------|
| app_service_account | 5 | Business hours | Low |
| Manishekhar_jha | 3 | Business hours | Monitor |
| Ankita.kumari | 2 | After hours (2:45 AM) | ⚠️ HIGH |
| dba_admin | 3 | Mixed (3 AM + business) | ⚠️ MEDIUM |
| batch_processor | 2 | Scheduled (5 AM) | Low |
| monitoring_agent | 3 | 24/7 | Expected |

### Failed Logins: 4
| User | Source IP | Count | Assessment |
|------|-----------|-------|-----------|
| unknown_user | 203.45.67.89 | 4 | 🔴 Brute force attempt |

### Geographic Analysis
- Internal (10.x.x.x): 38 events — Normal
- External (203.45.67.89): 4 events — ⚠️ Suspicious
- External (45.33.22.11): 3 events — ⚠️ Reconnaissance
- External (192.168.1.55): 2 events — Needs verification

## 3. Privileged Access Monitoring

### User: Manishekhar_jha (DBA)
| Time | Action | Database | Risk |
|------|--------|----------|------|
| 04:20 | LOGIN | production_db | Low |
| 04:21 | ALTER TABLE (add column) | production_db | Medium |
| 04:22 | GRANT permissions | production_db | Medium |
| 05:20 | LOGIN | production_db | Low |
| 05:20 | CREATE INDEX | production_db | Low |
| 05:25 | DROP TABLE temp_migration_2025 | production_db | Medium |

**Assessment:** Activity appears legitimate (schema evolution), but DROP TABLE and GRANT actions lack associated change request documentation.

### User: Ankita.kumari (DBA)
| Time | Action | Database | Risk |
|------|--------|----------|------|
| 02:45 | LOGIN (after hours) | production_db | ⚠️ HIGH |
| 02:45 | SELECT employee_salaries | production_db | ⚠️ HIGH |
| 02:46 | EXPORT to CSV | production_db | 🔴 CRITICAL |
| 04:35 | DELETE audit_trail records | production_db | ⚠️ HIGH |

**Assessment:** CRITICAL — Sensitive salary data exported after hours followed by audit trail deletion. Requires immediate investigation.

## 4. Change Pattern Analysis

### Schema Changes This Period: 5
| Change | User | CR Reference | Compliance |
|--------|------|-------------|-----------|
| ADD COLUMN customers.loyalty_tier | Manishekhar_jha | None found | ❌ Non-compliant |
| ADD COLUMN users.mfa_enabled | dba_admin | CR-45678 | ✅ Compliant |
| ADD COLUMN orders.delivery_partner | migration_bot | CR-45679 | ✅ Compliant |
| CREATE INDEX idx_customers_email | Manishekhar_jha | None found | ❌ Non-compliant |
| DROP TABLE temp_migration_2025 | Manishekhar_jha | None found | ❌ Non-compliant |

**Change Management Compliance: 40%** (2 of 5 changes have CR documentation)  
**Target: 100%**

## 5. Compliance Findings

| Control | Status | Gap |
|---------|--------|-----|
| Change Management | ❌ FAILED | 60% of changes lack CR documentation |
| Access Control | ⚠️ AT RISK | Overly broad GRANT ALL detected |
| Privileged Access | ❌ FAILED | After-hours access without justification |
| Data Protection | ❌ FAILED | Sensitive data exported without authorization |
| Audit Integrity | ⚠️ AT RISK | Audit trail deletion detected |
| Authentication | ⚠️ AT RISK | Brute force attempt, no auto-lockout |

### Regulatory Impact
- **SOX:** Non-compliant — Insufficient segregation of duties, incomplete change documentation
- **PCI-DSS:** At risk — Privileged access without MFA, sensitive data export
- **HIPAA:** N/A for this period

## 6. Recommendations

### Immediate (Within 24 hours)
1. 🔴 Investigate Ankita.kumari's after-hours salary data export
2. 🔴 Block IP 203.45.67.89 at WAF/Security Group level
3. 🔴 Review and revoke GRANT ALL to new_developer
4. ⚠️ Block IP 45.33.22.11 pending investigation

### Short-term (Within 1 week)
5. Implement login attempt rate limiting (max 3 failures → 15-min lockout)
6. Enforce MFA for all DBA accounts
7. Create after-hours access alerting for sensitive tables
8. Mandate CR documentation for all schema changes

### Long-term (Within 1 month)
9. Implement Just-In-Time privileged access (time-boxed elevation)
10. Deploy database activity monitoring (DAM) solution
11. Establish quarterly access review process
12. Implement data masking for sensitive columns in non-prod environments

---
*Report generated by Database Audit AI Solution*  
*Next scheduled report: 2026-09-01*
EOF

aws s3 cp /tmp/aug-monthly-report.md \
    "s3://$BUCKET/reports/2026-08/monthly-audit-report.md" \
    --region $REGION

echo "   ✓ August monthly report uploaded"

echo ""
echo "=== Demo Data Upload Complete ==="
echo ""
echo "Data uploaded:"
echo "  • 26 SQL Server audit events"
echo "  • 20 PostgreSQL audit events"  
echo "  • 1 anomaly detection report (5 findings)"
echo "  • 1 monthly compliance report (August 2026)"
echo ""
echo "Dashboard: https://d13g0jl9x6z65n.cloudfront.net"
echo ""
echo "Anomalies included:"
echo "  🔴 Brute force login attempt (external IP)"
echo "  🔴 Sensitive data export after hours (DBA user)"
echo "  ⚠️  Schema reconnaissance from external IP"
echo "  ⚠️  Broad privilege grant without CR"
echo "  ℹ️  After-hours DBA maintenance activity"
