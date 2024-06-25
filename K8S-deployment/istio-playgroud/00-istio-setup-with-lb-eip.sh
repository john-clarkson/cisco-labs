djohn#!bin/bash
echo Download Istio
#curl -L https://istio.io/downloadIstio | sh -;
sleep 2
echo Setup env for istioctl bin 
#cd istio-1.6.5;
#export PATH=$PWD/bin:$PATH;
sleep 2
echo install demo tools
istioctl install --set profile=demo --set values.tracing.enabled=true --set values.tracing.provider=zipkin
#istioctl install --set profile=demo;
sleep 2

echo enable isotio-injection for default-namespace
kubectl label namespace default istio-injection=enabled;

echo manual injection kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)

sleep 2

echo Deploy demo-app=bookinfo
#kubectl apply -f /home/hitler/kuber-deployment/istio-playgroud/traffic/02-sample-bookinfo.yaml

echo Check
kubectl get services;
kubectl get pods;
kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>";


echo modify productpage svc from clusterip to LoadBalancer mode
#kubectl patch service productpage -p '{"spec": {"type": "LoadBalancer", "externalIPs":["98.98.98.98"]}}';

echo add ip route to productpage externalIPs
sudo ip route add 98.98.98.98/32 via 172.18.0.2 dev br-0a1a1395012d;

echo browse http://98.98.98.98:9080/productpage

echo curl loop
#while true ; do curl -s http://98.98.98.98:9080/productpage | grep -o "<title>.*</title>"; sleep 2 ; done
