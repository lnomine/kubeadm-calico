#!/bin/bash

# Prerequisites for Debian Bullseye:
# - No swap
# - systemd.unified_cgroup_hierarchy=0 in GRUB

apt update ; apt install --no-install-recommends -y gnupg2 apt-transport-https curl containerd ca-certificates
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt update
apt install --no-install-recommends -y kubelet=$1 kubeadm=$1 kubectl=$1
apt-mark hold kubelet kubeadm kubectl
echo "br_netfilter" >> /etc/modules
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

ln -s /opt/cni/bin/ /usr/lib/cni
kubeadm init --control-plane-endpoint "load.balancer:5443" --upload-certs --pod-network-cidr=192.168.0.0/16
export KUBECONFIG=/etc/kubernetes/admin.conf
echo "Waiting for Kubernetes API..."
sleep 30
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/$2/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/$2/manifests/custom-resources.yaml
