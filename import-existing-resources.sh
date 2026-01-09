#!/bin/bash
# Import existing Azure resources into Terraform state

cd terraform/environments/dev

# Import resource group
terraform import module.dev_infra.azurerm_resource_group.rg \
  /subscriptions/606e824b-aaf7-4b4e-9057-b459f6a4436d/resourceGroups/ari-rg-capstone-dev

# Import ACR
terraform import module.dev_infra.azurerm_container_registry.acr \
  /subscriptions/606e824b-aaf7-4b4e-9057-b459f6a4436d/resourceGroups/ari-rg-capstone-dev/providers/Microsoft.ContainerRegistry/registries/acrcapstoneari999

# Import AKS
terraform import module.dev_infra.azurerm_kubernetes_cluster.aks \
  /subscriptions/606e824b-aaf7-4b4e-9057-b459f6a4436d/resourceGroups/ari-rg-capstone-dev/providers/Microsoft.ContainerService/managedClusters/aks-capstone-dev

# Import App Service Plan
terraform import module.dev_infra.azurerm_service_plan.plan \
  /subscriptions/606e824b-aaf7-4b4e-9057-b459f6a4436d/resourceGroups/ari-rg-capstone-dev/providers/Microsoft.Web/serverFarms/plan-capstone-dev

# Import App Service
terraform import module.dev_infra.azurerm_linux_web_app.app \
  /subscriptions/606e824b-aaf7-4b4e-9057-b459f6a4436d/resourceGroups/ari-rg-capstone-dev/providers/Microsoft.Web/sites/app-capstone-ui-dev-ari999

# Import PostgreSQL Server
terraform import module.dev_infra.azurerm_postgresql_flexible_server.postgres \
  /subscriptions/606e824b-aaf7-4b4e-9057-b459f6a4436d/resourceGroups/ari-rg-capstone-dev/providers/Microsoft.DBforPostgreSQL/flexibleServers/psql-capstone-dev-ari999

# Import PostgreSQL Database
terraform import module.dev_infra.azurerm_postgresql_flexible_server_database.db \
  /subscriptions/606e824b-aaf7-4b4e-9057-b459f6a4436d/resourceGroups/ari-rg-capstone-dev/providers/Microsoft.DBforPostgreSQL/flexibleServers/psql-capstone-dev-ari999/databases/capstonedb

# Import APIM
terraform import module.dev_infra.azurerm_api_management.apim \
  /subscriptions/606e824b-aaf7-4b4e-9057-b459f6a4436d/resourceGroups/ari-rg-capstone-dev/providers/Microsoft.ApiManagement/service/apim-capstone-dev-ari999

echo "Import complete! Run 'terraform plan' to verify."
