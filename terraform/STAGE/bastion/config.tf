terraform {
  backend "s3" {
    bucket = "staging-acs730-project"            // Bucket where to SAVE Terraform State
    key    = "staging/bastion/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                         // Region where bucket is created
  }
}
