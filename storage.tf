resource "azurerm_storage_account" "bookapi_sa" {
  name                     = "stbookapiminimal"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    delete_retention_policy {
      days = 14
    }
    container_delete_retention_policy {
      days = 14
    }
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "bookapi-container"
  storage_account_name  = azurerm_storage_account.bookapi_sa.name
  container_access_type = "private"
}