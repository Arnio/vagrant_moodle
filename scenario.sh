#!/bin/bash
MAINDB="moodle"
PASSWDDB="moodle"
sudo yum -y update
sudo yum -y install wget
# install PHP 7.0
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum -y install yum-utils
sudo yum-config-manager --enable remi-php70
sudo yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo
#Install Apache
sudo yum -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd
#install DB
sudo yum -y install mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql -e "CREATE DATABASE ${MAINDB} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON ${MAINDB}.* TO '${MAINDB}'@'localhost' IDENTIFIED BY '${PASSWDDB}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${MAINDB}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

#Install App
wget https://download.moodle.org/download.php/direct/stable36/moodle-latest-36.tgz
tar -xzf moodle-latest-36.tgz -C /var/www/html/
cat <<EOF | sudo tee -a /var/www/html/config.php
<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'localhost';
$CFG->dbname    = '${MAINDB}';
$CFG->dbuser    = '${MAINDB}';
$CFG->dbpass    = '${MAINDB}';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => 3306,
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

$CFG->wwwroot   = 'http://localhost:8080/moodle';
$CFG->dataroot  = '/var/moodledata';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
EOF
#sudo -u apache /usr/bin/php /var/www/html/moodle/admin/cli/install.php --chmod=2770 --lang=pt-br --dbtype=mariadb --dblibrary=native --wwwroot=http://localhost:8080/moodle --dataroot=/var/moodledata --dbname=$MAINDB --dbuser=$MAINDB --dbport=3306 --fullname=Moodle --shortname=moodle --summary=Moodle --adminpass=Admin1234 --non-interactive --agree-license
sudo chmod o+r /var/www/html/moodle/config.php
sudo mkdir /var/moodledata
sudo chown -R apache:apache /var/moodledata
sudo chown -R apache:apache /var/www/
sudo systemctl restart httpd
sudo firewall-cmd --zone=publicweb --add-service=ssh
sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload