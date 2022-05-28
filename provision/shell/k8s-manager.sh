# sudo ufw allow 6443/tcp
# sudo ufw allow 2379/tcp
# sudo ufw allow 2380/tcp
# sudo ufw allow 10250/tcp
# sudo ufw allow 10251/tcp
# sudo ufw allow 10252/tcp
# sudo ufw allow 10255/tcp
# sudo ufw reload

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

# worker node token
kubeadm token create --print-join-command > /vagrant/worker-node-join-command