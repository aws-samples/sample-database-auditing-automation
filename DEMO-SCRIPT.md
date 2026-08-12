# Database Audit AI Solution — Demo Script & Speaker Notes
## 30-Minute Session | Bhavini Bhatia

---

## PRE-DEMO CHECKLIST (5 min before)

- [ ] Dashboard open in browser: https://d13g0jl9x6z65n.cloudfront.net
- [ ] AWS Console open (CloudWatch Logs tab): `/aws/rds/cluster/aurora-workshop.../postgresql`
- [ ] AWS Console open (S3 tab): `db-audit-logs-375747409238`
- [ ] Click "Generate Report Now" on dashboard **NOW** (takes ~2 min, will be ready by demo time)
- [ ] Verify Aurora cluster is running (if showing live logs)
- [ ] Have backup screenshots ready in case of connectivity issues

---

## SLIDE 1 — Title (30 seconds)

**Say:**
> "Good [morning/afternoon], everyone. I'm Bhavini Bhatia, AWS Support Engineer. Today I'm going to walk you through a solution I've built that uses AI to automate database auditing and compliance — turning what used to be days of manual work into something that runs on autopilot for under $50 a month."

**Transition:** Click to next slide.

---

## SLIDE 2 — Customer Initiative (2 minutes)

**Say:**
> "Let me start with why we built this. The customer initiative was clear — leverage AI to automate key activities around database audit and compliance."

> "Specifically, they needed seven things:"
> *(Point to each item)*
> 1. "Monthly review reports — currently taking their DBA team 2-3 days to compile"
> 2. "Auditable evidence for compliance — SOX, PCI-DSS requirements"
> 3. "AI-driven monitoring — not just collecting logs, but understanding them"
> 4. "Anomaly detection — catch suspicious logins before they become breaches"
> 5. "Privileged access monitoring — who are the DBAs doing, and when"
> 6. "Change pattern analysis — are schema changes following the CR process"
> 7. "Automated reporting — zero manual effort"

> "Phase 1 scope covers RDS SQL Server and Aurora PostgreSQL — the two engines in their environment. And the good news is, logs are already flowing to S3 and CloudWatch — we just need to make them intelligent."

**Transition:** "Let me show you how we mapped each requirement to a solution component."

---

## SLIDE 3 — Requirements Mapping (1.5 minutes)

**Say:**
> "Here's the mapping. Every requirement on the left has a corresponding solution component on the right."

> *(Walk through 2-3 key mappings)*
> - "Monthly reports → Bedrock Claude generates them automatically on the 1st of each month"
> - "Anomaly detection → Lambda runs hourly, feeds logs to Bedrock for pattern analysis"
> - "Privileged access → Configurable DBA user list, tracked and flagged in every report"

> "No gaps. Every ask is addressed."

**Transition:** "But first, let's understand why manual auditing doesn't scale."

---

## SLIDE 4 — Problem Statement (2 minutes)

**Say:**
> "Here's the reality of manual database auditing today."

> *(Point to each pain point — pick 3 to emphasize)*
> - "Manual log review — your DBAs are spending hours scrolling through text files looking for anomalies. That's not where their skills should be applied."
> - "Delayed detection — by the time someone notices a brute force attempt or unauthorized schema change, it could be days or weeks later. The damage is done."
> - "Compliance burden — every month, someone has to compile a report. It's tedious, error-prone, and nobody wants to do it."

> "The business risk is real. SOX auditors asking for evidence. PCI-DSS requiring immutable audit trails. And your team manually piecing together logs from scattered sources."

> "What if AI could do all of this — continuously, accurately, for less than $50 a month?"

**Transition:** "That's exactly what this solution does."

---

## SLIDE 5 — Solution Overview (1.5 minutes)

**Say:**
> "Here's the solution in one slide. It's fully serverless — no servers to manage, no patching, no scaling concerns."

