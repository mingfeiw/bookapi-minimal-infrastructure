resource "azurerm_role_assignment" "gh_oidc_app_acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = data.azuread_service_principal.tti_mingfei_poc.id
}

# Role assignment already exists in Azure - commenting out to avoid conflicts
# resource "azurerm_role_assignment" "aks_acr_pull" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

#   lifecycle {
#     ignore_changes = [principal_id]
#   }

#   depends_on = [azurerm_kubernetes_cluster.aks]
# }

# Grant AKS permission to manage network resources - already exists in Azure
# resource "azurerm_role_assignment" "aks_network_contributor" {
#   scope                = azurerm_virtual_network.vnet.id
#   role_definition_name = "Network Contributor"
#   principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id

#   lifecycle {
#     ignore_changes = [principal_id]
#   }

#   depends_on = [azurerm_kubernetes_cluster.aks]
# }

# Create federated identity credential for workload identity
resource "azurerm_federated_identity_credential" "bookapi_workload_identity" {
  name                = "bookapi-federated-identity"
  resource_group_name = azurerm_resource_group.rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.bookapi_workload_identity.id
  subject             = "system:serviceaccount:bookapi:bookapi-service-account"

  depends_on = [azurerm_kubernetes_cluster.aks]
}

data "azurerm_subscription" "primary" {
}