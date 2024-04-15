# Instance type
variable "instance_type" {
  default = {
   
    "staging" = "t3.small"
    
  }
  description = "Type of the instance"
  type        = map(string)
}

# Variable to signal the current environment 
variable "env" {
  default     = "staging"
  type        = string
  description = "Deployment Environment"
}

variable "my_private_ip" {
  type        = string
  default     = "172.31.58.62"
  description = "Private IP of my Cloud 9 station to be opened in bastion ingress"
}

variable "my_public_ip" {
  type        = string
  default     = "18.208.120.242"
  description = "Public IP of my Cloud 9 station to be opened in bastion ingress"
}

variable "prefix" {
  default     = "realistic-slice"
  type        = string
  description = "Name prefix"
}
