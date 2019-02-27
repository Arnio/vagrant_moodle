#!/bin/bash
MAINDB="moodledb"
USERDB="moodleus"
PASSWDDB="moodle123"
BASEHOST="192.168.56.10"

WWWHOST=$(hostname --all-ip-addresses| awk '{ print $2}')
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
