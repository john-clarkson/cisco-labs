djohn## sysctl
djohn@k8s-slave2:[~/wg]:
cat wiregurad-enable-ipv4-forwaring.sh
## you have to login wireguard pod to modify ipv4_forward=1
kubectl exec -ti -n wireguard wireguard bash


sysctl -w net.ipv4.ip_forward=1
sysctl -p
sysctl -a |grep net.ipv4.ip_forward
## this shell script is not working sometimes...no ideas.
#!bin/bash
echo wireguard-pod-enable-ipv4.ip_forwarding=1
kubectl exec -ti -n wireguard wireguard -- sysctl -w net.ipv4.ip_forward=1
kubectl exec -ti -n wireguard wireguard -- sysctl -p;
kubectl exec -ti -n wireguard wireguard -- sysctl -a |grep net.ipv4.ip_forward;

## 
djohn@k8s-slave2:[~/wg]:
cat update-configmap.md

## update configmap
kubectl replace -f 03-configmap.yaml

## restart pods
 kubectl exec -ti -n wireguard wireguard -- /bin/sh -c "kill 1"
cd /mnt/data
rm -rfv *
watch ls -al
#
 restart deployment : kubectl rollout restart deployment <name>
djohn@k8s-slave2:[~/wg]:

