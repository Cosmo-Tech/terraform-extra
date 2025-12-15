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
  group                   = "organization_user"

  extra_config = {
    syncMode = "INHERIT"
  }
}




# All the blocs below needs to be transfered to terraform-tenant
# Organization.User
data "keycloak_role" "organization_user" {
  realm_id = data.keycloak_realm.realm.id
  name     = "Organization.User"
}

resource "keycloak_group" "organization_user" {
  realm_id = data.keycloak_realm.realm.id
  name     = "platform-user"
}

resource "keycloak_group_roles" "organization_user" {
  realm_id = data.keycloak_realm.realm.id
  group_id = keycloak_group.organization_user.id

  role_ids = [
    data.keycloak_role.organization_user.id,
  ]

  depends_on = [
    keycloak_group.organization_user,
    data.keycloak_role.organization_user
  ]
}


# Platform.Admin (under Organization.User)
data "keycloak_role" "platform_admin" {
  realm_id = data.keycloak_realm.realm.id
  name     = "Platform.Admin"
}

resource "keycloak_group" "platform_admin" {
  realm_id  = data.keycloak_realm.realm.id
  parent_id = keycloak_group.organization_user.id
  name      = "platform-admin"

  depends_on = [
    keycloak_group.organization_user
  ]
}

resource "keycloak_group_roles" "platform_admin" {
  realm_id = data.keycloak_realm.realm.id
  group_id = keycloak_group.platform_admin.id

  role_ids = [
    data.keycloak_role.platform_admin.id,
  ]

  depends_on = [
    keycloak_group.platform_admin,
    data.keycloak_role.platform_admin
  ]
}

