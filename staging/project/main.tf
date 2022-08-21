#-------------------------------------------------------------------------------
#DEPLOYMENT INFRASTRUCTURE
#-------------------------------------------------------------------------------
provider "aws" {}
#-------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "vladyslav-negrich-project-x-terraform-state"
    key    = "dev/Project_X_ASG/terraform.tfstate"
    region = "eu-west-1"
  }
}
#MODULE SECURITY GROUP----------------------------------------------------------
module "security_group" {
  source = "/home/vlad/Project_X_ASG/modules/aws_security_group"
  ports  = ["80", "22", "3306"]
  name   = "Project"
}
#LAUNCH CONFIGURATION-----------------------------------------------------------
resource "aws_launch_configuration" "project" {
  #  name            = "web"
  name_prefix     = "projectx-"
  image_id        = data.aws_ami.latest_ubuntu.id
  instance_type   = var.instance_type
  security_groups = [module.security_group.security_group_id]
  key_name        = "ssh"
  user_data       = file("wordpress.sh")

  lifecycle {
    create_before_destroy = true
  }
}
#AUTOSCALING GROUP--------------------------------------------------------------
resource "aws_autoscaling_group" "project" {
  name                 = "ASG-${aws_launch_configuration.project.name}"
  launch_configuration = aws_launch_configuration.project.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  vpc_zone_identifier  = [aws_default_subnet.default-az1.id, aws_default_subnet.default-az2.id]
  health_check_type    = "ELB"
  load_balancers       = [data.terraform_remote_state.balancer.outputs.load_balancer_name]

  dynamic "tag" {
    for_each = {
      Name    = "Wordpress"
      Project = "X"
      Owner   = "Vladyslav"
      TAGKEY  = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
#-------------------------------------------------------------------------------
resource "aws_default_subnet" "default-az1" {
  availability_zone = data.aws_availability_zones.availability.names[0]
}

resource "aws_default_subnet" "default-az2" {
  availability_zone = data.aws_availability_zones.availability.names[1]
}
#-------------------------------------------------------------------------------
