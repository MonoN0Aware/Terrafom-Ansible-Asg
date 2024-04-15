
variable "default_tags" {
  default = {
    "Owner" = "Group11"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}


variable "prefix" {
  default     = "Group11"
  type        = string
  description = "Name prefix"
}
# Variable to signal the current environment 
variable "env" {
  description = "Environment (dev, stag, or prod)"
}


variable "main_cidr_block" {
  description = "stag-vpc cidr"
}





variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Type of the instance"
  type        = string
}

