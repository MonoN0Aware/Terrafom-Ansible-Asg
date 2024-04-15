
#  Define the provider
provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}
data "terraform_remote_state" "staging" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "acs730-project-staging"    // Bucket from where to GET Terraform State
    key    = "staging/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                 // Region where bucket created
  }
}
resource "aws_key_pair" "web_key" {
  key_name   = "webkey"
  public_key = file("webkey.pub")
}

locals {
  default_tags = {
    Environment = "staging",
    Project     = "myproject",
    # Add any other default tags you want to include
  }
}

# Bastion deployment
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.staging.outputs.public_subnet_ids[0]
  security_groups             = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true


  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-bastion"
    }
  )
}

# Security Group for Bastion host
resource "aws_security_group" "bastion_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.staging.outputs.vpc_id

  ingress {
    description = "SSH from private IP of CLoud9 machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

