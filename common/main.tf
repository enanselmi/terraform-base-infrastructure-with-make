resource "aws_vpc" "cnb_vpc" {
  cidr_block           = var.vpc_cidr.default
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"
  tags = {
    Name = "CNB VPC test"
  }
}

resource "aws_subnet" "cnb_public_subnets" {
  vpc_id                  = aws_vpc.cnb_vpc.id
  count                   = length(var.public_subnets.default)
  cidr_block              = var.public_subnets.default[count.index]
  map_public_ip_on_launch = "true"
  availability_zone       = var.azs.default[count.index]
  tags = {
    Name = "Public-Subnet-${count.index}-${var.azs.default[count.index]}"
  }
}

resource "aws_subnet" "cnb_private_subnets" {
  vpc_id                  = aws_vpc.cnb_vpc.id
  count                   = length(var.private_subnets.default)
  cidr_block              = var.private_subnets.default[count.index]
  map_public_ip_on_launch = "false"
  availability_zone       = var.azs.default[count.index]
  tags = {
    Name = "Private-Subnet-${count.index}-${var.azs.default[count.index]}"
  }
}

resource "aws_internet_gateway" "cnb_igw" {
  vpc_id = aws_vpc.cnb_vpc.id
  tags = {
    Name = "CNB IGW"
  }
}

resource "aws_eip" "eips" {
  count      = length(var.public_subnets.default)
  vpc        = true
  depends_on = [aws_internet_gateway.cnb_igw]
  tags = {
    Name = "CNB-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "nat_gateways" {
  count         = length(var.public_subnets.default)
  allocation_id = aws_eip.eips[count.index].id
  subnet_id     = aws_subnet.cnb_public_subnets[count.index].id
  depends_on    = [aws_internet_gateway.cnb_igw, aws_eip.eips]
  tags = {
    Name = "CNB-NGW-${count.index}"
  }
}

resource "aws_route_table" "cnb_public_crt" {
  vpc_id = aws_vpc.cnb_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cnb_igw.id
  }
  tags = {
    Name = "CNB-Public-CRT"
  }
}

resource "aws_route_table_association" "cnb_crta_public_subnets" {
  count          = length(var.public_subnets.default)
  subnet_id      = aws_subnet.cnb_public_subnets[count.index].id
  route_table_id = aws_route_table.cnb_public_crt.id
}

resource "aws_route_table" "cnb_private_crts" {
  count  = length(var.private_subnets.default)
  vpc_id = aws_vpc.cnb_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }
  tags = {
    Name = "CNB-Private-CRT-${var.azs.default[count.index]}"
  }
}

resource "aws_route_table_association" "cnb_crta_private_subnets" {
  count          = length(var.private_subnets.default)
  subnet_id      = aws_subnet.cnb_private_subnets[count.index].id
  route_table_id = aws_route_table.cnb_private_crts[count.index].id
}




