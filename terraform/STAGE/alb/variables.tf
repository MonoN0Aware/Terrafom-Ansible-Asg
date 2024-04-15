# Default tags
variable "default_tags" {
  default     = {}
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Name prefix
variable "prefix" {
  type        = string
  default     = "stage"
  description = "Name prefix"
}

# Variable for list of subnets to associate with the load balancer
variable "subnets" {
  description = "A list of subnets"
  type        = list(string)
  default     = null
}
# Variable for The security groups to attach to the load balancer
variable "security_groups" {
  description = "The security groups to attach to the load balancer"
  type        = list(string)
  default     = []
}
# Variable for VPC_ID
variable "vpc_id" {
  description = "VPC id"
  type        = string
  default     = null
}
variable "instance_type" {
  default = {
    "prod"  = "t3.medium"
    "stage" = "t2.small"
     "dev" = "t3.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}
# Variable to signal the current environment 
variable "env" {
  default     = "stage"
  type        = string
  description = "Deployment Environment"
}