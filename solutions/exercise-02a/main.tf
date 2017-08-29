# ---------------------------------------------------------------------------------------------------------------------
# CREATE A VERSIONED S3 BUCKET AS A TERRAFORM BACKEND AND A DYNAMODB TABLE FOR LOCKING
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE S3 AS A BACKEND
# Note that this has been commented out because of a slightly awkward chicken and egg: you must first apply this
# module without a backend to create the S3 bucket and DynamoDB table and only then can you uncomment the section
# below and run terraform init to use this module with a backend.
# ---------------------------------------------------------------------------------------------------------------------

#terraform {
#  backend "s3" {
#    region         = "us-east-1"
#    bucket         = "iac-workshop-example-bucket"
#    key            = "exercise-02a/terraform.tfstate"
#    encrypt        = true
#    dynamodb_table = "terraform-locks-example"
#  }
#}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE S3 BUCKET
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "remote_state" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE DYNAMODB TABLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_dynamodb_table" "terraform_locks" {
  name           = "${var.dynamodb_lock_table_name}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}