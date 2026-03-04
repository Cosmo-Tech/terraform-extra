## CosmoTech Platform specifics
variable "tenant" {
  description = "CosmoTech platform tenant name (e.g. tenant-sphinx)"
  type        = string
}

variable "cluster_domain" {
  description = "The DNS name of the API, e.g. cluster.azure.platform.cosmotech.com"
  type        = string
}

## General variables
variable "keycloak_url" {
  description = "Keycloak server URL"
  type        = string
}

variable "keycloak_client_id" {
  description = "Keycloak client ID"
  type        = string
}

variable "keycloak_username" {
  description = "Keycloak admin username"
  type        = string
}

variable "keycloak_password" {
  description = "Keycloak admin password"
  type        = string
  sensitive   = true
}

variable "keycloak_realm" {
  description = "Keycloak realm name"
  type        = string
}
