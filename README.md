![Static Badge](https://img.shields.io/badge/Cosmo%20Tech-%23FFB039?style=for-the-badge)
![Static Badge](https://img.shields.io/badge/extra-%23f8f8f7?style=for-the-badge)


# Cosmo Tech extra configs
*optionals configurations for Cosmo Tech tenants*

## Requirements
* working Kubernetes tenant deployed from Cosmo Tech terraform-tenant
* [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## How to
* clone & open the repository
    ```
    git clone https://github.com/Cosmo-Tech/terraform-extra.git --branch <tag>
    cd terraform-extra
    ```
* deploy
    * fill `terraform.tfvars` variables according to your needs
    * run pre-configured script
        > ℹ️ comment/uncomment the terraform apply line at the end to get a plan without deploy anything
        * Linux
            ```
            ./_run-terraform.sh
            ```

## Known errors
* No known error for now !

## Developpers
* modules
    * **terraform-extra**
        * *config_keycloak_idp* = add an Identity Provider on the top of an existing Keycloak (for exemple set Okta as IdP for Keycloak)
* Terraform **state**
    * The state is stored beside the cluster Terraform state, in the current cloud s3/blob storage service (generally called `cosmotech-states` or `cosmotechstates`, depending on what the cloud provider allows in naming convention)

<br>
<br>
<br>

Made with :heart: by Cosmo Tech DevOps team
