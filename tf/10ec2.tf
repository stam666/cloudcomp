data "template_file" "user_data" {
  template = file("user-data.yaml")
  vars = {
    database_name = var.database_name
    database_user = var.database_user
    database_pass = var.database_pass
    db_host       = aws_network_interface.db_app_eni.private_ip
    bucket_name   = var.bucket_name
    region        = var.region
    wp_public_ip  = aws_eip.app_eip.public_ip
    admin_user    = var.admin_user
    admin_pass    = var.admin_pass
  }
}
resource "aws_instance" "app" {
  ami                  = var.ami
  instance_type        = "t2.micro"
  key_name             = "stam-pc"
  iam_instance_profile = aws_iam_instance_profile.app_iam.name
  network_interface {
    network_interface_id = aws_network_interface.app_eni.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.app_db_eni.id
    device_index         = 1
  }

  user_data = data.template_file.user_data.rendered
  user_data_replace_on_change = true

  depends_on = [aws_network_interface.app_eni, aws_network_interface.db_app_eni, aws_eip.app_eip, aws_instance.db]
  tags = {
    Name = "app-instance"
  }
}

resource "aws_instance" "db" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = "stam-pc"
  network_interface {
    network_interface_id = aws_network_interface.db_eni.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.db_app_eni.id
    device_index         = 1
  }

  user_data = <<-EOF
  #!/bin/bash
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
  sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
  sudo systemctl restart mariadb
  EOF
  tags = {
    Name = "db-instance"
  }
}
