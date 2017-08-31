# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
terragrunt = {
  # Configure Terragrunt to automatically store tfstate files in an S3 bucket
  remote_state {
    backend = "s3"
    config {
      region     = "us-east-1"
      key        = "exercise-08/${path_relative_to_include()}/terraform.tfstate"
      encrypt    = true

      # TODO: fill in the name of the S3 bucket where these modules should store remote state
      # bucket     = ""

      # TODO: fill in the name of a DynamoDB table that can be used for locking
      # lock_table = ""
    }
  }
}
