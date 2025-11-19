resource "azuread_application_federated_identity_credential" "github" {
  application_object_id = azuread_application.example.object_id
  display_name          = "github-actions"
  description           = "OIDC for GitHub Actions"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:mingfeiw/bookapi-minimal-infrastructure:ref:refs/heads/main"
}