# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
  default     = "us-east-1"
}

variable "name" {
  description = "The name for the EC2 Instance and all other resources in this module."
  default     = "example-web-server"
}

variable "key_name" {
  description = "The name of the EC2 Key Pair that can be used to SSH to the EC2 Instance. Leave blank to not associate a Key Pair with the Instance."
  default     = ""
}

variable "http_port" {
  description = "The port the EC2 Instance should listen on for HTTP requests"
  default     = 8080
}

variable "server_text" {
  description = "The text the server should return for HTTP requests"
  default     = "Hello, World"
}