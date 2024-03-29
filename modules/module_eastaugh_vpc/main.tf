// Create the VPC for the region associated with the AZ
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = merge(local.common_tags, {
    "Name" = "eastaugh-${var.infra_env}-vpc"
  })
}

// Create a public subnet for each AZ within the regional VPC
resource "aws_subnet" "public" {
  for_each = var.public_subnet_numbers

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key

  // 2,048 IP addesses each
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  tags = merge(local.common_tags, {
    Name   = "eastaugh-${var.infra_env}-public-subnet"
    Role   = "public"
    Subnet = "${each.key}-${each.value}"
  })
}

// Create a private subnet for each AZ within the regional VPC
resource "aws_subnet" "private" {
  for_each = var.private_subnet_numbers

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key

  // 2,048 IP addesses each
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  tags = merge(local.common_tags, {
    Name   = "eastaugh-${var.infra_env}-private-subnet"
    Role   = "private"
    Subnet = "${each.key}-${each.value}"
  })
}