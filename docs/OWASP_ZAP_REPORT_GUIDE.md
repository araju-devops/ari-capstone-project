# OWASP ZAP Security Report Generation Guide

**Target Application**: http://app-capstone-ui-dev-ari999.azurewebsites.net/
**APIM Endpoints**:
- Backend A: https://apim-capstone-dev-ari999.azure-api.net/api/A:/
- Backend B: https://apim-capstone-dev-ari999.azure-api.net/api/B:/

---

## 🎯 Option 1: Run OWASP ZAP Locally with Docker (RECOMMENDED)

### Step 1: Run OWASP ZAP Container
```bash
docker run -u zap -p 8080:8080 -i zaproxy/zap-stable:latest zap.sh \
  -daemon \
  -host 0.0.0.0 \
  -port 8080 \
  -config api.disablekey=true \
  -config api.addrs.addr.name=.* \
  -config api.addrs.addr.regex=true
```

**Wait 30 seconds** for ZAP to start.

### Step 2: Run Spider Scan (Discover Pages)
```bash
# Scan Frontend
curl "http://localhost:8080/JSON/spider/action/scan/?url=http://app-capstone-ui-dev-ari999.azurewebsites.net"

# Wait for spider to complete (about 60 seconds)
sleep 60
```

### Step 3: Run Active Security Scan
```bash
# Start active scan
curl "http://localhost:8080/JSON/ascan/action/scan/?url=http://app-capstone-ui-dev-ari999.azurewebsites.net"

# Check scan progress
curl "http://localhost:8080/JSON/ascan/view/status/"
# Output: {"status":"100"} when complete

# Wait for scan (5-10 minutes)
# Keep checking status until it shows 100
```

### Step 4: Generate HTML Report
```bash
# Generate report
curl "http://localhost:8080/OTHER/core/other/htmlreport/" -o owasp-zap-security-report.html

# Open the report
start owasp-zap-security-report.html  # Windows
open owasp-zap-security-report.html   # Mac
xdg-open owasp-zap-security-report.html  # Linux
```

### Step 5: Generate Additional Report Formats

**XML Report**:
```bash
curl "http://localhost:8080/OTHER/core/other/xmlreport/" -o owasp-zap-report.xml
```

**JSON Report**:
```bash
curl "http://localhost:8080/JSON/core/view/alerts/" -o owasp-zap-report.json
```

**Markdown Report**:
```bash
curl "http://localhost:8080/OTHER/core/other/mdreport/" -o owasp-zap-report.md
```

---

## 🎯 Option 2: Use OWASP ZAP Desktop Application

### Step 1: Download OWASP ZAP
- Download from: https://www.zaproxy.org/download/
- Install and launch ZAP

### Step 2: Configure Target
1. Click **Automated Scan**
2. Enter URL: `http://app-capstone-ui-dev-ari999.azurewebsites.net`
3. Click **Attack**

### Step 3: Wait for Scan
- Spider scan will run first (discovers all pages)
- Active scan will run second (tests for vulnerabilities)
- Total time: 10-15 minutes

### Step 4: Generate Report
1. Go to **Report** → **Generate HTML Report**
2. Save as: `owasp-zap-security-report.html`
3. Open the report in your browser

---

## 🎯 Option 3: Automated Scan Script

Create this script: `run-owasp-scan.sh`

