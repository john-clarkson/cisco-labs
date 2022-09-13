# calico testing
- 
```sh
root@k8s-master1:/etc# ss -tulnp |grep 179
tcp     LISTEN   0        8                0.0.0.0:179            0.0.0.0:*      users:(("bird",pid=56149,fd=7))
root@k8s-master1:/etc#
```

```sh
calicoctl patch node kind-worker -p '{"spec": {"bgp": {"routeReflectorClusterID": "244.0.0.1"}}}' 

calicoctl get node
-o yaml
###
export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=~/.kube/config
calicoctl get workloadendpoints
export calico node config
```
## check bgp peer config
```sh
root@kind-control-plane:/# calicoctl get bgppeer
NAME                         PEERIP       NODE       ASN   
2frr                         172.18.0.5   (global)   1     
peer-with-route-reflectors                all()      0     

$calicoctl get bgppeer -oyaml
```

## check ippool config
```sh
╰─ calicoctl get ippool -o yaml                                                                                                                                       ─╯
apiVersion: projectcalico.org/v3
items:
- apiVersion: projectcalico.org/v3
  kind: IPPool
  metadata:
    creationTimestamp: "2021-01-25T09:54:33Z"
    name: default-ipv4-ippool
    resourceVersion: "6485"
    uid: a4e1f908-38d9-49d8-9a1b-71f8808ae703
  spec:
    blockSize: 26
    cidr: 10.244.0.0/16
    ipipMode: Never
    natOutgoing: true
    nodeSelector: all()
    vxlanMode: Never
kind: IPPoolList
metadata:
  resourceVersion: "45680"
 ```
## Advertise subnet(service subnet/external subnet), pod subnet advertise by default.
```sh
$cat 01-calico-bgp-config-adv-ip.yaml                                                                                                                               ─╯
apiVersion: projectcalico.org/v3
kind: BGPConfiguration
metadata:
  name: default
spec:
  logSeverityScreen: Info
  nodeToNodeMeshEnabled: false
  asNumber: 65000
  serviceClusterIPs:
  - cidr: 10.96.0.0/12
  serviceExternalIPs:
  - cidr: 4.3.2.1/32
  - cidr: 1.2.3.4/32
```
```sh
$calicoctl get bgpconfig default -o yaml                                                                                                                            
apiVersion: projectcalico.org/v3
kind: BGPConfiguration
metadata:
  creationTimestamp: "2021-01-25T10:28:54Z"
  name: default
  resourceVersion: "7613"
  uid: a62b063f-0c0f-4bf2-bb3f-28e99a2d4cb0
spec:
  asNumber: 65000
  logSeverityScreen: Info
  nodeToNodeMeshEnabled: false
  serviceClusterIPs:
  - cidr: 10.96.0.0/12
  serviceExternalIPs:
  - cidr: 4.3.2.1/32
  - cidr: 1.2.3.4/32
```
## kind-worker=172.18.0.4 =BGP RR
```sh
$calicoctl get node kind-worker --export -o yaml > kind-worker.yaml
```

## add route-reflector: "true" under labels: section. save
```sh
$calicoctl replace -f kind-worker.yaml

##kind-worker as bgp RR config  
calicoctl get node kind-worker -oyaml                                                                                                                             
apiVersion: projectcalico.org/v3
kind: Node
metadata:
  annotations:
    projectcalico.org/kube-labels: '{"beta.kubernetes.io/arch":"amd64","beta.kubernetes.io/os":"linux","kubernetes.io/arch":"amd64","kubernetes.io/hostname":"kind-worker","kubernetes.io/os":"linux"}'
  creationTimestamp: "2021-01-25T09:48:52Z"
  labels:
    beta.kubernetes.io/arch: amd64
    beta.kubernetes.io/os: linux
    kubernetes.io/arch: amd64
    kubernetes.io/hostname: kind-worker
    kubernetes.io/os: linux
    route-reflector: "true"
  name: kind-worker
  resourceVersion: "40078"
  uid: adf495e7-464d-434c-8126-b186de5d4da9
spec:
  bgp:
    ipv4Address: 172.18.0.4/16
    routeReflectorClusterID: 244.0.0.1
  orchRefs:
  - nodeName: kind-worker
    orchestrator: k8s
status: {}
```