> *(Point to key capabilities)*
> - "Automated log collection from both RDS SQL Server and Aurora PostgreSQL"
> - "AI-powered analysis using Amazon Bedrock — specifically Claude Sonnet"
> - "Real-time anomaly detection running every hour"
> - "Monthly compliance reports auto-generated on the 1st"
> - "Instant SNS alerts for high-severity findings"
> - "A web dashboard for your team to access everything"
> - "And a 7-year immutable audit trail using S3 Object Lock in COMPLIANCE mode — no one can delete it, not even the account admin"

**Transition:** "Let me show you how the pieces fit together."

---

## SLIDE 6 — Architecture (2 minutes)

**Say:**
> "The architecture is straightforward."

> *(Walk through the flow left to right)*
> 1. "Your databases — RDS SQL Server, Aurora PostgreSQL — their audit logs flow to CloudWatch"
> 2. "A Lambda processor picks them up, normalizes them, and stores them in S3 — partitioned by date"
> 3. "EventBridge triggers two separate Lambda functions:"
>    - "The Anomaly Detector runs every hour — it pulls the last hour's logs, sends them to Bedrock for analysis, and if it finds anything high-severity, fires an SNS alert immediately"
>    - "The Report Generator runs on the 1st of each month — it compiles all the month's data and asks Bedrock to produce a comprehensive compliance report"
> 4. "Reports go to a separate S3 bucket with Object Lock — immutable for 7 years"
> 5. "And the web dashboard sits on top — CloudFront, API Gateway, Lambda — giving your team a single pane of glass"

> "Total AWS services: 9. Total servers: zero. Total monthly cost: $15 to $50."

**Transition:** "Now let me show you this running live."

---

## 🎬 LIVE DEMO (10 minutes)

### Demo Step 1: Dashboard Overview (2 minutes)

**Action:** Switch to browser tab with dashboard open.

**Say:**
> "Here's the live dashboard. This is deployed in a real AWS account right now."

> *(Point to stats)*
> - "SQL Server logs today — these are real audit events"
> - "PostgreSQL logs — flowing from a live Aurora cluster I started earlier today"
> - "Total reports — 6 monthly reports generated so far"

> "Your team opens this URL, they see their audit status at a glance. No SSH, no CLI, no digging through S3."

### Demo Step 2: View a Compliance Report (3 minutes)

**Action:** Click "Reports" tab → Click "View" on the August 2026 report.

**Say:**
> "Let me open the latest monthly report. This was generated entirely by AI."

> *(Scroll through the report, highlighting sections)*
> - "Executive Summary — compliance status at a glance. It says 'Needs Attention' — let's see why."
> - "Key Metrics — 46 events, 12 unique users, 4 failed logins, 5 high-risk events"
> - "Here's what it caught:"
>   - "A brute force login attempt — 4 consecutive failures from external IP 203.45.67.89"
>   - "A DBA — Ankita.kumari — exported the entire employee_salaries table to CSV at 2:45 AM. That's flagged as CRITICAL."
>   - "Schema reconnaissance from an external IP — someone enumerating table structures"
> - "Change Management Compliance — only 40%. 3 out of 5 schema changes had no change request documentation."
> - "And recommendations — block the external IPs, revoke excessive grants, enforce MFA"

> "This entire report — generated in 2 minutes by Bedrock. No human involvement. Imagine your DBA's reaction when they don't have to spend 2 days writing this every month."

### Demo Step 3: Live Logs Flowing (2 minutes)

**Action:** Switch to AWS Console — CloudWatch Logs OR S3 bucket.

**Say:**
> "Behind the scenes, here's what's happening right now."

> *(Show CloudWatch Logs)*
> "These are real-time logs from a live Aurora PostgreSQL cluster. You can see connection events — every login, every query, captured automatically."

> *(Show S3 bucket)*
> "And here in S3 — new files appearing every minute. Each one contains the processed, structured audit data ready for AI analysis."

> "This pipeline runs 24/7. No intervention needed."

