resource "random_string" "admin_username" {
  count   = var.generate_credentials ? 1 : 0
  length  = var.admin_username_length
  special = false
  upper   = true
  lower   = true
  numeric = true

  # Do not rotate the username on every apply.
  lifecycle {
    ignore_changes = [length, special, upper, lower, numeric]
  }
}

resource "random_password" "admin_password" {
  count            = var.generate_credentials ? 1 : 0
  length           = var.admin_password_length
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  upper            = true
  lower            = true
  numeric          = true

  # Do not rotate the password on every apply.
  lifecycle {
    ignore_changes = [length, special, override_special, upper, lower, numeric]
  }
}

locals {
  effective_admin_username = var.generate_credentials ? random_string.admin_username[0].result : var.admin_username
  effective_admin_password = var.generate_credentials ? random_password.admin_password[0].result : var.admin_password
}
