djohn#!bin/bash
kubectl delete svc productpage
kubectl apply -f /home/hitler/kuber-deployment/istio-playgroud/sample-bookinfo.yaml
kubectl get svc
kubectl apply -f /home/hitler/kuber-deployment/istio-playgroud/bookinfo-gateway.yaml

kubectl patch service -n istio-system istio-ingressgateway -p '{"spec": {"type": "LoadBalancer", "externalIPs":["98.98.98.98"]}}';
sudo ip route add 98.98.98.98/32 via 172.18.0.2 dev br-0a1a1395012d;

kubectl get svc -n istio-system istio-ingressgateway

echo curl loop
while true ; do curl -s http://98.98.98.98:80/productpage | grep -o "<title>.*</title>"; sleep 2 ; done


