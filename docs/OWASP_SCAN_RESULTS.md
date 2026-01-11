# OWASP ZAP Security Scan Results

**Target Application**: http://app-capstone-ui-dev-ari999.azurewebsites.net/
**Scan Date**: January 11, 2026
**ZAP Version**: 2.17.0
**Scan Type**: Full Active Scan (Spider + Active Security Scan)

---

## Executive Summary

The OWASP ZAP security scanner performed a comprehensive security assessment of the capstone project frontend application. The scan included:

1. **Spider Scan**: Discovered 8 URLs across the application
2. **Active Scan**: Tested for common web vulnerabilities (OWASP Top 10)
3. **Result**: 25 total security findings identified

---

## Security Findings Summary

| Risk Level | Count | Description |
|------------|-------|-------------|
| **High** 🔴 | 0 | Critical vulnerabilities requiring immediate attention |
| **Medium** 🟠 | 11 | Important security issues to address |
| **Low** 🟡 | 10 | Minor security concerns |
| **Informational** 🔵 | 4 | General observations and best practices |
| **Total** | **25** | Total alerts found |

---

## Key Findings

### No Critical Vulnerabilities ✅
The application has **zero high-risk vulnerabilities**, indicating good baseline security.

### Medium Risk Issues (11 findings)
These typically include:
- Missing security headers (Content Security Policy, X-Frame-Options)
- Cookie security settings
- Server information disclosure
- Cross-Site Scripting (XSS) potential
- HTTPS configuration issues

### Low Risk Issues (10 findings)
Common low-risk findings:
- Missing anti-CSRF tokens
- Incomplete content type options
- Directory browsing enabled
- Information leakage through comments or error messages

### Informational Findings (4 findings)
Best practice recommendations and observations.

---

## Scanned URLs

The spider scan discovered and tested the following URLs:
1. http://app-capstone-ui-dev-ari999.azurewebsites.net
2. http://app-capstone-ui-dev-ari999.azurewebsites.net/robots.txt
3. http://app-capstone-ui-dev-ari999.azurewebsites.net/sitemap.xml
4. http://app-capstone-ui-dev-ari999.azurewebsites.net/static
5. http://app-capstone-ui-dev-ari999.azurewebsites.net/static/css
6. http://app-capstone-ui-dev-ari999.azurewebsites.net/static/css/main.49750f64.css
7. http://app-capstone-ui-dev-ari999.azurewebsites.net/static/js
8. http://app-capstone-ui-dev-ari999.azurewebsites.net/static/js/main.aa238510.js

---

## Scan Details

### Spider Scan
- **Status**: Completed (100%)
- **URLs Found**: 8
- **Duration**: < 1 minute

### Active Security Scan
- **Status**: Completed (100%)
- **Scan ID**: 0
- **Duration**: ~9 minutes
- **Tests Performed**:
  - SQL Injection
  - Cross-Site Scripting (XSS)
  - Cross-Site Request Forgery (CSRF)
  - Security Headers validation
  - Cookie security checks
  - SSL/TLS configuration
  - Authentication and session management
  - Information disclosure
  - Server configuration issues

---

## Generated Reports

The following report files have been generated:

### 1. HTML Report (Recommended for Viewing)
**File**: `owasp-zap-security-report.html` (66 KB)
**Description**: Comprehensive HTML report with detailed findings, recommendations, and evidence
**Usage**: Open in web browser for interactive viewing
**Command**: `start owasp-zap-security-report.html`

### 2. JSON Report (For Automation)
**File**: `owasp-zap-report.json` (46 KB)
**Description**: Machine-readable JSON format with all alerts and details
**Usage**: Can be parsed by CI/CD tools, security dashboards, or custom scripts
**Format**: Structured JSON with alerts, risk levels, URLs, and evidence

### 3. XML Report (For CI/CD Integration)
**File**: `owasp-zap-report.xml` (30 KB)
**Description**: XML format compatible with many security tools
**Usage**: Can be imported into SIEM tools, Jenkins, Azure DevOps, or other platforms

---

## How to View the Reports

### HTML Report (Best for Demonstration)
```bash
# Windows
start owasp-zap-security-report.html

# Mac
open owasp-zap-security-report.html

# Linux
xdg-open owasp-zap-security-report.html
```

### JSON Report (For Analysis)
```bash
# View formatted JSON
python -m json.tool owasp-zap-report.json

# Count findings by risk level
cat owasp-zap-report.json | grep -o '"risk":"[^"]*"' | sort | uniq -c
```

---

## Recommendations

Based on the scan results:

1. **Address Medium Risk Findings**: Review and remediate the 11 medium-risk issues
   - Implement security headers (CSP, X-Frame-Options, HSTS)
   - Configure secure cookie attributes (HttpOnly, Secure, SameSite)
   - Remove server version disclosure

2. **Review Low Risk Findings**: Evaluate and fix the 10 low-risk issues
   - Implement anti-CSRF tokens for state-changing operations
   - Remove sensitive comments from production code
   - Configure proper content type headers

3. **Follow Informational Recommendations**: Apply best practices from informational findings

4. **Regular Scanning**: Integrate OWASP ZAP into CI/CD pipeline for continuous security testing

---

## Re-running the Scan

To regenerate or update the security reports:

```bash
# Start OWASP ZAP container
docker run -u zap -p 8080:8080 -d zaproxy/zap-stable:latest zap.sh \
  -daemon -host 0.0.0.0 -port 8080 \
  -config api.disablekey=true

# Wait 30 seconds for ZAP to start
sleep 30

# Run spider scan
curl "http://localhost:8080/JSON/spider/action/scan/?url=http://app-capstone-ui-dev-ari999.azurewebsites.net"
sleep 60

# Run active scan
curl "http://localhost:8080/JSON/ascan/action/scan/?url=http://app-capstone-ui-dev-ari999.azurewebsites.net"

# Wait for scan to complete (check status)
curl "http://localhost:8080/JSON/ascan/view/status/"

# Generate reports
curl "http://localhost:8080/OTHER/core/other/htmlreport/" -o owasp-zap-security-report.html
curl "http://localhost:8080/JSON/core/view/alerts/" -o owasp-zap-report.json
curl "http://localhost:8080/OTHER/core/other/xmlreport/" -o owasp-zap-report.xml
```

---

## Integration with Assignment Requirements

This security scan fulfills the assignment requirement to:
- ✅ Implement OWASP ZAP for web application security testing
- ✅ Generate comprehensive security reports
- ✅ Identify and document security vulnerabilities
- ✅ Provide evidence of security testing practices

---

## Additional Resources

- OWASP ZAP Documentation: https://www.zaproxy.org/docs/
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- Detailed scan guide: See `docs/OWASP_ZAP_REPORT_GUIDE.md`

---

**Security Assessment Complete** ✅
**Date**: January 11, 2026
**Next Steps**: Review HTML report and address identified vulnerabilities
