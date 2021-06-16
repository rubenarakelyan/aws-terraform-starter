#
# This is a wrapper for Terraform to make running projects easier.
# It takes two arguments: the command (e.g. "plan" or "apply") and the
# project name (e.g. "infra-security").
#

[CmdletBinding(PositionalBinding = $false)]

param (
  [string]$c,
  [string]$p,
  [switch]$h = $false,
  [parameter(ValueFromRemainingArguments = $true)][string[]]$args
)

function Show-Help {
  Write-Output @"
usage: $PSCommandPath -c -p

     -c   The Terraform command to run, e.g. "plan" or "apply".
     -p   The project to create, e.g. "infra-security".
     -h   Display this message.

Any remaining arguments are passed to Terraform
e.g. $PSCommandPath -c plan -p bar -- -var further=override
     will pass "-var further=override" to Terraform
"@
}

function Show-Error-Message {
  param (
    [parameter(position=0)]
    [string]$message
  )
  Write-Output "ERROR: $message`n"
  Show-Help
  exit
}

# Catch the -h option, display usage info and exit
if ($h -eq $true) {
  Show-Help
  exit
}

# Set up our locations
$terraform_dir = "./terraform"
$project_dir = "$terraform_dir/projects/$p"
$backend_file = "terraform.backend"
$tfvars_file = "terraform.tfvars"
$var_file = ""

# Check for the terraform command
if ((Get-Command "terraform" -ErrorAction SilentlyContinue) -eq $null) {
  Show-Error-Message "Terraform not found, please make sure it is installed."
}

# Check we have all the arguments we need
if ($PSBoundParameters.ContainsKey("c") -eq $false) {
  Show-Error-Message "Specify the Terraform command to run, e.g. `"plan`" or `"apply`"."
} elseif ($PSBoundParameters.ContainsKey("p") -eq $false) {
  Show-Error-Message "Specify which project to run, e.g. `"infra-security`"."
} elseif ((Test-Path -Path "$project_dir") -eq $false) {
  Show-Error-Message "Could not find $p directory: $project_dir"
}

# Run everything from the appropriate project
Push-Location -Path "$project_dir"

# Check if there's a tfvars file to load
if (Test-Path -Path "$tfvars_file" -PathType Leaf) {
  $var_file = "-var-file=`"$tfvars_file`""
}

# Run the command
Remove-Item .terraform -Recurse -Force -ErrorAction Ignore
Remove-Item terraform.tfstate.backup -Recurse -Force -ErrorAction Ignore
Invoke-Expression "aws-vault exec username -- terraform init -backend-config `"$backend_file`""
Invoke-Expression "aws-vault exec username -- terraform $c $var_file $args"

# Reset the current working directory
Pop-Location
