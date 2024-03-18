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

resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id = aws_subnet.app_db_subnet.id
  tags = {
    Name = "app-db-instance-connect-endpoint"
  }
}

resource "aws_subnet" "nat_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.availability_zone
  tags = {
    Name = "nat-subnet"
  }
}