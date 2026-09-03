output "fqdn" {
  value       = azurerm_postgresql_flexible_server.this.fqdn
  description = "Fully qualified domain name of the PostgreSQL Flexible Server."
}

output "server_id" {
  value       = azurerm_postgresql_flexible_server.this.id
  description = "Resource ID of the PostgreSQL Flexible Server."
}

output "server_name" {
  value       = azurerm_postgresql_flexible_server.this.name
  description = "Name of the PostgreSQL Flexible Server."
}

output "resource_group_name" {
  value       = var.resource_group_name
  description = "Resource group name where the PostgreSQL Flexible Server lives."
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