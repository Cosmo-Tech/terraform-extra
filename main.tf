module "config_keycloak_idp" {
  source = "./modules/config_keycloak_idp"
  count  = var.enable_config_keycloak_idp ? 1 : 0

  providers = {
    keycloak = keycloak
  }

  cluster_domain        = var.cluster_domain
  tenant                = var.tenant
  idp_issuer            = var.idp_issuer
  idp_alias             = var.idp_alias
  idp_authorization_url = var.idp_authorization_url
  idp_token_url         = var.idp_token_url
  idp_logout_url        = var.idp_logout_url
  idp_user_info_url     = var.idp_user_info_url
  idp_jwks_url          = var.idp_jwks_url
  idp_client_id         = var.idp_client_id
  idp_client_secret     = var.idp_client_secret
}


module "azure_postgres_flexible" {
  source = "./modules/azure_postgres_flexible"
  count  = var.cloud_provider == "azure" && var.enable_azure_postgres_flexible ? 1 : 0

  resource_group_name  = split(".", var.cluster_domain)[0]
  location             = var.cluster_region
  cluster_name         = split(".", var.cluster_domain)[0]
  tags                 = var.azure_postgres_tags

  postgresql_version     = var.azure_postgres_version
  sku_name               = var.azure_postgres_sku_name
  storage_mb              = var.azure_postgres_storage_mb
  backup_retention_days   = var.azure_postgres_backup_retention_days
  high_availability_mode  = var.azure_postgres_high_availability_mode

  manage_aks_lb_firewall_rules = var.azure_postgres_manage_aks_lb_firewall_rules
  additional_firewall_rules    = var.azure_postgres_additional_firewall_rules

  generate_credentials = var.azure_postgres_generate_credentials
}
