# Getting started

## Preparing your local environment

Follow these steps to set up your local environment so you can run Terraform and AWS commands.

### Windows

* Install `awscli`, `aws-vault` and `terraform` using [Chocolatey](https://chocolatey.org/)
* Run `aws-vault add <username>` and enter your AWS access key ID and secret access key (provided when your user is created; `username` is a name of your choice)
* Find your MFA serial - log into the AWS Console at https://console.aws.amazon.com/, then click your name at the top right, choose "My Security Credentials", scroll down to the "Multi-factor authentication" section and copy the assigned MFA device ARN, which looks like `arn:aws:iam::123456789012:mfa/user`
* Edit the file `C:\Users\<username>\.aws\config` in a text editor - find the line `[profile <username>]` and under it, add:

```
region=eu-west-2
mfa_serial=<MFA serial>
```

* Test your configuration by running `aws-vault exec <username> -- aws s3 ls` - you should see a list of all S3 buckets in the account

### macOS

* Install `awscli`, `aws-vault` and `terraform` using [Homebrew](https://brew.sh/)
* Run `aws-vault add <username>` and enter your AWS access key ID and secret access key (provided when your user is created; `username` is a name of your choice)
* Find your MFA serial - log into the AWS Console at https://console.aws.amazon.com/, then click your name at the top right, choose "My Security Credentials", scroll down to the "Multi-factor authentication" section and copy the assigned MFA device ARN, which looks like `arn:aws:iam::123456789012:mfa/user`
* Edit the file `~/.aws/config` in a text editor - find the line `[profile <username>]` and under it, add:

```
region=eu-west-2
mfa_serial=<MFA serial>
```

* Test your configuration by running `aws-vault exec <username> -- aws s3 ls` - you should see a list of all S3 buckets in the account

## Deploying a project

The following arguments are accepted:

* `-c` (command) can be `plan`, or `apply` (`plan` outputs a diff of changes without applying them whereas `apply` (after asking for confirmation) will go ahead and make the changes)
* `-p` (project) is the name of the project to run

### Windows

> NOTE: All PowerShell scripts need to be run with the default execution policy bypassed. You can do this by running PowerShell as `powershell.exe -ExecutionPolicy Bypass`.

To deploy a Terraform project, run `.\tools\build.ps1 -c plan -p <project-directory>`.

### macOS

To deploy a Terraform project, run `./tools/build.sh -c plan -p <project-directory>`.
