resource "azurerm_storage_account" "bookapi_sa" {
  name                          = "stbookapiminimal"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = true

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]

    # Allow access from VNet subnets
    virtual_network_subnet_ids = [
      azurerm_subnet.aks_subnet.id,
      azurerm_subnet.appgw_subnet.id
    ]

    # Allow access from your public IP and GitHub Actions
    ip_rules = [
      "87.113.24.110", # Your current public IP
      "4.175.0.0/16",  # GitHub Actions IP range
      "13.64.0.0/16",  # GitHub Actions IP range
      "20.0.0.0/8",    # GitHub Actions IP range
      "40.0.0.0/8",    # GitHub Actions IP range
      "52.0.0.0/8",    # GitHub Actions IP range
      "104.0.0.0/8"    # GitHub Actions IP range
    ]
  }

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
  storage_account_id    = azurerm_storage_account.bookapi_sa.id
  container_access_type = "private"
}