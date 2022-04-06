# Fonte: https://phoenixnap.com/kb/how-to-install-kubernetes-on-centos

# executar todos os comandos em modo privilegiado

systemctl stop firewalld
systemctl disable firewalld
ip a
systemctl restart network

# instalar apenas dependencias necessarias.
yum install -y vim curl yum-utils device-mapper-persistent-data lvm2

# install docker
yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker --now

# etc/hosts
cat <<EOF >> /etc/hosts
192.168.56.3 k8s-manager
192.168.56.4 k8s-worker01
192.168.56.5 k8s-worker02
EOF

# install kubernetes
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet kubeadm kubectl
systemctl enable kubelet --now

# Step 4: Configure Firewall


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

systemctl daemon-reload
systemctl restart docker
systemctl restart kubelet



