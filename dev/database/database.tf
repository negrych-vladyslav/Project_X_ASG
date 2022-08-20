#-------------------------------------------------------------------------------
#DATABASE WORDPRESS
#-------------------------------------------------------------------------------
provider "aws" {}
#-------------------------------------------------------------------------------
resource "aws_db_instance" "project_x" {
  identifier           = "mysqldb"
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "db"
  username             = "vlad"
  password             = var.password_db
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  apply_immediately    = true
  publicly_accessible  = true
#  lifecycle {
#   prevent_destroy = true
# }
}
#-------------------------------------------------------------------------------
