output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}

output "load_balancer_dns_name" {
  value = aws_lb.alb.dns_name
}

