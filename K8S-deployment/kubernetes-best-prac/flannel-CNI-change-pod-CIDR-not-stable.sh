$!bin/bash
echo "refer link"
echo "https://stackoverflow.com/questions/60176343/how-to-make-the-pod-cidr-range-larger-in-kubernetes-cluster-deployed-with-kubead"
sleep 10


echo "Replace kube-apiserver.yaml+kube-controller-manager-SVC-CIDR"
sed -i "s~10.96.0.0/12~10.96.254.0/24~" /etc/kubernetes/manifests/kube-apiserver.yaml
sed -i "s~10.96.0.0/12~10.96.254.0/24~" /etc/kubernetes/manifests/kube-controller-manager.yaml
sleep 2

echo "Delete default kubernetes service, Regenerate later"
kubectl delete svc kubernetes
sleep 4
watch kubectl get svc
root@MASTER:~# cat flannel\=changePODcidr.sh 
#!/bin/bash
echo "kubectl get node $hostname -o yaml >> file.yaml | sed -i "s~old_ip~new_ip~" file.yaml| kubectl delete no $hostname && kubectl create -f file.yaml"
echo "Get node-config"
mkdir -p temp
cd temp
kubectl get node master -o yaml >master-node.yaml;
kubectl get node worker -o yaml >worker-node.yaml;
echo "Replace podCIDR"
sed -i "s~10.244.0.0/24~10.250.0.0/24~" master-node.yaml;
sed -i "s~10.244.1.0/24~10.250.1.0/24~" worker-node.yaml;
echo "Delete node"
kubectl delete node master;
kubectl delete node worker;
echo "Add node"
kubectl apply -f master-node.yaml;
kubectl apply -f worker-node.yaml;
echo "Get flannel configmaps"
kubectl get configmaps -n kube-system kube-flannel-cfg -oyaml >kube-flannel-configmap.yaml
echo "Change podCIDR subnets "
sed -i "s~10.244.0.0/16~10.250.0.0/16~" kube-flannel-configmap.yaml;
echo "Apply changes"
kubectl apply -f kube-flannel-configmap.yaml

echo "changes kube-controller-manifests"
sed -i "s~10.244.0.0/16~10.250.0.0/16~" /etc/kubernetes/manefests/kube-controler-manager.yaml

echo "ALL nodes:delete cni0 and flannel.1 interface"
ip link del cni0;
ip link del flannel.1;
echo Restart daemon and kubelet
systemctl daemon-reload;
systemctl restart kubelet;

echo if IP subnets are not change or POD got stuck state, try del cni0, then redeploy app.
ip link del cni0;
echo "Delete flannel and kube-dns pods, Regenerate"
kubectl delete pod --selector=app=flannel -n kube-system;
kubectl delete pod --selector=k8s-app=kube-dns -n kube-system;

echo Delete temp
cd;
rm -frv temp;

echo "kubectl get pods -n kube-system -o wide"
echo "kubectl get pod -o wide"
watch kubectl get pod -n kube-system -o wide --selector=k8s-app=kube-dns -n kube-system

echo '
1261: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default qlen 1000
    link/ether 4a:30:52:8e:49:b8 brd ff:ff:ff:ff:ff:ff
    inet 10.250.0.1/24 brd 10.250.0.255 scope global cni0

1265: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN group default 
    link/ether 9e:d8:ca:86:ee:f0 brd ff:ff:ff:ff:ff:ff
    inet 10.250.0.0/32 scope global flannel.1


kubectl get pods -o wide
NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE     NOMINATED NODE   READINESS GATES
busybox-deployment-65ff9b6c7b-bdzlb   1/1     Running   0          7m14s   10.250.0.129   master   <none>           <none>
busybox-deployment-65ff9b6c7b-rs4m4   1/1     Running   0          7m14s   10.250.0.128   master   <none>           <none>
busybox-deployment-65ff9b6c7b-t7g2c   1/1     Running   0          7m14s   10.250.0.130   master   <none>           <none>
root:~/temp


kubectl get pods -n kube-system -o wide
NAME                             READY   STATUS    RESTARTS   AGE     IP                NODE     NOMINATED NODE   READINESS GATES
coredns-66bff467f8-87zdz         1/1     Running   0          9s      10.250.0.132      master   <none>           <none>
coredns-66bff467f8-bzphl         1/1     Running   0          9s      10.250.0.131      master   <none>           <none>

'
