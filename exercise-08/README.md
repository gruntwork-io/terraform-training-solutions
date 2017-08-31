# Exercise 08

This code deploys two environments: stage and prod. Within each environment, we deploy two "microservices": a frontend 
that returns HTML and a backend that returns JSON. Both microservices are built on top of a module that runs them in 
an Auto Scaling Group (ASG) with an Application Load Balancer (ALB) in front of it. The frontend talks to the backend 
via the backend's ALB.

Note that we use [Terragrunt](https://github.com/gruntwork-io/terragrunt) to keep the code DRY.




## Quick start

*Note: you must deploy the backend in each environment before the frontend!*

To deploy these modules:

1. Install [Terraform](https://www.terraform.io/)

1. Install [Terragrunt](https://github.com/gruntwork-io/terragrunt)

1. Open up `live/terraform.tfvars` and fill in the variables labeled with a `TODO`

1. `cd` into the module you want to deploy in the `live` folder.

1. Open up `terraform.tfvars`, set the environment variables specified at the top of the file, and fill in variables
   labeled with a `TODO`.

1. Run `terragrunt plan`

1. If the plan looks good, run `terragrunt apply`
