# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that supports locking and enforces best
# practices: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terragrunt = {
  # Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
  # working directory, into a temporary folder, and execute your Terraform commands in that folder.
  terraform {
    source = "../../../modules/microservice"
  }

  # Include all settings from the root terraform.tfvars file
  include = {
    path = "${find_in_parent_folders()}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

aws_region      = "us-east-1"
name            = "frontend-stage"
size            = 2
is_internal_alb = false
server_text     = "Hello from frontend"
key_name        = ""

include_backend_url         = true
backend_remote_state_s3_key = "exercise-08/stage/backend/terraform.tfstate"

# TODO: fill in the ID of the AMI to run for the frontend microservice
# ami_id = ""

# TODO: fill in the variables below with the name/path of the S3 bucket where the backend stores its remote state
# backend_remote_state_s3_bucket = ""
