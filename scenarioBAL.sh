#!/bin/bash
# sudo yum -y update

#Install Nginx
sudo yum -y install epel-release
sudo yum -y install nginx
sudo systemctl start nginx
sudo systemctl enable nginx
# nginx config
sudo rm /etc/nginx/nginx.conf
scheme='$scheme'
request_uri='$request_uri'
remote_addr='$remote_addr'
remote_user='$remote_user'
time_local='$time_local'
request='$request'
status='$status'
body_bytes_sent='$body_bytes_sent'
http_referer='$http_referer'
http_user_agent='$http_user_agent'
http_x_forwarded_for='$http_x_forwarded_for'
# cat <<EOF | sudo tee -a /etc/nginx/nginx.conf
# # For more information on configuration, see:
# #   * Official English Documentation: http://nginx.org/en/docs/
# #   * Official Russian Documentation: http://nginx.org/ru/docs/

# user nginx;
# worker_processes auto;
# error_log /var/log/nginx/error.log;
# pid /run/nginx.pid;

# # Load dynamic modules. See /usr/share/nginx/README.dynamic.
# include /usr/share/nginx/modules/*.conf;

# events {
#     worker_connections 1024;
# }

# http {
#     log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
#                       '$status $body_bytes_sent "$http_referer" '
#                       '"$http_user_agent" "$http_x_forwarded_for"';

#     access_log  /var/log/nginx/access.log  main;

#     sendfile            on;
#     tcp_nopush          on;
#     tcp_nodelay         on;
#     keepalive_timeout   65;
#     types_hash_max_size 2048;

#     include             /etc/nginx/mime.types;
#     default_type        application/octet-stream;

#     # Load modular configuration files from the /etc/nginx/conf.d directory.
#     # See http://nginx.org/en/docs/ngx_core_module.html#include
#     # for more information.
#     include /etc/nginx/conf.d/*.conf;
#     upstream moodle {
#     ip_hash;    
#     server 192.168.56.101;  
#     server 192.168.56.102;
#     }
#     server {
#         listen       80 default_server;
#         listen       [::]:80 default_server;
#         server_name  192.168.56.100;
#         root         /usr/share/nginx/html;

#         # Load configuration files for the default server block.
#         include /etc/nginx/default.d/*.conf;

#         location / {
#           proxy_pass http://moodle;
          
#         }

#         error_page 404 /404.html;
#             location = /40x.html {
#         }

#         error_page 500 502 503 504 /50x.html;
#             location = /50x.html {
#         }
#     }

# # Settings for a TLS enabled server.
# #
# #    server {
# #        listen       443 ssl http2 default_server;
# #        listen       [::]:443 ssl http2 default_server;
# #        server_name  _;
# #        root         /usr/share/nginx/html;
# #
# #        ssl_certificate "/etc/pki/nginx/server.crt";
# #        ssl_certificate_key "/etc/pki/nginx/private/server.key";
# #        ssl_session_cache shared:SSL:1m;
# #        ssl_session_timeout  10m;
# #        ssl_ciphers HIGH:!aNULL:!MD5;
# #        ssl_prefer_server_ciphers on;
# #
# #        # Load configuration files for the default server block.
# #        include /etc/nginx/default.d/*.conf;
# #
# #        location / {
# #        }
# #
# #        error_page 404 /404.html;
# #            location = /40x.html {
# #        }
# #
# #        error_page 500 502 503 504 /50x.html;
# #            location = /50x.html {
# #        }
# #    }

# }
# EOF
cat <<EOF | sudo tee -a /etc/nginx/conf.d/balancer.conf
upstream moodle {
    server 192.168.56.101;  
    server 192.168.56.102;
  }
    

server {
    listen 80;
    server_name 192.168.56.100
    root /var/www/html;
    index index.php
  location / {
      proxy_pass http://moodle;
      
  }
}
EOF
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload