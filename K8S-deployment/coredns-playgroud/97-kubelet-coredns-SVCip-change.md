
# Modify kubelet coredns Service IP address
## Default value=10.96.1.10
## After change=10.96.1.100
```sh
#!/bin/bash
echo "Access kubernetes all nodes,replace default clusterDNS:10.96.0.10 to 10.96.0.100" 

sed -i "s~10.96.0.10~10.96.0.100~" /var/lib/kubelet/config.yaml;

sleep 2W

echo Reset kubelet
systemctl daemon-reload && systemctl restart kubelet;

sleep 2
cat /var/lib/kubelet/config.yaml
#root@kind-worker:/# cat /var/lib/kubelet/config.yaml |grep 10.96     
#- 10.96.0.100
```
## Create new yaml file, then apply

```sh
$touch 00-coredns-svc-new-ip100.96.0.100.yaml
$nano 00-coredns-svc-new-ip100.96.0.100.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: "CoreDNS"
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: 10.96.0.100
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
  - name: metrics
    port: 9153
    protocol: TCP
```
### ctrl+x=save ctrl+z=quit


## Apply config
```sh
$kubectl apply -f 00-coredns-svc-new-ip100.96.0.100.yaml
```


### Note
Be ware of the Configmap section with health lameduck settings. if not. coredns pod crash cuz liveness issue.

##
```yaml 
Corefile: |
    .:53 {
        log
        errors
        health {
            lameduck 5s
        }'
```
```sh
/ # nslookup kubernetes.default
Server:         10.96.0.100
Address:        10.96.0.100#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1

/ # nslookup nginx.kube-system
Server:         10.96.0.100
Address:        10.96.0.100#53

Name:   nginx.kube-system.svc.cluster.local
Address: 10.102.94.80       
```
# Coredns error log
```sh
$kubectl describe pods coredns-85b4878f78-
```
``` log
Name:                 coredns-85b4878f78-j84tv
Namespace:            kube-system
Priority:             2000000000
Priority Class Name:  system-cluster-critical
Node:                 kind-worker2/172.18.0.2
Start Time:           Wed, 15 Jul 2020 11:08:15 +0800
Labels:               k8s-app=kube-dns
                      pod-template-hash=85b4878f78
Annotations:          cni.projectcalico.org/podIP: 10.244.110.141/32
                      cni.projectcalico.org/podIPs: 10.244.110.141/32
Status:               Running
IP:                   10.244.110.141
IPs:
  IP:           10.244.110.141
Controlled By:  ReplicaSet/coredns-85b4878f78
Containers:
  coredns:
    Container ID:  containerd://cb579c8597e7cdfbdbeacfb380db538e6804dec5857e2757e51c2c85cd2e9406
    Image:         coredns/coredns:1.7.0
    Image ID:      docker.io/coredns/coredns@sha256:73ca82b4ce829766d4f1f10947c3a338888f876fbed0540dc849c89ff256e90c
    Ports:         53/UDP, 53/TCP, 9153/TCP
    Host Ports:    0/UDP, 0/TCP, 0/TCP
    Args:
      -conf
      /etc/coredns/Corefile
    State:          Running
      Started:      Wed, 15 Jul 2020 11:08:51 +0800
    Ready:          False
    Restart Count:  0
    Limits:
      memory:  170Mi
    Requests:
      cpu:        100m
      memory:     70Mi
    Liveness:     http-get http://:8080/health delay=60s timeout=5s period=10s #success=1 #failure=5
    Readiness:    http-get http://:8181/ready delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /etc/coredns from config-volume (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from coredns-token-g8n58 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  config-volume:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      coredns
    Optional:  false
  coredns-token-g8n58:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  coredns-token-g8n58
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  kubernetes.io/os=linux
Tolerations:     CriticalAddonsOnly
                 node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
```
## Events
```log
Events:
  Type     Reason     Age                   From                   Message
  ----     ------     ----                  ----                   -------
  Normal   Scheduled  <unknown>             default-scheduler      Successfully assigned kube-system/coredns-85b4878f78-j84tv to kind-worker2
  Normal   Pulling    14m                   kubelet, kind-worker2  Pulling image "coredns/coredns:1.7.0"
  Normal   Pulled     13m                   kubelet, kind-worker2  Successfully pulled image "coredns/coredns:1.7.0"
  Normal   Created    13m                   kubelet, kind-worker2  Created container coredns
  Normal   Started    13m                   kubelet, kind-worker2  Started container coredns
  Warning  Unhealthy  4m26s (x58 over 13m)  kubelet, kind-worker2  Readiness probe failed: Get http://10.244.110.141:8181/ready: dial tcp 10.244.110.141:8181: connect: connection refused
```

