djohn# cilium playgroud note
## ref link 
https://docs.cilium.io/en/latest/gettingstarted/hubble/


## Docker pull cilium image
```sh
$docker pull cilium/cilium:latest
$docker image ls;
```
## kind load local image
```sh
$kind load docker-image cilium/cilium:latest;
$kind load docker-image busybox:latest;
$kind load docker-image dlneintr/kuard;
$kind load docker-image ubuntu:latest;
$kind load docker-image gcr.io/kubernetes-e2e-test-images/dnsutils:1.3;
```

## Download cilium github master tar packages
```sh
cd /home/djohn/kuber-deployment/cilium-playgroud;
curl -LO https://github.com/cilium/cilium/archive/master.tar.gz;
```

## unzip pack
```sh
$tar -xzvf master.tar.gz;
$cd cilium-master/install/kubernetes/cilium-master/install/kubernetes;
```
## install cilium+hubble
```sh
$helm install cilium ./cilium \
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
   --set global.hubble.ui.enabled=true;
```
## Verification
```sh
 kubectl get pod -n kube-system -o wide
 NAME                                         READY   STATUS    RESTARTS   AGE     IP             NODE                 NOMINATED NODE   READINESS GATES
 cilium-5gl9k                                 1/1     Running   0          5m52s   172.18.0.3     kind-worker          <none>           <none>
 cilium-5glhk                                 1/1     Running   0          5m52s   172.18.0.4     kind-worker2         <none>           <none>
 cilium-lrqkg                                 1/1     Running   0          5m52s   172.18.0.2     kind-control-plane   <none>           <none>
 cilium-node-init-68h4v                       1/1     Running   1          5m52s   172.18.0.4     kind-worker2         <none>           <none>
 cilium-node-init-88zxp                       1/1     Running   1          5m52s   172.18.0.3     kind-worker          <none>           <none>
 cilium-node-init-zl2bd                       1/1     Running   1          5m52s   172.18.0.2     kind-control-plane   <none>           <none>
 cilium-operator-55f4d76dc7-7jvrl             1/1     Running   0          5m52s   172.18.0.4     kind-worker2         <none>           <none>
 coredns-66bff467f8-7lsb9                     1/1     Running   0          17m     10.244.1.59    kind-worker2         <none>           <none>
 coredns-66bff467f8-m9fgm                     1/1     Running   0          17m     10.244.2.153   kind-worker          <none>           <none>
 etcd-kind-control-plane                      1/1     Running   0          18m     172.18.0.2     kind-control-plane   <none>           <none>
 hubble-relay-755cd795c7-bt8kg                1/1     Running   0          5m52s   10.244.1.128   kind-worker2         <none>           <none>
 hubble-ui-66fdcdc6d-lb9lk                    1/1     Running   0          5m52s   10.244.2.45    kind-worker          <none>           <none>
 kube-apiserver-kind-control-plane            1/1     Running   0          18m     172.18.0.2     kind-control-plane   <none>           <none>
 kube-controller-manager-kind-control-plane   1/1     Running   0          18m     172.18.0.2     kind-control-plane   <none>           <none>
 kube-proxy-98jb7                             1/1     Running   0          17m     172.18.0.4     kind-worker2         <none>           <none>
 kube-proxy-dzp78                             1/1     Running   0          17m     172.18.0.2     kind-control-plane   <none>           <none>
 kube-proxy-h52dz                             1/1     Running   0          17m     172.18.0.3     kind-worker          <none>           <none>
 kube-scheduler-kind-control-plane            1/1     Running   0          18m     172.18.0.2     kind-control-plane   <none>           <none>
```


## watch kubectl get pods -n kube-system -o wide, make sure hubble-ui pod location. which worker handle this pod
```sh
$kubectl get pods -n kube-system -o wide;

#Create hubble-ui service for accessing, port 3333 target-port=12000, http://3.3.3.3:3333
$kubectl expose deployment -n kube-system hubble-ui --port 3333 --target-port 12000 --type=LoadBalancer --external-ip=3.3.3.3 --dry-run -oyaml

$kubectl get nodes -o wide

$sudo ip route add 3.3.3.3/32 via kind-worker-ip dev br-0a1a1395012d

## optional kubectl port-forward -n kube-system svc/hubble-ui 12000:80;
## echo -e kubectl apply -f hubble-ui-svc-loadbalancer.yaml
$kubectl apply -f /home/djohn/kuber-deployment/cilium-playgroud/hubble-ui-svc-loadbalancer.yaml;

## Check hubble expose svc port=3333
$kubectl get svc -n kube-system hubble-ui -o wide;

## Check hubble real port=12000
$kubectl get endpoints -n kube-system hubble-ui -o wide;

## All pod should be running, kind-config extramounts:readonly=false"
```

## kind config-file
```yaml
kind: Cluster
 apiVersion: kind.x-k8s.io/v1alpha4
 networking:
  disableDefaultCNI: true
   podSubnet: "10.244.0.0/16"
   serviceSubnet: "10.96.0.0/12"
 nodes:
 - role: control-plane
   extraMounts:
   - hostPath: /home/djohn/Downloads/cni-plugins-linux-amd64-v0.8.6/
     containerPath: /opt/cni/bin/
     readOnly: false
 - role: worker
   extraMounts:
   - hostPath: /home/djohn/Downloads/cni-plugins-linux-amd64-v0.8.6/
     containerPath: /opt/cni/bin/
     readOnly: false
 - role: worker
   extraMounts:
   - hostPath: /home/djohn/Downloads/cni-plugins-linux-amd64-v0.8.6/
     containerPath: /opt/cni/bin/
     readOnly: false
```     
