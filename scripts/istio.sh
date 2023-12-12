#!/bin/bash

cd /tmp/ || exit
kubectl apply -f metric-server.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
sleep 20
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -
cd istio-1.20.0/bin || exit
sudo chmod +x istioctl
./istioctl install -f /tmp/istio-operator.yaml -y
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-prometheus-stack  --create-namespace  --namespace kube-prometheus-stack  prometheus-community/kube-prometheus-stack
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install loki grafana/loki-stack --namespace loki --create-namespace --set grafana.enabled=false
helm repo add jetstack https://charts.jetstack.io
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
cd /tmp/ || exit
kubectl apply -f istio.yaml
kubectl apply -f ssl.yaml
kubectl apply -f metal-ip.yaml