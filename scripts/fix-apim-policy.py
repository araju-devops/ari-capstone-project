#!/usr/bin/env python3
"""
Script to update Azure API Management policy with correct backend routing.

This script configures APIM to route requests to Backend A or Backend B
based on the URL path.
"""

import json
import subprocess
import sys
from pathlib import Path

# Azure resource configuration
SUBSCRIPTION_ID = '606e824b-aaf7-4b4e-9057-b459f6a4436d'
RESOURCE_GROUP = 'ari-rg-capstone-dev'
APIM_NAME = 'apim-capstone-dev-ari999'
API_ID = 'backends'
API_VERSION = '2021-08-01'

# Backend service URLs
BACKEND_A_URL = 'http://132.196.250.187:8080'
BACKEND_B_URL = 'http://68.220.237.26:8080'

# Frontend origins for CORS
FRONTEND_HTTP = 'http://app-capstone-ui-dev-ari999.azurewebsites.net'
FRONTEND_HTTPS = 'https://app-capstone-ui-dev-ari999.azurewebsites.net'


def get_policy_xml():
    """
    Generate the APIM policy XML for backend routing.

    Returns:
        str: XML policy configuration
    """
    return f'''<policies>
    <inbound>
        <base />
        <cors allow-credentials="true">
            <allowed-origins>
                <origin>{FRONTEND_HTTP}</origin>
                <origin>{FRONTEND_HTTPS}</origin>
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
                <set-backend-service base-url="{BACKEND_A_URL}" />
                <rewrite-uri template="/api/a" />
            </when>
            <when condition="@(context.Request.Url.Path.Contains(&quot;/B:&quot;))">
                <set-backend-service base-url="{BACKEND_B_URL}" />
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
</policies>'''


def create_policy_payload(policy_xml):
    """
    Create the JSON payload for the APIM policy update.

    Args:
        policy_xml (str): The XML policy configuration

    Returns:
        dict: JSON payload for Azure REST API
    """
    return {
        'properties': {
            'format': 'rawxml',
            'value': policy_xml
        }
    }


def get_api_uri():
    """
    Construct the Azure REST API URI for policy update.

    Returns:
        str: Complete API URI
    """
    return (
        f'/subscriptions/{SUBSCRIPTION_ID}'
        f'/resourceGroups/{RESOURCE_GROUP}'
        f'/providers/Microsoft.ApiManagement/service/{APIM_NAME}'
        f'/apis/{API_ID}/policies/policy'
        f'?api-version={API_VERSION}'
    )


def write_payload_file(payload, file_path):
    """
    Write the policy payload to a JSON file.

    Args:
        payload (dict): The JSON payload
        file_path (Path): Path to write the file

    Raises:
        IOError: If file write fails
    """
    try:
        with open(file_path, 'w', encoding='utf-8') as file:
            json.dump(payload, file, indent=2)
    except IOError as err:
        print(f'Error writing payload file: {err}', file=sys.stderr)
        raise


def execute_az_command(uri, payload_file):
    """
    Execute the Azure CLI command to update the policy.

    Args:
        uri (str): The API URI
        payload_file (Path): Path to the payload JSON file

    Returns:
        subprocess.CompletedProcess: Result of the command execution
    """
    cmd = [
        'az', 'rest',
        '--method', 'put',
        '--uri', uri,
        '--body', f'@{payload_file}'
    ]

    print(f'Executing command: {" ".join(cmd)}')

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=False  # Don't raise exception on non-zero exit
        )
        return result
    except FileNotFoundError:
        print('Error: Azure CLI (az) not found. Please install Azure CLI.', file=sys.stderr)
        sys.exit(1)


def main():
    """Main execution function."""
    print('=== Azure APIM Policy Update ===\n')

    # Generate policy
    policy_xml = get_policy_xml()
    policy_payload = create_policy_payload(policy_xml)

    # Get API URI
    uri = get_api_uri()
    print(f'Target URI: {uri}\n')

    # Write payload to file
    payload_file = Path('policy-payload.json')
    try:
        write_payload_file(policy_payload, payload_file)
        print(f'Payload written to: {payload_file}\n')
    except IOError:
        sys.exit(1)

    # Execute Azure CLI command
    result = execute_az_command(uri, payload_file)

    # Display results
    print('\n--- Output ---')
    if result.stdout:
        print(result.stdout)

    if result.stderr:
        print('\n--- Errors ---')
        print(result.stderr)

    # Check result
    print(f'\nExit code: {result.returncode}')

    if result.returncode == 0:
        print('\n✅ Policy updated successfully!')
        return 0

    print('\n❌ Failed to update policy')
    return 1


if __name__ == '__main__':
    sys.exit(main())
