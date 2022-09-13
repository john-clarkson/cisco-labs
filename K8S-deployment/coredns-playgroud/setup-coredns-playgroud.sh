#!/bin/bash

echo This deployment is under kube-system namespace.
sleep 4

echo "setup Dnsbox pod with replica=1"
kubectl apply -f /home/hitler/kuber-deployment/deployment-example/dnsbox-deployment-example.yaml; 
sleep 2

echo "setup nginx pod"
kubectl create deployment nginx --image=nginx;

echo "expose svc port80"
kubectl expose deployment nginx --port 80;

echo "check svc"
kubectl get svc;
 
echo "kubectl exec -ti <dnsbox> sh"

echo "nslookup kubernetes.default+nslookup nginx.kube-system"
