terraform {
  backend "http" {
    update_method          = "PUT"
    lock_method            = "POST"
    unlock_method          = "DELETE"
    skip_cert_verification = true

    address        = "$TEMPLATE_state_url"
    lock_address   = "$TEMPLATE_state_url/lock"
    unlock_address = "$TEMPLATE_state_url/lock"
  }
}

variable "state_host" { type = string }
