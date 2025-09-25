terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_key_pair" "demo" {
  key_name   = "devops-homework-key"
  public_key = var.public_key_openssh
}

# Security group
resource "aws_security_group" "demo_sg" {
  name        = "devops-homework-sg"
  description = "Allow SSH/HTTP/HTTPS"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "devops-homework-sg" }
}

data "aws_ssm_parameter" "ubuntu_2404_amd64" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_instance" "demo" {
  ami                    = data.aws_ssm_parameter.ubuntu_2404_amd64.value
  instance_type          = var.instance_type
  key_name               = aws_key_pair.demo.key_name
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  tags = { Name = "devops-homework-ec2" }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y python3
  EOF
}

# Elastic IP
resource "aws_eip" "demo" {
  instance = aws_instance.demo.id
  domain   = "vpc"
}

# Inventory for Ansible
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
  [demo]
  ${aws_eip.demo.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.ssh_private_key_path}

  [demo:vars]
  ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  EOT
}