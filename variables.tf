variable "cloud_provider" {}
variable "cluster_region" {}
variable "cluster_domain" {}
variable "tenant" {}

# Module "config_keycloak_idp"
variable "idp_issuer" {}
variable "idp_alias" {}
variable "idp_authorization_url" {}
variable "idp_token_url" {}
variable "idp_logout_url" {}
variable "idp_user_info_url" {}
variable "idp_jwks_url" {}
variable "idp_client_id" { sensitive = true }
variable "idp_client_secret" { sensitive = true }

variable "enable_config_keycloak_idp" {
  type        = bool
  default     = true
  description = "Whether to deploy the config_keycloak_idp module. Set to false if you only want to run azure_postgres_flexible."
}

# Module "azure_postgres_flexible"
variable "enable_azure_postgres_flexible" {
  type        = bool
  default     = false
  description = "Whether to deploy the Azure PostgreSQL Flexible Server module (azure cloud_provider only)."
}

variable "azure_postgres_tags" {
  type    = map(string)
  default = {}
}
variable "azure_postgres_version" {
  type        = string
  default     = "18"
}
variable "azure_postgres_sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}
variable "azure_postgres_storage_mb" {
  type    = number
  default = 32768
}
variable "azure_postgres_backup_retention_days" {
  type    = number
  default = 7
}
variable "azure_postgres_high_availability_mode" {
  type    = string
  default = null
}
variable "azure_postgres_manage_aks_lb_firewall_rules" {
  type    = bool
  default = true
}
variable "azure_postgres_additional_firewall_rules" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}
variable "azure_postgres_generate_credentials" {
  type    = bool
  default = true
}
