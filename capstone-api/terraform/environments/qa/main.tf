provider "azurerm" {
  features {}
  subscription_id = "606e824b-aaf7-4b4e-9057-b459f6a4436d"
}

module "qa_infra" {
  source      = "../../modules/infra"
  environment = "qa"
  location    = "North Central US"
  unique_id   = "ari123" # Keep this the same as dev to keep naming consistent
}