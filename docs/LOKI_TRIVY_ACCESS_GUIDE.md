# Loki and Trivy Access Guide

## Important Note
Both Loki and Trivy are **API-only services** - they don't have web UIs when you visit them in a browser. This is why you see "404 page not found" on the root path. This is **normal and expected behavior**.

---

## ✅ Loki (Log Aggregation)

### Service Details
- **External URL**: http://48.214.13.134:3100
- **Status**: Running ✅
- **Type**: API-only service (no web UI)

### How to Access Loki

**Option 1: Via Grafana (RECOMMENDED)**

Loki is designed to be accessed through Grafana, which provides the UI:

1. Go to Grafana: http://135.222.184.27/
2. Login: `admin` / `t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU`
3. Click **Explore** (compass icon)
4. Select **Loki** from data source dropdown
5. Run queries like:
   ```logql
   {namespace="microservices-app", app="backend-a"}
   {namespace="microservices-app"} |= "error"
   ```

**Option 2: Via API (for demonstration)**

```bash
# Test Loki is running
curl http://48.214.13.134:3100/ready
# Output: ready

# Get available labels
curl http://48.214.13.134:3100/loki/api/v1/labels
# Output: {"status":"success","data":["app","component","container",...]}

# Query logs from Backend A
curl -G -s "http://48.214.13.134:3100/loki/api/v1/query" \
  --data-urlencode 'query={namespace="microservices-app", app="backend-a"}' \
  --data-urlencode 'limit=10' | jq

# Query error logs
curl -G -s "http://48.214.13.134:3100/loki/api/v1/query" \
  --data-urlencode 'query={namespace="microservices-app"} |= "error"' \
  --data-urlencode 'limit=10' | jq
```

### Screenshots for Demonstration

1. **Show Loki API Working**:
   ```bash
   curl http://48.214.13.134:3100/ready
   ```
   Screenshot showing "ready" response

2. **Show Logs in Grafana**:
   - Open Grafana Explore
   - Select Loki
   - Run query: `{namespace="microservices-app"}`
   - Screenshot showing log results

3. **Show Available Labels**:
   ```bash
   curl http://48.214.13.134:3100/loki/api/v1/labels | jq
   ```
   Screenshot showing JSON response with label list

---

## ✅ Trivy (Container Security Scanner)

### Service Details
- **External URL**: http://48.214.12.245:8080
- **Status**: Running ✅
- **Type**: API-only service (no web UI)

### How to Access Trivy

**Option 1: Scan Container Images via API**

```bash
# Test Trivy is running
curl http://48.214.12.245:8080/healthz
# Output: ok

# Scan an image (example)
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "image": "alpine:3.19",
    "scanners": ["vuln"]
  }' \
  http://48.214.12.245:8080/scan

# Scan your backend image
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "image": "acrcapstonedevari999.azurecr.io/backend-a:latest",
    "scanners": ["vuln","secret"]
  }' \
  http://48.214.12.245:8080/scan
```

**Option 2: Use Trivy CLI (connects to server)**

```bash
# If you have Trivy CLI installed locally
trivy image --server http://48.214.12.245:8080 alpine:3.19

# Scan your backend images
trivy image --server http://48.214.12.245:8080 acrcapstonedevari999.azurecr.io/backend-a:latest
trivy image --server http://48.214.12.245:8080 acrcapstonedevari999.azurecr.io/backend-b:latest
```

**Option 3: Verify via kubectl**

```bash
# Check Trivy pod is running
kubectl get pods -n security
# Output: trivy-server-xxx   1/1   Running

# Check Trivy logs
kubectl logs -n security -l app=trivy-server
# Should show: "Listening 0.0.0.0:8080..."
```

### Screenshots for Demonstration

1. **Show Trivy Health Check**:
   ```bash
   curl http://48.214.12.245:8080/healthz
   ```
   Screenshot showing "ok" response

2. **Show Trivy Pod Running**:
   ```bash
   kubectl get pods -n security
   ```
   Screenshot showing pod in Running state

3. **Show Trivy Logs**:
   ```bash
   kubectl logs -n security -l app=trivy-server --tail=20
   ```
   Screenshot showing "Listening 0.0.0.0:8080..." message

---

## Why No Web UI?

### Loki
- Loki is a **log aggregation backend** similar to Elasticsearch
- It stores and queries logs but doesn't provide a UI
- **Grafana is the UI** for Loki (already configured at http://135.222.184.27/)
- This is the standard architecture: Loki (backend) + Grafana (frontend)

### Trivy
- Trivy Server is an **API endpoint** for remote scanning
- It doesn't have a web dashboard
- It's designed to be called via:
  - Trivy CLI (command-line client)
  - CI/CD pipelines
  - API calls from other tools
- For reports, use the API to scan and save results to files

---

## Summary for Demonstration

| Service | URL | Has UI? | How to Show It Works |
|---------|-----|---------|---------------------|
| **Loki** | http://48.214.13.134:3100 | No | Use Grafana Explore at http://135.222.184.27/ |
| **Trivy** | http://48.214.12.245:8080 | No | Use `kubectl get pods` and `curl /healthz` |
| **Grafana** | http://135.222.184.27/ | **Yes** | Open in browser - shows Loki logs and dashboards |

---

## Complete Monitoring Stack URLs

For your capstone demonstration:

| Component | URL | Login |
|-----------|-----|-------|
| Frontend | http://app-capstone-ui-dev-ari999.azurewebsites.net/ | - |
| Prometheus | http://4.150.114.54/ | - |
| **Grafana** | http://135.222.184.27/ | admin / t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU |
| Loki API | http://48.214.13.134:3100 | - |
| Trivy API | http://48.214.12.245:8080 | - |

**For assignment demonstration**:
- Show **Grafana** (has UI) which displays data from Prometheus and Loki
- Show API responses from Loki and Trivy to prove they're running
- See [LOKI_LOGS_DEMO.md](LOKI_LOGS_DEMO.md) for detailed Loki queries
- See [OWASP_ZAP_REPORT_GUIDE.md](OWASP_ZAP_REPORT_GUIDE.md) for security scanning

---

**Date**: January 11, 2026
