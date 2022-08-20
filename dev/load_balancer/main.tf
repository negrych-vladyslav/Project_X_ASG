#-------------------------------------------------------------------------------
provider "aws" {}
#-------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "vladyslav-negrich-project-x-terraform-state"
    key    = "dev/load_balancer/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "project" {
  backend = "s3"
  config = {
    bucket = "vladyslav-negrich-project-x-terraform-state"
    key    = "dev/Project_X_ASG/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "aws_availability_zones" "availability" {}
#-------------------------------------------------------------------------------
resource "aws_elb" "project_x" {
  name               = "projectx"
  availability_zones = [data.aws_availability_zones.availability.names[0], data.aws_availability_zones.availability.names[1]]
  security_groups    = [aws_security_group.load_balancer_sg.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "web"
  }
}
resource "aws_security_group" "load_balancer_sg" {
  name = "load_balancer_sg"

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "load_balancer_sg"
  }
}
#-------------------------------------------------------------------------------
output "load_balancer_name" {
  value = aws_elb.project_x.name
}

output "load_balancer_dns_name" {
  value = aws_elb.project_x.dns_name
}
