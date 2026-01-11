# Complete Access Guide - All Systems Operational ✅

**Last Updated**: January 11, 2026
**Status**: All services running and configured

---

## 🌐 Application URLs

### Frontend UI
**URL**: http://app-capstone-ui-dev-ari999.azurewebsites.net/

**Features**:
- Upload images to Backend A or Backend B
- View upload history from database
- Real-time loading states
- Error handling

**Health Check**: http://app-capstone-ui-dev-ari999.azurewebsites.net/health

---

### APIM Gateway (API Management)

**Base URL**: https://apim-capstone-dev-ari999.azure-api.net

**Endpoints**:
- **Backend A**: https://apim-capstone-dev-ari999.azure-api.net/api/A:/
- **Backend B**: https://apim-capstone-dev-ari999.azure-api.net/api/B:/

**Test Commands**:
```bash
# Upload to Backend A
curl -X POST https://apim-capstone-dev-ari999.azure-api.net/api/A:/ \
  -F "image=@yourfile.jpg"

# Upload to Backend B
curl -X POST https://apim-capstone-dev-ari999.azure-api.net/api/B:/ \
  -F "image=@yourfile.jpg"
```

**Features**:
- CORS enabled for frontend
- Routes requests to correct backend
- Returns JSON with upload history and base64 image

---

### Backend Services (Direct Access)

**Backend A**:
- **Service URL**: http://132.196.250.187:8080
- **API Endpoint**: http://132.196.250.187:8080/api/a
- **Metrics**: http://132.196.250.187:8080/metrics
- **Health**: http://132.196.250.187:8080/health

**Backend B**:
- **Service URL**: http://68.220.237.26:8080
- **API Endpoint**: http://68.220.237.26:8080/api/b
- **Metrics**: http://68.220.237.26:8080/metrics
- **Health**: http://68.220.237.26:8080/health

---

## 📊 Monitoring & Observability

### Prometheus - Metrics Collection

**URL**: http://4.150.114.54/

**What You'll See**:
- Backend A metrics (`backend-a` job)
- Backend B metrics (`backend-b` job)
- Kubernetes cluster metrics
- Node metrics
- Container metrics

**Useful Queries**:
```promql
# Check all scrape targets
up

# Backend A CPU usage
rate(process_cpu_seconds_total{job="backend-a"}[5m])

# Backend A memory
process_resident_memory_bytes{job="backend-a"}

# HTTP request rate (if instrumented)
rate(http_requests_total[5m])

# All backend jobs
up{job=~"backend-.*"}
```

**How to Use**:
1. Go to http://4.150.114.54/
2. Click **Graph** tab
3. Enter a PromQL query
4. Click **Execute**
5. View results as graph or table

**Check Targets**:
- Go to **Status** → **Targets**
- You should see `backend-a` and `backend-b` jobs showing as "UP"

---

### Grafana - Dashboards & Visualization

**URL**: http://135.222.184.27/

**Login Credentials**:
- **Username**: `admin`
- **Password**: `t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU`

**Data Sources Configured**:
- ✅ **Prometheus** (default) - Metrics
- ✅ **Loki** - Logs

**Quick Start**:

#### 1. View Metrics
1. Login at http://135.222.184.27/
2. Click **Explore** (compass icon) in left sidebar
3. Select **Prometheus** data source
4. Enter query: `up{job="backend-a"}`
5. Click **Run query**

#### 2. View Logs
1. Click **Explore**
2. Select **Loki** data source
3. Enter LogQL query:
   ```logql
   {namespace="microservices-app"}
   {namespace="microservices-app", app="backend-a"}
   {namespace="microservices-app"} |= "error"
   ```

#### 3. Create Dashboard
1. Click **+** → **Dashboard**
2. Click **Add visualization**
3. Select **Prometheus**
4. Enter query (e.g., `up{job="backend-a"}`)
5. Customize panel
6. Click **Apply**

#### 4. Import Pre-built Dashboards
1. Click **+** → **Import**
2. Enter dashboard ID:
   - **7249** - Kubernetes Cluster Monitoring
   - **1860** - Node Exporter Full
   - **315** - Kubernetes Cluster (Prometheus)
3. Select **Prometheus** as data source
4. Click **Import**

**Recommended Dashboards**:
- Kubernetes Cluster Monitoring (ID: 7249)
- Node Exporter Full (ID: 1860)
- Kubernetes Pods (ID: 6417)

---

## 🛡️ Security & Scanning

### OWASP ZAP - Web Application Security Scanner

**URL**: http://20.161.182.60:8080/

**How to Generate Security Report**:

#### Option 1: Web UI (Easiest)
1. Open http://20.161.182.60:8080/
2. Click **Quick Start** tab
3. Enter URL: `http://app-capstone-ui-dev-ari999.azurewebsites.net`
4. Click **Attack**
5. Wait for scan to complete (5-10 minutes)
6. View alerts in **Alerts** tab
7. Click **Report** → **Generate HTML Report**

