resource "aws_eip" "app_eip" {
  tags = {
    Name = "app-eip"
  }
}

resource "aws_eip" "nat_eip" {
  tags = {
    Name = "nat-eip"
  }
}