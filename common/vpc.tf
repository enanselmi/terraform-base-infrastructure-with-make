resource "aws_vpc" "cnb_vpc" {
  cidr_block           = var.vpc.cidr
  enable_dns_support   = var.vpc.dns_support
  enable_dns_hostnames = var.vpc.dns_hostnames
  enable_classiclink   = var.vpc.classiclink
  instance_tenancy     = var.vpc.tenancy
  tags = {
    Name = "${local.naming_prefix}-vpc-${var.region}"
  }
}

resource "aws_subnet" "cnb_public_subnets" {
  vpc_id                  = aws_vpc.cnb_vpc.id
  count                   = length(var.public_subnets)
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = "true"
  availability_zone       = var.azs[count.index]
  tags = {
    Name = "${local.naming_prefix}-public-subnet-${count.index}-${var.azs[count.index]}-${var.region}"
  }
}

resource "aws_subnet" "cnb_private_subnets" {
  vpc_id                  = aws_vpc.cnb_vpc.id
  count                   = length(var.private_subnets)
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = "false"
  availability_zone       = var.azs[count.index]
  tags = {
    Name = "${local.naming_prefix}-private-subnet-${count.index}-${var.azs[count.index]}-${var.region}"
  }
}

resource "aws_internet_gateway" "cnb_igw" {
  vpc_id = aws_vpc.cnb_vpc.id
  tags = {
    Name = "${local.naming_prefix}-igw-${var.region}"
  }
}

resource "aws_eip" "eips" {
  count      = length(var.public_subnets)
  vpc        = true
  depends_on = [aws_internet_gateway.cnb_igw]
  tags = {
    Name = "${local.naming_prefix}-eip-${count.index}-${var.region}"
  }
}

resource "aws_nat_gateway" "nat_gateways" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.eips[count.index].id
  subnet_id     = aws_subnet.cnb_public_subnets[count.index].id
  depends_on    = [aws_internet_gateway.cnb_igw, aws_eip.eips]
  tags = {
    Name = "${local.naming_prefix}-ngw-${count.index}-${var.region}"
  }
}

resource "aws_route_table" "cnb_public_crt" {
  vpc_id = aws_vpc.cnb_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cnb_igw.id
  }
  tags = {
    Name = "${local.naming_prefix}-public-crt-${var.region}"
  }
}

resource "aws_route_table_association" "cnb_crta_public_subnets" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.cnb_public_subnets[count.index].id
  route_table_id = aws_route_table.cnb_public_crt.id
}

resource "aws_route_table" "cnb_private_crts" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.cnb_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }
  tags = {
    Name = "${local.naming_prefix}-private-crt-${var.azs[count.index]}-${var.region}"
  }
}

resource "aws_route_table_association" "cnb_crta_private_subnets" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.cnb_private_subnets[count.index].id
  route_table_id = aws_route_table.cnb_private_crts[count.index].id
}




