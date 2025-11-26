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

  # Access policy for Terraform/GitHub Actions service principal
  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List"]
  }

  # Access policy for AKS cluster
  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = azurerm_kubernetes_cluster.aks.identity[0].principal_id
    secret_permissions = ["Get", "List"]
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