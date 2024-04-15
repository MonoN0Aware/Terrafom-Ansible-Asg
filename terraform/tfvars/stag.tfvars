# environments/dev.tfvars
env                  = "stag"
main_cidr_block       = "10.0.0.0/16"
public_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidr_blocks = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
instance_type        = "t2.micro"
prefix               = "G11"
default_tags = {
  "Owner" = "Group11"
  "App"   = "Web"
}