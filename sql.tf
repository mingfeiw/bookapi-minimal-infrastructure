# Generate a secure random password for SQL admin
resource "random_password" "sql_admin_password" {
  length      = 16
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  min_special = 2
  special     = true
}

# Store the SQL admin password in Key Vault
resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  value        = random_password.sql_admin_password.result
  key_vault_id = azurerm_key_vault.bookapi_kv.id

  depends_on = [azurerm_key_vault.bookapi_kv]

  tags = {
    Environment = "dev"
    Project     = "bookapi"
  }
}

# Store the full database connection string in Key Vault
resource "azurerm_key_vault_secret" "db_connection_string" {
  name         = "DbConnectionString"
  value        = "Server=${azurerm_mssql_server.main.fully_qualified_domain_name};Database=${azurerm_mssql_database.main.name};User ID=${azurerm_mssql_server.main.administrator_login};Password=${random_password.sql_admin_password.result};Encrypt=True;TrustServerCertificate=False;"
  key_vault_id = azurerm_key_vault.bookapi_kv.id

  depends_on = [azurerm_key_vault.bookapi_kv, azurerm_mssql_server.main, azurerm_mssql_database.main]

  tags = {
    Environment = "dev"
    Project     = "bookapi"
  }
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_mssql_server" "main" {
  name                         = "bookapisqlserver${random_integer.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = random_password.sql_admin_password.result

  # Security settings
  public_network_access_enabled = true
  minimum_tls_version           = "1.2"

  tags = {
    Environment = "dev"
    Project     = "bookapi"
  }
}

# Enable auditing on SQL Server
resource "azurerm_mssql_server_extended_auditing_policy" "main" {
  server_id                               = azurerm_mssql_server.main.id
  storage_endpoint                        = azurerm_storage_account.bookapi_sa.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.bookapi_sa.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 90

  # Audit specific events
  log_monitoring_enabled = true

  depends_on = [
    azurerm_storage_account.bookapi_sa
  ]
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

# Simple firewall rule - allow all access for development and CI/CD
resource "azurerm_mssql_firewall_rule" "allow_all" {
  name             = "AllowAllAccess"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}