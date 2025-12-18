# This file defines HOW to build infrastructure, but acts as a template.

variable "environment" {}
variable "location" {}
variable "unique_id" {}
variable "docker_image_name" {
  description = "The docker image to deploy to the app service"
  default     = "nginx:latest"
}

# 1. Resource Group (Dynamic Name - Matches your AKS location)
resource "azurerm_resource_group" "rg" {
  name     = "ari-rg-capstone-${var.environment}"
  location = var.location
}

# 2. Azure Container Registry (REQUIRED for your images)
resource "azurerm_container_registry" "acr" {
  name                = "acrcapstone${var.unique_id}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# 3. AKS Cluster (Keeps using the RG location - North Central US)
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

# 4. App Service Plan (FORCED TO EAST US to bypass quota)
resource "azurerm_service_plan" "plan" {
  name                = "plan-capstone-${var.environment}"
  location            = "East US"      # <--- HARDCODED: Moves App Service to East US
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"           # Free Tier
}

# 5. App Service / Frontend (FORCED TO EAST US)
resource "azurerm_linux_web_app" "webapp" {
  name                = "app-capstone-ui-${var.environment}-${var.unique_id}"
  location            = "East US"      # <--- HARDCODED: Must match the Plan above
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = true                  # <--- REQUIRED for Free Tier
    
    application_stack {
      # Uses the variable passed from environments/dev/main.tf
      docker_image_name = var.docker_image_name
    }
  }
}