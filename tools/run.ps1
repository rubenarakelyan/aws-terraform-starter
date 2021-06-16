#
# This is a wrapper for AWS Vault to make running individual commands easier.
# Any arguments are passed via `aws-vault`.
#

[CmdletBinding(PositionalBinding = $false)]

param (
  [parameter(ValueFromRemainingArguments = $true)][string[]]$args
)

Invoke-Expression "aws-vault exec username -- $args"
