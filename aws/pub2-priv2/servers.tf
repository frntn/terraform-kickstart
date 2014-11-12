## EXAMPLES ===================================================================

# FRONTEND --------------------------------------------------------------------

resource "aws_security_group" "http-from-everywhere" {
  name = "http-from-everywhere"
  description = "allow http inbound traffic"

  vpc_id = "${aws_vpc.internal.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_instance" "web-front-b" {
  ami = "ami-f0b11187"
  instance_type = "t2.micro"
  key_name = "${var.keyname}"
  subnet_id = "${aws_subnet.public-b.id}"
  security_groups = [
    "${aws_security_group.ssh-from-bastion.id}",
    "${aws_security_group.http-from-everywhere.id}"
  ]

  tags {
    Name = "web-front-b"
  }
}

resource "aws_instance" "web-front-c" {
  ami = "ami-f0b11187"
  instance_type = "t2.micro"
  key_name = "${var.keyname}"
  subnet_id = "${aws_subnet.public-c.id}"
  security_groups = [
    "${aws_security_group.ssh-from-bastion.id}",
    "${aws_security_group.http-from-everywhere.id}"
  ]

  tags {
    Name = "web-front-c"
  }
}

# BACKEND ---------------------------------------------------------------------

resource "aws_security_group" "mysql-from-publicsubnet" {
  name = "mysql-from-publicsubnet"
  description = "allow mysql inbound traffic from public subnet"

  vpc_id = "${aws_vpc.internal.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "TCP"
    cidr_blocks = [
      "10.10.0.0/18"
    ]
  }
}

resource "aws_instance" "web-back-b" {
  ami = "ami-f0b11187"
  instance_type = "t2.micro"
  key_name = "${var.keyname}"
  subnet_id = "${aws_subnet.private-b.id}"
  security_groups = [
    "${aws_security_group.ssh-from-bastion.id}",
    "${aws_security_group.mysql-from-publicsubnet.id}"
  ]

  tags {
    Name = "web-back-b"
  }
}

resource "aws_instance" "web-back-c" {
  ami = "ami-f0b11187"
  instance_type = "t2.micro"
  key_name = "${var.keyname}"
  subnet_id = "${aws_subnet.private-c.id}"
  security_groups = [
    "${aws_security_group.ssh-from-bastion.id}",
    "${aws_security_group.mysql-from-publicsubnet.id}"
  ]

  tags {
    Name = "web-back-c"
  }
}
