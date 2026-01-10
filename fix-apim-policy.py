#!/usr/bin/env python3
"""
Script to update APIM policy with correct backend routing
"""
import subprocess
import json

subscription_id = "606e824b-aaf7-4b4e-9057-b459f6a4436d"
resource_group = "ari-rg-capstone-dev"
apim_name = "apim-capstone-dev-ari999"
api_id = "backends"

# The policy XML that routes to both backends
policy_xml = """<policies>
    <inbound>
        <base />
        <cors allow-credentials="true">
            <allowed-origins>
                <origin>http://app-capstone-ui-dev-ari999.azurewebsites.net</origin>
                <origin>https://app-capstone-ui-dev-ari999.azurewebsites.net</origin>
            </allowed-origins>
            <allowed-methods preflight-result-max-age="300">
                <method>*</method>
            </allowed-methods>
            <allowed-headers>
                <header>*</header>
            </allowed-headers>
        </cors>
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
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>"""

# Escape the policy XML for JSON
policy_json = {
    "properties": {
        "format": "rawxml",
        "value": policy_xml
    }
}

uri = f"/subscriptions/{subscription_id}/resourceGroups/{resource_group}/providers/Microsoft.ApiManagement/service/{apim_name}/apis/{api_id}/policies/policy?api-version=2021-08-01"

print("Updating APIM policy...")
print(f"URI: {uri}")

# Write JSON to file
with open("C:/Users/Araju/Documents/GitHub/ari-capstone-project/policy-payload.json", "w", encoding="utf-8") as f:
    json.dump(policy_json, f, indent=2)

# Execute az rest command
cmd = [
    "az", "rest",
    "--method", "put",
    "--uri", uri,
    "--body", "@C:/Users/Araju/Documents/GitHub/ari-capstone-project/policy-payload.json"
]

print(f"Running: {' '.join(cmd)}")
result = subprocess.run(cmd, capture_output=True, text=True)

print("\nSTDOUT:")
print(result.stdout)

if result.stderr:
    print("\nSTDERR:")
    print(result.stderr)

print(f"\nReturn code: {result.returncode}")

if result.returncode == 0:
    print("\n✅ Policy updated successfully!")
else:
    print("\n❌ Failed to update policy")
