provider "azurerm" {
  features {}
}

variable "unique_id" {
  default = "ari123" # Keep this consistent
}

# 1. Resource Group (Must match your LIVE cluster in North Central US)
resource "azurerm_resource_group" "rg" {
  name     = "ari-rg-capstone-dev"
  location = "North Central US"    
}

# 2. Azure Container Registry (Required for your images)
resource "azurerm_container_registry" "acr" {
  name                = "acrcapstone${var.unique_id}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# 3. AKS Cluster (Already exists in North Central US)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-capstone-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-capstone-dev"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"  # <--- Corrected size
  }

  identity {
    type = "SystemAssigned"
  }
}

# 4. App Service Plan (Forced to East US for Quota reasons)
resource "azurerm_service_plan" "plan" {
  name                = "plan-capstone-dev"
  location            = "East US"         # <--- FORCED TO EAST US
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"              # Free Tier
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "app-capstone-ui-dev-${var.unique_id}"
  location            = "East US"         # <--- FORCED TO EAST US
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = false                     # <--- REQUIRED for Free Tier
    
    application_stack {
      # This placeholder will be updated when you deploy your real image
      docker_image_name = "nginx:latest" 
    }
  }
}