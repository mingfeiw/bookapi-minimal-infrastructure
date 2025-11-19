resource "azurerm_resource_group" "rg" {
  name     = "rg-bookapi-minimal"
  location = "uksouth"
  tags = {
    preserve = "true"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-bookapi-minimal"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "bookapi"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "acrbookapi"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}
