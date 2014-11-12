provider "aws" {
  access_key = "${file(concat(path.root,"/../access_key"))}"
  secret_key = "${file(concat(path.root,"/../secret_key"))}"
  region     = "${var.region}"
}

## VPC ========================================================================

resource "aws_vpc" "internal" {
  cidr_block = "10.11.0.0/16"

  tags {
    Name = "${var.tagprefix} pub1-priv1"
  }
}

## Subnet (private) ===========================================================

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.internal.id}"
  cidr_block = "10.11.0.0/17"
  availability_zone = "${var.region}a"

  tags {
    Name = "${var.tagprefix} priv1a"
  }
}

## Subnet (public) ============================================================

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.internal.id}"
  cidr_block = "10.11.128.0/17"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.tagprefix} pub1a"
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

## BASTION instance (public) ==================================================

resource "aws_security_group" "ssh-to-bastion" {
  name = "ssh-to-bastion"
  description = "allow all inbound traffic to bastion"

  vpc_id = "${aws_vpc.internal.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [
      "${var.my_cidr_block}"
    ]
  }
}

resource "aws_security_group" "ssh-from-bastion" {
  name = "ssh-from-bastion"
  description = "allow ssh inbound traffic from bastion"

  vpc_id = "${aws_vpc.internal.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [
      "${aws_instance.bastion.private_ip}/32"
    ]
  }
}

resource "aws_instance" "bastion" {
  ami = "ami-f0b11187"
  instance_type = "t2.micro"
  key_name = "${var.keyname}"
  subnet_id = "${aws_subnet.public.id}"
  security_groups = [
    "${aws_security_group.ssh-to-bastion.id}"
  ]
  associate_public_ip_address = true

  tags {
    Name = "${var.tagprefix} bastion"
  }

}

## NAT instance (public) =====================================================

resource "aws_security_group" "nat-http-from-privatesubnet" {
  name = "nat-http-from-privatesubnet"
  description = "allow internet access from private subnet"

  vpc_id = "${aws_vpc.internal.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = [
      "${aws_subnet.private.cidr_block}"
    ]
  }
}

resource "aws_route_table" "route-to-nat" {
  vpc_id = "${aws_vpc.internal.id}"
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.route-to-nat.id}"  
}

resource "aws_instance" "nat" {
  # This HVM instance doesn't work :
  #ami = "ami-892fe1fe"
  #instance_type = "t2.micro"

  # Using PV instance instead :
  ami = "ami-ed352799"
  instance_type = "t1.micro"
  key_name = "${var.keyname}"
  subnet_id = "${aws_subnet.public.id}"
  security_groups = [
    "${aws_security_group.nat-http-from-privatesubnet.id}"
  ]
  associate_public_ip_address = true
  source_dest_check = false

  tags {
    Name = "${var.tagprefix} nat"
  }

}

