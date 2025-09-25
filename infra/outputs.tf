output "region" {
  value = var.region
}

output "public_ip" {
  value = aws_eip.demo.public_ip
}

output "ssh_user" {
  value = "ubuntu"
}

output "ssh_cmd" {
  value = "ssh ubuntu@${aws_eip.demo.public_ip}"
}

output "app_host" {
  value = "app.${replace(aws_eip.demo.public_ip, ".", "-")}.nip.io"
}

output "static_host" {
  value = "static.${replace(aws_eip.demo.public_ip, ".", "-")}.nip.io"
}
