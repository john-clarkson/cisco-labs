#!/bin/bash
echo Setup kubeadm/kubectl/crictl/helm completion.
source <(kubeadm completion bash);
source <(kubectl completion bash);
source <(crictl completion bash);
source <(helm completion bash);
sleep 2
echo Refresh .bashrc
source  ~/.bashrc
sleep 2

echo Turnoff swap
swapoff -a

echo kubeadm init
kubeadm init --apiserver-advertise-address 10.211.55.8 --pod-network-cidr 10.233.0.0/16 --service-cidr 10.33.33.0/24;
sleep 2

echo Build kubeconfig
mkdir -p $HOME/.kube;
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config;
sudo chown $(id -u):$(id -g) $HOME/.kube/config;
sleep 2
echo "
kubectl get nodes -o json | jq .items[].spec.taints
[
  {
    "effect": "NoSchedule",
    "key": "node-role.kubernetes.io/master"
  }
]
"

echo scheduled master node
kubectl taint nodes --all node-role.kubernetes.io/master-;
sleep 2

echo kubectl get nodes
kubectl get node;

echo watch kubectl get pods -n kube-system
echo Next step, Choose a CNI plugin. Have a nice day!
echo Deploy busybox with 3 replicas with pending state.
kubectl apply -f  /root/k8s/kuber-deployment/busybox-deployment.yaml;




#kubectl get pods -n kube-system
#NAME                                   READY   STATUS    RESTARTS   AGE
#cilium-etcd-kmbvsp6sxw                 1/1     Running   0          2m33s
#cilium-etcd-operator-87c6f846f-2rsfl   1/1     Running   0          28m
#cilium-lzmgx                           0/1     Running   3          28m
#cilium-operator-5c797db947-8fpff       1/1     Running   2          28m
#coredns-66bff467f8-82jjq               1/1     Running   0          32m
#coredns-66bff467f8-r454l               1/1     Running   0          32m
#etcd-master                            1/1     Running   0          32m
#etcd-operator-6c57fff6f5-7sppf         1/1     Running   0          2m52s
#kube-apiserver-master                  1/1     Running   0          32m
#kube-controller-manager-master         1/1     Running   0          32m
#kube-proxy-9nbvh                       1/1     Running   0          32m
#kube-scheduler-master                  1/1     Running   0          32m

