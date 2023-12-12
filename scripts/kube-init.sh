#!/bin/bash
cd /home/rocky/ 
sudo mkdir -p /etc/kubernetes/pki/etcd
sudo cp ca.pem etcd.pem etcd-key.pem /etc/kubernetes/pki/etcd/
sudo kubeadm init --config=cluster.yaml --upload-certs
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo cp -i /etc/kubernetes/admin.conf /home/rocky/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chown -R rocky:rocky /home/rocky/config
export KUBECONFIG=/home/rocky/config
sudo chmod 644 /etc/kubernetes/admin.conf
sudo echo $(kubeadm token create --print-join-command) --control-plane --certificate-key $(sudo kubeadm init phase upload-certs --upload-certs --config cluster.yaml | grep -vw -e certificate -e Namespace) >> join-master.sh
sudo kubeadm token create --print-join-command >> join-worker.sh
sudo chown -R rocky:rocky join-master.sh
sudo chown -R rocky:rocky join-worker.sh
export KUBECONFIG=/etc/kubernetes/admin.conf