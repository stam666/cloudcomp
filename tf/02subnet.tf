resource "aws_subnet" "app_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zone
  tags = {
    Name = "app-subnet"
  }
}

resource "aws_subnet" "db_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zone
  tags = {
    Name = "db-subnet"
  }
}

resource "aws_subnet" "app_db_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "app-db-subnet"
  }
}

resource "aws_vpc_endpoint" "ec2_endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.app_db_subnet.id]

  security_group_ids = [aws_security_group.app_sg.id]

  private_dns_enabled = true
}


resource "aws_subnet" "nat_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.availability_zone
  tags = {
    Name = "nat-subnet"
  }
}