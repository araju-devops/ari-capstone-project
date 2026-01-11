# Monitoring & Security Tools Access Guide

## 🔍 Prometheus - Metrics Collection

**URL**: http://4.150.114.54/

### What is Prometheus?
Prometheus collects and stores metrics from your applications and infrastructure.

### How to Use:
1. **Access the Web UI**: Open http://4.150.114.54/ in your browser
2. **Run Queries**: Use PromQL to query metrics
   - Example: `up` - Shows all targets that are up/down
   - Example: `container_memory_usage_bytes` - Container memory usage
   - Example: `http_requests_total` - Total HTTP requests

### Common Queries:
```promql
# Check if all services are running
up

# CPU usage by pod
rate(container_cpu_usage_seconds_total[5m])

# Memory usage
container_memory_working_set_bytes

# Backend A request rate
rate(http_requests_total{job="backend-a"}[5m])
```

### Targets:
Go to **Status → Targets** to see all monitored endpoints:
- Backend A metrics: http://backend-a-service:8080/metrics
- Backend B metrics: http://backend-b-service:8080/metrics
- Node exporter, kube-state-metrics, etc.

---

## 📊 Grafana - Visualization & Dashboards

**URL**: http://135.222.184.27/

### Login Credentials:
- **Username**: `admin`
- **Password**: `t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU`

### What is Grafana?
Grafana creates beautiful dashboards to visualize your Prometheus metrics and Loki logs.

### How to Use:

#### 1. Access Grafana
Open http://135.222.184.27/ and login with the credentials above.

#### 2. View Pre-built Dashboards
- Click **Dashboards** (left sidebar)
- Browse available dashboards:
  - Kubernetes Cluster Monitoring
  - Node Exporter Full
  - Prometheus Stats

#### 3. Create Custom Dashboard
1. Click **+ Create** → **Dashboard**
2. Click **Add visualization**
3. Select **Prometheus** as data source
4. Enter a query (e.g., `up`, `container_memory_usage_bytes`)
5. Click **Apply**

#### 4. View Logs (Loki)
1. Click **Explore** (compass icon in left sidebar)
2. Select **Loki** as data source
3. Use LogQL queries:
   ```logql
   {namespace="microservices-app"}
   {namespace="microservices-app", app="backend-a"}
   {namespace="microservices-app"} |= "error"
   ```

### Recommended Dashboards to Import:
- Kubernetes Cluster Monitoring: Dashboard ID **7249**
- Node Exporter Full: Dashboard ID **1860**

To import:
1. Click **+** → **Import**
2. Enter dashboard ID
3. Select **Prometheus** as data source
4. Click **Import**

---

## 🛡️ OWASP ZAP - Security Testing

**URL**: http://20.161.182.60:8080/

### What is OWASP ZAP?
OWASP ZAP (Zed Attack Proxy) is a security testing tool that finds vulnerabilities in web applications.

### How to Use:

#### Option 1: Web UI (Recommended)
1. **Access ZAP**: Open http://20.161.182.60:8080/ in your browser
2. **Start a Quick Scan**:
   - Click **Quick Start**
   - Enter URL to scan: `http://app-capstone-ui-dev-ari999.azurewebsites.net`
   - Click **Attack**
3. **View Results**:
   - Check the **Alerts** tab for vulnerabilities
   - Alerts are categorized by severity: High, Medium, Low, Informational

#### Option 2: API (Automated Scanning)
```bash
# Start a spider scan
curl "http://20.161.182.60:8080/JSON/spider/action/scan/?url=http://app-capstone-ui-dev-ari999.azurewebsites.net"

# Start an active scan
curl "http://20.161.182.60:8080/JSON/ascan/action/scan/?url=http://app-capstone-ui-dev-ari999.azurewebsites.net"

# Get scan status
curl "http://20.161.182.60:8080/JSON/ascan/view/status/"

# Get alerts/vulnerabilities (HTML report)
curl "http://20.161.182.60:8080/OTHER/core/other/htmlreport/" -o zap-report.html

# Get alerts (JSON)
curl "http://20.161.182.60:8080/JSON/core/view/alerts/" | jq .
```

#### Option 3: Generate Full Report
```bash
# Generate HTML report
curl "http://20.161.182.60:8080/OTHER/core/other/htmlreport/" > owasp-zap-report.html

# Generate XML report
curl "http://20.161.182.60:8080/OTHER/core/other/xmlreport/" > owasp-zap-report.xml

# Generate JSON report
curl "http://20.161.182.60:8080/JSON/core/view/alerts/" > owasp-zap-report.json
```

### Understanding ZAP Results:
- **High Risk**: Critical vulnerabilities (SQL injection, XSS, etc.)
- **Medium Risk**: Important issues that should be fixed
- **Low Risk**: Minor issues
- **Informational**: General observations

