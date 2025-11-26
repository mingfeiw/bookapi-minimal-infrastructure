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

# Key Vault permission variables to reduce redundancy
variable "kv_key_permissions_full" {
  type        = list(string)
  description = "Full key permissions for Key Vault access policies"
  default     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
}

variable "kv_secret_permissions_full" {
  type        = list(string)
  description = "Full secret permissions for Key Vault access policies"
  default     = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}

variable "kv_certificate_permissions_full" {
  type        = list(string)
  description = "Full certificate permissions for Key Vault access policies"
  default     = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
}

