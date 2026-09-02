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

# Module "azure_postgres_autostartstop"
variable "postgres_server_already_exists" {
  description = "Indicates whether the Postgres server already exists and should be used without being created by this module."
  type        = bool
  default     = false
}

variable "existing_postgres_resource_group_name" {
  description = "Resource group name of the already-deployed Postgres Flexible Server. Required when postgres_server_already_exists = true."
  type        = string
  default     = null
}

variable "existing_postgres_server_name" {
  description = "Name of the already-deployed Postgres Flexible Server. Required when postgres_server_already_exists = true."
  type        = string
  default     = null
}

variable "enable_postgres_auto_start_stop" {
  description = "Whether to deploy the auto start/stop feature for the Azure Postgres Flexible Server (cost saving, e.g. business hours only). Disabled by default."
  type        = bool
  default     = false
}

variable "postgres_autostartstop_start_hours" {
  description = "UTC hour (0-23) at which the Postgres Flexible Server is started, Monday to Friday."
  type        = number
  default     = 7
}

variable "postgres_autostartstop_start_minutes" {
  description = "UTC minute (0-59) at which the Postgres Flexible Server is started."
  type        = number
  default     = 0
}

variable "postgres_autostartstop_stop_hours" {
  description = "UTC hour (0-23) at which the Postgres Flexible Server is stopped, Monday to Friday."
  type        = number
  default     = 19
}

variable "postgres_autostartstop_stop_minutes" {
  description = "UTC minute (0-59) at which the Postgres Flexible Server is stopped."
  type        = number
  default     = 0
}

variable "postgres_autostartstop_disable_start" {
  description = "Disable the start timer function without destroying the auto start/stop infrastructure."
  type        = bool
  default     = false
}

variable "postgres_autostartstop_disable_stop" {
  description = "Disable the stop timer function without destroying the auto start/stop infrastructure."
  type        = bool
  default     = false
}

variable "postgres_autostartstop_holiday_country" {
  description = "Country code used to skip start/stop operations on public holidays."
  type        = string
  default     = "FR"
}

variable "postgres_autostartstop_solidarity_day" {
  description = "Date (format DD-MM) that should be treated as a working day even if it falls on a public holiday."
  type        = string
  default     = ""
}

variable "postgres_autostartstop_enable_failure_alert" {
  description = "Whether to notify Slack (via Incoming Webhook) when the auto start/stop Function App fails. Disabled by default."
  type        = bool
  default     = false
}

variable "postgres_autostartstop_slack_webhook_url" {
  description = "Slack Incoming Webhook URL (https://api.slack.com/messaging/webhooks) notified on Function App failure. Required when postgres_autostartstop_enable_failure_alert = true."
  type        = string
  default     = null
}
