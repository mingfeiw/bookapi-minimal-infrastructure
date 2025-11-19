resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-restrict-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_private_ranges" {
  name                   = "allow-private-ranges"
  priority               = 100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "*"
  source_port_range      = "*"
  destination_port_range = "80"
  source_address_prefixes = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}