```log
Name:                 coredns-85b4878f78-kmndt
Namespace:            kube-system
Priority:             2000000000
Priority Class Name:  system-cluster-critical
Node:                 kind-worker/172.18.0.3
Start Time:           Wed, 15 Jul 2020 10:58:35 +0800
Labels:               k8s-app=kube-dns
                      pod-template-hash=85b4878f78
Annotations:          cni.projectcalico.org/podIP: 10.244.162.141/32
                      cni.projectcalico.org/podIPs: 10.244.162.141/32
Status:               Running
IP:                   10.244.162.141
IPs:
  IP:           10.244.162.141
Controlled By:  ReplicaSet/coredns-85b4878f78
Containers:
  coredns:
    Container ID:  containerd://560b12884dfce2a0edab27e1a8ab9e226d235bc3b57cddd0c1b0d591b3026f3a
    Image:         coredns/coredns:1.7.0
    Image ID:      docker.io/coredns/coredns@sha256:73ca82b4ce829766d4f1f10947c3a338888f876fbed0540dc849c89ff256e90c
    Ports:         53/UDP, 53/TCP, 9153/TCP
    Host Ports:    0/UDP, 0/TCP, 0/TCP
    Args:
      -conf
      /etc/coredns/Corefile
```
## Pod status: Terminated, reason:liveness issue
```log    
    State:          Running
      Started:      Wed, 15 Jul 2020 11:04:40 +0800
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Wed, 15 Jul 2020 11:01:56 +0800
      Finished:     Wed, 15 Jul 2020 11:01:56 +0800
    Ready:          False
    Restart Count:  6
    Limits:
      memory:  170Mi
    Requests:
      cpu:        100m
      memory:     70Mi
    Liveness:     http-get http://:8080/health delay=60s timeout=5s period=10s #success=1 #failure=5
    Readiness:    http-get http://:8181/ready delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /etc/coredns from config-volume (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from coredns-token-g8n58 (ro)
```  
```log    
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  config-volume:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      coredns
    Optional:  false
  coredns-token-g8n58:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  coredns-token-g8n58
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  kubernetes.io/os=linux
Tolerations:     CriticalAddonsOnly
                 node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason     Age                   From                  Message
  ----     ------     ----                  ----                  -------
  Normal   Scheduled  <unknown>             default-scheduler     Successfully assigned kube-system/coredns-85b4878f78-kmndt to kind-worker
  Normal   Pulling    24m                   kubelet, kind-worker  Pulling image "coredns/coredns:1.7.0"
  Normal   Pulled     23m                   kubelet, kind-worker  Successfully pulled image "coredns/coredns:1.7.0"
  Normal   Created    22m (x5 over 23m)     kubelet, kind-worker  Created container coredns
  Normal   Pulled     22m (x4 over 23m)     kubelet, kind-worker  Container image "coredns/coredns:1.7.0" already present on machine
  Normal   Started    22m (x5 over 23m)     kubelet, kind-worker  Started container coredns
  Warning  BackOff    18m (x26 over 23m)    kubelet, kind-worker  Back-off restarting failed container
  Warning  Unhealthy  2m20s (x91 over 17m)  kubelet, kind-worker  Readiness probe failed: Get http://10.244.162.141:8181/ready: dial tcp 10.244.162.141:8181: connect: connection refused

Name:                 coredns-85b4878f78-nvzxq
Namespace:            kube-system
Priority:             2000000000
Priority Class Name:  system-cluster-critical
Node:                 kind-worker/172.18.0.3
Start Time:           Wed, 15 Jul 2020 11:08:15 +0800
Labels:               k8s-app=kube-dns
                      pod-template-hash=85b4878f78
Annotations:          cni.projectcalico.org/podIP: 10.244.162.142/32
                      cni.projectcalico.org/podIPs: 10.244.162.142/32
Status:               Running
IP:                   10.244.162.142
IPs:
  IP:           10.244.162.142
Controlled By:  ReplicaSet/coredns-85b4878f78
Containers:
  coredns:
    Container ID:  containerd://d3b47ca0824356d297b74e5f88401d025eeb5c1d19c119cdf5d880f35a5117a7
    Image:         coredns/coredns:1.7.0
    Image ID:      docker.io/coredns/coredns@sha256:73ca82b4ce829766d4f1f10947c3a338888f876fbed0540dc849c89ff256e90c
    Ports:         53/UDP, 53/TCP, 9153/TCP
    Host Ports:    0/UDP, 0/TCP, 0/TCP
    Args:
      -conf
      /etc/coredns/Corefile
    State:          Running
      Started:      Wed, 15 Jul 2020 11:08:17 +0800
    Ready:          False
    Restart Count:  0
    Limits:
      memory:  170Mi
    Requests:
      cpu:        100m
      memory:     70Mi
    Liveness:     http-get http://:8080/health delay=60s timeout=5s period=10s #success=1 #failure=5
    Readiness:    http-get http://:8181/ready delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /etc/coredns from config-volume (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from coredns-token-g8n58 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  config-volume:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      coredns
    Optional:  false
  coredns-token-g8n58:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  coredns-token-g8n58
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  kubernetes.io/os=linux
Tolerations:     CriticalAddonsOnly
                 node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason     Age                   From                  Message
  ----     ------     ----                  ----                  -------
  Normal   Scheduled  <unknown>             default-scheduler     Successfully assigned kube-system/coredns-85b4878f78-nvzxq to kind-worker
  Normal   Pulled     14m                   kubelet, kind-worker  Container image "coredns/coredns:1.7.0" already present on machine
  Normal   Created    14m                   kubelet, kind-worker  Created container coredns
  Normal   Started    14m                   kubelet, kind-worker  Started container coredns
  Warning  Unhealthy  4m31s (x60 over 14m)  kubelet, kind-worker  Readiness probe failed: Get http://10.244.162.142:8181/ready: dial tcp 10.244.162.142:8181: connect: connection refused
```

