# Presentation Slide Notes — Quick Reference Card
## Database Audit AI Solution | 30-min Session

Print this as your speaker reference during the presentation.

---

### Slide 1 — Title
- Introduce yourself
- "AI to automate database auditing — days of work → autopilot, under $50/month"

### Slide 2 — Initiative
- 7 purposes → highlight #1 (monthly reports), #4 (anomalies), #5 (DBA monitoring)
- "Logs already in S3 & CloudWatch — we make them intelligent"

### Slide 3 — Requirements Mapping
- "Every requirement mapped to a solution component. No gaps."
- Walk through 2-3 mappings quickly

### Slide 4 — Problem
- Emphasize: "Manual = days. Delayed = breach happened already. Compliance = tedious."
- "What if AI could do this for $50/month?"

### Slide 5 — Solution
- Hit the 7 capabilities quickly
- Emphasize: "7-year immutable retention — no one can delete, not even account admin"

### Slide 6 — Architecture
- Walk left to right: DB → CW → Lambda → S3 → Bedrock → Reports/Alerts
- "9 services. Zero servers. $15-50/month."
- **TRANSITION TO DEMO**

### 🎬 DEMO (~10 min)
1. **Dashboard** (2 min) — Stats, real-time counts
2. **View August Report** (3 min) — Executive summary, brute force, salary export at 2AM, 40% change compliance
3. **Live Logs** (2 min) — CloudWatch or S3, files every minute
4. **Generate Report** (2 min) — Click button or show pre-generated
5. **Wrap** (1 min) — "Live data, AI reports, under $50"

### Slide 7 — Databases
- "SQL Server native audit + PostgreSQL pgAudit. Binary parser included."

### Slide 8 — Anomaly Detection
- 5 patterns. Emphasize: failed logins, after-hours DBA, schema without CR
- "Bedrock understands context — internal IP vs external IP"

### Slide 9 — Reports
- "7 sections. Auto on 1st of month. You saw it live."

### Slide 10 — Dashboard
- "Bookmark a URL → audit visibility"

### Slide 11 — Security
- **KEY:** "S3 Object Lock COMPLIANCE mode. 7 years. Nobody deletes. Auditor's best friend."

### Slide 12 — Infrastructure
- "One CloudFormation command. 5 minutes to production."

### Slide 13 — Cost
- **KEY:** "$15-50/month vs $1,200/month in DBA time (2-3 days × $50/hr)"
- "Scales down when quiet"

### Slide 14 — Deployment
- "5 steps. That's it."

### Slide 15 — SQL Audit
- "Already have .sqlaudit files? Just upload. Parser handles the binary."

### Slide 16 — Use Cases
- Pick 3: Monthly compliance (zero effort), Incident investigation (seconds), Cost ($50 vs $1200)

### Slide 17 — Customization
- "Environment variables. No code changes. MySQL and Security Hub on roadmap."

### Slide 18 — Benefits
- "90% reduction. Real-time vs weeks. <$50/month."

### Slide 19 — Demo (skip, already done)

### Slide 20 — Next Steps & Q&A
- "Deploy → Configure → Subscribe → Validate first report"
- "Questions?"

---

## KEY NUMBERS TO REMEMBER
- **$15-50/month** — solution cost
- **$1,200/month** — manual DBA audit effort replaced
- **90%** — reduction in manual effort  
- **2 minutes** — report generation time
- **7 years** — immutable retention
- **1 hour** — anomaly detection frequency
- **9** — AWS services used
- **0** — servers to manage
- **5 minutes** — deployment time

---

## EMERGENCY FALLBACKS

**Dashboard won't load?**
→ Show screenshots from presentation, explain "normally this is live"

**Report generation fails during demo?**
→ Show the pre-uploaded August report, say "I generated this earlier today"

**No live logs visible?**
→ Show S3 bucket with the log files, explain the pipeline

**Bedrock timeout?**
→ "Bedrock is processing — typically takes 2 minutes. Let me show you a previously generated report while we wait."
