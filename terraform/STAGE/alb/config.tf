terraform {
  backend "s3" {
    bucket = "staging-acs730-project" // Bucket where to SAVE Terraform State
    key    = "stage/alb/terraform.tfstate"  // Name in the bucket to SAVE Terraform State
    region = "us-east-1"                    // Bucket created region
  }
}
