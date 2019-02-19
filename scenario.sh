#!/bin/bash
sudo yum update -y
sudo yum install wget -y
sudo yum install httpd -y
sudo systemctl start httpd
wget http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm 
sudo yum -y install ./mysql57-community-release-el7-7.noarch.rpm 
sudo yum -y install mysql-community-server 
systemctl start mysqld 
# Get the temporary password
temp_password=$(grep password /var/log/mysqld.log | awk '{print $NF}')

echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'password'; flush privileges;" > reset_pass.sql

# Log in to the server with the temporary password, and pass the SQL file to it.
mysql -u root --password="$temp_password" --connect-expired-password < reset_pass.sql
