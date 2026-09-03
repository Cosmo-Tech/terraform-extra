terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.7.0"
    }
  }
}

provider "keycloak" {
  url       = var.keycloak_url
  client_id = var.keycloak_client_id
  username  = var.keycloak_username
  password  = var.keycloak_password
  realm     = var.keycloak_realm
}


# get realm for current tenant
data "keycloak_realm" "realm" {
  realm = var.tenant
}

# automation client
resource "keycloak_openid_client" "automation-client" {
  realm_id                 = data.keycloak_realm.realm.id
  client_id                = "automation-client"
  name                     = "automation-client"
  enabled                  = true
  standard_flow_enabled    = false
  access_type              = "CONFIDENTIAL"
  service_accounts_enabled = true
  login_theme              = "keycloak"
  root_url                 = "https://${var.cluster_domain}"
  full_scope_allowed       = true
}

resource "keycloak_generic_protocol_mapper" "automation_realm_roles_mapper" {
  realm_id        = data.keycloak_realm.realm.id
  client_id       = keycloak_openid_client.automation-client.id
  name            = "realm roles"
  protocol        = "openid-connect"
  protocol_mapper = "oidc-usermodel-realm-role-mapper"
  config = {
    "id.token.claim" : "true",
    "access.token.claim" : "true",
    "claim.name" : "userRoles",
    "jsonType.label" : "String",
    "multivalued" : "true",
    "userinfo.token.claim" : "true",
    "introspection.token.claim" : "true"
  }
}

resource "keycloak_openid_client_service_account_realm_role" "automation_client_service_account_role" {
  realm_id                = data.keycloak_realm.realm.id
  service_account_user_id = keycloak_openid_client.automation-client.service_account_user_id
  role                    = "Platform.Admin"
}
