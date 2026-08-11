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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags inherited from the resource group / AKS cluster, applied to every resource created by this module."
}

# Server sizing / engine
variable "server_name" {
  type        = string
  default     = null
  description = "Override for the PostgreSQL Flexible Server name. If null, defaults to csm-<resource_group_name> (lowercased, truncated to 63 chars)."
}

variable "postgresql_version" {
  type        = string
  default     = "18"
  description = "PostgreSQL major version. One of '11'..'18' (requires azurerm provider >= 4.60.0 for '18')."

  validation {
    condition     = contains(["11", "12", "13", "14", "15", "16", "17", "18"], var.postgresql_version)
    error_message = "postgresql_version must be a major version only (e.g. '18', not '18.4')."
  }
}

variable "sku_name" {
  type        = string
  default     = "B_Standard_B1ms"
  description = "Compute SKU. e.g. 'B_Standard_B1ms' for dev/test, 'GP_Standard_D2s_v3' (General Purpose) for prod workloads."
}

variable "storage_mb" {
  type        = number
  default     = 32768
  description = "Storage size in MB (minimum 32768 = 32GB)."
}

variable "backup_retention_days" {
  type        = number
  default     = 7
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
  description = "Create the 0.0.0.0-0.0.0.0 firewall rule allowing any Azure service (required for PowerBI, Data Factory, etc.) to reach the server."
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
  default = {
    cosmo_office = {
      start_ip_address = "94.231.41.184"
      end_ip_address   = "94.231.41.190"
    }
    cosmo_datacenter = {
      start_ip_address = "185.55.98.16"
      end_ip_address   = "185.55.98.22"
    }
  }
  description = "Well-known Cosmo Tech firewall ranges (office / datacenter). Override only if these ranges change."
}

variable "manage_aks_lb_firewall_rules" {
  type        = bool
  default     = true
  description = "Whether to dynamically discover the AKS frontend Load Balancer public IP(s) (from the MC_ node resource group) and create one firewall rule per IP: <cluster_name>-lb1, <cluster_name>-lb2, ..."
}

# Admin credentials
variable "generate_credentials" {
  type        = bool
  default     = true
  description = "If true, Terraform generates a strong admin username/password with the random provider (printed at the end of apply). If false, admin_username/admin_password must be supplied."
}

variable "admin_username" {
  type        = string
  default     = null
  sensitive   = true
  description = "PostgreSQL admin username to use when generate_credentials = false. Must be >= 30 alphanumeric characters."

  validation {
    condition     = var.admin_username == null || (length(var.admin_username) >= 30 && can(regex("^[a-zA-Z0-9]+$", var.admin_username)))
    error_message = "admin_username must be at least 30 alphanumeric characters."
  }
}

variable "admin_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "PostgreSQL admin password to use when generate_credentials = false. Must be >= 80 characters, alphanumeric + special characters."

  validation {
    condition     = var.admin_password == null || length(var.admin_password) >= 80
    error_message = "admin_password must be at least 80 characters."
  }
}

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