### Scan Your Application:
```bash
# Scan frontend
curl "http://20.161.182.60:8080/JSON/spider/action/scan/?url=http://app-capstone-ui-dev-ari999.azurewebsites.net"

# Scan APIM endpoints
curl "http://20.161.182.60:8080/JSON/spider/action/scan/?url=https://apim-capstone-dev-ari999.azure-api.net"

# Wait for scan to complete, then get report
sleep 60
curl "http://20.161.182.60:8080/OTHER/core/other/htmlreport/" -o capstone-security-report.html
```

---

## 🔐 Trivy - Vulnerability Scanner

**URL**: http://68.220.211.86:8080/

### What is Trivy?
Trivy scans container images, filesystems, and configurations for vulnerabilities and misconfigurations.

### How to Use:

#### Scan a Container Image
```bash
# Scan your backend-a image
curl -X POST "http://68.220.211.86:8080/scan" \
  -H "Content-Type: application/json" \
  -d '{
    "image": "acrcapstoneari999.azurecr.io/backend-a:latest"
  }'

# Scan your frontend image
curl -X POST "http://68.220.211.86:8080/scan" \
  -H "Content-Type: application/json" \
  -d '{
    "image": "acrcapstoneari999.azurecr.io/frontend-ui:latest"
  }'
```

#### Using Trivy CLI (from local machine)
```bash
# Install Trivy (if not installed)
# Windows: choco install trivy
# Mac: brew install trivy
# Linux: wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -

# Scan your ACR images
trivy image acrcapstoneari999.azurecr.io/backend-a:latest
trivy image acrcapstoneari999.azurecr.io/backend-b:latest
trivy image acrcapstoneari999.azurecr.io/frontend-ui:latest

# Scan filesystem
trivy fs .

# Scan Kubernetes manifests
trivy config k8s-azure/
```

#### Generate Trivy Reports
```bash
# HTML report
trivy image --format template --template "@contrib/html.tpl" \
  -o trivy-report.html \
  acrcapstoneari999.azurecr.io/backend-a:latest

# JSON report
trivy image --format json \
  -o trivy-report.json \
  acrcapstoneari999.azurecr.io/backend-a:latest

# SARIF report (for GitHub/Azure DevOps)
trivy image --format sarif \
  -o trivy-report.sarif \
  acrcapstoneari999.azurecr.io/backend-a:latest
```

#### Understanding Trivy Results:
- **CRITICAL**: Severe vulnerabilities with known exploits
- **HIGH**: Serious vulnerabilities that should be patched
- **MEDIUM**: Moderate vulnerabilities
- **LOW**: Minor issues
- **UNKNOWN**: Severity not determined

---

## 📝 Quick Access Summary

| Service | URL | Credentials | Purpose |
|---------|-----|-------------|---------|
| **Prometheus** | http://4.150.114.54/ | None | Metrics & monitoring |
| **Grafana** | http://135.222.184.27/ | admin / t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU | Dashboards & visualization |
| **OWASP ZAP** | http://20.161.182.60:8080/ | None (API key disabled) | Security testing |
| **Trivy Server** | http://68.220.211.86:8080/ | None | Vulnerability scanning |

---

## 🔧 Troubleshooting

### Can't Access Services?
```bash
# Check service status
kubectl get svc -n monitoring
kubectl get svc -n security

# Check pod status
kubectl get pods -n monitoring
kubectl get pods -n security

# View logs
kubectl logs -n monitoring deployment/grafana
kubectl logs -n security deployment/owasp-zap
```

### Reset Grafana Password
```bash
kubectl exec -n monitoring deployment/grafana -- grafana-cli admin reset-admin-password newpassword
```

### Port Forward (Alternative Access)
If LoadBalancer IPs aren't working, use port forwarding:
```bash
# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Prometheus
kubectl port-forward -n monitoring svc/prometheus-server 9090:80

# OWASP ZAP
kubectl port-forward -n security svc/owasp-zap 8080:8080

# Trivy
kubectl port-forward -n security svc/trivy-server 8081:8080
```

Then access via localhost:
- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090
- OWASP ZAP: http://localhost:8080
- Trivy: http://localhost:8081

---

## 📊 Recommended Workflow

### 1. Daily Monitoring
- Check **Grafana** dashboards for system health
- Review **Prometheus** alerts

### 2. Security Scanning (Weekly)
- Run **OWASP ZAP** spider + active scan
- Review **Trivy** vulnerability reports
- Fix critical and high-severity issues

### 3. Before Releases
- Full security scan with OWASP ZAP
- Trivy scan of all container images
- Review Grafana metrics for performance issues

---

**Last Updated**: January 11, 2026
**Status**: All Services Running ✅
