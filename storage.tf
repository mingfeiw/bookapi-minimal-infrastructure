resource "azurerm_storage_account" "bookapi_sa" {
  name                          = "stbookapiminimal"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = true

  blob_properties {
    # Enable soft delete for blobs
    delete_retention_policy {
      days = 30
    }

    # Enable versioning (recommended with soft delete)
    versioning_enabled = true

    # Enable change feed (recommended for monitoring)
    change_feed_enabled = true
  }

  # Enable soft delete for containers
  container_delete_retention_policy {
    days = 30
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "bookapi-container"
  storage_account_id    = azurerm_storage_account.bookapi_sa.id
  container_access_type = "private"
}