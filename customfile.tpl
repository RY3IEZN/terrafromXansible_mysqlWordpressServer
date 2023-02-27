#!/bin/bash 

# Update Ubuntu Repository List 
sudo apt-get update && 

# Update Ubuntu Package List 
sudo apt-get upgrade \

# Install PHP 
sudo apt-get install php php-mysqli php-xml -y \

# Install Apache 
sudo apt-get install apache2 -y \

# Remove Apache main page  
sudo rm /var/www/html/index.html \

# Download Wordpress latest version  
sudo wget https://wordpress.org/latest.tar.gz \

# Uncompress and move Wordpress to Apache Folder  
sudo tar xvf latest.tar.gz  &&
sudo mv wordpress/* /var/www/html/ 

# Set the right permission in folder  
sudo chown -R www-data:www-data /var/www/html/ 