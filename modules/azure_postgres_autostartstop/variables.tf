variable "location" {
  type        = string
  description = "Azure region where the auto start/stop infrastructure (function app, storage, ...) will be created."
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID."
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure Entra (AD) Tenant ID."
}

variable "postgres_resource_group_name" {
  type        = string
  description = "Resource group name where the target PostgreSQL Flexible Server lives."
}

variable "postgres_server_name" {
  type        = string
  description = "Name of the target PostgreSQL Flexible Server."
}

variable "postgres_server_id" {
  type        = string
  description = "Resource ID of the target PostgreSQL Flexible Server. Used to scope the Contributor role assignment as narrowly as possible."
}

variable "start_hours" {
  type        = number
  description = "UTC hour (0-23) at which the PostgreSQL Flexible Server is started, Monday to Friday."
}

variable "start_minutes" {
  type        = number
  description = "UTC minute (0-59) at which the PostgreSQL Flexible Server is started."
}

variable "stop_hours" {
  type        = number
  description = "UTC hour (0-23) at which the PostgreSQL Flexible Server is stopped, Monday to Friday."
}

variable "stop_minutes" {
  type        = number
  description = "UTC minute (0-59) at which the PostgreSQL Flexible Server is stopped."
}

variable "disable_start" {
  type        = bool
  default     = false
  description = "Disable the start timer function without destroying the infrastructure."
}

variable "disable_stop" {
  type        = bool
  default     = false
  description = "Disable the stop timer function without destroying the infrastructure."
}

variable "holiday_country" {
  type        = string
  default     = "FR"
  description = "Country code used to skip start/stop operations on public holidays."
}

variable "solidarity_day" {
  type        = string
  default     = ""
  description = "Date (format DD-MM) that should be treated as a working day even if it falls on a public holiday."
}

variable "enable_failure_alert" {
  type        = bool
  default     = false
  description = "Whether to notify Slack (via Incoming Webhook) when the Function App fails to start/stop the server (e.g. exception during the API call)."
}

variable "slack_webhook_url" {
  type        = string
  default     = null
  description = "Slack Incoming Webhook URL (https://api.slack.com/messaging/webhooks) notified on Function App failure. Required when enable_failure_alert = true."
}
