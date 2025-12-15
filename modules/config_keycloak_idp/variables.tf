variable "cluster_domain" {}
variable "tenant" {}
variable "idp_issuer" {}
variable "idp_alias" {}
variable "idp_authorization_url" {}
variable "idp_token_url" {}
variable "idp_logout_url" {}
variable "idp_user_info_url" {}
variable "idp_jwks_url" {}
variable "idp_client_id" { sensitive = true }
variable "idp_client_secret" { sensitive = true }
