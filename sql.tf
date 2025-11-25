data "azurerm_key_vault" "kv" {
  name                = "kv-bookapi"
  resource_group_name = "rg-bookapi-minimal"
}

data "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_mssql_server" "main" {
  name                         = "bookapisqlserver${random_integer.suffix.result}"
  resource_group_name          = "rg-bookapi-minimal"
  location                     = "uksouth"
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = data.azurerm_key_vault_secret.sql_admin_password.value

  # Security settings
  public_network_access_enabled = true
  minimum_tls_version           = "1.2"

  tags = {
    Environment = "dev"
    Project     = "bookapi"
  }
}

resource "azurerm_mssql_database" "main" {
  name           = "bookapidb"
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "Basic"
  zone_redundant = false

  tags = {
    Environment = "dev"
    Project     = "bookapi"
  }
}

# Firewall rule to allow Azure services
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Firewall rule for your development environment (optional - remove if not needed)
resource "azurerm_mssql_firewall_rule" "dev_access" {
  name             = "AllowDevelopmentAccess"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}