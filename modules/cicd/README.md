# CICD Keycloak Automation Client Submodule

This submodule creates a Keycloak OpenID client named `automation-client` in an existing realm. It does not require admin access to a kubernetes cluster with the downside of requiring configuring the keycloak variables.

## Module Input Variables

- Cosmotech Platform specific variables
    - `tenant`: CosmoTech platform tenant name
    - `cluster_domain`: The cluster location
- Variables for keycloak
    - `keycloak_url` Keycloak server URL
    - `keycloak_client_id` Keycloak client id (with admin rights)
    - `keycloak_username` Keycloak admin username
    - `keycloak_password` Keycloak admin password
    - `keycloak_realm` Keycloak realm name

## Usage
```
module "cicd" {
  source = "./modules/cicd"

  tenant            = "tenant-test"
  cluster_domain    = "localhost"
  keycloak_url      = "http://localhost:8080"
  keycloak_client_id = "admin-cli"
  keycloak_username = "admin"
  keycloak_password = "admin"
  keycloak_realm    = "master"
}
```

## Testing
Start the keycloak container
```shell
cd tests
docker compose up -d
```
A keycloak instance will start and will be configured with a realm and roles loaded.
Run the terraform test:
```shell
terraform test --var-file keycloak.local.tfvars
```