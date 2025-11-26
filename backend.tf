terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate[UNIQUE_SUFFIX]"
    container_name       = "tfstate"
    key                  = "bookapi-minimal.tfstate"
  }
}