# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY TWO MICROSERVICES: FRONTEND AND BACKEND
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE FRONTEND
# ---------------------------------------------------------------------------------------------------------------------

module "frontend" {
  source = "./microservice"

  name                  = "frontend"
  ami_id                = "${var.frontend_ami_id}"
  size                  = 3
  key_name              = "${var.key_name}"
  user_data_script_name = "user-data-frontend.sh"
  server_text           = "${var.frontend_server_text}"
  is_internal_alb       = false

  # Pass an output from the backend module to the frontend module. This is the URL of the backend microservice, which
  # the frontend will use for "service calls"
  backend_url = "${module.backend.url}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE BACKEND
# ---------------------------------------------------------------------------------------------------------------------

module "backend" {
  source = "./microservice"

  name                  = "backend"
  ami_id                = "${var.backend_ami_id}"
  size                  = 3
  key_name              = "${var.key_name}"
  user_data_script_name = "user-data-backend.sh"
  server_text           = "${var.backend_server_text}"
  is_internal_alb       = true
}
