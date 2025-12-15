terraform {
  required_version = ">= 1.13.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
  }
}


provider "kubernetes" {
  config_path            = "~/.kube/config"
  config_context_cluster = split(".", var.cluster_domain)[0]
}

