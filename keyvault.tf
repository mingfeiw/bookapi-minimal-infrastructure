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

  # Access policies with full permissions for all principals
  dynamic "access_policy" {
    for_each = [
      {
        comment   = "Terraform/GitHub Actions service principal"
        object_id = data.azurerm_client_config.current.object_id
      },
      {
        comment   = "AKS cluster"
        object_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
      },
      {
        comment   = "tti_mingfei_poc service principal"
        object_id = data.azuread_service_principal.tti_mingfei_poc.object_id
      },
      {
        comment   = "mingfei.wang@kpmg.co.uk user"
        object_id = data.azuread_user.mingfei_wang.object_id
      }
    ]
    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      key_permissions         = var.kv_key_permissions_full
      secret_permissions      = var.kv_secret_permissions_full
      certificate_permissions = var.kv_certificate_permissions_full
    }
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