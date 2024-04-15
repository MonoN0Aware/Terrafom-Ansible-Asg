# environments/prod.tfvars
env                  = "prod"
main_cidr_block       = "10.20.0.0/16"
public_subnet_cidr_blocks = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
private_subnet_cidr_blocks = ["10.20.4.0/24", "10.20.5.0/24", "10.20.6.0/24"]
instance_type        = "t2.micro"
prefix               = "G11"
