#!/bin/bash

# Update package lists
sudo apt-get update

# Install Apache2, PHP 8.1, and other dependencies
sudo apt-get install -y apache2 php8.1 libapache2-mod-php php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-xmlrpc php8.1-soap php8.1-intl php8.1-zip

# Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Download and extract the latest Wordpress package
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

# Copy the Wordpress files to the Apache document root
sudo cp -r wordpress/* /var/www/html/

# Give proper permissions
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Remove the WordPress installation directory
rm -rf wordpress

# Create the Wordpress configuration file
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Configure database settings in wp-config.php
# Replace the placeholders with the database credentials from the database instance
sudo sed -i "s/database_name_here/wordpress_db/" /var/www/html/wp-config.php
sudo sed -i "s/username_here/wordpress_user/" /var/www/html/wp-config.php
sudo sed -i "s/password_here/12345678/" /var/www/html/wp-config.php
sudo sed -i "s/localhost/172.31.42.206/" /var/www/html/wp-config.php


# Configure WP Offload Media plugin settings
cat <<EOT > /tmp/wp-offload-media-settings.txt
define('AS3CF_SETTINGS', serialize(array(
    'provider' => 'aws',
    'use-server-roles' => true,
    'bucket' => 'stam-midterm-bucket',
    'region' => 'ap-southeast-1',
    'copy-to-s3' => true,
    'enable-object-prefix' => true,
    'object-prefix' => 'wp-content/uploads/',
    'use-yearmonth-folders' => true,
    'object-versioning' => true,
    'delivery-provider' => 'aws',
    'serve-from-s3' => true,
    'force-https' => true,
    'remove-local-file' => false,
)));
EOT

# Insert the WP Offload Media settings into wp-config.php
sudo sed -i "/define( 'WP_DEBUG', false );/r /tmp/wp-offload-media-settings.txt" /var/www/html/wp-config.php

# Update Apache configuration
sudo sed -i '/<Directory /var/www/>/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Restart Apache
sudo systemctl restart apache2

# Install and activate the WP Offload Media plugin
sudo -u www-data wp plugin install amazon-s3-and-cloudfront --activate
sudo -u www-data wp s3-uploads setup --force