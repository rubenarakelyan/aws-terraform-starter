#!/bin/bash
#
# This is a wrapper for AWS Vault to make running individual commands easier.
# Any arguments are passed via `aws-vault`.
#

aws-vault exec username -- "$@"