## worker2 peer to RR
```sh
$cat 08-peer-to-rr.yaml                                                                                                                                             
kind: BGPPeer
apiVersion: projectcalico.org/v3
metadata:
  name: peer-with-route-reflectors
spec:
  nodeSelector: all()
  peerSelector: route-reflector == 'true'
```
```sh
## $calicoctl get bgppeer -o yaml
## 172.18.0.5=frrouting ebgp asn=1
## kind-worker2=non RR
╰─ calicoctl get bgppeer -o yaml                                                                                                                                      ─╯
apiVersion: projectcalico.org/v3
items:
- apiVersion: projectcalico.org/v3
  kind: BGPPeer
  metadata:
    creationTimestamp: "2021-01-25T10:20:02Z"
    name: 2frr
    resourceVersion: "21701"
    uid: 7b3a54a1-0480-4371-8692-b35c149a3d93
  spec:
    asNumber: 1
    peerIP: 172.18.0.5
- apiVersion: projectcalico.org/v3
  kind: BGPPeer
  metadata:
    creationTimestamp: "2021-01-25T12:29:54Z"
    name: peer-with-route-reflectors
    resourceVersion: "28651"
    uid: fb03a04b-b1ac-4a62-82db-a11b20204e38
  spec:
    asNumber: 0
    nodeSelector: all()
    peerIP: ""
    peerSelector: route-reflector == 'true'
kind: BGPPeerList
metadata:
  resourceVersion: "44346"

```
## frrouter=leaf bgp router
 - 172.18.0.5=frrouter asn=1 
 - kind-calico-asn=65000
 - 172.18.0.4=worker rr
 - 172.18.0.2=worker2 non-rr
 
 ```sh
sh-4.4# ip -c route show |grep bird
10.244.82.0/26 via 172.18.0.3 dev eth0 proto bird 
10.244.110.128/26 via 172.18.0.2 dev eth0 proto bird 
blackhole 10.244.162.128/26 proto bird 
sh-4.4# exit
exit
╭─    ~/kuber-deployment/calico-playgroud/calico3.14-v4  on   master !6 ?5 ······························ ✔  took 48m 18s   at kind-kind ⎈  at 22:51:22  ─╮
$kubectl exec -ti -n kube-system calico-node-p9pd8 sh                                                                                                              
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
sh-4.4# ip -c route show | grep bird
10.244.82.0/26 via 172.18.0.3 dev eth0 proto bird 
blackhole 10.244.110.128/26 proto bird 
10.244.162.128/26 via 172.18.0.4 dev eth0 proto bird 
```
## pod<>pod connection
```sh
$kubectl exec -ti busybox-deploy-worker-6bc68749fc-rv7k9 sh                                                                                                         ─╯
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
4: eth0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1440 qdisc noqueue 
    link/ether 2a:23:b8:c4:82:e0 brd ff:ff:ff:ff:ff:ff
    inet 10.244.162.132/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::2823:b8ff:fec4:82e0/64 scope link 
       valid_lft forever preferred_lft forever
/ # ping 10.244.110.130
PING 10.244.110.130 (10.244.110.130): 56 data bytes
64 bytes from 10.244.110.130: seq=0 ttl=62 time=1.522 ms
64 bytes from 10.244.110.130: seq=1 ttl=62 time=0.114 ms
^C
--- 10.244.110.130 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.114/0.818/1.522 ms
/ # traceroute 10.244.110.130
traceroute to 10.244.110.130 (10.244.110.130), 30 hops max, 46 byte packets
 1  kind-worker.kind (172.18.0.4)  0.007 ms  0.006 ms  0.004 ms
 2  kind-worker2.kind (172.18.0.2)  0.073 ms  0.007 ms  0.005 ms
 3  10.244.110.130 (10.244.110.130)  0.005 ms  0.008 ms  0.005 ms
/ # 


#####
─ kubectl exec -ti busybox-deploy-worker2-77f4c66985-5srzq sh                                                                                                        ─╯
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
/ # ping 10.244.162.132
PING 10.244.162.132 (10.244.162.132): 56 data bytes
64 bytes from 10.244.162.132: seq=0 ttl=62 time=0.800 ms
64 bytes from 10.244.162.132: seq=1 ttl=62 time=0.266 ms
^C
--- 10.244.162.132 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.266/0.533/0.800 ms
/ # traceroute 10.244.162.132
traceroute to 10.244.162.132 (10.244.162.132), 30 hops max, 46 byte packets
 1  kind-worker2.kind (172.18.0.2)  0.005 ms  0.005 ms  0.004 ms
 2  kind-worker.kind (172.18.0.4)  0.004 ms  0.004 ms  0.003 ms
 3  10.244.162.132 (10.244.162.132)  0.003 ms  0.006 ms  0.004 ms
/ # 
```

