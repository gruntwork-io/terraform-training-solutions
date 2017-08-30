# Terraform Training Solutions

This repo contains the solutions for the exercises in the Infrastructure as Code with Terraform Workshop. 




## Quick start

To deploy one of the solutions, do thehe following:

1. Install [Terraform](https://www.terraform.io/)

1. Open up `vars.tf` for the module you're trying to deploy, set any environment variables specified at the top of the
   file, and fill in `default` values for any variables that don't have them in the "REQUIRED PARAMETERS" section.

1. A few of the modules use S3 as a Terraform backend. S3 bucket names have to be unique, but unfortunately, Terraform
   does not support interpolation when configuring a backend, so there is no way to prompt the user for a bucket name.
   Therefore, we had to comment out the `backend` section entirely. Open up `main.tf`, uncomment the `backend`, and
   fill in a unique S3 bucket name.

1. Run `terraform init`

1. Run `terraform plan`

1. If the plan looks good, run `terraform apply`    