### Demo Step 4: Generate Report Now (2 minutes)

**Action:** Click "Generate Report Now" button on dashboard (or show the one triggered pre-demo).

**Say:**
> "I can also trigger a report on demand. Let me click 'Generate Report Now'..."

> *(If pre-triggered report is ready)*
> "Actually, I triggered one before we started — let me show you the freshly generated report."

> *(If triggering live)*
> "This is now calling Bedrock — it'll take about 2 minutes. Behind the scenes, Lambda is pulling all audit data from S3, formatting it as a prompt, and Claude is analyzing it."

> "In a real scenario, your team would use this before an audit — 'Generate me a fresh report for the last 30 days' — instant evidence."

### Demo Step 5: Wrap Demo (1 minute)

**Say:**
> "So to recap what you just saw:"
> - "Live data flowing from a real database"
> - "AI-generated compliance reports with specific findings"
> - "Anomaly detection that caught a brute force attempt, an after-hours data export, and unauthorized schema changes"
> - "All of it running serverless, costing under $50 a month"

**Transition:** "Let me quickly run through a few more capabilities." *(Switch back to slides)*

---

## SLIDE 7 — Supported Databases (30 seconds)

**Say:**
> "Quick note on database support — Phase 1 covers SQL Server with native audit files, and Aurora PostgreSQL with pgAudit. The binary .sqlaudit parser handles those legacy files you might have sitting in S3 already."

---

## SLIDE 8 — Anomaly Detection (1.5 minutes)

**Say:**
> "The anomaly detector runs every hour and looks for five specific patterns."

> *(Highlight 2-3)*
> - "Failed logins — more than 3 in 10 minutes triggers an alert"
> - "After-hours access — if your DBA logs in at 2 AM, you want to know"
> - "Schema changes without a CR — if someone drops a table without an approved change request, that's flagged immediately"

> "Severity scoring is done by Bedrock — it understands context, not just rules. A failed login from an internal IP is different from one originating from Russia."

---

## SLIDE 9 — Monthly Reports (30 seconds)

**Say:**
> "You've already seen the report in the demo. Seven sections. Auto-generated on the 1st at 2 AM UTC. SOX, PCI-DSS, HIPAA ready."

---

## SLIDE 10 — Dashboard (30 seconds)

**Say:**
> "The dashboard you saw — CloudFront for HTTPS, API Gateway backend, all private. Your team bookmarks a URL and they have audit visibility."

---

## SLIDE 11 — Security (1 minute)

**Say:**
> "Security and compliance features are built in, not bolted on."

> "The key one — S3 Object Lock in COMPLIANCE mode with 7-year retention. Once a report is written, nobody can delete or modify it. Not your DBAs, not your admins, not even AWS support. That's your auditor's best friend."

> "Everything encrypted AES-256, no public access, CloudTrail logging every API call."

---

## SLIDE 12 — Infrastructure (30 seconds)

**Say:**
> "Nine AWS services. One CloudFormation template. Deploy in 5 minutes."

> *(Read the deploy command)*
> "Literally this single command deploys everything."

---

## SLIDE 13 — Cost (1 minute)

**Say:**
> "$15 to $50 a month for a typical environment with 2-3 database instances."

> "Compare that to the alternative — your DBA spending 2-3 days compiling a monthly report. At even $50/hour, that's $1,200 a month in manual effort. This solution pays for itself in the first hour."

> "And it scales down when there's less activity — Lambda charges by invocation, Bedrock by token. Quiet month? Lower bill."

---

## SLIDE 14 — Deployment (30 seconds)

**Say:**
> "Five steps to production. Deploy the stack, enable Bedrock, configure your database audit settings, enable CloudWatch export, subscribe to alerts. That's it."

---

## SLIDE 15 — SQL Audit Processing (30 seconds)

**Say:**
> "For SQL Server — if you already have .sqlaudit files, just upload them. The Lambda parser extracts events from the binary format, converts to JSON, and feeds them into the same AI pipeline."

