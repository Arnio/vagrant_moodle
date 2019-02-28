#!/bin/bash
MAINDB=$1
USERDB=$2
PASSWDDB=$3
BASEHOST=$4
WWWHOST=$5
#WWWHOST=$(hostname --all-ip-addresses| awk '{ print $2}')
echo $WWWHOST

sudo -u apache /usr/bin/php /var/www/html/moodle/admin/cli/install.php --chmod=2770 \
 --lang=uk \
 --dbtype=mariadb \
 --wwwroot=http://$WWWHOST/ \
 --dataroot=/var/moodledata \
 --dbhost=$BASEHOST \
 --dbname=$MAINDB \
 --dbuser=$USERDB \
 --dbpass=$PASSWDDB \
 --dbport= \
 --fullname=Moodle \
 --shortname=moodle \
 --summary=Moodle \
 --adminpass=Admin1 \
 --non-interactive \
 --agree-license
