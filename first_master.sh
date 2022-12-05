#!/bin/bash

kubeadm init --kubernetes-version $1 --control-plane-endpoint "${loadbalancer}:5443" --upload-certs --pod-network-cidr=192.168.0.0/16
export KUBECONFIG=/etc/kubernetes/admin.conf
echo "Waiting for Kubernetes API..."
sleep 30
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/$2/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/$2/manifests/custom-resources.yaml
