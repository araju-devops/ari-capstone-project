# Update APIM Operations with correct backend URLs

$subscriptionId = "606e824b-aaf7-4b4e-9057-b459f6a4436d"
$resourceGroup = "ari-rg-capstone-dev"
$apimName = "apim-capstone-dev-ari999"
$apiId = "backends"

# Backend URLs
$backendAUrl = "http://132.196.250.187:8080"
$backendBUrl = "http://68.220.237.26:8080"

Write-Host "Updating APIM API operations with correct backend URLs..."

# Update API service URL
az rest --method patch `
    --uri "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.ApiManagement/service/$apimName/apis/$apiId?api-version=2021-08-01" `
    --body "{\"properties\":{\"serviceUrl\":\"$backendAUrl\"}}"

Write-Host "Updated API service URL to $backendAUrl"
Write-Host "Please also update CORS policy in Azure Portal as described in fix-apim-backend-urls.md"
