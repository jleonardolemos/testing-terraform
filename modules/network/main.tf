terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = var.aws_file_key_file_location
}

resource "aws_vpc" "swarm" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "swarm"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.swarm.id

  tags = {
    Name = "swarm gw"
  }
}


data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_one" {
  vpc_id     = aws_vpc.swarm.id
  cidr_block = "192.168.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "swarm public one"
  }
}

resource "aws_subnet" "private_one" {
  vpc_id     = aws_vpc.swarm.id
  cidr_block = "192.168.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "swarm private one"
  }
}

resource "aws_subnet" "public_two" {
  vpc_id     = aws_vpc.swarm.id
  cidr_block = "192.168.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "swarm public two"
  }
}

resource "aws_subnet" "private_two" {
  vpc_id     = aws_vpc.swarm.id
  cidr_block = "192.168.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "swarm private two"
  }
}

resource "aws_eip" "nat_elastic_ip" {
  vpc      = true
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_elastic_ip.id
  subnet_id     = aws_subnet.private_one.id

  tags = {
    Name = "swarm gw NAT"
  }
}

resource "aws_route_table" "swarm_route_table" {
  vpc_id = aws_vpc.swarm.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "swarm route table"
  }
}

resource "aws_route_table_association" "public_one" {
  subnet_id      = aws_subnet.public_one.id
  route_table_id = aws_route_table.swarm_route_table.id
}

resource "aws_route_table_association" "public_two" {
  subnet_id      = aws_subnet.public_two.id
  route_table_id = aws_route_table.swarm_route_table.id
}

resource "aws_route_table" "swarm_private_route_table" {
  vpc_id = aws_vpc.swarm.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "swarm private route table"
  }
}

resource "aws_route_table_association" "private_one" {
  subnet_id      = aws_subnet.private_one.id
  route_table_id = aws_route_table.swarm_private_route_table.id
}

resource "aws_route_table_association" "private_two" {
  subnet_id      = aws_subnet.private_two.id
  route_table_id = aws_route_table.swarm_private_route_table.id
}