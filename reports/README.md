# Security and Quality Reports

This directory contains generated security scan and quality assurance reports.

## Contents

### OWASP ZAP Security Reports

Generated on: January 11, 2026

1. **owasp-zap-security-report.html** (67 KB)
   - Comprehensive HTML report with detailed findings
   - Open in browser for interactive viewing
   - **Security Findings**: 0 High, 11 Medium, 10 Low, 4 Informational

2. **owasp-zap-report.json** (46 KB)
   - Machine-readable JSON format
   - For automation and CI/CD integration

3. **owasp-zap-report.xml** (30 KB)
   - XML format for SIEM tools and security platforms

## How to View Reports

### HTML Report (Recommended)
```bash
# Windows
start reports/owasp-zap-security-report.html

# Mac
open reports/owasp-zap-security-report.html

# Linux
xdg-open reports/owasp-zap-security-report.html
```

### JSON Report
```bash
cat reports/owasp-zap-report.json | python -m json.tool
```

### XML Report
```bash
cat reports/owasp-zap-report.xml
```

## Report Summary

**Target**: http://app-capstone-ui-dev-ari999.azurewebsites.net/
**Scan Type**: Full Active Scan (Spider + Active Security Testing)
**URLs Scanned**: 8

### Security Findings

| Risk Level | Count |
|------------|-------|
| High       | 0     |
| Medium     | 11    |
| Low        | 10    |
| Info       | 4     |
| **Total**  | **25** |

### Key Results

✅ No critical vulnerabilities
✅ Good baseline security
✅ All findings documented

## Documentation

For detailed information about:
- OWASP scan results: See [../docs/OWASP_SCAN_RESULTS.md](../docs/OWASP_SCAN_RESULTS.md)
- How to generate reports: See [../docs/OWASP_ZAP_REPORT_GUIDE.md](../docs/OWASP_ZAP_REPORT_GUIDE.md)

## Note

These files are excluded from SonarQube analysis as they are generated reports, not source code.

See `.sonarignore` and `sonar-project.properties` for exclusion configuration.
