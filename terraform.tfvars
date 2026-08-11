## VARIABLES EXAMPLE FOR AZURE
cloud_provider        = "azure"
cluster_region        = "westeurope"
cluster_domain        = "aks-dev-devops-ggon.azure.platform.cosmotech.com"
tenant                = "backup"
azure_subscription_id = "a24b131f-bd0b-42e8-872a-bded9b91ab74"
azure_entra_tenant_id = "e413b834-8be8-4822-a370-be619545cb49"


# ## VARIABLES EXAMPLE FOR AWS
# cloud_provider     = "aws"
# cluster_region     = "eu-west-3"
# cluster_domain     = "eks-dev-devops1.aws.platform.cosmotech.com"
# tenant             = "test0"


# ## VARIABLES EXAMPLE FOR GCP
# cloud_provider     = "gcp"
# cluster_domain     = "gke-dev-devops1.gcp.platform.cosmotech.com"
# tenant             = "test0"


# ## VARIABLES EXAMPLE FOR KOB (= On-premise)
# cloud_provider        = "kob"
# cluster_region        = ""
# cluster_domain        = "kob-dev-devops.onpremise.platform.cosmotech.com"
# tenant                = "test0"
# state_host            = "https://cosmotechstates.onpremise.platform.cosmotech.com"


## Module "config_keycloak_idp"
enable_config_keycloak_idp     = true
idp_alias             = "cosmotech.okta.com"
idp_issuer            = "https://cosmotech.okta.com"
idp_authorization_url = "https://cosmotech.okta.com/oauth2/v1/authorize"
idp_token_url         = "https://cosmotech.okta.com/oauth2/v1/token"
idp_logout_url        = "https://cosmotech.okta.com/oauth2/v1/logout"
idp_user_info_url     = "https://cosmotech.okta.com/oauth2/v1/userinfo"
idp_jwks_url          = "https://cosmotech.okta.com/oauth2/v1/keys"
# idp_client_id = <MUST REMAINS SECRET>
# idp_client_secret = <MUST REMAINS SECRET>


## Module "azure_postgres_flexible" (cloud_provider = "azure" only)
enable_azure_postgres_flexible = false
azure_postgres_manage_aks_lb_firewall_rules = false
azure_postgres_generate_credentials = false