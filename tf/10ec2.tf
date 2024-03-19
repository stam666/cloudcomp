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

  user_data = <<-EOF
  #!/bin/bash
  export DB_HOST=${aws_network_interface.db_app_eni.private_ip}
  export DB_NAME=${var.database_name}
  export DB_USER=${var.database_user}
  export DB_PASS=${var.database_pass}
  export WP_PUBLIC_IP=${aws_eip.app_eip.public_ip}
  export WP_ADMIN_USER=${var.admin_user}
  export WP_ADMIN_PASS=${var.admin_pass}
  export BUCKET_NAME=${var.bucket_name}
  export REGION=${var.region}

  sudo sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
  sudo apt-get update
  sudo apt-get install -y apache2 php8.1 libapache2-mod-php php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-xmlrpc php8.1-soap php8.1-intl php8.1-zip libapache2-mod-php

  wget https://wordpress.org/latest.tar.gz
  tar -xzf latest.tar.gz

  sudo cp -r wordpress/* /var/www/html/
  sudo chown -R www-data:www-data /var/www/html/
  sudo chmod -R 755 /var/www/html/
  rm -rf wordpress
  sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

  sudo sed -i "s/database_name_here/${var.database_name}/" /var/www/html/wp-config.php
  sudo sed -i "s/username_here/${var.database_user}/" /var/www/html/wp-config.php
  sudo sed -i "s/password_here/${var.database_pass}/" /var/www/html/wp-config.php
  sudo sed -i "s/localhost/$DB_HOST/" /var/www/html/wp-config.php

  cat <<EOT > /tmp/wp-offload-media-settings.txt
  define('AS3CF_SETTINGS', serialize(array(
      'provider' => 'aws',
      'use-server-roles' => true,
      'bucket' => '$BUCKET_NAME',
      'region' => '$REGION',
      'copy-to-s3' => true,
      'serve-from-s3' => true,
  )));
  EOT

  sudo sed -i "/define( 'WP_DEBUG', false );/r /tmp/wp-offload-media-settings.txt" /var/www/html/wp-config.php
  sudo sed -i '/<Directory /var/www/>/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

  sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  sudo chmod +x wp-cli.phar
  sudo mv wp-cli.phar /usr/local/bin/wp
  sudo wp core install --path=/var/www/html --allow-root --url=$WP_PUBLIC_IP --title="CloudCompMidterm" --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email="example@example.com" --skip-email
  sudo wp plugin install amazon-s3-and-cloudfront --path=/var/www/html --allow-root --activate
  sudo systemctl restart apache2
  EOF
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
