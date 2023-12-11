
resource "aws_network_interface" "terraform_client-priv" {
  subnet_id   = aws_subnet.public1.id
  private_ips = [cidrhost(cidrsubnet(var.vpc_cidr, 8, 1), 23)]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_network_interface_sg_attachment" "sg2_attachment" {
  security_group_id    = aws_security_group.default-sg.id
  network_interface_id = aws_network_interface.terraform_client-priv.id
}

resource "aws_route53_record" "www-client" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.dns_hostname}-client"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.terraform_client-eip.public_ip]
  depends_on = [
    aws_eip.terraform_client-eip
  ]
}


resource "aws_eip" "terraform_client-eip" {
  # domain = "vpc"

  instance                  = aws_instance.terraform_client.id
  associate_with_private_ip = aws_network_interface.terraform_client-priv.private_ip
  depends_on                = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.tag_prefix}-client-eip"
  }
}

resource "acme_certificate" "certificate-client" {
  account_key_pem = acme_registration.registration.account_key_pem
  common_name     = "${var.dns_hostname}-client.${var.dns_zonename}"

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.base_domain.zone_id
    }
  }

  depends_on = [acme_registration.registration]
}


resource "aws_instance" "terraform_client" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = "${var.tag_prefix}-key"

  network_interface {
    network_interface_id = aws_network_interface.terraform_client-priv.id
    device_index         = 0
  }

  iam_instance_profile = aws_iam_instance_profile.profile.name

  user_data = templatefile("${path.module}/scripts/cloudinit_tfe_client.yaml", {
    terraform_client_version = var.terraform_client_version
    rsyslog_conf             = filebase64("${path.module}/files/rsyslog.conf")
    dns_hostname             = var.dns_hostname
    dns_zonename             = var.dns_zonename
    server_cert              = base64encode("${acme_certificate.certificate-client.certificate_pem}${acme_certificate.certificate-client.issuer_pem}")
    server_key               = base64encode(acme_certificate.certificate-client.private_key_pem)
  })

  tags = {
    Name = "${var.tag_prefix}-client"
  }

  depends_on = [
    aws_network_interface_sg_attachment.sg2_attachment, acme_certificate.certificate-client
  ]

  lifecycle {
    ignore_changes = [ ami ]
  }

}




output "private_ip" {
  value = flatten(aws_network_interface.terraform_client-priv.private_ips)[0]
}
