//
// Public Security Group
//

resource "aws_security_group" "public" {
  name        = "eastaugh-${var.infra_env}-public-sg"
  description = "Public internet access"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "eastaugh-${var.infra_env}-public-sg"
    Role = "public"
  })
}

resource "aws_security_group_rule" "public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

//
// Private Security Group
//

resource "aws_security_group" "private" {
  name        = "eastaugh-${var.infra_env}-private-sg"
  description = "Private internet access"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "eastaugh-${var.infra_env}-private-sg"
    Role = "private"
  })
}

resource "aws_security_group_rule" "private_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "private_in" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = [aws_vpc.vpc.cidr_block]

  security_group_id = aws_security_group.private.id
}