# login to pod
kubectl exec -ti <pod> sh
# alpine pod tcpdump installation

/ # apk update
fetch http://dl-cdn.alpinelinux.org/alpine/v3.6/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.6/community/x86_64/APKINDEX.tar.gz
v3.6.5-44-gda55e27396 [http://dl-cdn.alpinelinux.org/alpine/v3.6/main]
v3.6.5-34-gf0ba0b43d5 [http://dl-cdn.alpinelinux.org/alpine/v3.6/community]
OK: 8442 distinct packages available
/ # apk add tcpdump --no-cache
fetch http://dl-cdn.alpinelinux.org/alpine/v3.6/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.6/community/x86_64/APKINDEX.tar.gz
(1/2) Installing libpcap (1.8.1-r0)
(2/2) Installing tcpdump (4.9.2-r0)
Executing busybox-1.26.2-r11.trigger
OK: 10 MiB in 20 packages
/ # tcpdump >>cap.log


IP 10-233-123-118.wireguard-service.wireguard.svc.cluster.local > dnsbox-k8s-slave3-667f6bbf6c-jkp4g: ICMP echo request, id 54534, seq 0, length 64
IP dnsbox-k8s-slave3-667f6bbf6c-jkp4g > 10-233-123-118.wireguard-service.wireguard.svc.cluster.local: ICMP echo reply, id 54534, seq 0, length 64
IP dnsbox-k8s-slave3-667f6bbf6c-jkp4g.43533 > 169.254.25.10.53: 51624+ PTR? 118.123.233.10.in-addr.arpa. (45)
IP 169.254.25.10.53 > dnsbox-k8s-slave3-667f6bbf6c-jkp4g.43533: 51624*- 1/0/0 PTR 10-233-123-118.wireguard-service.wireguard.svc.cluster.local. (146)
IP dnsbox-k8s-slave3-667f6bbf6c-jkp4g.41459 > 169.254.25.10.53: 38698+ PTR? 118.123.233.10.in-addr.arpa. (45)
IP 169.254.25.10.53 > dnsbox-k8s-slave3-667f6bbf6c-jkp4g.41459: 38698*- 1/0/0 PTR 10-233-123-118.wireguard-service.wireguard.svc.cluster.local. (146)
IP 10-233-123-118.wireguard-service.wireguard.svc.cluster.local > dnsbox-k8s-slave3-667f6bbf6c-jkp4g: ICMP echo request, id 54534, seq 1, length 64
IP dnsbox-k8s-slave3-667f6bbf6c-jkp4g > 10-233-123-118.wireguard-service.wireguard.svc.cluster.local: ICMP echo reply, id 54534, seq 1, length 64
IP dnsbox-k8s-slave3-667f6bbf6c-jkp4g.60341 > 169.254.25.10.53: 46398+ PTR? 10.25.254.169.in-addr.arpa. (44)
IP 169.254.25.10.53 > dnsbox-k8s-slave3-667f6bbf6c-jkp4g.60341: 46398 NXDomain 0/0/0 (44)

###wiregard pod ip
$kubectl get pod -A -o wide |grep wire
wireguard  wireguard   1/1     Running   3          12d   10.233.123.118   k8s-slave3   <none>           <none>