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
              git clone https://github.com/stam666/cloudcomp.git
              cd cloudcomp/scripts/db
              export DB_NAME=${var.database_name}
              export DB_USER=${var.database_user}
              export DB_PASS=${var.database_pass}

              sudo apt-get update
              sudo apt-get install -y mariadb-server
              sudo systemctl start mariadb
              sudo systemctl enable mariadb
              sudo mysql -e "CREATE DATABASE ${var.database_name};"
              sudo mysql -e "CREATE USER '${var.database_user}'@'%' IDENTIFIED BY '${var.database_pass}';"
              sudo mysql -e "GRANT ALL PRIVILEGES ON ${var.database_name}.* TO '${var.database_user}'@'%';"
              sudo mysql -e "FLUSH PRIVILEGES;"
              sudo python3 bind-address.py
              sudo systemctl restart mariadb
              EOF

  tags = {
    Name = "app-instance"
  }

}

resource "aws_instance" "db" {
  ami           = var.ami
  instance_type = "t2.micro"
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