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

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "staging-acs730-project" // Bucket from where to GET Terraform State
    key    = "${var.env}/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                    // Region where bucket created
  }
}


locals {
  default_tags = {
    Environment = "${var.env}",
    Project     = "Group11"
  }
}

resource "aws_launch_configuration" "rs-asg-stage-lc" {
  name_prefix     = "rs-asg-stage-lc"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = lookup(var.instance_type, var.env)
  key_name        = aws_key_pair.asg.key_name
  security_groups = [aws_security_group.rs-asg-sg_instance.id]


  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_key_pair" "asg" {
  key_name   = "asg"
  public_key = file("asg.pub")
}

resource "aws_key_pair" "bastion" {
  key_name   = "bastion"
  public_key = file("bastion.pub")
}

resource "aws_autoscaling_group" "rs-stage-autoscaling-group" {
  min_size                  = 3
  max_size                  = 4
  desired_capacity          = 3
  health_check_grace_period = 20
  health_check_type         = "ELB"
  launch_configuration      = aws_launch_configuration.rs-asg-stage-lc.id
  vpc_zone_identifier       = data.terraform_remote_state.networking.outputs.private_subnet_ids

  tag {
    key                 = "role"
    value               = "asg"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "asg"
    propagate_at_launch = true
  }

}

resource "aws_lb" "alb" {
  name               = "alb-${var.env}"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = data.terraform_remote_state.networking.outputs.public_subnet_ids
}


resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group" "target_group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  name        = "tg-alb-${var.env}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
}

resource "aws_security_group" "lb_sg" {
  name        = "allow_http_lb"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-lb-sg"
    }
  )
}

resource "aws_autoscaling_attachment" "stage_asca" {
  autoscaling_group_name = aws_autoscaling_group.rs-stage-autoscaling-group.id
  lb_target_group_arn    = aws_lb_target_group.target_group.arn
  
}

resource "aws_security_group" "rs-asg-sg_instance" {
  name = "stage-rs-asg-sg_instance"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["${aws_instance.bastion.private_ip}/32"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id

  tags = {
    "Name" = "${var.env}-rs-asg-sg_instance"
  }

  depends_on = [
    aws_instance.bastion
  ]

}

############## Autoscaling policy ##################
resource "aws_autoscaling_policy" "asg_policy_up" {
  name                   = "asg_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.rs-stage-autoscaling-group.id
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_alarm_up" {
  alarm_name          = "asg_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.rs-stage-autoscaling-group.id
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = ["${aws_autoscaling_policy.asg_policy_up.arn}"]

  tags = {
    "Name" = "${var.env}-scaleup-metric-alarm"
  }
}

resource "aws_autoscaling_policy" "asg_policy_down" {
  name                   = "asg_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.rs-stage-autoscaling-group.id
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_alarm_down" {
  alarm_name          = "asg_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.rs-stage-autoscaling-group.id
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = ["${aws_autoscaling_policy.asg_policy_down.arn}"]

  tags = {
    "Name" = "${var.env}-scaledown-metric-alarm"
  }

}
# Bastion deployment
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.bastion.key_name
  subnet_id                   = data.terraform_remote_state.networking.outputs.public_subnet_ids[0]
  security_groups             = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true


  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name"    = "${var.prefix}-bastion"
      "role"    = "bastion"
      "service" = "bastion"

    }
  )
}

# Security Group for Bastion host
resource "aws_security_group" "bastion_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    description = "SSH from private IP from anywhere"
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