resource "azurerm_key_vault" "bookapi_kv" {
  name                       = "kv-bookapi"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  # Network access configuration - disable firewall
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  # Access policy for tti_mingfei_poc service principal
  access_policy {
    tenant_id               = data.azurerm_client_config.current.tenant_id
    object_id               = data.azuread_service_principal.tti_mingfei_poc.object_id
    key_permissions         = var.kv_key_permissions_full
    secret_permissions      = var.kv_secret_permissions_full
    certificate_permissions = var.kv_certificate_permissions_full
  }

  # Access policy for current authenticated user - Key, Secret & Certificate Management
  access_policy {
    tenant_id               = data.azurerm_client_config.current.tenant_id
    object_id               = data.azurerm_client_config.current.object_id
    key_permissions         = var.kv_key_permissions_full
    secret_permissions      = var.kv_secret_permissions_full
    certificate_permissions = var.kv_certificate_permissions_full
  }

  # Access policy for bookapi workload identity - limited access
  access_policy {
    tenant_id               = data.azurerm_client_config.current.tenant_id
    object_id               = azurerm_user_assigned_identity.bookapi_workload_identity.principal_id
    key_permissions         = ["Get"]
    secret_permissions      = ["Get"]
    certificate_permissions = []
  }
}

resource "azurerm_monitor_diagnostic_setting" "bookapi_kv_diag" {
  name                       = "bookapi-kv-diagnostics"
  target_resource_id         = azurerm_key_vault.bookapi_kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.bookapi_workspace.id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}