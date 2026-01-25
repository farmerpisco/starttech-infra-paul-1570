resource "aws_vpc" "st_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

data "aws_availability_zones" "st_az" {
  state = "available"
}

resource "aws_subnet" "st_public_subnets" {
  count = 2

  vpc_id                  = aws_vpc.st_vpc.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = data.aws_availability_zones.st_az.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-Public-Subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "st_private_subnets" {
  count = 2

  vpc_id            = aws_vpc.st_vpc.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index + 10)
  availability_zone = data.aws_availability_zones.st_az.names[count.index]

  tags = {
    Name = "${var.project_name}-Private-Subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "st_gw" {
  vpc_id = aws_vpc.st_vpc.id

  tags = {
    Name = "${var.project_name}-Internet-Gateway"
  }
}

resource "aws_eip" "nat" {
  tags = {
    Name = "${var.project_name}-NAT-EIP"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.st_public_subnets[0].id

  tags = {
    Name = "${var.project_name}-NAT-GW"
  }

  depends_on = [aws_internet_gateway.st_gw]
}

resource "aws_route_table" "st_rt" {
  vpc_id = aws_vpc.st_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.st_gw.id
  }

  tags = {
    Name = "${var.project_name}-Public-RT"
  }
}

resource "aws_route_table_association" "public_rta" {
  count = length(aws_subnet.st_public_subnets)

  subnet_id      = aws_subnet.st_public_subnets[count.index].id
  route_table_id = aws_route_table.st_rt.id
}

resource "aws_route_table" "st_private_rt" {
  vpc_id = aws_vpc.st_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.project_name}-Private-RT"
  }
}

resource "aws_route_table_association" "private_rta" {
  count          = length(aws_subnet.st_private_subnets)
  subnet_id      = aws_subnet.st_private_subnets[count.index].id
  route_table_id = aws_route_table.st_private_rt.id
}

resource "aws_security_group" "st_sg" {
  name   = "${var.project_name}-SG"
  vpc_id = aws_vpc.st_vpc.id

  tags = {
    Name = "${var.project_name}-SG"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.st_alb_sg.id]
    description     = "Allow HTTP from Load Balabcer"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "st_alb_sg" {
  name        = "alb-security-group"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.st_vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-SG"
  }
}

resource "aws_security_group" "redis_sg" {
  name   = "${var.project_name}-redis-sg"
  vpc_id = aws_vpc.st_vpc.id

  ingress {
    description     = "Allow Redis from backend"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.st_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-Redis-SG"
  }
}