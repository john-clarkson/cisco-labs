#!/bin/bash
cd /home/hitler/kuber-deployment/cilium-playgroud;
kubectl apply -f hubble-demo.yaml;
#export HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt);
#curl -LO "https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-amd64.tar.gz";
#curl -LO "https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-amd64.tar.gz.sha256sum";
#sha256sum --check hubble-linux-amd64.tar.gz.sha256sum
#tar zxf hubble-linux-amd64.tar.gz
echo '
mv hubble binary to /usr/local/bin;
source <(hubble completion bash);
source ~/.bashrc;'
echo hubble-relay port-forward
kubectl port-forward -n kube-system svc/hubble-relay 4245:80;
echo hubble status --server localhost:4245
echo Healthcheck (via localhost:4245): Ok
echo Max Flows: 12288
echo Current Flows: 12288 (100.00%)

#$ kubectl get pods,svc
#NAME                             READY   STATUS    RESTARTS   AGE
#pod/deathstar-6fb5694d48-5hmds   1/1     Running   0          107s
#pod/deathstar-6fb5694d48-fhf65   1/1     Running   0          107s
#pod/tiefighter                   1/1     Running   0          107s
#pod/xwing                        1/1     Running   0          107s
#
#NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
#service/deathstar    ClusterIP   10.96.110.8   <none>        80/TCP    107s
#service/kubernetes   ClusterIP   10.96.0.1     <none>        443/TCP   3m53s
#
#  hitler>~/kuber-deployment/cilium-playgroud
echo "while true; do sleep 6; kubectl exec tiefighter -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing; echo ;done"
echo "while true; do sleep 6; kubectl exec tiefighter -- curl -s -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port; echo ;done"
echo "while true; do sleep 6; kubectl exec xwing -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
; echo ;done"

#  kubectl exec tiefighter -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
#  Ship landed
#  hitler>~/kuber-deployment/cilium-playgroud
#  kubectl exec tiefighter -- curl -s -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port
#  Panic: deathstar exploded
#  
#  goroutine 1 [running]:
#  main.HandleGarbage(0x2080c3f50, 0x2, 0x4, 0x425c0, 0x5, 0xa)
#          /code/src/github.com/empire/deathstar/
#          temp/main.go:9 +0x64
#  main.main()
#          /code/src/github.com/empire/deathstar/
#          temp/main.go:5 +0x85
#  hitler>~/kuber-deployment/cilium-playgroud
#  





##by default, allow all traffic!!!
##  kubectl -n kube-system exec cilium-5gl9k -- cilium endpoint list
##  ENDPOINT   POLICY (ingress)   POLICY (egress)   IDENTITY   LABELS (source:key[=value])                                                      IPv6   IPv4           STATUS   
##             ENFORCEMENT        ENFORCEMENT                                                                                                                         
##  356        Disabled           Disabled          44229      k8s:io.cilium.k8s.policy.cluster=default                                                10.244.2.45    ready   
##                                                             k8s:io.cilium.k8s.policy.serviceaccount=hubble-ui                                                              
##                                                             k8s:io.kubernetes.pod.namespace=kube-system                                                                    
##                                                             k8s:k8s-app=hubble-ui                                                                                          
##  690        Disabled           Disabled          24207      k8s:class=tiefighter                                                                    10.244.2.19    ready   
##                                                             k8s:io.cilium.k8s.policy.cluster=default                                                                       
##                                                             k8s:io.cilium.k8s.policy.serviceaccount=default                                                                
##                                                             k8s:io.kubernetes.pod.namespace=default                                                                        
##                                                             k8s:org=empire                                                                                                 
##  2528       Disabled           Disabled          4          reserved:health                                                                         10.244.2.213   ready   
##  2657       Disabled           Disabled          32016      k8s:app=local-path-provisioner                                                          10.244.2.15    ready   
##                                                             k8s:io.cilium.k8s.policy.cluster=default                                                                       
##                                                             k8s:io.cilium.k8s.policy.serviceaccount=local-path-provisioner-service-account                                 
##                                                             k8s:io.kubernetes.pod.namespace=local-path-storage                                                             
##  2958       Disabled           Disabled          1          reserved:host                                                                                          ready   
##  3085       Disabled           Disabled          63583      k8s:io.cilium.k8s.policy.cluster=default                                                10.244.2.153   ready   
##                                                             k8s:io.cilium.k8s.policy.serviceaccount=coredns                                                                
##                                                             k8s:io.kubernetes.pod.namespace=kube-system                                                                    
##                                                             k8s:k8s-app=kube-dns                                                                                           
##  3701       Disabled           Disabled          13296      k8s:class=deathstar                                                                     10.244.2.219   ready   
##                                                             k8s:io.cilium.k8s.policy.cluster=default                                                                       
##                                                             k8s:io.cilium.k8s.policy.serviceaccount=default                                                                
##                                                             k8s:io.kubernetes.pod.namespace=default                                                                        
##                                                             k8s:org=empire                                                                                                 
##  hitler>~
##  $
echo Apply-network-policy 
##cat cilium-network-policy.yaml 
##apiVersion: "cilium.io/v2"
##kind: CiliumNetworkPolicy
##description: "L3-L4 policy to restrict deathstar access to empire ships only"
##metadata:
##  name: "rule1"
##spec:
##  endpointSelector:
##    matchLabels:
##      org: empire
##      class: deathstar
##  ingress:
##  - fromEndpoints:
##    - matchLabels:
##        org: empire
##    toPorts:
##    - ports:
##      - port: "80"
##        protocol: TCP
##
##
echo permit tiefighter->deathstar
echo deny xwing->deathstar
echo kubectl get cnp=CiliumNetworkPolicy
echo login cilium pod: kubectl -n kube-system exec -ti cilium-5gl9k -- /bin/bash
echo cilium status
echo cli cheatsheet https://docs.cilium.io/en/latest/cheatsheet/
##  root@kind-worker:/home/cilium# cilium status
##  KVStore:                Ok   Disabled
##  Kubernetes:             Ok   1.18 (v1.18.2) [linux/amd64]
##  Kubernetes APIs:        ["CustomResourceDefinition", "cilium/v2::CiliumClusterwideNetworkPolicy", "cilium/v2::CiliumEndpoint", "cilium/v2::CiliumNetworkPolicy", "cilium/v2::CiliumNode", "core/v1::Namespace", "core/v1::Node", "core/v1::Pods", "core/v1::Service", "discovery/v1beta1::EndpointSlice", "networking.k8s.io/v1::NetworkPolicy"]
##  KubeProxyReplacement:   Partial   [eth0 (DR)]   [NodePort (SNAT, 30000-32767, XDP: DISABLED), HostPort, ExternalIPs, SessionAffinity]
##  Cilium:                 Ok        OK
##  NodeMonitor:            Listening for events on 128 CPUs with 64x4096 of shared memory
##  Cilium health daemon:   Ok   
##  IPAM:                   IPv4: 7/255 allocated from 10.244.2.0/24, 
##  Masquerading:           BPF   [eth0]   10.244.2.0/24
##  Controller Status:      37/37 healthy
##  Proxy Status:           OK, ip 10.244.2.80, 0 redirects active on ports 10000-20000
##  Hubble:                 Ok              Current/Max Flows: 4096/4096 (100.00%), Flows/s: 3.22   Metrics: Disabled
##  Cluster health:         3/3 reachable   (2020-07-12T23:34:40Z)
echo done;
