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
  security_groups    = [module.security_group.security_group_id]
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
#===============================================================================
module "security_group" {
  source = "/home/vlad/Project_X_ASG/modules/aws_security_group"
  ports  = ["80"]
  name   = "load-balancer"
}
#===============================================================================
output "load_balancer_name" {
  value = aws_elb.project_x.name
}

output "load_balancer_dns_name" {
  value = aws_elb.project_x.dns_name
}
