#!/bin/bash
PASSWDDB=$1
BASEHOST=$2

sudo yum -y update
#Install Apache
sudo yum -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd

sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum -y install yum-utils
sudo yum --enablerepo=remi,remi-php72 install -y php \
         php-common php-pear php-mcrypt php-cli php-gd php-curl \
         php-mysqli php-mysqlnd php-ldap php-zip php-fileinfo php-xml php-intl \
         php-mbstring php-xmlrpc php-soap php-pgsql php-redis

sudo sed -i -e 's/session.save_handler = files/session.save_handler = redis/g' /etc/php.ini
sudo sed -i -e "s+;session.save_path = \"/tmp\"+session.save_path = \"tcp://$BASEHOST:6379?auth=$PASSWDDB\"+g" /etc/php.ini

#Install App
curl https://download.moodle.org/download.php/direct/stable36/moodle-latest-36.tgz -o moodle-latest-36.tgz -s
sudo tar -xzf moodle-latest-36.tgz -C /var/www/html
sudo mkdir -p /var/moodledata
sudo chown -R apache:apache /var/moodledata
sudo sed -i -e 's+DocumentRoot "/var/www/html"+DocumentRoot "/var/www/html/moodle"+g' /etc/httpd/conf/httpd.conf
sudo sed -i -e 's+DirectoryIndex index.html+DirectoryIndex index.php index.html index.htm+g' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd

sudo chcon -R -t httpd_sys_rw_content_t /var/moodledata
sudo setsebool httpd_can_network_connect true

sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload