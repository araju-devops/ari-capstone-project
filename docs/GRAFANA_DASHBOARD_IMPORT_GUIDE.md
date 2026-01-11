# Grafana Dashboard Import Guide

**Grafana URL**: http://135.222.184.27/
**Username**: `admin`
**Password**: `t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU`

---

## ✅ Dashboard Already Imported

I've already created a custom dashboard for you:

**Backend Services Monitoring**
**URL**: http://135.222.184.27/d/e9744d5a-7006-46a1-936c-9d2eabbac1e7/backend-services-monitoring

This dashboard includes:
- Backend A CPU Usage
- Backend B CPU Usage
- Backend A Memory Usage
- Backend B Memory Usage

---

## 📊 How to Import More Dashboards

### Method 1: Import by Dashboard ID (Easiest)

1. **Login to Grafana**: http://135.222.184.27/
2. **Click the "+" icon** in the left sidebar
3. **Select "Import"**
4. **Enter Dashboard ID** and click "Load"
5. **Select "Prometheus"** as the data source
6. **Click "Import"**

### Recommended Dashboard IDs:

| Dashboard Name | ID | Description |
|----------------|-----|-------------|
| **Kubernetes Cluster Monitoring** | 7249 | Complete Kubernetes cluster overview |
| **Node Exporter Full** | 1860 | Detailed node metrics |
| **Kubernetes Pod Resources** | 6417 | Pod CPU/Memory usage |
| **Kubernetes Cluster (Prometheus)** | 315 | Alternative cluster view |
| **Prometheus Stats** | 2 | Prometheus performance |

---

### Method 2: Import from JSON File

If you have a JSON dashboard file:

1. **Go to**: http://135.222.184.27/dashboard/import
2. **Click "Upload JSON file"**
3. **Select your .json file**
4. **Choose "Prometheus" as data source**
5. **Click "Import"**

---

### Method 3: Import via Grafana.com URL

1. **Go to**: http://135.222.184.27/dashboard/import
2. **Paste Grafana.com dashboard URL**
   Example: `https://grafana.com/grafana/dashboards/7249`
3. **Click "Load"**
4. **Select "Prometheus" data source**
5. **Click "Import"**

---

## 🎯 Step-by-Step: Import Kubernetes Cluster Monitoring

Let me walk you through importing the most useful dashboard:

### Step 1: Access Import Page
Go to: http://135.222.184.27/dashboard/import

### Step 2: Enter Dashboard ID
In the "Import via grafana.com" field, enter: **7249**

Click **"Load"**

### Step 3: Configure
- **Name**: Kubernetes Cluster Monitoring (auto-filled)
- **Folder**: General (leave default)
- **Prometheus**: Select "Prometheus" from dropdown

### Step 4: Import
Click **"Import"** button

### Step 5: View Dashboard
You'll be redirected to the dashboard automatically!

---

## 📋 Alternative: Import via API (Advanced)

You can also import dashboards via the Grafana API:

```bash
# Download dashboard JSON
curl -s https://grafana.com/api/dashboards/7249/revisions/1/download -o dashboard.json

# Import to Grafana
curl -X POST http://135.222.184.27/api/dashboards/db \
  -H "Content-Type: application/json" \
  -u "admin:t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU" \
  -d @dashboard.json
```

---

## 🔍 Popular Dashboards for Your Setup

### 1. **Kubernetes Cluster Monitoring (ID: 7249)** ⭐ RECOMMENDED
**What it shows**:
- Cluster CPU/Memory usage
- Pod status and health
- Node resource utilization
- Network I/O
- Storage usage

**Import**: Enter `7249` in the import dialog

---

### 2. **Node Exporter Full (ID: 1860)**
**What it shows**:
- Detailed host metrics
- CPU, Memory, Disk, Network
- System load
- Filesystem usage

**Import**: Enter `1860` in the import dialog

---

### 3. **Kubernetes Pod Resources (ID: 6417)**
**What it shows**:
- Per-pod CPU usage
- Per-pod Memory usage
- Pod restart counts
- Container metrics

