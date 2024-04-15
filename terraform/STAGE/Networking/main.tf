# Define the provider (AWS)
provider "aws" {
  region = "us-east-1" 
}

data "aws_availability_zones" "available" {}


# Create the first VPC for staging
resource "aws_vpc" "main_vpc" {
  cidr_block = var.main_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
   tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-${var.env}-vpc"
    }
  )
  
  
}


# Create subnets in the VPC
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidr_blocks)
  vpc_id           = aws_vpc.main_vpc.id
  cidr_block       = var.public_subnet_cidr_blocks[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-public-subnet-${count.index+1}"
    }
  )
}


resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidr_blocks)
  vpc_id           = aws_vpc.main_vpc.id
  cidr_block       = var.private_subnet_cidr_blocks[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-private-subnet-${count.index+1}"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-igw"
    }
  )
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Create a NAT Gateway for the staging subnet
resource "aws_nat_gateway" "main_nat_gateway" {
  subnet_id     = aws_subnet.public_subnet[1].id
  allocation_id = aws_eip.nat_eip.id
  depends_on    = [aws_internet_gateway.igw]
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-natgateway"
    }
  )

}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-public-route-table"
    }
  )
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id

}

resource "aws_route_table" "main_private_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-staging-private-route-table"
    }
  )
}


resource "aws_route" "private_route_table" {

  route_table_id         = aws_route_table.main_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.main_nat_gateway.id

}




# Associate subnets with the custom route table
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.private_subnet[*].id)
  route_table_id = aws_route_table.main_private_route_table.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}





