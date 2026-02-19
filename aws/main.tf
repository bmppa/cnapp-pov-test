# Retireve AWS Account ID
data "aws_caller_identity" "current" {}

# Define provider
provider "aws" {
  region = var.aws_region
}

resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.vpc.id
}

# Find available AZs
data "aws_availability_zones" "azs" {
  state = "available"
}

# Creates a public subnet 1
resource "aws_subnet" "pub_net_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_net_1_cidr
  availability_zone       = element(data.aws_availability_zones.azs.names, 0)
  map_public_ip_on_launch = true
}

# Creates a public subnet 2
resource "aws_subnet" "pub_net_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_net_2_cidr
  availability_zone       = element(data.aws_availability_zones.azs.names, 1)
  map_public_ip_on_launch = true
}

# Creates a private subnet 1
resource "aws_subnet" "priv_net_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.priv_net_1_cidr
  availability_zone       = element(data.aws_availability_zones.azs.names, 0)
  map_public_ip_on_launch = false
}

# Creates a private subnet 2
resource "aws_subnet" "priv_net_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.priv_net_2_cidr
  availability_zone       = element(data.aws_availability_zones.azs.names, 1)
  map_public_ip_on_launch = false
}

# Create an Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# Create route table with a default Internet route to Internet Gateway
resource "aws_route_table" "internet_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  lifecycle {
    ignore_changes = all
  }
}

# Associate public subnet 1 with a routing table
resource "aws_route_table_association" "default-route-assoc-1" {
  subnet_id      = aws_subnet.pub_net_1.id
  route_table_id = aws_route_table.internet_route.id
}

# Associate public subnet 2 with a routing table
resource "aws_route_table_association" "default-route-assoc-2" {
  subnet_id      = aws_subnet.pub_net_2.id
  route_table_id = aws_route_table.internet_route.id
}

# Create an elastic IP address for the NAT gateway in public subnet 1
resource "aws_eip" "nat_gateway_ip_1" {
}

# Create an elastic IP address for the NAT gateway in public subnet 2
resource "aws_eip" "nat_gateway_ip_2" {
}

# Create a NAT gateway in public subnet 1
resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_ip_1.id
  subnet_id     = aws_subnet.pub_net_1.id

  # To ensure proper ordering, it is recommended to add an explicit dependency on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# Create a NAT gateway in public subnet 2
resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_gateway_ip_2.id
  subnet_id     = aws_subnet.pub_net_2.id

  # To ensure proper ordering, it is recommended to add an explicit dependency on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# Create route table with a default Internet route to the NAT Gateway in public subnet 1
resource "aws_route_table" "nat_internet_route_1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }

  lifecycle {
    ignore_changes = all
  }
}

# Create route table with a default Internet route to the NAT Gateway in public subnet 2
resource "aws_route_table" "nat_internet_route_2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
  }

  lifecycle {
    ignore_changes = all
  }
}

# Associate public subnet 1 with a routing table
resource "aws_route_table_association" "nat-default-route-assoc-1" {
  subnet_id      = aws_subnet.priv_net_1.id
  route_table_id = aws_route_table.nat_internet_route_1.id
}

# Associate public subnet 2 with a routing table
resource "aws_route_table_association" "nat-default-route-assoc-2" {
  subnet_id      = aws_subnet.priv_net_2.id
  route_table_id = aws_route_table.nat_internet_route_2.id
}