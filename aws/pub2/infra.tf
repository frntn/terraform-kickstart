variable "tagname" { 
  default = "(template) pub2" 
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

## Subnet (public) ========================================

resource "aws_subnet" "public-b" {
  vpc_id = "${aws_vpc.internal.id}"
  cidr_block = "10.10.128.0/18"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.tagname}b"
  }
}

resource "aws_subnet" "public-c" {
  vpc_id = "${aws_vpc.internal.id}"
  cidr_block = "10.10.192.0/18"
  availability_zone = "${var.region}c"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.tagname}c"
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

