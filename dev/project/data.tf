data "aws_availability_zones" "availability" {}

data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "terraform_remote_state" "balancer" {
  backend = "s3"
  config = {
    bucket = "vladyslav-negrich-project-x-terraform-state"
    key    = "dev/load_balancer/terraform.tfstate"
    region = "eu-west-1"
  }
}
