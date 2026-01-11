#!/bin/bash

# Grafana Dashboard Import Script
# Imports pre-configured dashboards into Grafana

GRAFANA_URL="http://135.222.184.27"
GRAFANA_USER="admin"
GRAFANA_PASS="t1pQH81OU0CbvSPwwB2KFwyZpvSW9Gss8CtPYaAU"

echo "================================================"
echo "Grafana Dashboard Import Script"
echo "================================================"
echo ""

# Function to import dashboard from file
import_dashboard() {
    local file=$1
    local name=$(basename $file .json)

    echo "Importing: $name"

    response=$(curl -s -X POST "${GRAFANA_URL}/api/dashboards/import" \
        -H "Content-Type: application/json" \
        -u "${GRAFANA_USER}:${GRAFANA_PASS}" \
        -d @"$file")

    if echo "$response" | grep -q "imported.*true"; then
        uid=$(echo "$response" | grep -o '"uid":"[^"]*"' | cut -d'"' -f4)
        echo "✅ Success! Dashboard UID: $uid"
        echo "   URL: ${GRAFANA_URL}/d/$uid"
    else
        echo "❌ Failed to import $name"
        echo "   Response: $response"
    fi
    echo ""
}

# Check if Grafana is accessible
echo "Checking Grafana connection..."
if ! curl -s -f "${GRAFANA_URL}/api/health" > /dev/null; then
    echo "❌ Error: Cannot connect to Grafana at ${GRAFANA_URL}"
    exit 1
fi
echo "✅ Grafana is accessible"
echo ""

# Import all dashboards from the grafana-dashboards directory
if [ -d "grafana-dashboards" ]; then
    echo "Importing dashboards from grafana-dashboards/..."
    echo ""

    for dashboard in grafana-dashboards/*.json; do
        if [ -f "$dashboard" ]; then
            import_dashboard "$dashboard"
        fi
    done
else
    echo "❌ grafana-dashboards directory not found"
    exit 1
fi

echo "================================================"
echo "Import Complete!"
echo "================================================"
echo ""
echo "Access your dashboards at:"
echo "${GRAFANA_URL}/dashboards"
echo ""
echo "Login credentials:"
echo "Username: ${GRAFANA_USER}"
echo "Password: ${GRAFANA_PASS}"
