variable "ports" {
  default = ["80", "443", "3306", "22"]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "ssh"
}