---

## SLIDE 16 — Use Cases (1 minute)

**Say:**
> "Seven use cases, but let me highlight three."

> 1. "Monthly compliance — zero effort. Report appears on the 1st."
> 2. "Incident investigation — searchable audit trail in S3. When the auditor asks 'who accessed the customers table on July 15th?' — you have the answer in seconds."
> 3. "Cost-effective — serverless means you're not paying for idle compute. Under $50/month replaces $1,200+ in manual effort."

---

## SLIDE 17 — Customization (30 seconds)

**Say:**
> "Everything is configurable. Add your DBA usernames, change the report schedule, tune sensitivity. No code changes needed — just environment variables and cron expressions."

> "And the roadmap — MySQL support, Security Hub integration, Slack notifications. All planned."

---

## SLIDE 18 — Benefits (1 minute)

**Say:**
> "Before and after, side by side."

> *(Point to key rows)*
> - "Hours reviewing logs → automatic, zero effort"
> - "Reactive post-breach → proactive real-time alerts"
> - "Scattered logs → centralized, searchable, immutable"

> "90% reduction in manual audit effort. Real-time detection instead of days. Compliance-ready evidence at the click of a button. All for less than $50 a month."

---

## SLIDE 19 — Demo Recap (skip — already done live)

**Say:**
> "You've already seen the live demo. The dashboard URL and API are on this slide for your reference."

---

## SLIDE 20 — Next Steps & Q&A (3 minutes)

**Say:**
> "Next steps — if you'd like to move forward:"

> 1. "We deploy this in your AWS account — single CloudFormation command"
> 2. "Configure your RDS and Aurora instances for audit logging"
> 3. "Subscribe your security team to the SNS alerts"
> 4. "Validate the first monthly report — review it together"

> "The source code is on GitLab, the dashboard is live, and I'm happy to walk through deployment with your team."

> "What questions do you have?"

---

## Q&A CHEAT SHEET

| Likely Question | Answer |
|----------------|--------|
| "Can we customize the report format?" | Yes — modify the Bedrock prompt in the Lambda function. You can add company-specific sections or remove irrelevant ones. |
| "What about MySQL?" | On the roadmap. The architecture is engine-agnostic — we just need a log parser for MySQL's general/slow query logs. |
| "How accurate is the AI analysis?" | Claude Sonnet is highly capable at pattern recognition. However, it's a tool — not a replacement for human judgment. High-severity findings should always be reviewed by your security team. |
| "What if Bedrock is down?" | Logs continue flowing to S3 regardless. The report/anomaly Lambda retries on next scheduled run. No data is lost. |
| "Can multiple accounts feed into this?" | Not in Phase 1, but it's architecturally straightforward — cross-account S3 access or CloudWatch cross-account log forwarding. |
| "What about data residency?" | Everything stays in your account, in your chosen region. Bedrock processes in the same region — no data leaves. |
| "How long does report generation take?" | Typically 1-2 minutes for a month of data. Depends on log volume. |
| "Can we block the suspicious IPs automatically?" | Not in Phase 1, but you could extend the anomaly Lambda to update WAF rules or Security Group rules automatically. |

---

## CLOSING (if no more questions)

**Say:**
> "Thank you for your time today. I'll share the presentation and the GitLab link with you. If you'd like to do a hands-on deployment session, I'm happy to schedule that."

> "Enjoy the rest of your day!"

---

## TIMING SUMMARY

| Section | Duration | Cumulative |
|---------|----------|-----------|
| Slides 1–6 (Intro → Architecture) | 10 min | 10 min |
| Live Demo | 10 min | 20 min |
| Slides 7–18 (Features, quick flip) | 7 min | 27 min |
| Q&A | 3 min | 30 min |

**If running long:** Skip slides 7, 10, 14, 15 (least impactful).  
**If running short:** Expand the demo — show CloudWatch, show S3 lifecycle rules, trigger anomaly detection.
