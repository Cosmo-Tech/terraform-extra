terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.5.0"
    }
  }
}


provider "keycloak" {
  url       = "https://${var.cluster_domain}/keycloak/"
  client_id = "admin-cli"
  username  = data.kubernetes_secret.keycloak.data["keycloak_admin_user"]
  password  = data.kubernetes_secret.keycloak.data["keycloak_admin_password"]
}


data "kubernetes_secret" "keycloak" {
  metadata {
    namespace = "keycloak"
    name      = "keycloak-config"
  }
}


data "keycloak_realm" "realm" {
  realm = "tenant-${var.tenant}"
}


resource "keycloak_oidc_identity_provider" "oidc" {
  realm = data.keycloak_realm.realm.id
  alias = var.idp_alias

  issuer             = var.idp_issuer
  authorization_url  = var.idp_authorization_url
  token_url          = var.idp_token_url
  logout_url         = var.idp_logout_url
  user_info_url      = var.idp_user_info_url
  jwks_url           = var.idp_jwks_url
  validate_signature = true
  login_hint         = false
  trust_email        = true
  client_id          = var.idp_client_id
  client_secret      = var.idp_client_secret
  default_scopes     = "email openid profile"

  extra_config = {
    "clientAuthMethod" = "client_secret_post"
  }
}


resource "keycloak_hardcoded_group_identity_provider_mapper" "oidc" {
  realm                   = data.keycloak_realm.realm.id
  name                    = "set_as_organization_user"
  identity_provider_alias = keycloak_oidc_identity_provider.oidc.alias
  group                   = "/organization_user"

  extra_config = {
    syncMode = "INHERIT"
  }
}

