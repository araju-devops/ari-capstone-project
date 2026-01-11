# Loki Log Aggregation Demo Guide

**Loki URL**: Integrated in Grafana
**Grafana URL**: http://135.222.184.27/
**Credentials**: admin / t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU

---

## ✅ Loki is Running

```bash
# Verify Loki is running
kubectl get pods -n monitoring -l app=loki
# Should show: loki-0   1/1   Running
```

---

## 📊 How to View Logs in Grafana (Using Loki)

### Step 1: Access Grafana Explore
1. Go to: http://135.222.184.27/
2. Login with: `admin` / `t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU`
3. Click **Explore** (compass icon) in the left sidebar
4. Select **Loki** from the data source dropdown

### Step 2: Query Backend Logs

**View All Backend A Logs**:
```logql
{namespace="microservices-app", app="backend-a"}
```

**View All Backend B Logs**:
```logql
{namespace="microservices-app", app="backend-b"}
```

**View All Microservices Logs**:
```logql
{namespace="microservices-app"}
```

### Step 3: Filter Logs

**Show Only Errors**:
```logql
{namespace="microservices-app"} |= "error"
```

**Show HTTP Requests**:
```logql
{namespace="microservices-app"} |= "POST" |= "/api/"
```

**Show Database Queries**:
```logql
{namespace="microservices-app"} |= "INSERT" or "SELECT"
```

**Exclude Health Checks**:
```logql
{namespace="microservices-app"} != "/health"
```

---

## 🎯 LogQL Query Examples

### Basic Queries

1. **All logs from Backend A**:
   ```logql
   {namespace="microservices-app", app="backend-a"}
   ```

2. **Logs from last 5 minutes**:
   ```logql
   {namespace="microservices-app"}
   ```
   (Set time range to "Last 5 minutes" in Grafana)

3. **Count errors per minute**:
   ```logql
   sum(rate({namespace="microservices-app"} |= "error" [1m]))
   ```

### Advanced Queries

1. **Find all 500 errors**:
   ```logql
   {namespace="microservices-app"} |= "500" |= "error"
   ```

2. **Database connection errors**:
   ```logql
   {namespace="microservices-app"} |= "Database" |= "error"
   ```

3. **File upload logs**:
   ```logql
   {namespace="microservices-app"} |= "uploaded"
   ```

4. **Logs by pod**:
   ```logql
   {namespace="microservices-app", pod=~"backend-a.*"}
   ```

---

## 📸 Screenshot Guide for Demonstration

### Screenshot 1: Loki Data Source in Grafana
1. Go to: http://135.222.184.27/connections/datasources
2. Click on **Loki**
3. Scroll down and click **Save & Test**
4. Screenshot showing "Data source is working" ✅

### Screenshot 2: Backend Logs in Explore
1. Go to: http://135.222.184.27/explore
2. Select **Loki** data source
3. Enter query: `{namespace="microservices-app", app="backend-a"}`
4. Click **Run query**
5. Screenshot showing logs with timestamps

### Screenshot 3: Error Log Filtering
1. In Explore, enter: `{namespace="microservices-app"} |= "error"`
2. Screenshot showing filtered error logs

### Screenshot 4: Logs Dashboard
1. Create a new dashboard
2. Add panel with Loki query
3. Show log stream with live updates
4. Screenshot of logs flowing in real-time

---

## 🔍 Generate Sample Logs for Demo

Run these commands to generate logs:

```bash
# Generate successful upload logs
curl -X POST https://apim-capstone-dev-ari999.azure-api.net/api/A:/ \
  -F "image=@test.jpg"

# View the logs immediately
# In Grafana Explore:
{namespace="microservices-app", app="backend-a"} |= "uploaded"
```

---

## 📋 Loki Features Demonstrated

✅ **Log Collection**: Collecting logs from all pods in microservices-app namespace
✅ **Log Filtering**: Filter by namespace, app, pod, or content
✅ **Log Parsing**: Parse JSON logs automatically
✅ **Time-Series**: Query logs over time ranges
✅ **Integration**: Seamlessly integrated with Grafana
✅ **Real-Time**: Live log streaming
✅ **Search**: Full-text search across all logs

---

## 🎨 Create a Logs Dashboard

1. Go to: http://135.222.184.27/
2. Click **+** → **Dashboard**
3. Click **Add visualization**
4. Select **Loki**
5. Add these panels:

   **Panel 1: Backend A Logs**
   ```logql
   {namespace="microservices-app", app="backend-a"}
   ```

   **Panel 2: Backend B Logs**
   ```logql
   {namespace="microservices-app", app="backend-b"}
   ```

   **Panel 3: Error Count**
   ```logql
   sum(rate({namespace="microservices-app"} |= "error" [1m]))
   ```

6. Save dashboard as "Application Logs"

---

## ✅ Verification Steps

1. **Loki Pod Running**:
   ```bash
   kubectl get pods -n monitoring -l app=loki
   # Output: loki-0   1/1   Running
   ```

2. **Loki Service Available**:
   ```bash
   kubectl get svc -n monitoring loki
   # Output: loki   ClusterIP   10.0.x.x   <none>   3100/TCP
   ```

3. **Grafana Can Query Loki**:
   - Go to Grafana Explore
   - Select Loki
   - Run any query
   - Logs should appear

---

**Loki Implementation: COMPLETE ✅**
**Date**: January 11, 2026
