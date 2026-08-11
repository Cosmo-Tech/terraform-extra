output "fqdn" {
  value       = azurerm_postgresql_flexible_server.this.fqdn
  description = "Fully qualified domain name of the PostgreSQL Flexible Server."
}

output "administrator_login" {
  value       = local.effective_admin_username
  description = "PostgreSQL administrator login. Copy this into your Vault server."
  sensitive   = true
}

output "administrator_password" {
  value       = local.effective_admin_password
  description = "PostgreSQL administrator password. Copy this into your Vault server."
  sensitive   = true
}

output "credentials_hint" {
  description = "One-line reminder: generated admin credentials are not printed and must be pulled from Terraform state into Vault."
  value       = "Admin credentials generated for '${azurerm_postgresql_flexible_server.this.name}' are not displayed. Fetch with: terraform output -raw azure_postgres_flexible-administrator_login / -administrator_password (save to Vault, shown only once)."
}
