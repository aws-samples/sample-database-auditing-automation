# Database Audit AI - Web Dashboard

## ✅ UI Successfully Deployed!

Your web dashboard is now live and accessible.

### 🌐 Access URL
**https://d13g0jl9x6z65n.cloudfront.net**

### 📊 Dashboard Features

1. **Dashboard Tab**
   - Real-time statistics
   - SQL Server logs count (today)
   - PostgreSQL logs count (today)
   - Total reports generated
   - Quick action: Generate report now

2. **Reports Tab**
   - List of all compliance reports
   - View report content
   - Download reports
   - Sort by date

### 🔧 API Endpoints

Base URL: `https://hbahedp2dd.execute-api.us-east-1.amazonaws.com/prod`

- `GET /stats` - Get dashboard statistics
- `GET /reports` - List all reports
- `GET /report-content?key=<key>` - Get report content
- `POST /trigger-report` - Manually trigger report generation

### 🚀 How to Use

1. **Open the dashboard** in your browser
2. **View statistics** on the Dashboard tab
3. **Generate a report** by clicking "Generate Report Now"
4. **View reports** in the Reports tab
5. **Click "View"** on any report to see its content

### 📝 Notes

- CloudFront distribution may take 5-10 minutes to fully propagate
- Reports are generated monthly automatically (1st of each month at 2 AM UTC)
- You can manually trigger reports anytime from the dashboard
- All data is fetched in real-time from S3

### 🔐 Security

- Dashboard served via HTTPS (CloudFront)
- S3 bucket is private (not publicly accessible)
- API Gateway with CORS enabled
- IAM roles with least privilege access

### 🛠️ Troubleshooting

**Dashboard not loading?**
- Wait 5-10 minutes for CloudFront to propagate
- Clear browser cache
- Check browser console for errors

**No data showing?**
- Ensure RDS/Aurora audit logs are configured
- Check that logs are flowing to CloudWatch
- Verify Lambda functions are running

**Reports not generating?**
- Check Lambda function logs in CloudWatch
- Verify Bedrock model access
- Ensure sufficient audit data exists

### 📦 Infrastructure

**Frontend:**
- S3: `db-audit-ai-web-ui-<YOUR-ACCOUNT-ID>`
- CloudFront: `d13g0jl9x6z65n.cloudfront.net`

**Backend:**
- API Gateway: `hbahedp2dd.execute-api.us-east-1.amazonaws.com`
- Lambda Functions:
  - `db-audit-ai-api-get-reports`
  - `db-audit-ai-api-get-report-content`
  - `db-audit-ai-api-get-stats`
  - `db-audit-ai-api-trigger-report`

### 🔄 Updating the UI

To update the dashboard:

```bash
cd database-auditing-automation-solution
# Edit web-ui/index.html
./deploy-ui.sh
```

CloudFront cache will be updated automatically.

### 📞 Support

For issues, check:
- CloudWatch Logs: `/aws/lambda/db-audit-ai-api-*`
- CloudFront distribution status
- S3 bucket contents
- API Gateway logs

---

**Enjoy your AI-powered database audit dashboard!** 🎉
