## VARIABLES EXAMPLE FOR AZURE
cloud_provider        = "azure"
cluster_region        = "westeurope"
cluster_domain        = "aks-dev-devops.azure.platform.cosmotech.com"
tenant                = "test0"
azure_subscription_id = "xxxxxxxx_xxxx_xxxx_xxxx_xxxxxxxxxxxx"
azure_entra_tenant_id = "xxxxxxxx_xxxx_xxxx_xxxx_xxxxxxxxxxxx"


# ## VARIABLES EXAMPLE FOR AWS
# cloud_provider     = "aws"
# cluster_region     = "eu-west-3"
# cluster_domain     = "eks-dev-devops1.aws.platform.cosmotech.com"
# tenant             = "test0"


## VARIABLES EXAMPLE FOR GCP
# cloud_provider     = "gcp"
# cluster_domain     = "gke-dev-devops1.gcp.platform.cosmotech.com"
# tenant             = "test0"


## VARIABLES EXAMPLE FOR BARE
# cloud_provider = "bare"
# cluster_domain     = ""
# tenant             = "test0"


## Module "config_keycloak_idp"
idp_alias             = "cosmotech.okta.com"
idp_issuer            = "https://cosmotech.okta.com"
idp_authorization_url = "https://cosmotech.okta.com/oauth2/v1/authorize"
idp_token_url         = "https://cosmotech.okta.com/oauth2/v1/token"
idp_logout_url        = "https://cosmotech.okta.com/oauth2/v1/logout"
idp_user_info_url     = "https://cosmotech.okta.com/oauth2/v1/userinfo"
idp_jwks_url          = "https://cosmotech.okta.com/oauth2/v1/keys"
# idp_client_id = <MUST REMAINS SECRET>
# idp_client_secret = <MUST REMAINS SECRET>