//
//  IGW and NGW
//
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "eastaugh-${var.infra_env}-igw"
    VPC  = aws_vpc.vpc.id
  })
}

resource "aws_eip" "nat" {
  vpc = true

  lifecycle {
    //prevent_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "eastaugh-${var.infra_env}-eip"
    VPC  = aws_vpc.vpc.id
    Role = "private"
  })
}

/* Note: We're only creating one NAT Gateway, potential single point of failure
  Each NGW has a base cost per hour to run, roughly $32/mo per NGW. You'll often see
  one NGW per AZ created, and sometimes one per subnet.
  Note: Cross-AZ bandwidth is an extra charge, so having a NAT per AZ could be cheaper
  than a single NGW depending on your usage
*/
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id

  /* Whichever the first public subnet happens to be
    (because NGW needs to be on a public subnet with an IGW)
    keys(): https://www.terraform.io/docs/configuration/functions/keys.html
    element(): https://www.terraform.io/docs/configuration/functions/element.html
  */
  subnet_id = aws_subnet.public[element(keys(aws_subnet.public), 0)].id

  tags = merge(local.common_tags, {
    Name = "eastaugh-${var.infra_env}-ngw"
    VPC  = aws_vpc.vpc.id
    Role = "private"
  })
}

//
// Route tables + Routes and Associations
//

// Public Route Tables (Subnets with NGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "eastaugh-${var.infra_env}-public-rt"
    VPC  = aws_vpc.vpc.id
    Role = "public"
  })
}

// Private Route Tables (Subnets with NGW)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "eastaugh-${var.infra_env}-private-rt"
    VPC  = aws_vpc.vpc.id
    Role = "private"
  })
}

// Public Route
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

// Private Route
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

// Public Route to Public Route Table for Public Subnets
resource "aws_route_table_association" "public" {
  for_each  = aws_subnet.public
  subnet_id = aws_subnet.public[each.key].id

  route_table_id = aws_route_table.public.id
}

// Private Route to Private Route Table for Private Subnets
resource "aws_route_table_association" "private" {
  for_each  = aws_subnet.private
  subnet_id = aws_subnet.private[each.key].id

  route_table_id = aws_route_table.private.id
}