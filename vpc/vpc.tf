variable "AWS_VPC_SUBNET_CIDR" {}
variable "AWS_VPC_PUBLIC_SUBNET_CIDR" {}
variable "AWS_VPC_PRIVATE_SUBNET_CIDR" {}
variable "availability_zones" {}
variable "private_tag" {}
variable "public_tag" {}


# Internet VPC
resource "aws_vpc" "test" {
    cidr_block = "${var.AWS_VPC_SUBNET_CIDR}"
    tags = {
    Terraform   = "true"
    Name        = "test"
    Environment = "test"
  }
}

# Private subnet
resource "aws_subnet" "private" {
  count = "${length(var.AWS_VPC_PRIVATE_SUBNET_CIDR)}"
  vpc_id            = "${aws_vpc.test.id}"
  cidr_block        = "${var.AWS_VPC_PRIVATE_SUBNET_CIDR[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"
tags = {
    Terraform   = "true"
    Name        = "${var.private_tag[count.index]}"
    Environment = "test"
  }

}

#private subnet 

resource "aws_subnet" "public" {
  count = "${length(var.AWS_VPC_PUBLIC_SUBNET_CIDR)}"
  vpc_id            = "${aws_vpc.test.id}"
  cidr_block        = "${var.AWS_VPC_PUBLIC_SUBNET_CIDR[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"
tags = {
    Terraform   = "true"
    Name        = "${var.public_tag[count.index]}"
    Environment = "test"
  }

}

# Internet gateway
resource "aws_internet_gateway" "test-gw" {
    vpc_id = "${aws_vpc.test.id}"

tags = {
    Terraform   = "true"
    Name        = "test-gw"
    Environment = "test"
  }
}

#private-route-table and route
resource "aws_route_table" "private-route" {
  count = "${length(var.AWS_VPC_PRIVATE_SUBNET_CIDR)}"
  vpc_id = "${aws_vpc.test.id}"
tags = {
    Terraform   = "true"
    Name        = "${var.private_tag[count.index]}"
    Environment = "test"
  }
}

resource "aws_route" "private" {
  count = "${length(var.AWS_VPC_PRIVATE_SUBNET_CIDR)}"
  route_table_id         = "${aws_route_table.private-route.*.id[count.index]}"
  destination_cidr_block = "0.0.0.0/0"
  #nat_gateway_id         = "${aws_nat_gateway.default.*.id[count.index]}"
  instance_id           = "${aws_instance.test.*.id[count.index]}"
}

#Public-route-table and route
resource "aws_route_table" "public-route" {
  count = "${length(var.AWS_VPC_PUBLIC_SUBNET_CIDR)}"
  vpc_id = "${aws_vpc.test.id}"
tags = {
    Terraform   = "true"
    Name        = "${var.public_tag[count.index]}"
    Environment = "test"
  }
}

resource "aws_route" "public" {
  count = "${length(var.AWS_VPC_PUBLIC_SUBNET_CIDR)}"
  route_table_id         = "${aws_route_table.public-route.*.id[count.index]}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.test-gw.id}"
}

#Private-route-table-association

resource "aws_route_table_association" "private" {
  count = "${length(var.AWS_VPC_PRIVATE_SUBNET_CIDR)}"
  subnet_id      = "${aws_subnet.private.*.id[count.index]}"
  route_table_id = "${aws_route_table.private-route.*.id[count.index]}"
}

#public-route-table-association

resource "aws_route_table_association" "public" {
  count = "${length(var.AWS_VPC_PUBLIC_SUBNET_CIDR)}"
  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${aws_route_table.public-route.*.id[count.index]}"
}
