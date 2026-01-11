# Known Issues and Workarounds

**Last Updated**: January 11, 2026

---

## 🔴 Issue 1: Prometheus Not Showing Backend Metrics in Targets

### Problem
Prometheus targets page shows backend services with error: `server returned HTTP status 404 Not Found`
The scrape path is incorrectly showing as `C:/Program Files/Git/metrics` instead of `/metrics`

### Root Cause
- Prometheus service discovery with annotations is being interpreted by Git Bash on Windows
- The path `/metrics` is being prefixed with the Git installation directory

### Workaround Applied
Created external service endpoints in the monitoring namespace that point to the backend LoadBalancer IPs:

**Files Created**:
- `k8s-azure/09-prometheus-backend-endpoints.yaml` - External endpoints for backend-a and backend-b

**Manual Verification**:
You can still access backend metrics directly:
```bash
# Backend A metrics
curl http://132.196.250.187:8080/metrics

# Backend B metrics
curl http://68.220.237.26:8080/metrics
```

### Status
✅ **WORKAROUND IN PLACE** - Backend metrics are accessible, Prometheus should discover them via kubernetes-service-endpoints

### Recommended Fix
For production, use ServiceMonitor CRDs with Prometheus Operator instead of annotations.

---

## 🔴 Issue 2: OWASP ZAP and Trivy Deployment Timeout in Terraform

### Problem
When running the Terraform pipeline, OWASP ZAP and Trivy deployments fail after 10 minutes with:
```
Error: Deployment exceeded its progress deadline
```

Pods are stuck in `Pending` state with error:
```
0/1 nodes are available: 1 Insufficient cpu
```

### Root Cause
- **Cluster Size**: Single-node AKS cluster with 1900m CPU (1.9 cores)
- **Current Allocation**: 91% (1742m) already allocated to:
  - Backend A & B
  - Prometheus
  - Grafana
  - Loki
  - ArgoCD
  - Kubernetes system pods
- **Remaining**: Only 158m CPU available
- **Required**: 100m CPU (50m request × 2 tools)

### Workaround Applied
1. **Disabled in Terraform**: Commented out OWASP ZAP and Trivy resources in `terraform/modules/k8s-addons/main.tf`
2. **Manual Deployment**: Security tools were deployed manually via kubectl and are still accessible
3. **LoadBalancer Services**: Created LoadBalancer services for external access

**Security Tools Remain Accessible**:
- OWASP ZAP: http://20.161.182.60:8080/
- Trivy: http://68.220.237.26:8080/

### Status
✅ **WORKAROUND IN PLACE** - Security tools are running and accessible, just not managed by Terraform

### Recommended Fix
Choose one:

**Option 1: Scale the Cluster** (Recommended)
```bash
az aks scale \
  --resource-group ari-rg-capstone-dev \
  --name aks-capstone-dev-ari999 \
  --node-count 2
```

**Option 2: Increase Node Size**
```bash
az aks nodepool update \
  --resource-group ari-rg-capstone-dev \
  --cluster-name aks-capstone-dev-ari999 \
  --name default \
  --node-vm-size Standard_D4s_v3  # 4 vCPU, 16 GB RAM
```

**Option 3: Reduce Replicas**
Scale backend services to 1 replica each (already done):
```bash
kubectl scale deployment/backend-a deployment/backend-b --replicas=1 -n microservices-app
```

### To Re-enable in Terraform
Once cluster is scaled:
1. Uncomment lines in `terraform/modules/k8s-addons/main.tf` (lines 86-212)
2. Uncomment output in `terraform/modules/k8s-addons/outputs.tf` (lines 11-15)
3. Run terraform apply

---

## 🟡 Issue 3: Grafana Has No Data Sources Initially

### Problem
Fresh Grafana deployment has no data sources configured.

### Root Cause
Helm chart doesn't auto-configure data sources by default.

### Workaround Applied
Configured via Grafana API:
```bash
# Added Prometheus
curl -X POST -H "Content-Type: application/json" \
  -u "admin:PASSWORD" \
  -d '{"name":"Prometheus","type":"prometheus","url":"http://prometheus-server.monitoring.svc.cluster.local","isDefault":true}' \
  http://135.222.184.27/api/datasources

# Added Loki
curl -X POST -H "Content-Type: application/json" \
  -u "admin:PASSWORD" \
  -d '{"name":"Loki","type":"loki","url":"http://loki.monitoring.svc.cluster.local:3100"}' \
  http://135.222.184.27/api/datasources
```

