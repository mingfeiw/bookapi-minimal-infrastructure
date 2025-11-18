variable "subscription_id" {
  type = string
}

variable "github_repo_owner" {
  type = string
}

variable "github_repo_name" {
  type = string
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "acr_name" {
  type = string
}

variable "aks_name" {
  type = string
}

variable "rg_name" {
  type = string
}