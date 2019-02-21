#!/bin/bash
MAINDB="moodle"
USERDB-"moodle"
PASSWDDB="moodle"
sudo yum -y update

# install PHP 7.0
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum -y install yum-utils
sudo yum-config-manager --enable remi-php70
sudo yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-xml php-intl php-mbstring php-xmlrpc php-soap
#Install Apache
sudo yum -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd
#install DB
sudo yum -y install mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql -e "SET GLOBAL character_set_server = 'utf8mb4';"
sudo mysql -e "SET GLOBAL collation-server = 'utf8mb4_unicode_ci';"
sudo mysql -e "SET GLOBAL innodb_file_format = 'BARRACUDA';"
sudo mysql -e "SET GLOBAL innodb_large_prefix = 'ON';"
sudo mysql -e "SET GLOBAL innodb_file_per_table = 'ON';"
sudo mysql -e "CREATE DATABASE ${MAINDB};"
sudo mysql -e "CREATE USER '${USERDB}'@'localhost' IDENTIFIED BY '${PASSWDDB}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${USERDB}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

#Install App
curl https://download.moodle.org/download.php/direct/stable36/moodle-latest-36.tgz -o moodle-latest-36.tgz -s
tar -xzf moodle-latest-36.tgz -C /var/www/html/
sudo mkdir /var/moodledata
sudo chcon -R -t httpd_sys_rw_content_t /var/moodledata
sudo chown -R apache:apache /var/moodledata
sudo chown -R apache:apache /var/www/

sudo -u apache /usr/bin/php /var/www/html/moodle/admin/cli/install.php --chmod=2770 \
 --lang=pt-br \
 --dbtype=mariadb \
 --wwwroot=http://localhost:8080/moodle \
 --dataroot=/var/moodledata \
 --dbname=$MAINDB \
 --dbuser=$USERDB \
 --dbport=3306 \
 --fullname=Moodle \
 --shortname=moodle \
 --summary=Moodle \
 --adminpass=Admin1 \
 --non-interactive \
 --agree-license
sudo chmod o+r /var/www/html/moodle/config.php
sudo systemctl restart httpd
sudo firewall-cmd --zone=publicweb --add-service=ssh
sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload