resource "azurerm_log_analytics_workspace" "bookapi_workspace" {
  name                = "bookapi-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "bookapi_appinsights" {
  name                = "bookapi-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.bookapi_workspace.id
  application_type    = "web"
}