## frrouting bgp config
```sh
router bgp 1
 bgp router-id 1.2.3.4
 neighbor 172.18.0.2 remote-as 65000
 neighbor 172.18.0.4 remote-as 65000
 !
 address-family ipv4 unicast
  neighbor 172.18.0.2 route-map pass in
  neighbor 172.18.0.2 route-map pass out
  neighbor 172.18.0.4 route-map pass in
  neighbor 172.18.0.4 route-map pass out
 exit-address-family
!

quagga-router# show bgp su   

IPv4 Unicast Summary:
BGP router identifier 1.2.3.4, local AS number 1 vrf-id 0
BGP table version 19
RIB entries 11, using 2112 bytes of memory
Peers 2, using 29 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
172.18.0.2      4      65000       102        89        0    0    0 01:21:19           12        6
172.18.0.4      4      65000       142       128        0    0    0 01:56:20           12        6

Total number of neighbors 2
quagga-router# show ip bgp
BGP table version is 19, local router ID is 1.2.3.4, vrf id 0
Default local pref 100, local AS 1
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthops vrf id, < announce-nh-self

Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*= 1.2.3.4/32       172.18.0.2                             0 65000 i
*                   172.18.0.4                             0 65000 i
*                   172.18.0.4                             0 65000 i
*                   172.18.0.2                             0 65000 i
*                   172.18.0.2                             0 65000 i
*>                  172.18.0.4                             0 65000 i
*= 4.3.2.1/32       172.18.0.2                             0 65000 i
*                   172.18.0.4                             0 65000 i
*                   172.18.0.4                             0 65000 i
*                   172.18.0.2                             0 65000 i
*                   172.18.0.2                             0 65000 i
*>                  172.18.0.4                             0 65000 i
*= 10.96.0.0/12     172.18.0.2                             0 65000 i
*                   172.18.0.4                             0 65000 i
*                   172.18.0.4                             0 65000 i
*                   172.18.0.2                             0 65000 i
*                   172.18.0.2                             0 65000 i
*>                  172.18.0.4                             0 65000 i
*> 10.244.82.0/26   172.18.0.2                             0 65000 i
*=                  172.18.0.4                             0 65000 i
*= 10.244.110.128/26
                    172.18.0.4                             0 65000 i
*>                  172.18.0.2                             0 65000 i
*= 10.244.162.128/26
                    172.18.0.2                             0 65000 i
*>                  172.18.0.4                             0 65000 i

Displayed  6 routes and 24 total paths
quagga-router# 


quagga-router# show ip route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, D - SHARP,
       F - PBR, f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup

K>* 0.0.0.0/0 [0/0] via 172.17.0.1, eth0, 02:52:16
B>* 1.2.3.4/32 [20/0] via 172.18.0.2, eth1, weight 1, 00:30:55---external-ip
  *                   via 172.18.0.4, eth1, weight 1, 00:30:55---external-ip
B>* 4.3.2.1/32 [20/0] via 172.18.0.2, eth1, weight 1, 00:30:55---external-ip 
  *                   via 172.18.0.4, eth1, weight 1, 00:30:55---external-ip
B>* 10.96.0.0/12 [20/0] via 172.18.0.2, eth1, weight 1, 00:30:55---svc-ip
  *                     via 172.18.0.4, eth1, weight 1, 00:30:55
B>* 10.244.82.0/26 [20/0] via 172.18.0.2, eth1, weight 1, 00:30:55-kube-system-pod-ip
  *                       via 172.18.0.4, eth1, weight 1, 00:30:55
B>* 10.244.110.128/26 [20/0] via 172.18.0.2, eth1, weight 1, 00:30:55--busybox-worker2-ip
  *                          via 172.18.0.4, eth1, weight 1, 00:30:55
B>* 10.244.162.128/26 [20/0] via 172.18.0.2, eth1, weight 1, 00:30:55--busybox-worker-ip
  *                          via 172.18.0.4, eth1, weight 1, 00:30:55
C>* 172.17.0.0/16 is directly connected, eth0, 02:52:16
C>* 172.18.0.0/16 is directly connected, eth1, 02:47:00
quagga-router#
```
## delete non-rr ebgp neighbor <kind-worker2-frr>
```sh
quagga-router(config)# router bgp 1
quagga-router(config-router)# no neighbor 172.18.0.2 remote-as 65000
quagga-router(config-router)# end
quagga-router# show bgp 
No BGP prefixes displayed, 0 exist
quagga-router# show bgp summary 

IPv4 Unicast Summary:
BGP router identifier 1.2.3.4, local AS number 1 vrf-id 0
BGP table version 25
RIB entries 11, using 2112 bytes of memory
Peers 1, using 14 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
172.18.0.4      4      65000       147       133        0    0    0 02:00:31           12        6

Total number of neighbors 1
quagga-router# show bgp summary 

IPv4 Unicast Summary:
BGP router identifier 1.2.3.4, local AS number 1 vrf-id 0
BGP table version 25
RIB entries 11, using 2112 bytes of memory
Peers 1, using 14 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
172.18.0.4      4      65000       147       133        0    0    0 02:00:32           12        6

Total number of neighbors 1
quagga-router# show ip route 
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, D - SHARP,
       F - PBR, f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup

K>* 0.0.0.0/0 [0/0] via 172.17.0.1, eth0, 02:55:23
B>* 1.2.3.4/32 [20/0] via 172.18.0.4, eth1, weight 1, 00:00:06
B>* 4.3.2.1/32 [20/0] via 172.18.0.4, eth1, weight 1, 00:00:06
B>* 10.96.0.0/12 [20/0] via 172.18.0.4, eth1, weight 1, 00:00:06
B>* 10.244.82.0/26 [20/0] via 172.18.0.4, eth1, weight 1, 00:00:06
B>* 10.244.110.128/26 [20/0] via 172.18.0.4, eth1, weight 1, 00:00:06
B>* 10.244.162.128/26 [20/0] via 172.18.0.4, eth1, weight 1, 00:00:06
C>* 172.17.0.0/16 is directly connected, eth0, 02:55:23
C>* 172.18.0.0/16 is directly connected, eth1, 02:50:07
quagga-router# ping 10.244.110.130
PING 10.244.110.130 (10.244.110.130): 56 data bytes
64 bytes from 10.244.110.130: seq=0 ttl=63 time=0.833 ms
^C
--- 10.244.110.130 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.833/0.833/0.833 ms
quagga-router# ping 10.244.162.132
PING 10.244.162.132 (10.244.162.132): 56 data bytes
64 bytes from 10.244.162.132: seq=0 ttl=63 time=0.117 ms
64 bytes from 10.244.162.132: seq=1 ttl=63 time=0.111 ms
^C
--- 10.244.162.132 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.111/0.114/0.117 ms
quagga-router# 


###tcpdump with busybox

/ # ping 10.244.110.131
PING 10.244.110.131 (10.244.110.131): 56 data bytes
64 bytes from 10.244.110.131: seq=0 ttl=62 time=0.225 ms
64 bytes from 10.244.110.131: seq=1 ttl=62 time=0.190 ms
64 bytes from 10.244.110.131: seq=2 ttl=62 time=0.149 ms
64 bytes from 10.244.110.131: seq=3 ttl=62 time=0.176 ms
64 bytes from 10.244.110.131: seq=4 ttl=62 time=0.146 ms
64 bytes from 10.244.110.131: seq=5 ttl=62 time=0.184 ms
64 bytes from 10.244.110.131: seq=6 ttl=62 time=0.203 ms
^C
--- 10.244.110.131 ping statistics ---
7 packets transmitted, 7 packets received, 0% packet loss
round-trip min/avg/max = 0.146/0.181/0.225 ms
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
4: eth0@if10: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1440 qdisc noqueue state UP 
    link/ether e2:22:0c:67:3d:20 brd ff:ff:ff:ff:ff:ff
    inet 10.244.162.133/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::e022:cff:fe67:3d20/64 scope link 
       valid_lft forever preferred_lft forever
/ # 

####tcpdump capture

/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
4: eth0@if9: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1440 qdisc noqueue state UP 
    link/ether 0e:21:3a:60:0f:c7 brd ff:ff:ff:ff:ff:ff
    inet 10.244.110.131/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::c21:3aff:fe60:fc7/64 scope link 
       valid_lft forever preferred_lft forever
/ # 

/ # tcpdump 
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes

15:37:31.884771 IP6 fe80::c21:3aff:fe60:fc7 > ff02::2: ICMP6, router solicitation, length 16
15:37:31.886890 ARP, Request who-has 169.254.1.1 tell busybox-deploy-worker2-58d6c6d88b-gkxf9, length 28
15:37:31.886909 ARP, Reply 169.254.1.1 is-at ee:ee:ee:ee:ee:ee (oui Unknown), length 28
15:37:31.886911 IP busybox-deploy-worker2-58d6c6d88b-gkxf9.45942 > kube-dns.kube-system.svc.cluster.local.53: 27464+ PTR? 2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.0.f.f.ip6.arpa. (90)
15:37:31.982281 IP kube-dns.kube-system.svc.cluster.local.53 > busybox-deploy-worker2-58d6c6d88b-gkxf9.45942: 27464 NXDomain 0/1/0 (166)
15:37:31.984985 IP busybox-deploy-worker2-58d6c6d88b-gkxf9.42880 > kube-dns.kube-system.svc.cluster.local.53: 16275+ PTR? 7.c.f.0.0.6.e.f.f.f.a.3.1.2.c.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.e.f.ip6.arpa. (90)
15:37:32.051746 IP kube-dns.kube-system.svc.cluster.local.53 > busybox-deploy-worker2-58d6c6d88b-gkxf9.42880: 16275 NXDomain 0/1/0 (166)
15:37:32.053384 IP busybox-deploy-worker2-58d6c6d88b-gkxf9.45548 > kube-dns.kube-system.svc.cluster.local.53: 4599+ PTR? 1.1.254.169.in-addr.arpa. (42)
15:37:32.131799 IP busybox-deploy-worker2-58d6c6d88b-gkxf9.39312 > kube-dns.kube-system.svc.cluster.local.53: 21939+ PTR? 10.0.96.10.in-addr.arpa. (41)
15:37:32.138329 IP kube-dns.kube-system.svc.cluster.local.53 > busybox-deploy-worker2-58d6c6d88b-gkxf9.39312: 21939*- 1/0/0 PTR kube-dns.kube-system.svc.cluster.local. (116)
15:37:37.000820 ARP, Request who-has busybox-deploy-worker2-58d6c6d88b-gkxf9 tell kind-worker2.kind, length 28
15:37:37.000914 ARP, Reply busybox-deploy-worker2-58d6c6d88b-gkxf9 is-at 0e:21:3a:60:0f:c7 (oui Unknown), length 28
15:37:37.001150 IP busybox-deploy-worker2-58d6c6d88b-gkxf9.60221 > kube-dns.kube-system.svc.cluster.local.53: 44655+ PTR? 2.0.18.172.in-addr.arpa. (41)
15:37:37.020342 IP kube-dns.kube-system.svc.cluster.local.53 > busybox-deploy-worker2-58d6c6d88b-gkxf9.60221: 44655 1/0/0 PTR kind-worker2.kind. (95)
15:37:45.545684 IP 10.244.162.133 > busybox-deploy-worker2-58d6c6d88b-gkxf9: ICMP echo request, id 5120, seq 0, length 64
15:37:45.545730 IP busybox-deploy-worker2-58d6c6d88b-gkxf9 > 10.244.162.133: ICMP echo reply, id 5120, seq 0, length 64
15:37:45.545889 IP busybox-deploy-worker2-58d6c6d88b-gkxf9.38307 > kube-dns.kube-system.svc.cluster.local.53: 20526+ PTR? 133.162.244.10.in-addr.arpa. (45)
15:37:45.619184 IP kube-dns.kube-system.svc.cluster.local.53 > busybox-deploy-worker2-58d6c6d88b-gkxf9.38307: 20526 NXDomain 0/0/0 (45)
15:37:46.546083 IP 10.244.162.133 > busybox-deploy-worker2-58d6c6d88b-gkxf9: ICMP echo request, id 5120, seq 1, length 64
15:37:46.546138 IP busybox-deploy-worker2-58d6c6d88b-gkxf9 > 10.244.162.133: ICMP echo reply, id 5120, seq 1, length 64
15:37:47.546389 IP 10.244.162.133 > busybox-deploy-worker2-58d6c6d88b-gkxf9: ICMP echo request, id 5120, seq 2, length 64
15:37:47.546429 IP busybox-deploy-worker2-58d6c6d88b-gkxf9 > 10.244.162.133: ICMP echo reply, id 5120, seq 2, length 64
15:37:48.546616 IP 10.244.162.133 > busybox-deploy-worker2-58d6c6d88b-gkxf9: ICMP echo request, id 5120, seq 3, length 64
15:37:48.546661 IP busybox-deploy-worker2-58d6c6d88b-gkxf9 > 10.244.162.133: ICMP echo reply, id 5120, seq 3, length 64
15:37:49.546836 IP 10.244.162.133 > busybox-deploy-worker2-58d6c6d88b-gkxf9: ICMP echo request, id 5120, seq 4, length 64
15:37:49.546873 IP busybox-deploy-worker2-58d6c6d88b-gkxf9 > 10.244.162.133: ICMP echo reply, id 5120, seq 4, length 64
15:37:50.547043 IP 10.244.162.133 > busybox-deploy-worker2-58d6c6d88b-gkxf9: ICMP echo request, id 5120, seq 5, length 64
15:37:50.547082 IP busybox-deploy-worker2-58d6c6d88b-gkxf9 > 10.244.162.133: ICMP echo reply, id 5120, seq 5, length 64
15:37:51.547271 IP 10.244.162.133 > busybox-deploy-worker2-58d6c6d88b-gkxf9: ICMP echo request, id 5120, seq 6, length 64
15:37:51.547331 IP busybox-deploy-worker2-58d6c6d88b-gkxf9 > 10.244.162.133: ICMP echo reply, id 5120, seq 6, length 64
^C
30 packets captured
31 packets received by filter
1 packet dropped by kernel
/ # 



```
# kind-control-plane calicoctl setup

