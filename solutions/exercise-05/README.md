# Exercise 05

This code deploys two "microservices": a frontend that returns HTML and a backend that returns JSON. Both microservices
are built on top of a module that runs them in an Auto Scaling Group (ASG) with an Application Load Balancer (ALB) in 
front of it. The frontend talks to the backend via the backend's ALB.




## Quick start


To deploy this module:

1. Install [Terraform](https://www.terraform.io/)

1. Open up `vars.tf`, set the environment variables specified at the top of the file, and fill in `default` values for 
   any variables in the "REQUIRED PARAMETERS" section.

1. Run `terraform init`

1. Run `terraform plan`

1. If the plan looks good, run `terraform apply`
