provider "azurerm" {
  features {}
  subscription_id = "606e824b-aaf7-4b4e-9057-b459f6a4436d"
}

variable "docker_image_name" {
  description = "The docker image to deploy to the app service"
  default     = "nginx:latest"
}

module "dev_infra" {
  source            = "../../modules/infra"
  environment       = "dev"
  location          = "North Central US"
  unique_id         = "ari123"
  
  # Pass the variable from command line -> to the module
  docker_image_name = var.docker_image_name
}