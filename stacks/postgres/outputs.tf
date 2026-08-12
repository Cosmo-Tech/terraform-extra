output "fqdn" {
  value       = try(module.azure_postgres_flexible[0].fqdn, null)
  description = "FQDN of the Azure PostgreSQL Flexible Server, if the module is enabled."
}

output "administrator_login" {
  value       = try(module.azure_postgres_flexible[0].administrator_login, null)
  description = "Generated PostgreSQL administrator login. Save it in Vault."
  sensitive   = true
}

output "administrator_password" {
  value       = try(module.azure_postgres_flexible[0].administrator_password, null)
  description = "Generated PostgreSQL administrator password. Save it in Vault."
  sensitive   = true
}
