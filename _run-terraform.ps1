# Script to run a single, independent Terraform stack.
# Each stack (postgres, keycloak, ...) has its own state, so running one
# never risks planning changes/destruction on another.
#
# Usage:
#   ./_run-terraform.ps1 <stack> [--apply]
#
# Examples:
#   ./_run-terraform.ps1 postgres
#   ./_run-terraform.ps1 postgres --apply
#   ./_run-terraform.ps1 keycloak --apply


# Stop script if missing dependency
$required_commands = 'terraform'
foreach ($command in $required_commands) {
    if (!(Get-Command -errorAction SilentlyContinue -Name $command)) {
        echo "error: required command not found in the PATH: $command"
        exit 1
    }
}


# Validate stack argument
$stack = $args[0]
$available_stacks = 'postgres', 'keycloak'
if (-not $stack -or ($available_stacks -notcontains $stack)) {
    echo "error: missing or unknown stack name."
    echo "usage: ./_run-terraform.ps1 <stack> [--apply]"
    echo "available stacks: $($available_stacks -join ' ')"
    exit 1
}

$stack_dir = "stacks/$stack"
if (!(Test-Path $stack_dir -PathType Container)) {
    echo "error: stack directory not found: $stack_dir"
    exit 1
}


# Get value of a variable declared in a given file from this pattern: variable = "value"
# Usage: get_var_value <file> <variable>
function get_var_value {
    param($File, $Variable)

    # Anchor on the variable name at the start of the line (ignoring leading
    # whitespace) to avoid matching substrings, e.g. "tenant" inside
    # "azure_entra_tenant_id".
    $value = (cat $File | select-string "^\s*$Variable\s*=" | select-string -Pattern '#.*' -NotMatch | select -first 1)
    $value -replace '.*=.*\"(.*)\".*','$1'
}
$tfvars_file = "$stack_dir/terraform.tfvars"
$cloud_provider = (get_var_value $tfvars_file 'cloud_provider')
$cluster_region = (get_var_value $tfvars_file 'cluster_region')
$cluster_domain = (get_var_value $tfvars_file 'cluster_domain')
$cluster_name = $cluster_domain.Split('.')[0]
$tenant = (get_var_value $tfvars_file 'tenant')

# One state per (stack): isolates postgres from keycloak.
# "tenant" is optional: some stacks (e.g. postgres) are not tenant-scoped.
if ($tenant) {
    $state_file_name = "tfstate-$cluster_name-tenant-$tenant-$stack"
} else {
    $state_file_name = "tfstate-$cluster_name-$stack"
}

# Clear old data, scoped to the stack directory
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$stack_dir/.terraform*"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$stack_dir/terraform.tfstate*"


# Automatically detect all the $TEMPLATE variables from a given a file,
# and replace them with the value that the same variable has in the current script.
# Usage: prepare_target_file <source file> <target file>
function prepare_target_file {
    param($SourceFile, $TargetFile)

    Remove-Item -Force -ErrorAction SilentlyContinue $TargetFile
    Copy-Item -Force $SourceFile $TargetFile

    $needed_variables = (cat $TargetFile | select-string 'TEMPLATE_' | ForEach-Object { $_ -replace '.*TEMPLATE_([a-zA-Z_]*).*', '$1' } | select -unique)
    foreach ($var in $needed_variables) {
        $value = Get-Variable -Name $var -ValueOnly -ErrorAction SilentlyContinue

        (Get-Content $TargetFile) -replace "\`$TEMPLATE_$var", $value | Set-Content $TargetFile
    }
}
$target_file = "$stack_dir/target.tf"


# The trick here is to write configuration in a dynamic file created at the begin of the
# execution, containing the config that the concerned provider is waiting for Terraform backend.
# Then, Terraform will automatically detects it from its .tf extension.
# NOTE: templates in targets/ are SHARED across all stacks; only the
# state_file_name (and therefore the backend "key") differs per stack.
switch ([string]$cloud_provider) {
    "azure" {
        # Azure storage account names must be 3-24 chars, lowercase alphanumeric only
        $azure_subscription_id = (get_var_value $tfvars_file 'azure_subscription_id')
        $sub_hash = ([System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($azure_subscription_id)) | ForEach-Object { $_.ToString("x2") }) -join ''
        $sub_hash = $sub_hash.Substring(0, 9)
        $state_storage_name = "csmstates$sub_hash"

        prepare_target_file "targets/$cloud_provider.target.tf" $target_file
    }

    "aws" {
        prepare_target_file "targets/$cloud_provider.target.tf" $target_file
    }

    "gcp" {
        prepare_target_file "targets/$cloud_provider.target.tf" $target_file
    }

    "kob" {
        $state_host = (get_var_value $tfvars_file 'state_host')
        $state_url = "$state_host/$state_file_name"

        if (([string]::IsNullOrEmpty($env:TF_HTTP_USERNAME)) -or ([string]::IsNullOrEmpty($env:TF_HTTP_PASSWORD))) {
            echo "error: empty TF_HTTP_USERNAME or TF_HTTP_PASSWORD (required for backend authentication)"
            echo '  $Env:TF_HTTP_USERNAME = ""'
            echo '  $Env:TF_HTTP_PASSWORD = ""'
            exit 1
        } else {
            echo "found TF_HTTP_USERNAME & TF_HTTP_PASSWORD"
        }

        $env:TF_CLI_ARGS += ';-lock=false'

        prepare_target_file "targets/$cloud_provider.target.tf" $target_file
    }

    default {
        Write-Host "error: unknown or empty cloud_provider from $tfvars_file" -ForegroundColor Red
        exit 1
    }
}


# Deploy, scoped to the stack directory
# NOTE: use array splatting (@array) rather than inline tokens, so that
# PowerShell reliably expands each argument when invoking the native
# terraform executable (avoids "-chdir"/"-out" argument mangling).
& terraform @("-chdir=$stack_dir", "fmt", "target.tf")
& terraform @("-chdir=$stack_dir", "init", "-upgrade", "-reconfigure")
& terraform @("-chdir=$stack_dir", "plan", "-var-file=terraform.tfvars", "-out", ".terraform.plan")

$option_apply = '--apply'
if ($args[1] -eq $option_apply) {
    & terraform @("-chdir=$stack_dir", "apply", ".terraform.plan")
    echo ""
    echo "Sensitive outputs are hidden above. Reveal one with:"
    Write-Host "  terraform -chdir=$stack_dir output -raw <output_name>" -ForegroundColor Magenta
} else {
    echo ""
    echo "Terraform plan can be applied with:"
    Write-Host "  ./_run-terraform.ps1 $stack $option_apply" -ForegroundColor Magenta
}


echo ""
if ($tenant) {
    Write-Host "target is $cluster_name/tenant-$tenant (stack: $stack)" -ForegroundColor Magenta
} else {
    Write-Host "target is $cluster_name (stack: $stack)" -ForegroundColor Magenta
}


exit 0
