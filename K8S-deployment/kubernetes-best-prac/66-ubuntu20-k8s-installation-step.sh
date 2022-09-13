#!bin/bash
echo -e "ubuntu 20.04 kubernetes v18 installation"
sleep 3
##check kernel version
uname -rs;
#Linux 5.4.0-40-generic

echo login as Root
sudo -i

echo "turn off swap"
swapoff -a;
sed -i '/ swap / s/^/#/' /etc/fstab;
sleep 3

echo "apt update+install curl"
apt-get update && apt-get install -y apt-transport-https curl;
apt install -y gnupg2;
apt install -y jq

echo "k8s install loading~~~"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -;


cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

echo deb https://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list
 
apt-get update;
apt-get install -y docker.io;

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d;
systemctl start docker;
systemctl enable docker;
apt-get install -y kubelet kubeadm kubectl;


kubectl get nodes -o json | jq .items[].spec.taints
[
  {
    "effect": "NoSchedule",
    "key": "node-role.kubernetes.io/master"
  }
]
"
kubectl create deployment nginx3 --image=nginx
deployment.apps/nginx3 created
hitler@k8s-slave3:~$ kubectl expose deployment nginx3 --port 80 --target-port 80
echo scheduled master node
kubectl taint nodes --all node-role.kubernetes.io/master-;
sleep 2


echo '##check version
root@MASTER:~# apt search kubelet
Sorting... Done
Full Text Search... Done
kubelet/kubernetes-xenial,now 1.18.5-00 amd64 [installed]
  Kubernetes Node Agent

root@MASTER:~# apt search kubeadm
Sorting... Done
Full Text Search... Done
kubeadm/kubernetes-xenial,now 1.18.5-00 amd64 [installed]
  Kubernetes Cluster Bootstrapping Tool

root@MASTER:~# apt search kubectl
Sorting... Done
Full Text Search... Done
kubectl/kubernetes-xenial,now 1.18.5-00 amd64 [installed]
  Kubernetes Command Line Tool

kubetail/focal 1.6.5-2 all
  Aggregate logs from multiple Kubernetes pods into one stream

root@MASTER:~# ' 