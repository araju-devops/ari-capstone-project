terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

variable "unique_id" {
  default = "ari123" 
}

# 2. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "ari-rg-capstone-dev"
  location = "East US"    
}

# 3. Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acrcapstone${var.unique_id}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# 4. AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-capstone-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-capstone-dev"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s" 
  }

  identity {
    type = "SystemAssigned"
  }
}

# 5. App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = "plan-capstone-dev"
  location            = "East US"        
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"             
}

# 6. Web App (UPDATED FOR DOCKER)
resource "azurerm_linux_web_app" "webapp" {
  name                = "app-capstone-ui-dev-${var.unique_id}"
  location            = "East US" 
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = false 
    
    application_stack {
      # Points to the Docker image in your ACR
      docker_image_name        = "${azurerm_container_registry.acr.login_server}/frontend:latest"
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }
}