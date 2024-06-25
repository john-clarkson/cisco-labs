djohn#!/bin/bash
#shell color ref https://gist.github.com/vratiu/9780109
RED='\033[0;31m'
Yellow="\[\033[0;33m\]"
Green="[\033[0;32m\]****"
NC='\033[0m'
Cyan="\[\033[0;36m\]"  

echo -e "${Green}cilium+hubble for kind https://docs.cilium.io/en/latest/gettingstarted/hubble/${NC}"
sleep 2
echo -e "${Green}Docker pull cilium image${NC}"
#Docker pull cilium/cilium:latest
sleep 2
echo check cilium image name and version
docker image ls;

echo -e "${Green}kind loading docker image cilium+busybox+kuard+ubuntu locally${NC}"
kind load docker-image cilium/cilium:latest;
kind load docker-image busybox:latest;
kind load docker-image dlneintr/kuard;
kind load docker-image ubuntu:latest;
kind load docker-image gcr.io/kubernetes-e2e-test-images/dnsutils:1.3;

echo -e "${Green}Download cilium github master by using ${Yellow}curl -LO https://github.com/cilium/cilium/archive/master.tar.gz${NC}"
cd /home/hitler/kuber-deployment/cilium-playgroud;
#curl -LO https://github.com/cilium/cilium/archive/master.tar.gz;

echo -e "${Yellow}unzip pack${NC}"
#tar xzvf master.tar.gz;
cd cilium-master/install/kubernetes/cilium-master/install/kubernetes;

echo -e "${Yellow}install cilium+hubble${NC}"
${Yellow} helm install cilium ./cilium \
   --namespace kube-system \
   --set global.nodeinit.enabled=true \
   --set global.kubeProxyReplacement=partial \
   --set global.hostServices.enabled=false \
   --set global.externalIPs.enabled=true \
   --set global.nodePort.enabled=true \
   --set global.hostPort.enabled=true \
   --set global.pullPolicy=IfNotPresent \
   --set config.ipam=kubernetes \
   --set global.hubble.enabled=true \
   --set global.hubble.listenAddress=":4244" \
   --set global.hubble.relay.enabled=true \
   --set global.hubble.ui.enabled=true;${NC}

# kubectl get pod -n kube-system -o wide
# NAME                                         READY   STATUS    RESTARTS   AGE     IP             NODE                 NOMINATED NODE   READINESS GATES
# cilium-5gl9k                                 1/1     Running   0          5m52s   172.18.0.3     kind-worker          <none>           <none>
# cilium-5glhk                                 1/1     Running   0          5m52s   172.18.0.4     kind-worker2         <none>           <none>
# cilium-lrqkg                                 1/1     Running   0          5m52s   172.18.0.2     kind-control-plane   <none>           <none>
# cilium-node-init-68h4v                       1/1     Running   1          5m52s   172.18.0.4     kind-worker2         <none>           <none>
# cilium-node-init-88zxp                       1/1     Running   1          5m52s   172.18.0.3     kind-worker          <none>           <none>
# cilium-node-init-zl2bd                       1/1     Running   1          5m52s   172.18.0.2     kind-control-plane   <none>           <none>
# cilium-operator-55f4d76dc7-7jvrl             1/1     Running   0          5m52s   172.18.0.4     kind-worker2         <none>           <none>
# coredns-66bff467f8-7lsb9                     1/1     Running   0          17m     10.244.1.59    kind-worker2         <none>           <none>
# coredns-66bff467f8-m9fgm                     1/1     Running   0          17m     10.244.2.153   kind-worker          <none>           <none>
# etcd-kind-control-plane                      1/1     Running   0          18m     172.18.0.2     kind-control-plane   <none>           <none>
# hubble-relay-755cd795c7-bt8kg                1/1     Running   0          5m52s   10.244.1.128   kind-worker2         <none>           <none>
# hubble-ui-66fdcdc6d-lb9lk                    1/1     Running   0          5m52s   10.244.2.45    kind-worker          <none>           <none>
# kube-apiserver-kind-control-plane            1/1     Running   0          18m     172.18.0.2     kind-control-plane   <none>           <none>
# kube-controller-manager-kind-control-plane   1/1     Running   0          18m     172.18.0.2     kind-control-plane   <none>           <none>
# kube-proxy-98jb7                             1/1     Running   0          17m     172.18.0.4     kind-worker2         <none>           <none>
# kube-proxy-dzp78                             1/1     Running   0          17m     172.18.0.2     kind-control-plane   <none>           <none>
# kube-proxy-h52dz                             1/1     Running   0          17m     172.18.0.3     kind-worker          <none>           <none>
# kube-scheduler-kind-control-plane            1/1     Running   0          18m     172.18.0.2     kind-control-plane   <none>           <none>

sleep 2
echo -e "${Green}watch kubectl get pods -n kube-system -o wide, make sure hubble-ui pod location. which worker handle this pod${NC}"
kubectl get pods -n kube-system -o wide;
sleep 2
echo -e "${Green}Create hubble-ui service for accessing, port 3333 target-port=12000, http://3.3.3.3:3333\n${NC}"
sleep 2
echo -e "${Green}kubectl expose deployment -n kube-system hubble-ui --port 3333 --target-port 12000 --type=LoadBalancer --external-ip=3.3.3.3 --dry-run -oyaml\n${NC}"
sleep 2
echo -e "${Green}kubectl get nodes -o wide\n${NC}" 
sleep 2
kubectl get nodes -o wide
sleep 2
echo -e "${Green}sudo ip route add 3.3.3.3/32 via kind-worker-ip dev br-0a1a1395012d${NC}"
sleep 2
##optional kubectl port-forward -n kube-system svc/hubble-ui 12000:80;
echo -e "${Cyan}kubectl apply -f hubble-ui-svc-loadbalancer.yaml${NC}"
kubectl apply -f /home/hitler/kuber-deployment/cilium-playgroud/hubble-ui-svc-loadbalancer.yaml;
sleep 2
echo -e "${Cyan}Check hubble expose svc port=3333${NC}"
kubectl get svc -n kube-system hubble-ui -o wide;
sleep 2
echo -e "${Cyan}Check hubble real port=12000${NC}"
kubectl get endpoints -n kube-system hubble-ui -o wide;
sleep 2
echo -e "${Cyan}All pod should be running, kind-config extramounts:readonly=false"
echo 'kind: Cluster
 apiVersion: kind.x-k8s.io/v1alpha4
 networking:
  disableDefaultCNI: true
   podSubnet: "10.244.0.0/16"
   serviceSubnet: "10.96.0.0/12"
 nodes:
 - role: control-plane
   extraMounts:
   - hostPath: /home/hitler/Downloads/cni-plugins-linux-amd64-v0.8.6/
     containerPath: /opt/cni/bin/
     readOnly: false
 - role: worker
   extraMounts:
   - hostPath: /home/hitler/Downloads/cni-plugins-linux-amd64-v0.8.6/
     containerPath: /opt/cni/bin/
     readOnly: false
 - role: worker
   extraMounts:
   - hostPath: /home/hitler/Downloads/cni-plugins-linux-amd64-v0.8.6/
     containerPath: /opt/cni/bin/
     readOnly: false


'
echo done;
