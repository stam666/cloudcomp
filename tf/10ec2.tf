resource "aws_instance" "app" {
  ami           = var.ami
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.app_iam.name
  network_interface {
    network_interface_id = aws_network_interface.app_eni.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.app_db_eni.id
    device_index         = 1
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y mariadb-server
              sudo systemctl start mariadb
              sudo systemctl enable mariadb
              EOF

  tags = {
    Name = "app-instance"
  }

}

resource "aws_instance" "db" {
  ami           = var.ami
  instance_type = "t2.micro"
  # key_name      = "your-key-pair"
  network_interface {
    network_interface_id = aws_network_interface.db_eni.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.db_app_eni.id
    device_index         = 1
  }
  tags = {
    Name = "db-instance"
  }
}