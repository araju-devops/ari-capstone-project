provider "azurerm" {
  features {}
  subscription_id = "606e824b-aaf7-4b4e-9057-b459f6a4436d"
}

module "qa_infra" {
  source      = "../../modules/infra"
  environment = "qa"
  location    = "East US"
  unique_id   = "ari999" # Keep this the same as dev to keep naming consistent
}