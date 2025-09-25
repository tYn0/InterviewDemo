variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ssh_ingress_cidr" {
  type = string
}

variable "public_key_openssh" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}
