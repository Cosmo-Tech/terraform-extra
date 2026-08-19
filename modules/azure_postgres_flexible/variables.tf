# Target / placement
variable "resource_group_name" {
  type        = string
  description = "Resource Group where the AKS cluster and the PostgreSQL Flexible Server live."
}

variable "location" {
  type        = string
  description = "Azure region (must match the AKS cluster region)."
}

variable "cluster_name" {
  type        = string
  description = "Name of the target AKS cluster. Used to derive the MC_ node resource group and to name firewall rules (<cluster_name>-lb1, -lb2, ...)."
}

variable "mc_resource_group_name" {
  type        = string
  default     = null
  description = "Override for the AKS node resource group name. If null, it is computed as MC_<resource_group_name>_<cluster_name>_<location>."
}

# Server sizing / engine
variable "server_name" {
  type        = string
  default     = null
  description = "Override for the PostgreSQL Flexible Server name. If null, defaults to csm-<resource_group_name> (lowercased, truncated to 63 chars)."
}

variable "postgresql_version" {
  type        = string
  description = "PostgreSQL major version. One of '11'..'18'."

  validation {
    condition     = contains(["16", "17", "18"], var.postgresql_version)
    error_message = "postgresql_version must be a major version only (e.g. '18', not '18.4')."
  }
}

variable "sku_name" {
  type        = string
  description = "Compute SKU. e.g. 'B_Standard_B1ms' for dev/test, 'GP_Standard_D2s_v3' (General Purpose) for prod workloads."
}

variable "storage_mb" {
  type        = number
  description = "Storage size in MB (minimum 32768 = 32GB)."
}

variable "backup_retention_days" {
  type        = number
  description = "Number of days to retain backups (7-35)."

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 7 and 35."
  }
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  default     = false
  description = "Whether geo-redundant backups are enabled. Recommended true for prod."
}

variable "high_availability_mode" {
  type        = string
  default     = null
  description = "High availability mode: null (disabled), 'ZoneRedundant' or 'SameZone'. Recommended for prod."

  validation {
    condition     = var.high_availability_mode == null || contains(["ZoneRedundant", "SameZone"], var.high_availability_mode)
    error_message = "high_availability_mode must be null, 'ZoneRedundant' or 'SameZone'."
  }
}

variable "zone" {
  type        = string
  default     = null
  description = "Availability zone to pin the server to (optional)."
}

# Networking / Firewall
variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Enable public network access on the Flexible Server."
}

variable "allow_access_from_azure_services" {
  type        = bool
  default     = true
  description = "Create the 0.0.0.0-0.0.0.0 firewall rule allowing any Azure service (required for PowerBI, etc.) to reach the server."
}

variable "additional_firewall_rules" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default     = {}
  description = "Extra firewall rules to create, keyed by rule name, in addition to the AKS LB / Cosmo office / Cosmo datacenter rules."
}

variable "fixed_firewall_ranges" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  description = "Defines fixed firewall IP address ranges for trusted office and datacenter networks."
}

# Admin credentials
variable "admin_username_length" {
  type        = number
  default     = 32
  description = "Length of the auto-generated admin username (>= 30)."

  validation {
    condition     = var.admin_username_length >= 30
    error_message = "admin_username_length must be >= 30."
  }
}

variable "admin_password_length" {
  type        = number
  default     = 80
  description = "Length of the auto-generated admin password (>= 80)."

  validation {
    condition     = var.admin_password_length >= 80
    error_message = "admin_password_length must be >= 80."
  }
}
