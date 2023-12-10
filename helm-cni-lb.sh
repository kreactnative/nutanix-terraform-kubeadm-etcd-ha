#!/bin/bash

sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh
sudo cp /usr/local/bin/helm /usr/bin/helm

kubectl -n kube-system delete ds kube-proxy
kubectl -n kube-system delete cm kube-proxy

helm repo add cilium https://helm.cilium.io/
helm upgrade --install cilium cilium/cilium \
    --namespace cilium --create-namespace \
    --set bpf.masquerade=true \
    --set encryption.nodeEncryption=false \
    --set k8sServiceHost=192.168.1.44 \
    --set k8sServicePort=6443  \
    --set kubeProxyReplacement=strict  \
    --set operator.replicas=1  \
    --set serviceAccounts.cilium.name=cilium  \
    --set serviceAccounts.operator.name=cilium-operator  \
    --set tunnel=vxlan \
    --set hubble.enabled=true \
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true \
    --set prometheus.enabled=true \
    --set operator.prometheus.enabled=true \
    --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}"