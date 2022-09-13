#!/bin/bash

RED='\033[0;31m'
Yellow="\[\033[0;33m\]"
Green="[\033[0;32m\]****"
NC='\033[0m'
Cyan="\[\033[0;36m\]" 

echo -e "'${Green}
hitler>~/kuber-deployment/cilium-playgroud
kubectl exec -ti dnsbox-deployment-8485677597-6p8t8 -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local localdomain
nameserver 10.96.0.10
options ndots:5${NC}

${Cyan}
hitler>~/kuber-deployment/cilium-playgroud
kubectl exec -ti dnsbox-deployment-8485677597-6p8t8 -- nslookup kubernetes.default
Server:		10.96.0.10
Address:	10.96.0.10#53

Name:	kubernetes.default.svc.cluster.local
Address: 10.96.0.1
${Green}
hitler>~/kuber-deployment/cilium-playgroud

kubectl exec -ti dnsbox-deployment-8485677597-6p8t8 -- sh
/ # nslookup kubernetes.default
Server:		10.96.0.10
Address:	10.96.0.10#53

Name:	kubernetes.default.svc.cluster.local
Address: 10.96.0.1
${NC}
${Yellow}
/ # nslookup google.com
Server:		10.96.0.10
Address:	10.96.0.10#53

Non-authoritative answer:
Name:	google.com
Address: 216.58.220.206
Name:	google.com
Address: 2404:6800:4005:80d::200e

/ # ping www.bing.com
PING www.bing.com (202.89.233.101): 56 data bytes
64 bytes from 202.89.233.101: seq=0 ttl=125 time=165.077 ms
64 bytes from 202.89.233.101: seq=3 ttl=125 time=165.190 ms
64 bytes from 202.89.233.101: seq=4 ttl=125 time=164.065 ms
^C
--- www.bing.com ping statistics ---
6 packets transmitted, 3 packets received, 50% packet loss
round-trip min/avg/max = 164.065/164.777/165.190 ms ${NC}'"


echo -e "${Green}kubernetes DNS troubleshooting link"
echo -e "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#:~:text=Every%20Service%20defined%20in%20the,in%20the%20Kubernetes%20namespace%20bar%20."