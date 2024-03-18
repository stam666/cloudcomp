#!/bin/bash

# Update package lists
sudo apt-get update

# Install MariaDB server
sudo apt-get install -y mariadb-server

# Secure the MariaDB installation
# sudo mysql_secure_installation

# Start the MariaDB service
sudo systemctl start mariadb

# Enable MariaDB to start on boot
sudo systemctl enable mariadb

# Create the WordPress database
sudo mysql -e "CREATE DATABASE wordpress;"

# Create the WordPress user and grant privileges
sudo mysql -e "CREATE USER 'username'@'%' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'username'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"

sudo systemctl restart mariadb
sudo systemctl status mariadb

# test
sudo sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i 's/bind-address\s*=\s*0.0.0.0/bind-address = 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf