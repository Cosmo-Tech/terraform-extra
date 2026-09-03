output "function_app_name" {
  value       = azurerm_linux_function_app.fa.name
  description = "Name of the Azure Function App handling the PostgreSQL Flexible Server start/stop schedule."
}

output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Resource group holding the auto start/stop infrastructure."
}
