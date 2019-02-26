#!/bin/bash
MAINDB="moodledb"
USERDB="moodleus"
PASSWDDB="moodle123"
WWWHOST="192.168.56.101"
BASEHOST="192.168.56.10"
#sudo yum -y update
cat <<EOF | sudo tee -a /etc/yum.repos.d/MariaDB.repo
# MariaDB 10.1 CentOS repository list
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.4.3/centos7-amd64/
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
# install PHP 7.0
#sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

#install DB
sudo yum -y install mariadb-server MariaDB-client
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo sed -i -e 's/#bind-address=0.0.0.0/bind-address=0.0.0.0/g' /etc/my.cnf.d/server.cnf
sudo mysql -e "SET GLOBAL character_set_server = 'utf8mb4';"
sudo mysql -e "SET GLOBAL innodb_file_format = 'BARRACUDA';"
sudo mysql -e "SET GLOBAL innodb_large_prefix = 'ON';"
sudo mysql -e "SET GLOBAL innodb_file_per_table = 'ON';"
sudo mysql -e "CREATE DATABASE ${MAINDB};"
sudo mysql -e "CREATE USER '${USERDB}'@'localhost' IDENTIFIED BY '${PASSWDDB}';"
sudo mysql -e "CREATE USER '${USERDB}'@'%' IDENTIFIED BY '${PASSWDDB}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${USERDB}'@'localhost';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${USERDB}'@'%'"
sudo mysql -e "CREATE USER 'andriy'@'192.168.56.%' IDENTIFIED BY 'moodle123';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'andriy'@'192.168.56.%'  IDENTIFIED BY 'moodle123' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"


sudo systemctl restart mariadb
# sudo systemctl enable firewalld
# sudo systemctl start firewalld
# sudo firewall-cmd --zone=public --add-service=ssh
# sudo firewall-cmd --permanent --zone=public --add-service=http 
# sudo firewall-cmd --permanent --zone=public --add-service=https
# sudo firewall-cmd --reload