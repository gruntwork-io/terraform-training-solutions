# Exercise 03

This code deploys multiple web servers in AWS, each with a different Name tag. Each web server always returns "Hello, 
World" on port 8080.



## Quick start


To deploy this module:

1. Install [Terraform](https://www.terraform.io/)

1. Open up `vars.tf`, set the environment variables specified at the top of the file, and fill in `default` values for 
   any variables in the "REQUIRED PARAMETERS" section.

1. Run `terraform init`

1. Run `terraform plan`

1. If the plan looks good, run `terraform apply`
