# This file defines HOW to build infrastructure.

# ADDED DEFAULTS: Prevents crashes if the pipeline doesn't pass these in.
variable "environment" { default = "dev" }
variable "location"    { default = "eastus2" }
variable "unique_id"   { default = "ari999" } # CHANGED: "ari999" to fix APIM conflict

variable "docker_image_name" {
  description = "The docker image (Unused now that we switched to Node)"
  default     = "nginx:latest"
}

# 1. Resource Group (FIXED: Forced to East US 2 due to PostgreSQL quota restrictions in East US)
resource "azurerm_resource_group" "rg" {
  name     = "ari-rg-capstone-${var.environment}"
  location = "eastus2"  # Changed from eastus due to PostgreSQL Flexible Server restrictions
}

# 2. Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acrcapstone${var.unique_id}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# 3. AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-capstone-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-${var.environment}-${var.unique_id}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

# 4. App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = "plan-capstone-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# 5. App Service / Frontend
resource "azurerm_linux_web_app" "webapp" {
  name                = "app-capstone-ui-${var.environment}-${var.unique_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = true

    # Docker container configuration
    application_stack {
      docker_image_name   = var.docker_image_name
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITES_PORT"                       = "8080"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.acr.admin_password
  }
}

# ---------------------------------------------------------
# NEW: DATABASE & APIM
# ---------------------------------------------------------

# 6. Random Password for Database
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 7. PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "psql-capstone-${var.environment}-${var.unique_id}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location # Now guaranteed to be eastus2
  version                = "13"
  sku_name               = "B_Standard_B1ms" # Cheapest tier
  administrator_login    = "psqladmin"
  administrator_password = random_password.db_password.result
  storage_mb             = 32768

  # REMOVED: zone = "1"
  # letting Azure decide the placement fixes the availability error

  lifecycle {
    ignore_changes = [
      zone,  # Ignore zone changes to prevent errors when Azure assigns zones
    ]
  }
}

# 8. Database inside the Server
resource "azurerm_postgresql_flexible_server_database" "capstone_db" {
  name      = "capstone_db"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# 9. Firewall Rule (Allow Azure Services)
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name             = "allow-azure-access"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# 10. API Management (Consumption Tier)
resource "azurerm_api_management" "apim" {
  name                = "apim-capstone-${var.environment}-${var.unique_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = "Capstone Admin"
  publisher_email     = "admin@capstone.com"
  sku_name            = "Consumption_0" # Serverless (Fast Deploy)
}