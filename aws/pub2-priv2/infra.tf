variable "tagname"  { 
  default = "(template) pub2-priv2" 
}

variable "region" { 
  default = "eu-west-1" 
}

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

resource "aws_subnet" "private-b" {
  vpc_id = "${aws_vpc.internal.id}"
  cidr_block = "10.10.0.0/18"
  availability_zone = "${var.region}b"

  tags {
    Name = "priv2b"
  }
}

resource "aws_subnet" "private-c" {
  vpc_id = "${aws_vpc.internal.id}"
  cidr_block = "10.10.64.0/18"
  availability_zone = "${var.region}c"

  tags {
    Name = "priv2c"
  }
}

## Subnet (public) =======================================

resource "aws_subnet" "public-b" {
  vpc_id = "${aws_vpc.internal.id}"
  cidr_block = "10.10.128.0/18"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true

  tags {
    Name = "pub2b"
  }
}

resource "aws_subnet" "public-c" {
  vpc_id = "${aws_vpc.internal.id}"
  cidr_block = "10.10.192.0/18"
  availability_zone = "${var.region}c"
  map_public_ip_on_launch = true

  tags {
    Name = "pub2c"
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

resource "aws_route_table_association" "public-b" {
  subnet_id = "${aws_subnet.public-b.id}"
  route_table_id = "${aws_route_table.route-to-gw.id}"  
}

resource "aws_route_table_association" "public-c" {
  subnet_id = "${aws_subnet.public-c.id}"
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
#  subnet_id = "${aws_subnet.public-b.id}"
#  security_groups = ["${aws_security_group.rebond.id}"]
#  associate_public_ip_address = true
#
#  tags {
#    Name = "rebond"
#  }
#
#}
