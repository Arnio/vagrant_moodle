#!/bin/bash
MAINDB="moodledb"
USERDB="moodleus"
PASSWDDB="moodle123"
#WWWHOST="192.168.56.101"
BASEHOST="192.168.56.10"
WWWHOST=$(hostname --all-ip-addresses| awk '{ print $2}')

#Install Apache
sudo yum -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd

#sudo yum -y install mariadb
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum -y install yum-utils
sudo yum --enablerepo=remi,remi-php72 install -y php php-fpm \
         php-common php-pear php-mcrypt php-cli php-gd php-curl \
         php-mysql php-mysqlnd php-ldap php-zip php-fileinfo php-xml php-intl \
         php-mbstring php-xmlrpc php-soap php-pdo php-pgsql

sudo sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
# sudo sed -i -e 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
# sudo sed -i -e 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf
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
# curl https://download.moodle.org/download.php/direct/stable36/moodle-latest-36.tgz -o moodle-latest-36.tgz -s
# sudo tar -xzf moodle-latest-36.tgz -C /var/www/

#  sudo mkdir -p /var/moodledata
#  sudo chown -R nginx:nginx /var/moodledata
#  sudo chmod 755 /var/moodledata
#  sudo chown -R nginx:nginx /var/www/moodle
#  sudo chmod 755 /var/www/moodle


# sudo chcon -R -t httpd_sys_rw_content_t /var/moodledata
# sudo setsebool httpd_can_network_connect true

# sudo /usr/bin/php /var/www/moodle/admin/cli/install.php --chmod=2770 \
#  --lang=uk \
#  --dbtype=mariadb \
#  --wwwroot=http://$WWWHOST/ \
#  --dataroot=/var/moodledata \
#  --dbhost=$BASEHOST \
#  --dbname=$MAINDB \
#  --dbuser=$USERDB \
#  --dbpass=$PASSWDDB \
#  --dbport=3306 \
#  --fullname=Moodle \
#  --shortname=moodle \
#  --summary=Moodle \
#  --adminpass=Admin1 \
#  --non-interactive \
#  --agree-license
# sudo chmod o+r /var/www/moodle/config.php
# sudo chcon -R -t httpd_sys_rw_content_t /var/moodledata
# sudo chown -R nginx:nginx /var/moodledata
# sudo chown -R nginx:nginx /var/www/moodle
# sudo systemctl restart nginx
# sudo systemctl enable firewalld
# sudo systemctl start firewalld
# sudo firewall-cmd --permanent --add-service=ssh
# sudo firewall-cmd --permanent --zone=public --add-service=http 
# sudo firewall-cmd --permanent --zone=public --add-service=https
# sudo firewall-cmd --reload