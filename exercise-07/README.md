# Exercise 07

This folder contains two types of modules:

* **Packer**: Packer template to build AMIs for sample frontend and backend microservices.
* **Terraform**: Terraform configurations to deploy the frontend and backend AMIs across an Auto Scaling Group.




## Quick start


To deploy the microservices, you need to:

1. [Build the AMIs](#build-the-amis)
1. [Deploy the AMIs using Terraform](#deploy-the-amis-using-terraform)


### Build the AMIs

1. Install [Packer](https://www.packer.io/)

1. Run `packer build packer/frontend/frontend.json`. Note down the AMI ID you get at the end.

1. Run `packer build packer/backend/backend.json`. Note down the AMI ID you get at the end.


### Deploy the AMIs using Terraform

1. Install [Terraform](https://www.terraform.io/)

1. Run `cd terraform`

1. Open up `vars.tf`, set the environment variables specified at the top of the file, and fill in `default` values for 
   any variables in the "REQUIRED PARAMETERS" section. This includes plugging in the AMI IDs from the previous section
   into the `frontend_ami_id` and `backend_ami_id` variables.

1. Run `terraform init`

1. Run `terraform plan`

1. If the plan looks good, run `terraform apply`
