output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "app_gateway_public_ip" {
  value       = azurerm_public_ip.appgw_pip.ip_address
  description = "Access your app via this IP from anywhere"
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

# SQL Server outputs
output "sql_server_name" {
  value       = azurerm_mssql_server.main.name
  description = "SQL Server name"
}

output "sql_server_fqdn" {
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
  description = "SQL Server fully qualified domain name"
}

output "sql_database_name" {
  value       = azurerm_mssql_database.main.name
  description = "SQL Database name"
}

output "sql_admin_username" {
  value       = azurerm_mssql_server.main.administrator_login
  description = "SQL Server admin username"
}

# Note: Password is stored in Key Vault secret 'sql-admin-password'
output "sql_connection_string_template" {
  value       = "Server=${azurerm_mssql_server.main.fully_qualified_domain_name};Database=${azurerm_mssql_database.main.name};User ID=${azurerm_mssql_server.main.administrator_login};Password=<from_key_vault>;Encrypt=True;TrustServerCertificate=False;"
  description = "SQL Connection string template (password from Key Vault)"
}