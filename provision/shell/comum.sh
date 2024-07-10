# executar todos os comandos em modo privilegiado

#yum update -y

# instalar apenas dependencias necessarias.
yum install -y vim curl yum-utils device-mapper-persistent-data lvm2 iproute-tc git

# install docker
yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker --now

# etc/hosts
cat <<EOF >> /etc/hosts
192.168.56.3 k8s-manager
192.168.56.4 k8s-worker01
192.168.56.5 k8s-worker02
EOF

# install kubernetes
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet --now


# Step 5: Update Iptables Settings
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# Step 6: Disable SELinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Step 7: Disable SWAP
sed -i '/swap/d' /etc/fstab
swapoff -a

# Resolvendo seguinte problema:
# [kubelet-check] Initial timeout of 40s passed.
# [kubelet-check] It seems like the kubelet isn't running or healthy.
# [kubelet-check] The HTTP call equal to 'curl -sSL http://localhost:10248/healthz' failed with error: Get "http://localhost:10248/healthz": dial tcp [::1]:10248: connect: connection refused.
cat <<EOF > /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

rm -f /etc/containerd/config.toml
systemctl restart containerd

systemctl daemon-reload
systemctl restart docker
systemctl restart kubelet



