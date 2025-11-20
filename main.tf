resource "azurerm_resource_group" "rg" {
  name     = "rg-bookapi-minimal"
  location = "uksouth"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-bookapi-minimal"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "bookapi"

  default_node_pool {
    name           = "default"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
    node_count     = 1
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
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
