terraform {
  required_version = ">= 1.13.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}


provider "kubernetes" {
  config_path            = "~/.kube/config"
  config_context_cluster = split(".", var.cluster_domain)[0]
}

# Only read the keycloak admin secret when config_keycloak_idp is enabled
data "kubernetes_secret" "keycloak" {
  count = var.enable_config_keycloak_idp ? 1 : 0

  metadata {
    namespace = "keycloak"
    name      = "keycloak-config"
  }
}

# Declared here (not inside the module) and passed explicitly via the
# module's `providers = { keycloak = keycloak }` argument. This is required
# for the module call to support `count`: Terraform only ever configures
# (and authenticates) this provider when at least one module instance
# actually uses it, i.e. when enable_config_keycloak_idp = true.
provider "keycloak" {
  url            = "https://${var.cluster_domain}"
  base_path      = "/keycloak"
  client_id      = "admin-cli"
  initial_login  = var.enable_config_keycloak_idp
  username       = try(data.kubernetes_secret.keycloak[0].data["keycloak_admin_user"], "unused")
  password       = try(data.kubernetes_secret.keycloak[0].data["keycloak_admin_password"], "unused")
}

