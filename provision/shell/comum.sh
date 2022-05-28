apt update

apt install -y curl apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

apt update

apt-get install -y docker-ce
systemctl enable docker --now

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt update

sed -i '/swap/d' /etc/fstab
swapoff -a

apt install -y kubelet kubeadm kubectl
systemctl enable kubelet --now

# etc/hosts
cat <<EOF >> /etc/hosts
192.168.56.3 k8s-manager
192.168.56.4 k8s-worker01
192.168.56.5 k8s-worker02
EOF

cat <<EOF > /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

rm /etc/containerd/config.toml
systemctl restart containerd

systemctl restart docker
systemctl restart kubelet

systemctl status docker
systemctl status kubelet