```bash
#!/bin/bash

TARGET_URL="http://app-capstone-ui-dev-ari999.azurewebsites.net"
ZAP_URL="http://localhost:8080"
REPORT_FILE="owasp-zap-security-report.html"

echo "======================================"
echo "OWASP ZAP Security Scan"
echo "Target: $TARGET_URL"
echo "======================================"
echo ""

# Step 1: Check if ZAP is running
echo "[1/5] Checking ZAP availability..."
if ! curl -s -f "$ZAP_URL" > /dev/null; then
    echo "Error: ZAP is not running at $ZAP_URL"
    echo "Start ZAP with:"
    echo "docker run -u zap -p 8080:8080 -d zaproxy/zap-stable:latest zap.sh -daemon -host 0.0.0.0 -port 8080 -config api.disablekey=true"
    exit 1
fi
echo "✅ ZAP is running"
echo ""

# Step 2: Spider scan
echo "[2/5] Starting spider scan..."
SPIDER_ID=$(curl -s "$ZAP_URL/JSON/spider/action/scan/?url=$TARGET_URL" | grep -o '"scan":"[0-9]*"' | cut -d'"' -f4)
echo "Spider scan started (ID: $SPIDER_ID)"

# Wait for spider to complete
while true; do
    STATUS=$(curl -s "$ZAP_URL/JSON/spider/view/status/?scanId=$SPIDER_ID" | grep -o '"status":"[0-9]*"' | cut -d'"' -f4)
    echo "Spider progress: $STATUS%"
    [ "$STATUS" = "100" ] && break
    sleep 5
done
echo "✅ Spider scan complete"
echo ""

# Step 3: Active scan
echo "[3/5] Starting active security scan..."
SCAN_ID=$(curl -s "$ZAP_URL/JSON/ascan/action/scan/?url=$TARGET_URL" | grep -o '"scan":"[0-9]*"' | cut -d'"' -f4)
echo "Active scan started (ID: $SCAN_ID)"

# Wait for active scan to complete
while true; do
    STATUS=$(curl -s "$ZAP_URL/JSON/ascan/view/status/?scanId=$SCAN_ID" | grep -o '"status":"[0-9]*"' | cut -d'"' -f4)
    echo "Active scan progress: $STATUS%"
    [ "$STATUS" = "100" ] && break
    sleep 10
done
echo "✅ Active scan complete"
echo ""

# Step 4: Generate report
echo "[4/5] Generating HTML report..."
curl -s "$ZAP_URL/OTHER/core/other/htmlreport/" -o "$REPORT_FILE"
echo "✅ Report generated: $REPORT_FILE"
echo ""

# Step 5: Get summary
echo "[5/5] Scan Summary:"
ALERTS=$(curl -s "$ZAP_URL/JSON/core/view/alerts/" | grep -o '"risk":"[^"]*"' | wc -l)
HIGH=$(curl -s "$ZAP_URL/JSON/core/view/alerts/" | grep -o '"risk":"High"' | wc -l)
MEDIUM=$(curl -s "$ZAP_URL/JSON/core/view/alerts/" | grep -o '"risk":"Medium"' | wc -l)
LOW=$(curl -s "$ZAP_URL/JSON/core/view/alerts/" | grep -o '"risk":"Low"' | wc -l)

echo "Total Alerts: $ALERTS"
echo "  High:   $HIGH"
echo "  Medium: $MEDIUM"
echo "  Low:    $LOW"
echo ""
echo "======================================"
echo "Scan Complete!"
echo "Open report: $REPORT_FILE"
echo "======================================"
```

Make it executable:
```bash
chmod +x run-owasp-scan.sh
./run-owasp-scan.sh
```

---

## 📊 What the Report Shows

The OWASP ZAP report includes:

### Security Alerts by Risk Level:
- **High** 🔴 - Critical vulnerabilities requiring immediate attention
- **Medium** 🟠 - Important security issues
- **Low** 🟡 - Minor security concerns
- **Informational** 🔵 - General observations

### Common Vulnerabilities Tested:
- ✅ SQL Injection
- ✅ Cross-Site Scripting (XSS)
- ✅ Cross-Site Request Forgery (CSRF)
- ✅ Security Headers (CSP, HSTS, X-Frame-Options)
- ✅ Cookie Security
- ✅ SSL/TLS Configuration
- ✅ Authentication and Session Management
- ✅ Information Disclosure
- ✅ Server Configuration Issues

---

## 📸 Screenshots for Demonstration

### Screenshot 1: OWASP ZAP Running
```bash
docker ps | grep zap
# Show container running
```

### Screenshot 2: Spider Scan Progress
```bash
curl "http://localhost:8080/JSON/spider/view/status/"
# Show JSON output with status
```

### Screenshot 3: Active Scan Results
```bash
curl "http://localhost:8080/JSON/core/view/alerts/" | head -50
# Show alerts in JSON format
```

### Screenshot 4: HTML Report
Open `owasp-zap-security-report.html` in browser and take screenshots of:
- Summary section showing vulnerability counts
- Detailed findings for each vulnerability
- Recommendations

---

## 🎨 Alternative: Quick Baseline Scan

For a quick demonstration:

```bash
# Run ZAP baseline scan (2-3 minutes)
docker run -v $(pwd):/zap/wrk:rw \
  -t zaproxy/zap-stable:latest \
  zap-baseline.py \
  -t http://app-capstone-ui-dev-ari999.azurewebsites.net \
  -r owasp-zap-baseline-report.html \
  -J owasp-zap-baseline-report.json

# Report will be saved in current directory
```

---

## ✅ Scan Multiple Targets

Scan all your endpoints:

```bash
# Scan Frontend
./run-owasp-scan.sh http://app-capstone-ui-dev-ari999.azurewebsites.net

# Scan APIM Gateway
./run-owasp-scan.sh https://apim-capstone-dev-ari999.azure-api.net

# Scan Backend A (direct)
./run-owasp-scan.sh http://132.196.250.187:8080
```

---

## 📝 Report Locations

After running scans, you'll have:

1. **HTML Report**: `owasp-zap-security-report.html` (for presentations)
2. **JSON Report**: `owasp-zap-report.json` (for automation)
3. **XML Report**: `owasp-zap-report.xml` (for CI/CD integration)
4. **Markdown Report**: `owasp-zap-report.md` (for documentation)

---

## 🔗 Resources

- **OWASP ZAP Documentation**: https://www.zaproxy.org/docs/
- **API Documentation**: https://www.zaproxy.org/docs/api/
- **Docker Hub**: https://hub.docker.com/r/zaproxy/zap-stable

---

**OWASP ZAP Security Scanning: READY ✅**
**Target URLs Configured ✅**
**Report Generation Scripts: READY ✅**

**Date**: January 11, 2026
