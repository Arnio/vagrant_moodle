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
sudo yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-xml php-intl php-mbstring php-xmlrpc php-soap
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
sudo mysql -e "SET GLOBAL character_set_server = 'utf8mb4';"
sudo mysql -e "SET GLOBAL collation-server = 'utf8mb4_unicode_ci';"
sudo mysql -e "SET GLOBAL innodb_file_format = 'BARRACUDA';"
sudo mysql -e "SET GLOBAL innodb_large_prefix = 'ON';"
sudo mysql -e "SET GLOBAL innodb_file_per_table = 'ON';"


# sudo touch /etc/mysql/my.cnf
# cat <<EOF | sudo tee -a /etc/mysql/my.cnf
# [client]
# default-character-set = utf8mb4

# [mysqld]
# innodb_file_format = Barracuda
# innodb_file_per_table = 1
# innodb_large_prefix

# character-set-server = utf8mb4
# collation-server = utf8mb4_unicode_ci
# skip-character-set-client-handshake

# [mysql]
# default-character-set = utf8mb4
# EOF


#Install App
wget https://download.moodle.org/download.php/direct/stable36/moodle-latest-36.tgz
tar -xzf moodle-latest-36.tgz -C /var/www/html/
sudo mkdir /var/moodledata
sudo chcon -R -t httpd_sys_rw_content_t /var/moodledata
sudo chown -R apache:apache /var/moodledata
sudo chown -R apache:apache /var/www/

# cat <<EOF | sudo tee -a /var/www/html/config.php
# <?php  // Moodle configuration file

# unset($CFG);
# global $CFG;
# $CFG = new stdClass();

# $CFG->dbtype    = 'mariadb';
# $CFG->dblibrary = 'native';
# $CFG->dbhost    = 'localhost';
# $CFG->dbname    = '${MAINDB}';
# $CFG->dbuser    = '${MAINDB}';
# $CFG->dbpass    = '${MAINDB}';
# $CFG->prefix    = 'mdl_';
# $CFG->dboptions = array (
#   'dbpersist' => 0,
#   'dbport' => 3306,
#   'dbsocket' => '',
#   'dbcollation' => 'utf8mb4_unicode_ci',
# );

# $CFG->wwwroot   = 'http://localhost:8080/moodle';
# $CFG->dataroot  = '/var/moodledata';
# $CFG->admin     = 'admin';

# $CFG->directorypermissions = 0777;

# require_once(__DIR__ . '/lib/setup.php');

# // There is no php closing tag in this file,
# // it is intentional because it prevents trailing whitespace problems!
# EOF
sudo -u apache /usr/bin/php /var/www/html/moodle/admin/cli/install.php --chmod=2770 \
 --lang=pt-br \
 --dbtype=mariadb \
 --wwwroot=http://localhost:8080/moodle \
 --dataroot=/var/moodledata \
 --dbname=$MAINDB \
 --dbuser=$MAINDB \
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