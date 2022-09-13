#!/bin/bash

echo "Access kubernetes all nodes,replace default 10.96.0.10 to 10.96.0.100" 

sed -i "s~10.96.0.10~10.96.0.100~" /var/lib/kubelet/config.yaml;

sleep 2

echo Reset kubelet
systemctl daemon-reload && systemctl restart kubelet;

sleep 2
cat /var/lib/kubelet/config.yaml
#root@kind-worker:/# cat /var/lib/kubelet/config.yaml |grep 10.96     
#- 10.96.0.100

sleep 5

echo 'Go back to (kubectl apply -f <manifest>)upload coredns manifest with right SVC ip 10.96.0.100

Corefile: |
    .:53 {
        log
        errors
        health {
            lameduck 5s
        }
be ware of the Configmap section with health lameduck settings. if not. coredns pod crash cuz liveness issue.
        '
