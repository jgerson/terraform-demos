provider "aws" {
  region = "${data.terraform_remote_state.networkdetails.region}"
}

data "terraform_remote_state" "networkdetails" {
  backend = "atlas"

  config {
    name = "jgersonorg1/${var.network_workspace}"
  }
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "1.3.0"

  instance_count              = 2
  name                        = "${var.application_name}-demo"
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${element(data.terraform_remote_state.networkdetails.public_subnets, 0)}"
  vpc_security_group_ids      = ["${data.terraform_remote_state.networkdetails.security_group}"]
  associate_public_ip_address = true
  key_name                    = "${var.key_name}"

  root_block_device = [{
    volume_size = "50"
  }]

  tags = {
    Owner = "${var.owner}"
    TTL   = "${var.ttl}"
  }
}

locals {
  namespace = "${var.namespace}-demo"
}

resource "aws_instance" "demo" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${element(data.terraform_remote_state.networkdetails.public_subnets, 0)}"
  vpc_security_group_ids = ["${data.terraform_remote_state.networkdetails.security_group}"]
  key_name               = "${var.key_name}"
  user_data = <<EOF
#!/bin/bash
yum install -y httpd
service httpd start
cat << EOM > /var/www/html/index.html
<html>
  <head><title>Meow!</title></head>
  <body>
  <center><img src="http://placekitten.com/600/400"></img></center>
  </body>
</html>
EOM
EOF

  root_block_device {
    volume_size = 80
    volume_type = "gp2"
  }

  tags {
    Name  = "${local.namespace}-instance"
    owner = "${var.owner}"
    TTL   = "${var.ttl}"
  }
}

resource "aws_eip" "demo" {
  instance = "${aws_instance.demo.id}"
  vpc      = true
}

resource "aws_route53_record" "demo" {
  zone_id = "${var.hashidemos_zone_id}"
  name    = "${local.namespace}.hashidemos.io."
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.demo.public_ip}"]
}
  
output "demo_fqdn" {
  value = "${aws_route53_record.demo.fqdn}"
}
