#!/bin/bash

# Prerequisites for Debian Bullseye:
# - No swap
# - systemd.unified_cgroup_hierarchy=0 in GRUB

apt update ; apt install -y gnupg2 apt-transport-https curl containerd ca-certificates
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

curl -sL https://github.com/containerd/containerd/releases/download/v1.6.14/containerd-1.6.14-linux-amd64.tar.gz -o containerd.tar.gz
tar xzvf containerd.tar.gz -C /tmp && cd /tmp
systemctl stop containerd
cp bin/* /usr/bin/
systemctl start containerd

apt update ; apt install -y kubelet=$1-00 kubeadm=$1-00 kubectl=$1-00
apt-mark hold kubelet kubeadm kubectl containerd
echo "br_netfilter" >> /etc/modules
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

ln -s /opt/cni/bin/ /usr/lib/cni
