locals {
  main_name = "${var.postgres_resource_group_name}-pgautostartstop"

  storage_account_name       = replace(lower("${var.postgres_resource_group_name}pgcron"), "-", "")
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  storage_connection_string  = azurerm_storage_account.sa.primary_connection_string

  tmp_dir = "/tmp/terraform-postgres-autostartstop-functions"
}

resource "azuread_application_registration" "azure_client_app_registration" {
  display_name     = local.main_name
  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_application_password" "azure_client_app_registration_secret" {
  application_id = azuread_application_registration.azure_client_app_registration.id
  display_name   = "secret"
}

resource "azuread_service_principal" "azure_client_service_principal" {
  client_id = azuread_application_registration.azure_client_app_registration.client_id
}

resource "azurerm_resource_group" "rg" {
  name     = local.main_name
  location = var.location
}

# Contributor scoped to the PostgreSQL Flexible Server only, required to call start/stop.
resource "azurerm_role_assignment" "azure_client_assignment_postgres" {
  scope                = var.postgres_server_id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.azure_client_service_principal.object_id
  depends_on           = [azuread_application_registration.azure_client_app_registration]
}

resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "asp" {
  name                = local.main_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = local.main_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "app_insights" {
  name                = local.main_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
}

# Package the timer-triggered functions and inject the configured cron schedules.
resource "null_resource" "package_functions" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      #!/bin/sh

      set -e
      set -x

      if ! [ -x "$(command -v zip)" ]; then
        echo "'zip' is not installed. Please install it."
        exit 1
      fi

      dir_tmp=${local.tmp_dir}
      file_archive="$dir_tmp/functions.zip"

      rm -rf $dir_tmp
      mkdir -p $dir_tmp/functions
      cp -R ${path.module}/functions/. $dir_tmp/functions/

      sed -i 's|%KEYSCHEDULE%|0 ${var.start_minutes} ${var.start_hours} * * 1-5|' $dir_tmp/functions/StartPostgres/function.json
      sed -i 's|%KEYSCHEDULE%|0 ${var.stop_minutes} ${var.stop_hours} * * 1-5|' $dir_tmp/functions/StopPostgres/function.json

      cd $dir_tmp/functions
      zip -r "$file_archive" .

      chmod -R 777 $dir_tmp
    EOT
  }

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_linux_function_app" "fa" {
  name                       = local.main_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = local.storage_account_access_key

  app_settings = {
    "ENABLE_ORYX_BUILD"                        = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"           = "true"
    "AzureWebJobsStorage"                      = local.storage_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY"           = azurerm_application_insights.app_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"    = azurerm_application_insights.app_insights.connection_string
    "FUNCTIONS_EXTENSION_VERSION"              = "~4"
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = local.storage_connection_string
    "WEBSITE_CONTENTSHARE"                     = replace(lower(local.main_name), "-", "")
    "FUNCTIONS_WORKER_RUNTIME"                 = "python"
    "HOLIDAY_COUNTRY"                          = var.holiday_country
    "SOLIDARITY_DAY"                           = var.solidarity_day
    "AZURE_SUBSCRIPTION_ID"                    = var.azure_subscription_id
    "AZURE_TENANT_ID"                          = var.azure_tenant_id
    "AZURE_CLIENT_ID"                          = azuread_application_registration.azure_client_app_registration.client_id
    "AZURE_CLIENT_SECRET"                      = azuread_application_password.azure_client_app_registration_secret.value
    "POSTGRES_RESOURCE_GROUP"                  = var.postgres_resource_group_name
    "POSTGRES_SERVER_NAME"                     = var.postgres_server_name
    "AzureWebJobs.StartPostgres.Disabled"      = var.disable_start
    "AzureWebJobs.StopPostgres.Disabled"       = var.disable_stop
  }

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  zip_deploy_file = "${local.tmp_dir}/functions.zip"

  depends_on = [null_resource.package_functions]
}
