#!/bin/bash

sudo dnf install firewalld -y
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-port=22/tcp --zone=public
sudo firewall-cmd --permanent --add-port=2379/tcp --zone=public
sudo firewall-cmd --permanent --add-port=2380/tcp --zone=public
sudo systemctl restart firewalld
sudo mkdir -p /etc/etcd/pki
sudo cp /tmp/ca.pem /etc/etcd/pki/
sudo cp /tmp/etcd.pem /etc/etcd/pki/
sudo cp /tmp/etcd-key.pem /etc/etcd/pki/
sudo cp /tmp/etcd.service /etc/systemd/system/etcd.service
sudo yum install wget tar -y
wget https://github.com/etcd-io/etcd/releases/download/v3.5.10/etcd-v3.5.10-linux-amd64.tar.gz
tar zxf etcd-v3.5.10-linux-amd64.tar.gz
sudo cp etcd-v3.5.10-linux-amd64/etcd* /usr/local/bin/
sudo cp etcd-v3.5.10-linux-amd64/etcd* /usr/bin/
sudo rm -rf etcd*
sudo systemctl daemon-reload
sudo systemctl enable --now etcd
sudo systemctl status etcd --no-pager
exit 0