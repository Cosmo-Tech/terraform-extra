provider "keycloak" {
  url      = "http://localhost:8080"
  username = "admin"
  password = "admin"
  initial_login = true
  client_id = "admin-cli"
  realm    = "master"
  tls_insecure_skip_verify = true
}

variables {
  tenant        = "tenant-test"
  cluster_domain  = "localhost"
}

run "verify_automation_client_creation" {
  command = plan
  variables {
    tenant        = var.tenant
    cluster_domain  = var.cluster_domain
  }
  assert {
    condition     = keycloak_openid_client.automation-client.client_id == "automation-client"
    error_message = "Keycloak automation client should be created"
  }
}
