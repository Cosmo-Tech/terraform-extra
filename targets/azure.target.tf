terraform {
  backend "azurerm" {
    resource_group_name  = "$TEMPLATE_state_storage_name"
    storage_account_name = "$TEMPLATE_state_storage_name"
    container_name       = "$TEMPLATE_state_storage_name"
    key                  = "$TEMPLATE_state_file_name"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_entra_tenant_id
}

variable "azure_subscription_id" { type = string }
variable "azure_entra_tenant_id" { type = string }