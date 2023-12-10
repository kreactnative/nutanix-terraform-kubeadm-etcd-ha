#!/bin/bash

sudo dnf install firewalld -y
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-port=22/tcp --zone=public
sudo firewall-cmd --permanent --add-port=6443/tcp --zone=public
sudo systemctl restart firewalld
sudo dnf install nginx -y
sudo systemctl enable nginx
sudo systemctl restart nginx
sudo dnf install openssl-devel gcc wget curl pcre-devel zlib-devel -y
sudo yum install gcc glibc glibc-common gd gd-devel -y
sudo wget https://nginx.org/download/nginx-1.20.1.tar.gz
tar  -xzvf  nginx-1.20.1.tar.gz
cd nginx-1.20.1
sudo ./configure --prefix=/usr/local/nginx --modules-path=/usr/local/nginx/modules --user=nginx --group=nginx --with-stream=dynamic --with-compat
sudo make
sudo make install
sudo yum install policycoreutils-python-utils -y
sudo semanage port -a -t http_port_t  -p tcp 6443
sudo setsebool -P httpd_can_network_connect 1
sudo sudo systemctl restart nginx
sudo systemctl status nginx --no-pager

n=0
retries=5
echo "update  nginx config"
sudo rm -rf /etc/nginx/nginx.conf
sudo cp /tmp/nginx.conf /etc/nginx/nginx.conf

echo "restart nginx proxy"
until [ "$n" -ge "$retries" ]; do
   if sudo systemctl restart nginx; then
      cat /etc/nginx/nginx.conf
      exit 0
   else
      n=$((n+1)) 
      sleep 5
   fi
done

echo "All retries failed. Exiting with code 1."
exit 1
