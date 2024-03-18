resource "aws_network_interface" "app_eni" {
  subnet_id = aws_subnet.app_subnet.id
  security_groups = [aws_security_group.app_sg.id]
  tags = {
    Name = "app-eni"
  }
}

resource "aws_eip_association" "app_eip_asso" {
  allocation_id = aws_eip.app_eip.id
  network_interface_id = aws_network_interface.app_eni.id
}

resource "aws_network_interface" "app_db_eni" {
  subnet_id = aws_subnet.app_db_subnet.id
  tags = {
    Name = "app-db-eni"
  }
}

resource "aws_network_interface" "db_eni" {
  subnet_id = aws_subnet.db_subnet.id
  tags = {
    Name = "db-eni"
  }
}

resource "aws_network_interface" "db_app_eni" {
  subnet_id = aws_subnet.app_db_subnet.id
  security_groups = [aws_security_group.db_sg.id]
  tags = {
    Name = "db-app-eni"
  }
}