terraform {
  backend "azurerm" {
    resource_group_name  = "rg-bookapi-minimal"
    storage_account_name = "stbookapiminimal"
    container_name       = "acrbookapi"
    key                  = "terraform.tfstate"
  }
}