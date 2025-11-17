resource "azuread_application" "gh_oidc_app" {
  display_name = "app-bookapi-gh-oidc"
}

resource "azuread_service_principal" "gh_oidc_sp" {
  client_id = azuread_application.gh_oidc_app.client_id
}

resource "azuread_application_federated_identity_credential" "gh_fed" {
  application_object_id = azuread_application.gh_oidc_app.object_id
  display_name          = "github-actions-oidc"
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_repo_owner}/${var.github_repo_name}:ref:refs/heads/${var.github_branch}"
  audiences             = ["api://AzureADTokenExchange"]
}