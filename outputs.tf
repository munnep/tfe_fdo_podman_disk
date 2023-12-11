output "ssh_tfe_server" {
  value = "ssh ec2-user@${var.dns_hostname}.${var.dns_zonename}"
}

output "tfe_appplication" {
  value = "https://${var.dns_hostname}.${var.dns_zonename}"
}

output "tfe_ip" {
  value = "ssh ubuntu@${aws_eip.tfe-eip.public_ip}"
}

output "ssh_tf_client" {
  value = "ssh ubuntu@${var.dns_hostname}-client.${var.dns_zonename}"
}


output "client_web_server" {
  value = "https://${var.dns_hostname}-client.${var.dns_zonename}"
}