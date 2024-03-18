resource "aws_route_table" "app_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "app-rt"
  }
}

resource "aws_route_table_association" "app_subnet_rta" {
  subnet_id      = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_rt.id
}

resource "aws_route_table" "nat_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "nat-rt"
  }
}

resource "aws_route_table_association" "nat_rta" {
  subnet_id      = aws_subnet.nat_subnet.id
  route_table_id = aws_route_table.nat_rt.id
}

resource "aws_route_table" "db_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id = aws_nat_gateway.nat_gateway.id
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "db-rt"
  }
}
resource "aws_route_table_association" "db_subnet_rta" {
  subnet_id      = aws_subnet.db_subnet.id
  route_table_id = aws_route_table.db_rt.id
}