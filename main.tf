module "config_keycloak_idp" {
  source = "./modules/config_keycloak_idp"

  cluster_domain        = var.cluster_domain
  tenant                = var.tenant
  idp_issuer            = var.idp_issuer
  idp_alias             = var.idp_alias
  idp_authorization_url = var.idp_authorization_url
  idp_token_url         = var.idp_token_url
  idp_logout_url        = var.idp_logout_url
  idp_user_info_url     = var.idp_user_info_url
  idp_jwks_url          = var.idp_jwks_url
  idp_client_id         = var.idp_client_id
  idp_client_secret     = var.idp_client_secret
}
