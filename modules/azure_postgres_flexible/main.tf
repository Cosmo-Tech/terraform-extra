# Naming
locals {
  # csm-<resource_group_name>, lowercased and truncated to the 63 char Azure limit
  server_name = substr(
    lower(coalesce(var.server_name, "csm-${var.resource_group_name}")),
    0,
    63,
  )

  mc_resource_group_name = coalesce(
    var.mc_resource_group_name,
    "MC_${var.resource_group_name}_${var.cluster_name}_${var.location}"
  )
}

data "azurerm_public_ips" "aks_lb" {
  resource_group_name = local.mc_resource_group_name
}

locals {
  aks_lb_ip_addresses = [
    for ip in data.azurerm_public_ips.aks_lb.public_ips : ip.ip_address
    if ip.ip_address != null
  ]

  aks_lb_firewall_rules = {
    for idx, ip in local.aks_lb_ip_addresses :
    "${var.cluster_name}-lb${idx + 1}" => {
      start_ip_address = ip
      end_ip_address   = ip
    }
  }

  all_firewall_rules = merge(
    local.aks_lb_firewall_rules,
    var.fixed_firewall_ranges,
    var.additional_firewall_rules,
  )
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "this" {
  name                = local.server_name
  resource_group_name = var.resource_group_name
  location            = var.location

  version  = var.postgresql_version
  sku_name = var.sku_name

  storage_mb                   = var.storage_mb
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  administrator_login    = local.effective_admin_username
  administrator_password = local.effective_admin_password

  public_network_access_enabled = var.public_network_access_enabled

  zone = var.zone

  dynamic "high_availability" {
    for_each = var.high_availability_mode == null ? [] : [var.high_availability_mode]
    content {
      mode = high_availability.value
    }
  }

  lifecycle {
    ignore_changes = [
      administrator_password,
      zone,
    ]
  }
}

# Allow access from Azure services (required for PowerBI, etc.)
resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  count            = var.allow_access_from_azure_services ? 1 : 0
  name             = "AllowAllWindowsAzureIps"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Dynamic firewall rules: AKS LB(s) + Cosmo office + Cosmo datacenter + extras
resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  for_each = local.all_firewall_rules

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}
