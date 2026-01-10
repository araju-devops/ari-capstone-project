# Fix APIM Backend URLs

## Problem
APIM is returning 500 errors because it's not correctly routing to the backend services.

## Backend Information
- **Backend A Service**: http://132.196.250.187:8080
- **Backend A Endpoint**: `/api/a`
- **Backend B Service**: http://68.220.237.26:8080
- **Backend B Endpoint**: `/api/b`

## Solution: Update APIM Operations in Azure Portal

### Step 1: Navigate to APIM
1. Go to Azure Portal
2. Navigate to `apim-capstone-dev-ari999`
3. Go to **APIs** → **Backends** API

### Step 2: Update "Upload to A" Operation
1. Click on **"POST Upload to A"** operation
2. Go to the **"Backend"** section
3. Click **"Pencil icon"** to edit
4. Set:
   - **HTTP(s) endpoint**: `http://132.196.250.187:8080/api/a`
   - Or use **Service URL**: `http://132.196.250.187:8080` and keep URL template as `/A:/`

5. In the **Inbound processing** section, add a rewrite policy:
```xml
<inbound>
    <base />
    <rewrite-uri template="/api/a" />
</inbound>
```

### Step 3: Update "Upload to B" Operation
1. Click on **"POST Upload to B"** operation
2. Go to the **"Backend"** section
3. Click **"Pencil icon"** to edit
4. Set:
   - **HTTP(s) endpoint**: `http://68.220.237.26:8080/api/b`
   - Or use **Service URL**: `http://68.220.237.26:8080` and keep URL template as `/B:/`

5. In the **Inbound processing** section, add a rewrite policy:
```xml
<inbound>
    <base />
    <rewrite-uri template="/api/b" />
</inbound>
```

### Step 4: Add CORS Policy (if not already done)
At the API level (All operations):
```xml
<inbound>
    <cors allow-credentials="true">
        <allowed-origins>
            <origin>http://app-capstone-ui-dev-ari999.azurewebsites.net</origin>
            <origin>https://app-capstone-ui-dev-ari999.azurewebsites.net</origin>
        </allowed-origins>
        <allowed-methods preflight-result-max-age="300">
            <method>GET</method>
            <method>POST</method>
            <method>OPTIONS</method>
        </allowed-methods>
        <allowed-headers>
            <header>*</header>
        </allowed-headers>
    </cors>
</inbound>
```

### Step 5: Test
After saving, test the API by uploading an image from the frontend UI.

## Alternative: Use Azure CLI (if automated approach needed)

The operations are:
- Operation A ID: `20d604c96b2d42c99054fb65b5455735`
- Operation B ID: `168774d5ca514be6b655508bb23e1e57`

You would need to use `az rest` commands to update the operation policies with the correct backend URLs.
