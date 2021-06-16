/**
* ## Project: security
*
* Apply the following infrastructure security settings:
*  - Default IAM password policy
*  - Create an IAM user with access key for Terraform
*/

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

terraform {
  required_version = "~> 0.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    region  = "eu-west-2"
    key     = "security.tfstate"
    encrypt = true
  }
}

provider "aws" {
  profile = "username"
  region  = var.aws_region
}

# Apply a strong password policy to all IAM users
resource "aws_iam_account_password_policy" "password_policy" {
  allow_users_to_change_password = true
  max_password_age             = 90
  minimum_password_length      = 14
  password_reuse_prevention    = 24
  require_lowercase_characters = true
  require_numbers              = true
  require_symbols              = true
  require_uppercase_characters = true
}

# Create an IAM user with a policy to be used for applying Terraform
resource "aws_iam_user" "terraform" {
  name = "terraform"
}

data "template_file" "terraform_policy_template" {
  template = file("${path.module}/../../policies/terraform_policy.json")
}

resource "aws_iam_user_policy" "terraform_policy" {
  name   = "terraform-policy"
  user   = aws_iam_user.terraform.name
  policy = data.template_file.terraform_policy_template.rendered
}

resource "aws_iam_access_key" "terraform" {
  user = aws_iam_user.terraform.name
}
