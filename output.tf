
output "availability_zones_1" {
  value = data.aws_availability_zones.availability.names[0]
}

output "availability_zones_2" {
  value = data.aws_availability_zones.availability.names[1]
}

output "aws_security_group_id" {
  value = aws_security_group.project_security_group.id
}

output "aws_load_balancer_dns_name" {
  value = data.terraform_remote_state.balancer.outputs.load_balancer_dns_name
}
