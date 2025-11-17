data "azurerm_client_config" "current" {}

output "azuread_app_id" {
  value = azuread_application.gh_oidc_app.application_id
}

output "sp_object_id" {
  value = azuread_service_principal.gh_oidc_sp.object_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}