#### Option 2: Command Line (Automated)
```bash
# Start spider scan (discover all pages)
curl "http://20.161.182.60:8080/JSON/spider/action/scan/?url=http://app-capstone-ui-dev-ari999.azurewebsites.net&maxChildren=10"

# Wait for spider to complete
sleep 60

# Start active scan (test for vulnerabilities)
curl "http://20.161.182.60:8080/JSON/ascan/action/scan/?url=http://app-capstone-ui-dev-ari999.azurewebsites.net"

# Check scan progress
curl "http://20.161.182.60:8080/JSON/ascan/view/status/"

# Wait for scan to complete (scan shows 100)
sleep 300

# Generate HTML report
curl "http://20.161.182.60:8080/OTHER/core/other/htmlreport/" -o owasp-zap-security-report.html

# Open the report
start owasp-zap-security-report.html  # Windows
open owasp-zap-security-report.html   # Mac
xdg-open owasp-zap-security-report.html  # Linux
```

#### Option 3: Get JSON Results
```bash
# Get all alerts as JSON
curl "http://20.161.182.60:8080/JSON/core/view/alerts/" > alerts.json

# Get summary
curl "http://20.161.182.60:8080/JSON/core/view/alertsSummary/"
```

**Understanding Results**:
- **High Risk** ⚠️ - Critical vulnerabilities (SQL injection, XSS, etc.)
- **Medium Risk** ⚡ - Important security issues
- **Low Risk** ℹ️ - Minor security concerns
- **Informational** 📝 - General observations

**Scan Your Entire Application**:
```bash
# Scan frontend
curl "http://20.161.182.60:8080/JSON/spider/action/scan/?url=http://app-capstone-ui-dev-ari999.azurewebsites.net"

# Scan APIM
curl "http://20.161.182.60:8080/JSON/spider/action/scan/?url=https://apim-capstone-dev-ari999.azure-api.net/api/A:/"

# Scan Backend A (direct)
curl "http://20.161.182.60:8080/JSON/spider/action/scan/?url=http://132.196.250.187:8080"
```

---

### Trivy - Container Vulnerability Scanner

**URL**: http://68.220.211.86:8080/

**How to Scan Your Images**:

#### Option 1: Using Trivy CLI (Recommended)
```bash
# Install Trivy
# Windows (Chocolatey): choco install trivy
# Mac (Homebrew): brew install trivy
# Linux: See https://aquasecurity.github.io/trivy/

# Scan your images
trivy image acrcapstoneari999.azurecr.io/backend-a:latest
trivy image acrcapstoneari999.azurecr.io/backend-b:latest
trivy image acrcapstoneari999.azurecr.io/frontend-ui:latest

# Generate HTML report
trivy image --format template --template "@contrib/html.tpl" \
  -o trivy-backend-a-report.html \
  acrcapstoneari999.azurecr.io/backend-a:latest

# Generate JSON report
trivy image --format json \
  -o trivy-backend-a-report.json \
  acrcapstoneari999.azurecr.io/backend-a:latest

# Scan filesystem (for IaC issues)
trivy fs .

# Scan Kubernetes manifests
trivy config k8s-azure/

# Scan Terraform
trivy config terraform/
```

#### Option 2: Using Trivy Server API
```bash
# Scan image via server
curl -X POST http://68.220.211.86:8080/scan \
  -H "Content-Type: application/json" \
  -d '{
    "image": "acrcapstoneari999.azurecr.io/backend-a:latest"
  }'
```

**Understanding Results**:
- **CRITICAL** 🔴 - Severe vulnerabilities with known exploits
- **HIGH** 🟠 - Serious vulnerabilities requiring immediate attention
- **MEDIUM** 🟡 - Moderate vulnerabilities
- **LOW** 🟢 - Minor issues
- **UNKNOWN** ⚪ - Severity not determined

**Common Vulnerabilities to Check**:
- CVE numbers with high scores (CVSS > 7.0)
- Outdated dependencies
- Known security issues in base images

---

## 🗄️ Database Access

**PostgreSQL Flexible Server**:
- **Host**: `psql-capstone-dev-ari999.postgres.database.azure.com`
- **Port**: `5432`
- **Database**: `capstone_db`
- **Username**: `psqladmin`
- **Password**: `SecurePass2026`

**Connect from Local Machine**:
```bash
psql -h psql-capstone-dev-ari999.postgres.database.azure.com \
     -U psqladmin \
     -d capstone_db
```

**View Upload History**:
```sql
SELECT id, backend_name, ts, meta
FROM requests
ORDER BY ts DESC
LIMIT 10;
```

---

## 📝 Complete URL Summary

