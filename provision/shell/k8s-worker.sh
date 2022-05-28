# Fonte: https://phoenixnap.com/kb/how-to-install-kubernetes-on-centos

# executar todos os comandos em modo privilegiado

systemctl restart network
systemctl restart docker
systemctl restart kubelet

export WORKER_IP=$(ip a |grep global | grep -v '10.0.2.15' | grep -v docker0 | awk '{print $2}' | cut -f1 -d '/')
export MANAGER_IP=$(cat /vagrant/manager-ip)
export NODE_TOKEN=$(cat /vagrant/worker-node-join-command)

cat <<EOF > /run/flannel/subnet.env
FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.1.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
EOF

#kubeadm join MANAGER_IP:6443 --token ${NODE_TOKEN} --discovery-token-ca-cert-hash sha256:5aa3873e1449b2e59f37492dec86578351f283e79e5a52f962a56e414f78b2ac
${NODE_TOKEN}

echo 'export PATH=$PATH:/usr/local/bin/' >> /root/.bashrc
source /root/.bashrc