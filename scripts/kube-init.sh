#!/bin/bash
cd /home/almalinux/ 
sudo mkdir -p /etc/kubernetes/pki/etcd
sudo cp ca.pem etcd.pem etcd-key.pem /etc/kubernetes/pki/etcd/
sudo kubeadm init --config=cluster.yaml --upload-certs
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo cp -i /etc/kubernetes/admin.conf /home/almalinux/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chown -R almalinux:almalinux /home/almalinux/config
export KUBECONFIG=/home/almalinux/config
sudo chmod 644 /etc/kubernetes/admin.conf
sudo echo $(kubeadm token create --print-join-command) --control-plane --certificate-key $(sudo kubeadm init phase upload-certs --upload-certs --config cluster.yaml | grep -vw -e certificate -e Namespace) >> join-master.sh
sudo kubeadm token create --print-join-command >> join-worker.sh
sudo chown -R almalinux:almalinux join-master.sh
sudo chown -R almalinux:almalinux join-worker.sh
export KUBECONFIG=/etc/kubernetes/admin.conf