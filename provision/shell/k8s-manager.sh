# Fonte: https://phoenixnap.com/kb/how-to-install-kubernetes-on-centos

# executar todos os comandos em modo privilegiado

# How to Deploy a Kubernetes Cluster
## Step 1: Create Cluster with kubeadm
### kubeadm init --pod-network-cidr=10.244.0.0/16

systemctl restart network
systemctl restart docker
systemctl restart kubelet

export MANAGER_IP=$(ip a |grep global | grep -v '10.0.2.15' | grep -v docker0 | awk '{print $2}' | cut -f1 -d '/')
echo $MANAGER_IP > /vagrant/manager-ip

kubeadm config images pull

kubeadm init --control-plane-endpoint ${MANAGER_IP} \
    --pod-network-cidr=10.244.0.0/16 \
    --apiserver-advertise-address=${MANAGER_IP} \
    --apiserver-cert-extra-sans=${MANAGER_IP} 

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml

cat <<EOF > /run/flannel/subnet.env
FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.1.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
EOF

# worker node token
kubeadm token create --print-join-command > /vagrant/worker-node-join-command