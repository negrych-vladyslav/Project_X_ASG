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
#-------------------------------------------------------------------------------
resource "aws_security_group" "project_security_group" {
  name = "project_security_group"

  dynamic "ingress" {
    for_each = var.ports
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
    Name = "my_security_group"
  }
}
#-------------------------------------------------------------------------------
resource "aws_launch_configuration" "project" {
  #  name            = "web"
  name_prefix     = "projectx-"
  image_id        = data.aws_ami.latest_ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.project_security_group.id]
  key_name        = "ssh"
  user_data       = file("wordpress.sh")

  lifecycle {
    create_before_destroy = true
  }
}
#-------------------------------------------------------------------------------
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
