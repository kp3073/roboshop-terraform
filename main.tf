variable "component" {
  default = [
    "frontend",
    "catalogue",
    "user",
    "cart",
    "shipping",
    "payment",
    "mongodb",
    "mysql",
    "rabbitmq",
    "redis",
    "dispatch",
  ]
}

data "aws_ami" "ami" {
  most_recent = true
  name_regex  = "Centos-8-DevOps-Practice"
  owners = ["973714476881"]
}

resource "aws_instance" "instance" {
  count = length(var.component)
  ami           = data.aws_ami.ami.id
  instance_type = "t3.micro"
  vpc_security_group_ids = ["sg-006eca25fc0b7619d"]
  tags = {
    Name = element(var.component, count.index)
  }
}

data "aws_route53_zone" "selected" {
  name         = "aligntune.online"
  private_zone = false
}

resource "aws_route53_record" "record" {
  count = length(var.component)
  zone_id = data.aws_route53_zone.selected.id
  name    = "${element(var.component, count.index)}-dev"
  type    = "A"
  ttl     = 30
  records = [element(aws_instance.instance.*.private_ip, count.index)]
}

resource "null_resource" "local" {
  count = length(var.component)
  provisioner "remote-exec" {
    connection {
      host = element(aws_instance.instance.*.private_ip, count.index)
      user     = "root"
      password = "DevOps321"
    }
    inline = [
      "set-hostname -skip-apply ${var.component[count.index]}"
    ]
  }
}