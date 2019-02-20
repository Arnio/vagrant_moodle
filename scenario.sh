#!/bin/bash
MAINDB="moodle"
PASSWDDB= "moodle"
#sudo yum -y update
sudo yum -y install wget
sudo yum -y install httpd
sudo systemctl start httpd
sudo yum -y install mariadb-server
sudo systemctl start mariadb 
wget https://download.moodle.org/download.php/stable36/moodle-latest-36.tgz
#wget http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
#sudo yum -y install ./mysql57-community-release-el7-7.noarch.rpm 
#sudo yum -y install mysql-community-server 
#sudo systemctl start mysqld 

# Get the temporary password
temp_password=$(grep password /var/log/mysqld.log | awk '{print $NF}')
# echo "UPDATE user SET password=PASSWORD('PassWord1!') WHERE User='root'; flush privileges;" > reset_pass.sql

# Log in to the server with the temporary password, and pass the SQL file to it.
#mysql -u root --password="$temp_password" --connect-expired-password < reset_pass.sql
#mysql -u root --password="$temp_password"
#mysql -uroot -p${temp_password} -e "CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
#mysql -uroot -p${temp_password} -e "CREATE USER ${MAINDB}@localhost IDENTIFIED BY '${PASSWDDB}';"
#mysql -uroot -p${temp_password} -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${MAINDB}'@'localhost';"
#mysql -uroot -p${temp_password} -e "FLUSH PRIVILEGES;"
sudo yum -y install php php-mysql
sudo systemctl restart httpd
sudo yum -y install php-fpm php-bcmath.x86_64 php-cli.x86_64 php-common.x86_64 php-dba.x86_64 php-devel.x86_64 php-embedded.x86_64 php-enchant.x86_64 php-fpm.x86_64 php-gd.x86_64
sudo firewall-cmd --zone=publicweb --add-service=ssh
sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload