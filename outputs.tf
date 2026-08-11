output "config_keycloak_idp-sign_in_redirect_uri" {
  value       = var.enable_config_keycloak_idp ? "https://${var.cluster_domain}/keycloak/realms/tenant-${var.tenant}/broker/${var.idp_alias}/endpoint" : null
  description = "Copy/paste this URI in a new entry under 'Sign-in redirect URIs' from the Okta OIDC application"
}

output "azure_postgres_flexible-fqdn" {
  value       = try(module.azure_postgres_flexible[0].fqdn, null)
  description = "FQDN of the Azure PostgreSQL Flexible Server, if the module is enabled."
}

output "azure_postgres_flexible-credentials_hint" {
  value       = try(module.azure_postgres_flexible[0].credentials_hint, null)
  description = "One-line reminder that generated PostgreSQL admin credentials are not printed and must be pulled into Vault."
}

output "azure_postgres_flexible-administrator_login" {
  value       = try(module.azure_postgres_flexible[0].administrator_login, null)
  description = "Generated PostgreSQL administrator login. Save it in Vault (terraform output -raw ...)."
  sensitive   = true
}

output "azure_postgres_flexible-administrator_password" {
  value       = try(module.azure_postgres_flexible[0].administrator_password, null)
  description = "Generated PostgreSQL administrator password. Save it in Vault (terraform output -raw ...)."
  sensitive   = true
}
