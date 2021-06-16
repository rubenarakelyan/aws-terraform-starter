#!/bin/bash
#
# This is a wrapper for Terraform to make running projects easier.
# It takes two arguments: the command (e.g. "plan" or "apply") and the
# project name (e.g. "infra-security").
#

set -e

while getopts "c:p:h" option
do
  case $option in
    c ) CMD=$OPTARG ;;
    p ) PROJECT=$OPTARG ;;
    h|* ) HELP=1 ;;
  esac
done

function show_help() {
  cat <<EOM
usage: $0 -c -p

     -c   The Terraform command to run, e.g. "plan" or "apply".
     -p   The project to create, e.g. "infra-security".
     -h   Display this message.

Any remaining arguments are passed to Terraform
e.g. $0 -c plan -p bar -- -var further=override
     will pass "-var further=override" to Terraform
EOM
}

function show_error_message() {
  echo -e "ERROR: $*\n"
  show_help
  exit 1
}

# Catch the -h option, display usage info and exit
if [[ $HELP = "1" ]]; then
  show_help
  exit
fi

# Un-shift all the parsed arguments
shift "$((OPTIND - 1))"

# Set up our locations
TERRAFORM_DIR="./terraform"
PROJECT_DIR="${TERRAFORM_DIR}/projects/${PROJECT}"
BACKEND_FILE="terraform.backend"
TFVARS_FILE="terraform.tfvars"
VAR_FILE=""

# Check for the terraform command
if [[ -z $(command -v terraform) ]]; then
  show_error_message "Terraform not found, please make sure it is installed."
fi

# Check we have all the arguments we need
if [[ -z $CMD ]]; then
  show_error_message "Specify the Terraform command to run, e.g. \"plan\" or \"apply\"."
elif [[ -z $PROJECT ]]; then
  show_error_message "Specify which project to run, e.g. \"infra-security\"."
elif [[ ! -d $PROJECT_DIR ]]; then
  show_error_message "Could not find $PROJECT directory: $PROJECT_DIR"
fi

# Run everything from the appropriate project
cd "$PROJECT_DIR"

# Check if there's a tfvars file to load
if [[ -f $TFVARS_FILE ]]; then
  VAR_FILE="-var-file=${TFVARS_FILE}"
fi

# Run the command
rm -rf .terraform && \
rm -rf terraform.tfstate.backup && \
aws-vault exec username -- terraform init -backend-config "$BACKEND_FILE" && \
aws-vault exec username -- terraform $CMD $VAR_FILE $*

# Reset the current working directory
cd -
