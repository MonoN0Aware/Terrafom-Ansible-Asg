provider "aws" {
  region = "us-east-1"  
}

module "networking" {
  source        = "./STAGE/Networking"
  env   = var.env
  main_cidr_block  = var.main_cidr_block
  public_subnet_cidr_blocks   = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks  = var.private_subnet_cidr_blocks
  
}