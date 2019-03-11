#!/bin/bash
PASSWDDB=$1
BASEHOST=$2



sudo yum -y install epel-release
sudo yum -y install redis
sudo systemctl start redis
sudo systemctl enable redis

sudo sed -i -e "s/bind 127.0.0.1/bind 127.0.0.1 $BASEHOST/g" /etc/redis.conf
sudo sed -i -e "s/# requirepass foobared/requirepass $PASSWDDB/g" /etc/redis.conf

sudo systemctl restart redis

sudo firewall-cmd --permanent --zone=public --add-port=6379/tcp
sudo firewall-cmd --reload