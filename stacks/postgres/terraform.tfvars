## VARIABLES EXAMPLE FOR AZURE (postgres stack, azure cloud_provider only)
cloud_provider        = "azure"
cluster_region        = "westeurope"
cluster_domain        = "aks-dev-devops.azure.platform.cosmotech.com"
azure_subscription_id = "xxxxxxxx_xxxx_xxxx_xxxx_xxxxxxxxxxxx"
azure_entra_tenant_id = "xxxxxxxx_xxxx_xxxx_xxxx_xxxxxxxxxxxx"
fixed_firewall_ranges = {
  cosmo_office = {
    start_ip_address = "xx.xxx.xx.xxx"
    end_ip_address   = "xx.xxx.xx.xxx"
  }
  cosmo_datacenter = {
    start_ip_address = "xx.xxx.xx.xxx"
    end_ip_address   = "xx.xxx.xx.xxx"
  }
}

## Optional: auto start/stop the PostgreSQL Flexible Server (cost saving).
enable_postgres_auto_start_stop        = false
postgres_autostartstop_start_hours     = 05   # UTC, Monday to Friday
postgres_autostartstop_start_minutes   = 00
postgres_autostartstop_stop_hours      = 19   # UTC, Monday to Friday
postgres_autostartstop_stop_minutes    = 00
postgres_autostartstop_disable_start   = false
postgres_autostartstop_disable_stop    = false
postgres_autostartstop_holiday_country = "FR"
postgres_autostartstop_solidarity_day  = ""