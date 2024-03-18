#!/bin/bash

# sudo sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
sudo apt-get update
sudo apt-get install -y apache2 php8.1 libapache2-mod-php php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-xmlrpc php8.1-soap php8.1-intl php8.1-zip libapache2-mod-php

wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

sudo cp -r wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo rm -rf wordpress
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sudo sed -i "s/database_name_here/wordpress_db/" /var/www/html/wp-config.php
sudo sed -i "s/username_here/wordpress_user2/" /var/www/html/wp-config.php
sudo sed -i "s/password_here/password/" /var/www/html/wp-config.php
sudo sed -i "s/localhost/172.31.42.206/" /var/www/html/wp-config.php

cat <<EOT > /tmp/wp-offload-media-settings.txt
define('AS3CF_SETTINGS', serialize(array(
    'provider' => 'aws',
    'use-server-roles' => true,
    'bucket' => 'stam-midterm-bucket',
    'region' => 'ap-southeast-1',
    'copy-to-s3' => true,
    'serve-from-s3' => true,
)));
EOT

sudo sed -i "/define( 'WP_DEBUG', false );/r /tmp/wp-offload-media-settings.txt" /var/www/html/wp-config.php
# sudo sed -i '/<Directory /var/www/>/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
sudo wp core install --path=/var/www/html --allow-root --url="18.143.148.169" --title="CloudCompMidterm" --admin_user="admin" --admin_password="admin" --admin_email="example@example.com" --skip-email
sudo wp plugin install amazon-s3-and-cloudfront --path=/var/www/html --allow-root --activate
sudo systemctl restart apache2