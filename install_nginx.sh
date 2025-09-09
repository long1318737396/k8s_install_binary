#!/bin/bash


source env.sh

yum install -y nginx

cat > /etc/nginx/conf.d/kube-nginx.conf <<EOF
worker_processes 1;
events {
    worker_connections  1024;
}
stream {
    upstream backend {
        least_conn;
        hash $remote_addr consistent;
        server ${IP_ADDRESS}:6443        max_fails=3 fail_timeout=30s;
    }
    server {
        listen 127.0.0.1:8443;
        proxy_connect_timeout 1s;
        proxy_pass backend;
    }
}
EOF

nginx -t 
systemctl enable nginx --now

nginx -s reload