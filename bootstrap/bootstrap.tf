terraform {
  # No backend block - uses local state
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "backend_rg" {
  name     = "rg-bookapi-minimal"
  location = "uksouth"
}

resource "azurerm_storage_account" "backend_sa" {
  name                          = "stbookapiminimal"
  resource_group_name           = azurerm_resource_group.backend_rg.name
  location                      = azurerm_resource_group.backend_rg.location
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = true

  blob_properties {
    delete_retention_policy {
      days = 30
    }
    versioning_enabled  = true
    change_feed_enabled = true
  }
}

resource "azurerm_storage_container" "backend_container" {
  name                  = "bookapi-container"
  storage_account_name  = azurerm_storage_account.backend_sa.name
  container_access_type = "private"
}
