data "azuread_application" "tti_mingfei_poc" {
  client_id = "6d9b61c7-8c93-4d79-b1f4-9a9f533baff1"
}

data "azuread_service_principal" "tti_mingfei_poc" {
  client_id = data.azuread_application.tti_mingfei_poc.client_id
}

data "azurerm_client_config" "current" {}