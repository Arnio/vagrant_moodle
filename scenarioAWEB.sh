#!/bin/bash
MAINDB="moodledb"
USERDB="moodleus"
PASSWDDB="moodle123"
BASEHOST="192.168.56.10"


WWWHOST=$(hostname --all-ip-addresses| awk '{ print $2}')

#Install Apache
sudo yum -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd

sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum -y install yum-utils
sudo yum --enablerepo=remi,remi-php72 install -y php php-fpm \
         php-common php-pear php-mcrypt php-cli php-gd php-curl \
         php-mysqli php-mysqlnd php-ldap php-zip php-fileinfo php-xml php-intl \
         php-mbstring php-xmlrpc php-soap php-pgsql php-pdo

sudo sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
sudo sed -i -e 's+listen = 127.0.0.1:9000+listen = /run/php-fpm/php-fpm.sock+g' /etc/php-fpm.d/www.conf
sudo sed -i -e 's/;listen.owner = nobody/listen.owner = apache/g' /etc/php-fpm.d/www.conf
sudo sed -i -e 's/;listen.group = nobody/listen.group = apache/g' /etc/php-fpm.d/www.conf
sudo sed -i -e 's/;listen.mode = 0660/listen.mode = 0660/g' /etc/php-fpm.d/www.conf
sudo sed -i -e 's/;security.limit_extensions = .php .php3 .php4 .php5 .php7/security.limit_extensions = .php/g' /etc/php-fpm.d/www.conf
sudo sed -i -e 's/;env/env/g' /etc/php-fpm.d/www.conf

# sudo mkdir -p /var/lib/php/session/
# sudo chown -R nginx:nginx /var/lib/php/session/
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

#Install App
curl https://download.moodle.org/download.php/direct/stable36/moodle-latest-36.tgz -o moodle-latest-36.tgz -s
sudo tar -xzf moodle-latest-36.tgz -C /var/www/html
sudo mkdir -p /var/moodledata
sudo chown -R apache:apache /var/moodledata
sudo chmod 755 /var/moodledata
sudo chown -R apache:apache /var/www/html/moodle
sudo chmod 755 /var/www/html/moodle
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