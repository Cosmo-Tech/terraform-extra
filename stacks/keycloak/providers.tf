terraform {
  required_version = "~> 1.13"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.7.0"
    }
  }
}


provider "kubernetes" {
  config_path            = "~/.kube/config"
  config_context_cluster = split(".", var.cluster_domain)[0]
}

# Read the keycloak admin secret from the cluster to authenticate the keycloak provider.
data "kubernetes_secret" "keycloak" {
  metadata {
    namespace = "keycloak"
    name      = "keycloak-config"
  }
}

provider "keycloak" {
  url           = "https://${var.cluster_domain}"
  base_path     = "/keycloak"
  client_id     = "admin-cli"
  initial_login = true
  username      = data.kubernetes_secret.keycloak.data["keycloak_admin_user"]
  password      = data.kubernetes_secret.keycloak.data["keycloak_admin_password"]
}
