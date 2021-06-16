output "terraform_access_key_id" {
  value       = aws_iam_access_key.terraform.id
  description = "Access key ID for Terraform user"
}

output "terraform_secret_access_key" {
  value       = aws_iam_access_key.terraform.secret
  description = "Secret access key for Terraform user"
  sensitive   = true
}
