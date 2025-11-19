data "azuread_application" "tti_mingfei_poc" {
  display_name = "tti-mingfei-poc"
}

data "azuread_service_principal" "tti_mingfei_poc" {
  display_name = "tti-mingfei-poc"
}

resource "azuread_application_federated_identity_credential" "gh_fed" {
  application_id = "/applications/${data.azuread_application.tti_mingfei_poc.object_id}"
  display_name   = "github-actions-oidc"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repo_owner}/${var.github_repo_name}:ref:refs/heads/${var.github_branch}"
  audiences      = ["api://AzureADTokenExchange"]
}
