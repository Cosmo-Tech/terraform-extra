output "config_keycloak_idp-sign_in_redirect_uri" {
  value = "https://${var.cluster_domain}/keycloak/realms/tenant-${var.tenant}/broker/${var.idp_alias}/endpoint"
  description = "Copy/paste this URI in a new entry under 'Sign-in redirect URIs' from the Okta OIDC application"
}
