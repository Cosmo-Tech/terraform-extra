variable "cloud_provider" {}
variable "cluster_region" {}
variable "cluster_domain" {}

# Module "azure_postgres_flexible"
variable "azure_postgres_version" {
  type    = string
  default = "18"
}
variable "azure_postgres_sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}
variable "azure_postgres_storage_mb" {
  type    = number
  default = 32768
}
variable "azure_postgres_backup_retention_days" {
  type    = number
  default = 7
}
variable "azure_postgres_high_availability_mode" {
  type    = string
  default = null
}
variable "azure_postgres_additional_firewall_rules" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}
variable "fixed_firewall_ranges" {
  description = "Map of IP ranges permitted through the firewall"
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
}