| Service | URL | Credentials | Status |
|---------|-----|-------------|--------|
| **Frontend UI** | http://app-capstone-ui-dev-ari999.azurewebsites.net/ | None | ✅ Running |
| **Frontend Health** | http://app-capstone-ui-dev-ari999.azurewebsites.net/health | None | ✅ Healthy |
| **APIM Backend A** | https://apim-capstone-dev-ari999.azure-api.net/api/A:/ | None | ✅ Working |
| **APIM Backend B** | https://apim-capstone-dev-ari999.azure-api.net/api/B:/ | None | ✅ Working |
| **Backend A (Direct)** | http://132.196.250.187:8080 | None | ✅ Running |
| **Backend B (Direct)** | http://68.220.237.26:8080 | None | ✅ Running |
| **Prometheus** | http://4.150.114.54/ | None | ✅ Scraping backends |
| **Grafana** | http://135.222.184.27/ | admin / t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU | ✅ Configured |
| **OWASP ZAP** | http://20.161.182.60:8080/ | None | ✅ Ready |
| **Trivy Server** | http://68.220.211.86:8080/ | None | ✅ Ready |

---

## 🧪 Testing Your Application

### 1. Test Frontend
```bash
# Access frontend
curl http://app-capstone-ui-dev-ari999.azurewebsites.net/

# Check health
curl http://app-capstone-ui-dev-ari999.azurewebsites.net/health
```

### 2. Test Backend via APIM
```bash
# Upload to Backend A
curl -X POST https://apim-capstone-dev-ari999.azure-api.net/api/A:/ \
  -F "image=@test.jpg"

# Upload to Backend B
curl -X POST https://apim-capstone-dev-ari999.azure-api.net/api/B:/ \
  -F "image=@test.jpg"
```

### 3. Test Backends Directly
```bash
# Backend A health
curl http://132.196.250.187:8080/health

# Backend A upload
curl -X POST http://132.196.250.187:8080/api/a \
  -F "image=@test.jpg"

# Backend A metrics
curl http://132.196.250.187:8080/metrics
```

### 4. Check Monitoring
```bash
# Query Prometheus for backend health
curl -G http://4.150.114.54/api/v1/query \
  --data-urlencode 'query=up{job="backend-a"}'

# Check if Grafana is responding
curl http://135.222.184.27/api/health
```

### 5. Run Security Scan
```bash
# Quick OWASP ZAP scan
curl "http://20.161.182.60:8080/JSON/spider/action/scan/?url=http://app-capstone-ui-dev-ari999.azurewebsites.net"

# Trivy scan
trivy image acrcapstoneari999.azurecr.io/backend-a:latest
```

---

## 🔧 Troubleshooting

### Frontend Not Loading
```bash
# Check Azure Web App status
az webapp show --name app-capstone-ui-dev-ari999 \
  --resource-group ari-rg-capstone-dev \
  --query "{state:state,hostNames:defaultHostName}"

# Check logs
az webapp log tail --name app-capstone-ui-dev-ari999 \
  --resource-group ari-rg-capstone-dev
```

### Backends Not Responding
```bash
# Check pods
kubectl get pods -n microservices-app

# Check logs
kubectl logs -n microservices-app deployment/backend-a --tail=50
kubectl logs -n microservices-app deployment/backend-b --tail=50

# Check services
kubectl get svc -n microservices-app
```

### Prometheus Not Scraping Backends
```bash
# Check if annotations are set
kubectl describe svc backend-a-service -n microservices-app | grep prometheus

# Check Prometheus targets
curl http://4.150.114.54/api/v1/targets | jq '.data.activeTargets[] | select(.labels.job | contains("backend"))'

# Restart Prometheus
kubectl rollout restart deployment/prometheus-server -n monitoring
```

### Grafana No Data
```bash
# Check data sources
curl -u "admin:t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU" \
  http://135.222.184.27/api/datasources

# Test Prometheus connection from Grafana
curl -u "admin:t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU" \
  http://135.222.184.27/api/datasources/proxy/1/api/v1/query?query=up
```

---

## 📚 Additional Resources

- **Architecture Diagram**: See [README.md](../README.md)
- **Backend Pipeline Details**: [BACKEND_PIPELINE_STAGES.md](BACKEND_PIPELINE_STAGES.md)
- **Monitoring Deep Dive**: [MONITORING_SECURITY_ACCESS.md](MONITORING_SECURITY_ACCESS.md)
- **Final Fixes Summary**: [FINAL_FIXES_SUMMARY.md](FINAL_FIXES_SUMMARY.md)

---

## ✅ System Health Checklist

- [x] Frontend UI accessible and loading
- [x] Backend A responding to requests
- [x] Backend B responding to requests
- [x] APIM routing correctly to both backends
- [x] Database connections working
- [x] Prometheus scraping backend metrics
- [x] Grafana configured with Prometheus + Loki
- [x] OWASP ZAP ready for security scanning
- [x] Trivy available for vulnerability scanning
- [x] All Kubernetes pods running
- [x] Monitoring stack operational

**Status**: 🟢 ALL SYSTEMS OPERATIONAL

**Date**: January 11, 2026
**Environment**: Development (dev)
**Region**: East US 2
