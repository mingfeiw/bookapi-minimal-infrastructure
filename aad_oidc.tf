data "azuread_application" "tti_mingfei_poc" {
  display_name = "tti-mingfei-poc"
}

data "azuread_service_principal" "tti_mingfei_poc" {
  application_id = data.azuread_application.tti_mingfei_poc.client_id
}

resource "azuread_application_federated_identity_credential" "github" {
  application_id = data.azuread_application.tti_mingfei_poc.id
  display_name   = "github-actions"
  description    = "OIDC for GitHub Actions"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:mingfeiw/bookapi-minimal-infrastructure:ref:refs/heads/main"
}
