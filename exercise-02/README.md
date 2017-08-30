# Exercise 02a

This code creates a versioned S3 bucket to use as a Terraform backend, as well as a DynamoDB table to use for locking.




## Quick start


To deploy this module:

1. Install [Terraform](https://www.terraform.io/)

1. Open up `vars.tf`, set the environment variables specified at the top of the file, and fill in `default` values for 
   any variables in the "REQUIRED PARAMETERS" section.

1. Run `terraform init`

1. Run `terraform plan`

1. If the plan looks good, run `terraform apply`
  
1. Edit `main.tf`, uncomment the `backend` block, and fill in the S3 bucket name and DynamoDB lock table name with the 
   names of the bucket and table you just created. Unfortunately, Terraform does not support interpolation in the
   `backend` configuration, so there is no way to re-use variables or prompt the user for these, and we must do this
   process manually.
   
1. Run `terraform init`

1. Run `terraform plan`

1. If the plan looks good, run `terraform apply`
