resource "random_string" "admin_username" {
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
  # Azure requires the admin username to NOT start with a digit. random_string
  # can produce a leading digit since "numeric = true" applies to every
  # position; force the first character to be a letter ("a") in that case,
  # keeping the same overall length.
  effective_admin_username = (
    can(regex("^[0-9]", random_string.admin_username.result))
    ? "a${substr(random_string.admin_username.result, 1, -1)}"
    : random_string.admin_username.result
  )
  effective_admin_password = random_password.admin_password.result
}
