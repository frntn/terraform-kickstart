variable "tagname" { default = "(template) pub1-priv1" }
variable "region" { default = "eu-west-1" }

                        #######
                        # AWS #
                        #######

provider "aws" {
  access_key = "${file(concat(path.root,"/../access_key"))}"
  secret_key = "${file(concat(path.root,"/../secret_key"))}"
  region     = "${var.region}"
}

## VPC =====================================================

resource "aws_vpc" "internal" {
  cidr_block = "10.10.0.0/16"

  tags {
    Name = "${var.tagname}"
  }
}

## Subnet (private) ======================================

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.internal.id}"
  cidr_block = "10.10.0.0/18"
  availability_zone = "${var.region}a"

  tags {
    Name = "priv1a"
  }
}

## Subnet (public) =======================================

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.internal.id}"
  cidr_block = "10.10.128.0/18"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true

  tags {
    Name = "pub1a"
  }
}

resource "aws_internet_gateway" "gw-to-internet" {
  vpc_id = "${aws_vpc.internal.id}"
}

resource "aws_route_table" "route-to-gw" {
  vpc_id = "${aws_vpc.internal.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw-to-internet.id}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.route-to-gw.id}"  
}

## REBOND ==================================================
#
#variable "keyname" {}
#
#resource "aws_security_group" "rebond" {
#  name = "rebond"
#  description = "allow all inbound traffic"
#
#  vpc_id = "${aws_vpc.internal.id}"
#
#  ingress {
#    from_port = 0
#    to_port = 65535
#    protocol = "TCP"
#    cidr_blocks = [
#      "WWW.XXX.YYY.ZZZ/32" # You IP goes here
#    ]
#  }
#}
#
#resource "aws_instance" "rebond" {
#  ami = "ami-f0b11187"
#  instance_type = "t2.micro"
#  key_name = "${var.keyname}"
#  subnet_id = "${aws_subnet.public.id}"
#  security_groups = ["${aws_security_group.rebond.id}"]
#  associate_public_ip_address = true
#
#  tags {
#    Name = "rebond"
#  }
#
#}
