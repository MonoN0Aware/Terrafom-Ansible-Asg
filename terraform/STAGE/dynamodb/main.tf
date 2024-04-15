# Define the provider (AWS)
provider "aws" {
  region = "us-east-1" # Modify to your desired AWS region
}

data "aws_availability_zones" "available" {}


resource "aws_dynamodb_table" "lock_state" {
  name           = "terraform-lock-state"
  hash_key       = "LockID"
  read_capacity  = 4
  write_capacity = 4
  attribute {
    name = "LockID"
    type = "S"
  }
}