**Import**: Enter `6417` in the import dialog

---

### 4. **Prometheus Stats (ID: 2)**
**What it shows**:
- Prometheus performance
- Scrape duration
- Target status
- Sample ingestion rate

**Import**: Enter `2` in the import dialog

---

## 📁 Creating Custom Dashboards

### Option 1: Create from Scratch

1. **Click "+"** → **"Dashboard"**
2. **Click "Add visualization"**
3. **Select "Prometheus"**
4. **Enter PromQL query**:
   ```promql
   # Backend A CPU
   rate(process_cpu_seconds_total{job="backend-a"}[5m])

   # Backend A Memory
   process_resident_memory_bytes{job="backend-a"}

   # Backend A Uptime
   up{job="backend-a"}
   ```
5. **Customize panel** (title, type, legend, etc.)
6. **Click "Apply"**
7. **Save dashboard** (top right)

---

### Option 2: Clone Existing Dashboard

1. **Open any dashboard**
2. **Click settings icon** (gear) in top right
3. **Click "Save As..."**
4. **Give it a new name**
5. **Modify as needed**

---

## 🎨 Useful PromQL Queries for Your Backends

### Backend Health
```promql
up{service=~"backend-.*"}
```

### CPU Usage
```promql
rate(process_cpu_seconds_total{service="backend-a"}[5m]) * 100
```

### Memory Usage
```promql
process_resident_memory_bytes{service="backend-a"} / 1024 / 1024
```

### HTTP Requests (if instrumented)
```promql
rate(http_requests_total{service="backend-a"}[5m])
```

### Request Duration (if instrumented)
```promql
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

---

## 📊 Pre-configured Variables

You can create dashboard variables for dynamic filtering:

### Example: Backend Selector

1. **Dashboard Settings** → **Variables** → **Add variable**
2. **Name**: `backend`
3. **Type**: Query
4. **Query**: `label_values(up{service=~"backend-.*"}, service)`
5. **Use in panels**: `{service="$backend"}`

---

## 🔗 Quick Links

| Resource | URL |
|----------|-----|
| **Grafana Home** | http://135.222.184.27/ |
| **Import Page** | http://135.222.184.27/dashboard/import |
| **Backend Dashboard** | http://135.222.184.27/d/e9744d5a-7006-46a1-936c-9d2eabbac1e7/backend-services-monitoring |
| **Explore Prometheus** | http://135.222.184.27/explore?orgId=1&left=%7B%22datasource%22:%22Prometheus%22%7D |
| **Explore Loki** | http://135.222.184.27/explore?orgId=1&left=%7B%22datasource%22:%22Loki%22%7D |
| **Grafana Dashboards Library** | https://grafana.com/grafana/dashboards |

---

## 💡 Pro Tips

1. **Use Folders**: Organize dashboards into folders (Kubernetes, Backends, Security)
2. **Set Refresh Rate**: Dashboard settings → Auto-refresh (30s, 1m, 5m)
3. **Create Alerts**: Add alert rules to panels for proactive monitoring
4. **Share Dashboards**: Use share icon → Get link or export JSON
5. **Use Variables**: Make dashboards dynamic with template variables
6. **Star Favorites**: Click star icon on dashboards you use frequently

---

## 🎯 Next Steps

1. ✅ **Access Grafana**: http://135.222.184.27/
2. ✅ **View Backend Dashboard**: Already created for you
3. 📊 **Import Kubernetes Dashboard**: Use ID `7249`
4. 📈 **Explore Metrics**: Click "Explore" → Select Prometheus
5. 📝 **View Logs**: Click "Explore" → Select Loki
6. ⭐ **Customize**: Create your own panels and dashboards

---

**Grafana Credentials**:
- **URL**: http://135.222.184.27/
- **Username**: `admin`
- **Password**: `t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU`

**Data Sources Configured**:
- ✅ Prometheus (default)
- ✅ Loki

**Happy Monitoring!** 📊
