#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --reload