# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name for the microservice and all resources in this module"
}

variable "size" {
  description = "The number of servers to run in the ASG for this microservice"
}

variable "ami_id" {
  description = "The ID of the AMI to run for this microservice"
}

variable "aws_region" {
  description = "The AWS region to deploy into"
}

variable "is_internal_alb" {
  description = "If set to true, the ALB will be internal, and therefore only accessible from within the VPC"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "key_name" {
  description = "The name of the EC2 Key Pair that can be used to SSH to the EC2 Instances. Leave blank to not associate a Key Pair with the Instances."
  default     = ""
}

variable "server_http_port" {
  description = "The port the EC2 Instances should listen on for HTTP requests"
  default     = 8080
}

variable "alb_http_port" {
  description = "The port the ALB should listen on for HTTP requests"
  default     = 80
}

variable "server_text" {
  description = "The text the server should return for HTTP requests"
  default     = "Hello, World"
}

variable "include_backend_url" {
  description = "If set to true, fetch the backend's URL from remote state and pass it to the User Data script"
  default     = false
}

variable "backend_remote_state_s3_bucket" {
  description = "The name of the S3 bucket where the backend stores its remote state. Required if var.include_backend_url is true."
  default     = ""
}

variable "backend_remote_state_s3_key" {
  description = "The path in the S3 bucket where the backend stores its remote state. Required if var.include_backend_url is true."
  default     = ""
}