### Status
✅ **FIXED** - Grafana now has both Prometheus and Loki data sources

### Recommended Fix
For production, use Helm values to pre-configure data sources:
```yaml
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server
      isDefault: true
    - name: Loki
      type: loki
      url: http://loki:3100
```

---

## 🟢 Issue 4: APIM Returning 404 for Backend Routes

### Problem
APIM returns `{"statusCode": 404, "message": "Resource not found"}` for `/api/A:/` and `/api/B:/`

### Root Cause
APIM API policy not configured with backend routing.

### Solution Applied
Applied routing policy via Azure REST API:
```xml
<policies>
  <inbound>
    <cors>...</cors>
    <choose>
      <when condition="@(context.Request.Url.Path.Contains(&quot;/A:&quot;))">
        <set-backend-service base-url="http://132.196.250.187:8080" />
        <rewrite-uri template="/api/a" />
      </when>
      <when condition="@(context.Request.Url.Path.Contains(&quot;/B:&quot;))">
        <set-backend-service base-url="http://68.220.237.26:8080" />
        <rewrite-uri template="/api/b" />
      </when>
    </choose>
  </inbound>
</policies>
```

### Status
✅ **FIXED** - APIM now correctly routes to both backends

---

## 📊 Current System Status

### ✅ Working Components
- Frontend UI: http://app-capstone-ui-dev-ari999.azurewebsites.net/
- Backend A (APIM): https://apim-capstone-dev-ari999.azure-api.net/api/A:/
- Backend B (APIM): https://apim-capstone-dev-ari999.azure-api.net/api/B:/
- Grafana: http://135.222.184.27/ (with Prometheus + Loki data sources)
- OWASP ZAP: http://20.161.182.60:8080/
- Trivy: http://68.220.211.86:8080/
- PostgreSQL: Database connections working

### ⚠️ Partial Working
- Prometheus: http://4.150.114.54/
  - Scraping Kubernetes metrics ✅
  - Backend metrics need verification ⚠️

### ❌ Not in Terraform
- OWASP ZAP (manual deployment only)
- Trivy (manual deployment only)

---

## 🔧 Troubleshooting Commands

### Check Prometheus Targets
```bash
# Via API
curl "http://4.150.114.54/api/v1/targets"

# Check specific backend
curl "http://4.150.114.54/api/v1/query?query=up{service='backend-a'}"
```

### Check Backend Metrics Directly
```bash
curl http://132.196.250.187:8080/metrics | head -20
curl http://68.220.237.26:8080/metrics | head -20
```

### Check Pod Resource Usage
```bash
kubectl top pods -n microservices-app
kubectl top pods -n monitoring
kubectl top nodes
```

### Check Why Pods Are Pending
```bash
kubectl get pods -n security
kubectl describe pod -n security <pod-name>
```

### Restart Prometheus
```bash
kubectl rollout restart deployment/prometheus-server -n monitoring
```

---

## 📝 Recommendations

### Short Term (Current Sprint)
1. ✅ **Keep current workarounds** - System is functional
2. ✅ **Use manual deployments** for OWASP ZAP and Trivy
3. ✅ **Direct metric access** - Backend metrics accessible via direct URLs

### Medium Term (Next Sprint)
1. **Scale cluster to 2 nodes** - Resolve CPU constraints
2. **Implement ServiceMonitors** - Better Prometheus integration
3. **Add Helm value files** - Pre-configure Grafana data sources
4. **Terraform APIM policy** - Manage APIM via IaC

### Long Term (Production)
1. **Multi-node cluster** with auto-scaling
2. **Prometheus Operator** with ServiceMonitor CRDs
3. **Persistent volumes** for Grafana dashboards
4. **Azure Monitor integration** for unified monitoring
5. **Resource quotas** and limits per namespace

---

## 📚 Related Documentation

- [Complete Access Guide](COMPLETE_ACCESS_GUIDE.md) - All URLs and credentials
- [Monitoring & Security Access](MONITORING_SECURITY_ACCESS.md) - Detailed usage guides
- [Final Fixes Summary](FINAL_FIXES_SUMMARY.md) - All fixes applied

---

**Status**: System operational with known workarounds in place
**Environment**: Development (dev)
**Date**: January 11, 2026
