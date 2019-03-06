#!/bin/bash
MAINDB=$1
USERDB=$2
PASSWDDB=$3
BASEHOST=$4
WWWHOST=$5
#WWWHOST=$(hostname --all-ip-addresses| awk '{ print $2}')
echo $WWWHOST

sudo /usr/bin/php /var/www/html/moodle/admin/cli/install.php --chmod=2770 \
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

CFG='$CFG'
cat <<EOF | sudo tee -a /var/www/html/moodle/config.php
$CFG->session_redis_host = '${BASEHOST}';
$CFG->session_redis_port = 6379;  // Optional.
$CFG->session_redis_database = 0;  // Optional, default is db 0.
$CFG->session_redis_prefix = ''; // Optional, default is don't set one.
$CFG->session_redis_acquire_lock_timeout = 120;
$CFG->session_redis_lock_expire = 7200;
EOF
sudo chown -R apache:apache /var/www/html/moodle