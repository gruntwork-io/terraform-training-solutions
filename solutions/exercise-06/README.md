# Exercise 06

This code deploys two environments: stage and prod. Within each environment, we deploy two "microservices": a frontend 
that returns HTML and a backend that returns JSON. Both microservices are built on top of a module that runs them in 
an Auto Scaling Group (ASG) with an Application Load Balancer (ALB) in front of it. The frontend talks to the backend 
via the backend's ALB.




## Quick start


To deploy these module:

1. Install [Terraform](https://www.terraform.io/)

1. `cd` into the module you want to deploy in the `live` folder.

1. Open up `vars.tf`, set the environment variables specified at the top of the file, and fill in `default` values for 
   any variables in the "REQUIRED PARAMETERS" section.

1. Open up `main.tf`, uncomment the `backend` section, and fill in values for the S3 bucket name and DynamoDB lock 
   table name you created in [exercise-02a](/solutions/exercise-02a). Unfortunately, Terraform does not support 
   interpolation in the `backend` configuration, so there is no way to re-use variables or prompt the user for these, 
   and we must do this process manually. 

1. Run `terraform init`

1. Run `terraform plan`

1. If the plan looks good, run `terraform apply`
