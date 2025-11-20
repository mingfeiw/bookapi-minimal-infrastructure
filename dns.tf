# Private DNS Zone for internal hostname resolution
resource "azurerm_private_dns_zone" "internal" {
  name                = "internal.local"
  resource_group_name = azurerm_resource_group.rg.name
}

# Link DNS zone to VNet so resources in VNet can resolve internal.local
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "vnet-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.internal.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

# Note: You'll need to create the A record manually after getting the ingress IP
# Or run: terraform apply again after deployment and update the IP below
# 
# resource "azurerm_private_dns_a_record" "bookapi" {
# name = "bookapi"
# zone_name = azurerm_private_dns_zone.internal.name
# resource_group_name = azurerm_resource_group.rg.name
# ttl = 300
# records = ["10.0.1.50"] # Replace with actual ingress controller IP
# }