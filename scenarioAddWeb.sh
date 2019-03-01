#!/bin/bash
WEBHOST=$1
sudo sed -i "/    upstream moodle {/a\      server $WEBHOST;" /etc/nginx/nginx.conf

#Install Nginx
sudo nginx -t
sudo systemctl restart nginx
