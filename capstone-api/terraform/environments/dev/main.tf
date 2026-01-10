terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      # FIX: This allows Terraform to delete the broken resource group
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "606e824b-aaf7-4b4e-9057-b459f6a4436d"
}

variable "docker_image_name" {
  description = "The docker image to deploy to the app service"
  default     = "nginx:latest"
}

module "dev_infra" {
  source            = "../../modules/infra"
  environment       = "dev"

  # FIX: Changed to East US 2 due to PostgreSQL quota restrictions
  location          = "eastus2"

  # FIX: Change ID to ari999 to avoid "Soft Delete" conflict
  unique_id         = "ari999"

  docker_image_name = var.docker_image_name
}

# Provider for Kubernetes (uses AKS credentials from infra module)
provider "kubernetes" {
  host                   = module.dev_infra.aks_host
  client_certificate     = base64decode(module.dev_infra.aks_client_certificate)
  client_key             = base64decode(module.dev_infra.aks_client_key)
  cluster_ca_certificate = base64decode(module.dev_infra.aks_cluster_ca_certificate)
}

# Provider for Helm (uses AKS credentials from infra module)
provider "helm" {
  kubernetes {
    host                   = module.dev_infra.aks_host
    client_certificate     = base64decode(module.dev_infra.aks_client_certificate)
    client_key             = base64decode(module.dev_infra.aks_client_key)
    cluster_ca_certificate = base64decode(module.dev_infra.aks_cluster_ca_certificate)
  }
}

# Deploy Kubernetes add-ons (ArgoCD, Monitoring, Security)
module "k8s_addons" {
  source = "../../modules/k8s-addons"

  aks_host                   = module.dev_infra.aks_host
  aks_client_certificate     = module.dev_infra.aks_client_certificate
  aks_client_key             = module.dev_infra.aks_client_key
  aks_cluster_ca_certificate = module.dev_infra.aks_cluster_ca_certificate
  environment                = "dev"

  depends_on = [module.dev_infra]
}