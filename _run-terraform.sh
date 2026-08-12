#!/bin/sh

# Script to run a single, independent Terraform stack.
# Each stack (postgres, keycloak, ...) has its own state, so running one
# never risks planning changes/destruction on another.
#
# Usage:
#   ./_run-terraform.sh <stack> [--apply]
#
# Examples:
#   ./_run-terraform.sh postgres
#   ./_run-terraform.sh postgres --apply
#   ./_run-terraform.sh keycloak --apply


# Colors
NO_FORMAT="\033[0m"
FG_COLOR_INFO="\033[38;5;141m"
FG_COLOR_WARN="\033[38;5;203m"


# Stop script if missing dependency
required_commands="terraform"
for command in $required_commands; do
	if [ -z "$(command -v $command)" ]; then
		echo "error: required command not found: \e[91m$command\e[97m"
        exit 1
	fi
done


# Validate stack argument
stack="$1"
available_stacks="postgres keycloak"
case " $available_stacks " in
  *" $stack "*) ;;
  *)
    echo "error: missing or unknown stack name."
    echo "usage: $0 <stack> [--apply]"
    echo "available stacks: $available_stacks"
    exit 1
    ;;
esac

stack_dir="stacks/$stack"
if [ ! -d "$stack_dir" ]; then
    echo "error: stack directory not found: $stack_dir"
    exit 1
fi


# Get value of a variable declared in a given file from this pattern: variable = "value"
# Usage: get_var_value <file> <variable>
get_var_value() {
    local file=$1
    local variable=$2

    cat $file | grep '=' | grep -w $variable | sed '/.*#.*/d' | sed 's|.*=.*"\(.*\)".*|\1|' | head -n 1
}
tfvars_file="$stack_dir/terraform.tfvars"
cloud_provider="$(get_var_value $tfvars_file cloud_provider)"
cluster_region="$(get_var_value $tfvars_file cluster_region)"
cluster_domain="$(get_var_value $tfvars_file cluster_domain)"
cluster_name="$(echo $cluster_domain | cut -d . -f 1)"
tenant="$(get_var_value $tfvars_file tenant)"

# One state per (stack): isolates postgres from keycloak.
# "tenant" is optional: some stacks (e.g. postgres) are not tenant-scoped.
if [ -n "$tenant" ]; then
  state_file_name="tfstate-$cluster_name-tenant-$tenant-$stack"
else
  state_file_name="tfstate-$cluster_name-$stack"
fi

# Generate state_storage_name for Azure backend
# Azure storage account names must be 3-24 chars, lowercase alphanumeric only
azure_subscription_id="$(get_var_value $tfvars_file azure_subscription_id)"
sub_hash="$(echo -n "$azure_subscription_id" | sha256sum | cut -c1-9)"
state_storage_name="csmstates${sub_hash}"

# Clear old data, scoped to the stack directory
rm -rf $stack_dir/.terraform*
rm -rf $stack_dir/terraform.tfstate*


# Automatically detect all the $TEMPLATE variables from a given a file,
# and replace them with the value that the same variable has in the current script.
# Usage: prepare_target_file <source file> <target file>
prepare_target_file() {
  local source_file=$1
  local target_file=$2

  rm -f $target_file
  cp -f $source_file $target_file

  local needed_variables="$(cat $target_file | grep TEMPLATE_ | sed 's|.*TEMPLATE_\([a-zA-Z_]*\).*|\1|' | sort -u)"
  for var in $needed_variables; do

    # Declare the TEMPLATE_variable
    eval value=\$$var

    # Replace TEMPLATE with the actual value
    sed -i "s|\$TEMPLATE_$var|$value|" $target_file
  done
}
target_file="$stack_dir/target.tf"


# The trick here is to write configuration in dynamic files created at the begin of the
# execution, containing the config that the concerned provider is waiting for Terraform backend.
# Then, Terraform will automatically detects it from its .tf extension.
# NOTE: templates in targets/ are SHARED across all stacks; only the
# state_file_name (and therefore the backend "key") differs per stack.
case "$(echo $cloud_provider)" in
  'azure')
    prepare_target_file "targets/$cloud_provider.target.tf" $target_file
    ;;

  'aws')
    prepare_target_file "targets/$cloud_provider.target.tf" $target_file
    ;;

  'gcp')
    prepare_target_file "targets/$cloud_provider.target.tf" $target_file
    ;;

  'kob')
    state_url="$(get_var_value $tfvars_file state_host)/$state_file_name"

    if [ -z $TF_HTTP_USERNAME ] || [ -z $TF_HTTP_PASSWORD ]; then
        echo "error: empty TF_HTTP_USERNAME or TF_HTTP_PASSWORD (required for backend authentication)"
        echo "  export TF_HTTP_USERNAME="
        echo "  export TF_HTTP_PASSWORD="
        exit 1
    else
        echo "found TF_HTTP_USERNAME & TF_HTTP_PASSWORD"
    fi

    export TF_CLI_ARGS="-lock=false"

    prepare_target_file "targets/$cloud_provider.target.tf" $target_file
    ;;

  *)
    echo "error: unknown or empty $FG_COLOR_WARN'cloud_provider'$NO_FORMAT from $tfvars_file"
    exit 1
    ;;
esac


# Deploy, scoped to the stack directory
terraform -chdir=$stack_dir fmt target.tf
terraform -chdir=$stack_dir init -upgrade -reconfigure
terraform -chdir=$stack_dir plan -var-file=terraform.tfvars -out .terraform.plan

option_apply='--apply'
if [ "$(echo $2)" = "$option_apply" ]; then
  terraform -chdir=$stack_dir apply .terraform.plan
  echo "$NO_FORMAT"
  echo "Sensitive outputs are hidden above. Reveal one with:"
  echo "$FG_COLOR_INFO  terraform -chdir=$stack_dir output -raw <output_name>$NO_FORMAT"
else
  echo "$NO_FORMAT"
  echo 'Terraform plan can be applied with:'
  echo "$FG_COLOR_INFO  $0 $stack $option_apply"
fi


tenant_name="tenant-$tenant"
echo "$NO_FORMAT"
if [ -n "$tenant" ]; then
  echo "target is $FG_COLOR_INFO$cluster_name/$tenant_name (stack: $stack)"
else
  echo "target is $FG_COLOR_INFO$cluster_name (stack: $stack)"
fi


echo "$NO_FORMAT"
exit 0
