# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE BACKEND MICROSERVICE
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE S3 AS A BACKEND
# Note that this has been commented out because Terraform does not allow interpolations in the backend configuration,
# but the S3 bucket name needs to be globally unique, so you have to uncomment the code below and specify it by hand.
# ---------------------------------------------------------------------------------------------------------------------

# TODO: uncomment!!
#terraform {
#  backend "s3" {
#    region         = "us-east-1"
#    bucket         = "iac-workshop-example-bucket"
#    key            = "exercise-06/stage/backend/terraform.tfstate"
#    encrypt        = true
#    dynamodb_table = "terraform-locks-example"
#  }
#}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE BACKEND
# ---------------------------------------------------------------------------------------------------------------------

module "backend" {
  source = "../../../modules/microservice"

  name                  = "backend-stage"
  size                  = 2
  key_name              = "${var.key_name}"
  user_data_script_name = "user-data-backend.sh"
  server_text           = "${var.backend_server_text}"
  is_internal_alb       = true
}