#!/bin/bash
kubectl create deployment --image=gcr.io/kuar-demo/kuard-amd64:1 kuardelb; 
kubectl create deployment --image=gcr.io/kuar-demo/kuard-amd64:1 kuardnp; 
kubectl expose deployment kuardnp --name=kuardnp --port 8080 --type=NodePort; 
kubectl expose deployment kuardelb --name=kuardelb --port 8080 --type=LoadBalancer --external-ip=6.6.6.6;

echo Add static-route-to-kind-node-for ELB testing-6.6.6.6;
sudo ip route add 6.6.6.6/32 nexthop via 172.18.0.4 dev br-0a1a1395012d nexthop via 172.18.0.3 dev br-0a1a1395012d nexthop via 172.18.0.2 dev br-0a1a1395012d;

echo 'setup helmv2 configuration<optional, helmv3 instead no tiller pod insert to k8s>
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller'

echo downloading nginx-ingress-controller

echo helm install stable/nginx-ingress --name helm-nginx-in --set rbac.create=true

echo create fake externalIPs(4.3.2.1) patch to svc nginx-controller.
kubectl patch service helm-nginx-in-nginx-ingress-controller -p '{"spec": {"type": "LoadBalancer", "externalIPs":["4.3.2.1"]}}'


echo Add static-route-to-kind-node-for NGINX-INGRESS-CONTROLLER4.3.2.1
sudo ip route add 4.3.2.1/32 nexthop via 172.18.0.4 dev br-0a1a1395012d nexthop via 172.18.0.3 dev br-0a1a1395012d nexthop via 172.18.0.2 dev br-0a1a1395012d

echo MOTHERFUCKERS-YEAH!!!
