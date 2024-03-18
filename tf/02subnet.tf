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
  tags = {
    Name = "app-db-subnet"
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