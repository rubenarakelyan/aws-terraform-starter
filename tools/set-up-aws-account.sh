#!/bin/bash
#
# This script runs the commands required to set up an AWS account for the first time.
#

aws-vault exec username -- aws s3 mb "s3://username-terraform-remote-state"
aws-vault exec username -- aws s3api put-bucket-versioning --bucket username-terraform-remote-state --versioning-configuration Status=Enabled
aws-vault exec username -- aws s3api put-bucket-encryption --bucket username-terraform-remote-state --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