```sh
╰─ docker exec -ti kind-control-plane bash                                                                                                                            ─╯
root@kind-control-plane:/# 
root@kind-control-plane:/# 
root@kind-control-plane:/# apt update
Ign:1 http://security.ubuntu.com/ubuntu eoan-security InRelease
Ign:2 http://archive.ubuntu.com/ubuntu eoan InRelease
Err:3 http://security.ubuntu.com/ubuntu eoan-security Release
  404  Not Found [IP: 91.189.91.38 80]
Ign:4 http://archive.ubuntu.com/ubuntu eoan-updates InRelease
Ign:5 http://archive.ubuntu.com/ubuntu eoan-backports InRelease
Err:6 http://archive.ubuntu.com/ubuntu eoan Release
  404  Not Found [IP: 91.189.88.142 80]
Err:7 http://archive.ubuntu.com/ubuntu eoan-updates Release
  404  Not Found [IP: 91.189.88.142 80]
Err:8 http://archive.ubuntu.com/ubuntu eoan-backports Release
  404  Not Found [IP: 91.189.88.142 80]
Reading package lists... Done
E: The repository 'http://security.ubuntu.com/ubuntu eoan-security Release' does not have a Release file.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
E: The repository 'http://archive.ubuntu.com/ubuntu eoan Release' does not have a Release file.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
E: The repository 'http://archive.ubuntu.com/ubuntu eoan-updates Release' does not have a Release file.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
E: The repository 'http://archive.ubuntu.com/ubuntu eoan-backports Release' does not have a Release file.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
root@kind-control-plane:/# curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.14.2/calicoctl
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   633  100   633    0     0    853      0 --:--:-- --:--:-- --:--:--   853
100 37.1M  100 37.1M    0     0   705k      0  0:00:53  0:00:53 --:--:--  850k
root@kind-control-plane:/# mkdir -p $HOME/.kube;
root@kind-control-plane:/# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config;
bash: sudo: command not found
root@kind-control-plane:/# cp -i /etc/kubernetes/admin.conf $HOME/.kube/config;
root@kind-control-plane:/# chown $(id -u):$(id -g) $HOME/.kube/config;


##download calicoctl bin 3.14
$cd /
$curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.14.2/calicoctl

root@kind-control-plane:/# cp calicoctl /usr/local/bin/
root@kind-control-plane:/usr/local/bin# chmod 777 calicoctl 
root@kind-control-plane:/usr/local/bin# ls -al
total 163072
drwxr-xr-x 1 root root     4096 Jan 25 16:11 .
drwxr-xr-x 1 root root     4096 Apr 30  2020 ..
-rwxrwxrwx 1 root root 38965248 Jan 25 16:12 calicoctl
-rwxr-xr-x 1 root root     1120 Mar 23  2020 clean-install
-rwxr-xr-x 1 root root 55383960 Feb 26  2020 containerd
-rwxr-xr-x 1 root root  7396352 Feb 26  2020 containerd-shim
-rwxr-xr-x 1 root root  9115872 Feb 26  2020 containerd-shim-runc-v2
-rwxr-xr-x 1 root root 28488749 Dec 16  2019 crictl
-rwxr-xr-x 1 root root 27597720 Feb 26  2020 ctr
-rwxrwxr-x 1 root root     9563 Apr 30  2020 entrypoint
##datastore setup
export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=~/.kube/config
export calico node config
root@kind-control-plane:/# calicoctl get bgppeer
NAME                         PEERIP       NODE       ASN   
2frr                         172.18.0.5   (global)   1     
peer-with-route-reflectors                all()      0     



─    ~/kuber-deployment/calico-playgroud/calico3.14-v4  on   master !6 ?7 ································································ ✔  at 00:37:56  ─╮
╰─ docker cp ./kube-config kind-worker                                                                                                                                ─╯
must specify at least one container source
╭─    ~/kuber-deployment/calico-playgroud/calico3.14-v4  on   master !6 ?7 ······························································ 1 ✘  at 00:38:34  ─╮
╰─ docker cp ./kube-config kind-worker:/                                                                                                                              ─╯
╭─    ~/kuber-deployment/calico-playgroud/calico3.14-v4  on   master !6 ?7 ································································ ✔  at 00:39:14  ─╮
╰─ docker cp ./kube-config kind-worker2:/                                                                                                                             ─╯
╭─    ~/kuber-deployment/calico-playgroud/calico3.14-v4  on   master !6 ?7 ································································ ✔  at 00:40:56  ─╮
╰─ ls                                                                                                                                                                 ─╯
00-calico-ebgppeer.yaml           02-calicoctl-disable-ipip-config.yaml    05-change-pod-cidr-and-service-cidr.yaml  08-peer-to-rr.yaml
00-calico-ibgppeer.yaml           03-calicoctl-ippool-default-config.yaml  06-disable-ipv4-default-pool.yaml         kind-worker-rr.yaml
01-calico-bgp-config-adv-ip.yaml  04-calico-enable-vxlan-config.yaml       07-calico-ipam-for-diff-ns.yaml           kube-config
╭─    ~/kuber-deployment/calico-playgroud/calico3.14-v4  on   master !6 ?7 ································································ ✔  at 00:40:58  ─╮
╰─                                                                                                                                                                    ─╯






