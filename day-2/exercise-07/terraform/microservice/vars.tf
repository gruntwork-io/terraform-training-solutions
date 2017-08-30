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
  description = "The ID of the AMI to deploy for this microservice"
}

variable "user_data_script_name" {
  description = "The name of the User Data script in this module's user-data folder that this microservice should run when it's booting. Should be one of user-data-backend.sh or user-data-frontend.sh."
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

variable "backend_url" {
  description = "The URL the frontend can use to reach the backend. Leave blank if this is not a frontend."
  default     = ""
}
