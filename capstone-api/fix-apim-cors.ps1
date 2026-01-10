# PowerShell script to add CORS policy to APIM
$resourceGroup = "ari-rg-capstone-dev"
$apimName = "apim-capstone-dev-ari999"
$apiId = "backends"

# CORS Policy XML
$corsPolicy = @"
<policies>
    <inbound>
        <base />
        <cors allow-credentials="true">
            <allowed-origins>
                <origin>http://app-capstone-ui-dev-ari999.azurewebsites.net</origin>
                <origin>https://app-capstone-ui-dev-ari999.azurewebsites.net</origin>
            </allowed-origins>
            <allowed-methods preflight-result-max-age="300">
                <method>GET</method>
                <method>POST</method>
                <method>PUT</method>
                <method>DELETE</method>
                <method>OPTIONS</method>
                <method>HEAD</method>
            </allowed-methods>
            <allowed-headers>
                <header>*</header>
            </allowed-headers>
            <expose-headers>
                <header>*</header>
            </expose-headers>
        </cors>
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
</policies>
"@

Write-Host "Adding CORS policy to APIM API: $apiId"

# Get the API Management context
$apimContext = New-AzApiManagementContext -ResourceGroupName $resourceGroup -ServiceName $apimName

# Set the API policy
Set-AzApiManagementPolicy -Context $apimContext -ApiId $apiId -Policy $corsPolicy

Write-Host "CORS policy added successfully!"
