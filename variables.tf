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

variable "github_pat" {
  description = "GitHub Personal Access Token"
  sensitive   = true
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

variable "admin_username" {
  description = "Admin username for the VM"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  sensitive   = true
}