provider "azurerm" {
  features {}
  subscription_id = "606e824b-aaf7-4b4e-9057-b459f6a4436d"
}

module "prod_infra" {
  source      = "../../modules/infra"
  environment = "prod"
  location    = "East US"
  unique_id   = "ari999"
}