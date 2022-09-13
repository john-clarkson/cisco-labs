## Loopback Route-leaking
```py
ABSR-1#show run int g1/0.3
Building configuration...

Current configuration : 137 bytes
!
interface GigabitEthernet1/0.3
 description OPTION_C_EBGP_MULTI_HOP
 encapsulation dot1Q 3
 ip address 91.91.91.9 255.255.255.252
end

ABSR-1#
JAPAN-ASBR-1#sh run int g1/0.3
Building configuration...

Current configuration : 138 bytes
!
interface GigabitEthernet1/0.3
 description OPTION_C_EBGP_MULTI_HOP
 encapsulation dot1Q 3
 ip address 91.91.91.10 255.255.255.252
end

JAPAN-ASBR-1#
```
```py
ASBR-2#sh run int g1/0.3
Building configuration...

Current configuration : 136 bytes
!
interface GigabitEthernet1/0.3
 description OPTION_C_EBGP_MULTI_HOP
 encapsulation dot1Q 3
 ip address 19.19.1.9 255.255.255.252
end

ASBR-2#

JAPAN-ASBR-2#sh run int g1/0.3
Building configuration...

Current configuration : 137 bytes
!
interface GigabitEthernet1/0.3
 description OPTION_C_EBGP_MULTI_HOP
 encapsulation dot1Q 3
 ip address 19.19.1.10 255.255.255.252
end
```
```py
ABSR-1#sh run | section bgp|address-family ipv4
router bgp 9000
 address-family ipv4
  no synchronization
  network 169.169.253.253 mask 255.255.255.255
  network 169.169.254.254 mask 255.255.255.255
  neighbor 91.91.91.10 activate
  neighbor 91.91.91.10 send-label
  no auto-summary
 exit-address-family
!
ABSR-2#
router bgp 9000
 address-family ipv4
  no synchronization
  network 169.169.253.253 mask 255.255.255.255
  network 169.169.254.254 mask 255.255.255.255
  neighbor 19.19.1.10 activate
  neighbor 19.19.1.10 send-label
  no auto-summary
 exit-address-family 
```


```py
JAPAN-ASBR-1#sh run | section bgp|address-family ipv4
router bgp 1000
 address-family ipv4
  no synchronization
  network 192.168.253.253 mask 255.255.255.255
  neighbor 91.91.91.9 activate
  neighbor 91.91.91.9 send-label
  no auto-summary
 exit-address-family

JAPAN-ASBR-2#
JAPAN-ASBR-2#sh run | section bgp|address-family ipv4
router bgp 1000
 address-family ipv4
  no synchronization
  network 192.168.253.253 mask 255.255.255.255
  neighbor 19.19.1.9 activate
  neighbor 19.19.1.9 send-label
  no auto-summary
 exit-address-family
```
```py
ABSR-1#show ip bgp
BGP table version is 4, local router ID is 169.169.250.250
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 169.169.253.253/32
                    169.169.5.1              3         32768 i
*> 169.169.254.254/32
                    169.169.5.1              3         32768 i
*> 192.168.253.253/32
                    91.91.91.10             10             0 1000 i
ABSR-1#
```
```py
ASBR-2#show ip bgp
BGP table version is 4, local router ID is 169.169.251.251
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 169.169.253.253/32
                    169.169.5.5              3         32768 i
*> 169.169.254.254/32
                    169.169.5.5              3         32768 i
*> 192.168.253.253/32
                    19.19.1.10              10             0 1000 i
ASBR-2#
```
```py
JAPAN-ASBR-1#show ip bgp
BGP table version is 4, local router ID is 192.168.254.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 169.169.253.253/32
                    91.91.91.9               3             0 9000 i
*> 169.169.254.254/32
                    91.91.91.9               3             0 9000 i
*> 192.168.253.253/32
                    192.168.198.10          10         32768 i
JAPAN-ASBR-1#

```
```py
JAPAN-ASBR-2#show ip bgp
BGP table version is 4, local router ID is 192.168.254.2
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 169.169.253.253/32
                    19.19.1.9                3             0 9000 i
*> 169.169.254.254/32
                    19.19.1.9                3             0 9000 i
*> 192.168.253.253/32
                    192.168.198.14          10         32768 i
JAPAN-ASBR-2#
```

## GLOBAL BGP INTO CORE IGP (REDISTRIBUTE LOOPBACK_32)
```PY
ABSR-1#show run | section ip prefix
   ip prefix-list OPTION_C_JAPAN_RR_LOOPBACK_192_168_253_253_32 seq 5 permit 192.168.253.253/32
    route-map OPTION_C_JAPAN_PREFIX_32 permit 10
      match ip address prefix-list OPTION_C_JAPAN_RR_LOOPBACK_192_168_253_253_32
```
```PY
ABSR-2#show run | section ip prefix
   ip prefix-list OPTION_C_JAPAN_RR_LOOPBACK_192_168_253_253_32 seq 5 permit 192.168.253.253/32
    route-map OPTION_C_JAPAN_PREFIX_32 permit 10
      match ip address prefix-list OPTION_C_JAPAN_RR_LOOPBACK_192_168_253_253_32

JAPAN-ASBR-1#sh run | section ip prefix
   ip prefix-list OPTION_C_RRs_LOOPBACK_32 seq 5 permit 169.169.253.253/32
   ip prefix-list OPTION_C_RRs_LOOPBACK_32 seq 10 permit 169.169.254.254/32
route-map OPTION_C_PREFIX_32 permit 10
   match ip address prefix-list OPTION_C_RRs_LOOPBACK_32

JAPAN-ASBR-2#sh run | section ip prefix
   ip prefix-list OPTION_C_RRs_LOOPBACK_32 seq 5 permit 169.169.253.253/32
   ip prefix-list OPTION_C_RRs_LOOPBACK_32 seq 10 permit 169.169.254.254/32
route-map OPTION_C_PREFIX_32 permit 10
   match ip address prefix-list OPTION_C_RRs_LOOPBACK_32
```
```PY
ASBR-1/2
router ospf 10
 redistribute bgp 9000 subnets route-map OPTION_C_JAPAN_PREFIX_32

JAPAN-ASBR-1/2
  router isis
   redistribute bgp 1000 route-map OPTION_C_PREFIX_32 metric-type external   
```
```PY
RR_1#sh ip route ospf 
Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP
       D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area 
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
       E1 - OSPF external type 1, E2 - OSPF external type 2
       i - IS-IS, su - IS-IS summary, L1 - IS-IS level-1, L2 - IS-IS level-2
       ia - IS-IS inter area, * - candidate default, U - per-user static route
       o - ODR, P - periodic downloaded static route, + - replicated route

Gateway of last resort is not set
      192.168.253.0/32 is subnetted, 1 subnets
O E2     192.168.253.253 [110/1] via 169.169.3.6, 00:04:57, FastEthernet2/0
                         [110/1] via 169.169.3.2, 00:04:57, FastEthernet2/1
RR_1# 
```
```PY
RR_2#show ip route ospf 
Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP
       D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area 
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
       E1 - OSPF external type 1, E2 - OSPF external type 2
       i - IS-IS, su - IS-IS summary, L1 - IS-IS level-1, L2 - IS-IS level-2
       ia - IS-IS inter area, * - candidate default, U - per-user static route
       o - ODR, P - periodic downloaded static route, + - replicated route

Gateway of last resort is not set
      192.168.253.0/32 is subnetted, 1 subnets
O E2     192.168.253.253 [110/1] via 169.169.3.18, 00:04:18, FastEthernet3/0
                         [110/1] via 169.169.3.14, 00:04:18, FastEthernet3/1
RR_2#

JAPAN-P#show ip route 
Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP
       D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area 
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
       E1 - OSPF external type 1, E2 - OSPF external type 2
       i - IS-IS, su - IS-IS summary, L1 - IS-IS level-1, L2 - IS-IS level-2
       ia - IS-IS inter area, * - candidate default, U - per-user static route
       o - ODR, P - periodic downloaded static route, + - replicated route

Gateway of last resort is not set

      169.169.0.0/32 is subnetted, 2 subnets
i L2     169.169.253.253 [115/10] via 192.168.198.13, FastEthernet1/1
                         [115/10] via 192.168.198.9, FastEthernet1/0
i L2     169.169.254.254 [115/10] via 192.168.198.13, FastEthernet1/1
                         [115/10] via 192.168.198.9, FastEthernet1/0
```PY
RR_1#ping 192.168.253.253 source loopback 0

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 192.168.253.253, timeout is 2 seconds:
Packet sent with a source address of 169.169.253.253 
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 172/198/224 ms
RR_1#

RR_2# ping 192.168.253.253 source loopback 0

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 192.168.253.253, timeout is 2 seconds:
Packet sent with a source address of 169.169.254.254 
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 116/160/204 ms
RR_2#

JAPAN-P#ping 169.169.253.253 source loopback 0

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 169.169.253.253, timeout is 2 seconds:
Packet sent with a source address of 192.168.253.253 
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 164/203/248 ms
JAPAN-P#ping 169.169.254.254 source loopback 0

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 169.169.254.254, timeout is 2 seconds:
Packet sent with a source address of 192.168.253.253 
!!!!!
Success rate is 80 percent (5/5), round-trip min/avg/max = 152/183/220 ms
JAPAN-P#
```
# EBGP Multihop RR_1/2
```PY
router bgp 9000
 neighbor 192.168.253.253 remote-as 1000
 neighbor 192.168.253.253 ebgp-multihop 255
 neighbor 192.168.253.253 update-source Loopback0
 !
 address-family vpnv4
  neighbor 192.168.253.253 activate
  neighbor 192.168.253.253 send-community extended
 exit-address-family

JAPAN-P#
router bgp 1000
 bgp router-id 192.168.253.253
 no bgp default ipv4-unicast
 bgp cluster-id 2
 bgp log-neighbor-changes
 neighbor 169.169.253.253 remote-as 9000
 neighbor 169.169.253.253 ebgp-multihop 255
 neighbor 169.169.253.253 update-source Loopback0
 neighbor 169.169.254.254 remote-as 9000
 neighbor 169.169.254.254 ebgp-multihop 255
 neighbor 169.169.254.254 update-source Loopback0

 address-family vpnv4
  neighbor 169.169.253.253 activate
  neighbor 169.169.253.253 send-community extended
  neighbor 169.169.254.254 activate
  neighbor 169.169.254.254 send-community extended
```
```PY
JAPAN-P#show ip bgp vpnv4 rd 9000:200
BGP table version is 57, local router ID is 192.168.253.253
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 9000:200
*  2.2.2.0/24       169.169.253.253                        0 9000 65511 i
*>                  169.169.254.254                        0 9000 65511 i

RR_1#show ip bgp vpnv4 rd 1000:1
BGP table version is 803, local router ID is 169.169.253.253
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 1000:1
*> 111.111.111.111/32
                    192.168.253.253                        0 1000 65511 ?
* i                 192.168.253.253          0    100      0 1000 65511 ?
*> 192.168.100.0    192.168.253.253                        0 1000 65511 ?
* i                 192.168.253.253          0    100      0 1000 65511 ?
RR_1#

RR_2#show ip bgp vpnv4 rd 1000:1
BGP table version is 694, local router ID is 169.169.254.254
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 1000:1
* i111.111.111.111/32
                    192.168.253.253          0    100      0 1000 65511 ?
*>                  192.168.253.253                        0 1000 65511 ?
* i192.168.100.0    192.168.253.253          0    100      0 1000 65511 ?
*>                  192.168.253.253                        0 1000 65511 ?
RR_2#
```
```PY
IDC-CORE#ping vrf GERMANY 111.111.111.111 source 2.2.2.254

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 111.111.111.111, timeout is 2 seconds:
Packet sent with a source address of 2.2.2.254 
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 352/424/476 ms
IDC-CORE#trac vrf GERMANY 111.111.111.111 source 2.2.2.254

Type escape sequence to abort.
Tracing the route to 111.111.111.111

  1 192.168.20.254 140 msec 44 msec 52 msec
  2 169.169.254.6 336 msec 120 msec * 
  3 169.169.2.6 [MPLS: Labels 200/21 Exp 0] 324 msec 368 msec 308 msec
  4 169.169.5.2 [MPLS: Labels 23/21 Exp 0] 428 msec 348 msec 252 msec
  5 91.91.91.10 [MPLS: Labels 16/21 Exp 0] 332 msec 324 msec 320 msec
  6 192.168.198.10 [MPLS: Label 21 Exp 0] 272 msec 340 msec 336 msec
  7 168.192.1.254 [MPLS: Label 21 Exp 0] 292 msec 384 msec 280 msec
  8 168.192.1.1 328 msec 328 msec 336 msec
  9 192.168.100.1 432 msec 480 msec 696 msec
IDC-CORE#

```
```PY
TOKYO-LAN#ping 2.2.2.254 source loopback 0

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 2.2.2.254, timeout is 2 seconds:
Packet sent with a source address of 111.111.111.111 
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 388/644/1392 ms
TOKYO-LAN#

TOKYO-LAN#traceroute 2.2.2.254 source loopback 0

Type escape sequence to abort.
Tracing the route to 2.2.2.254

  1 192.168.100.254 112 msec 80 msec 52 msec
  2 168.192.1.254 196 msec 132 msec 148 msec
  3 192.168.198.2 [MPLS: Labels 20/20002 Exp 0] 544 msec 392 msec * 
  4 192.168.198.13 [MPLS: Labels 20/20002 Exp 0] 288 msec 364 msec 324 msec
  5 19.19.1.9 [MPLS: Labels 16/20002 Exp 0] 436 msec 320 msec 308 msec
  6 169.169.5.5 [MPLS: Labels 206/20002 Exp 0] 388 msec 412 msec 400 msec
  7 169.169.3.13 [MPLS: Label 20002 Exp 0] 360 msec 308 msec 268 msec
  8 169.169.3.14 [MPLS: Labels 202/2015 Exp 0] 332 msec 324 msec 604 msec (RR)
  9 169.169.254.6 [MPLS: Label 2015 Exp 0] 440 msec 1428 msec 716 msec
 10 169.169.254.5 388 msec 556 msec 716 msec
 11 192.168.20.1 1284 msec 1236 msec 584 msec
TOKYO-LAN#
```
```PY
PE_2#show ip cef 192.168.253.253 detail 
192.168.253.253/32, epoch 0, per-destination sharing
  local label info: global/2038
  1 RR source [no flags]
  Dependent covered prefix type rr cover NULL
  nexthop 169.169.1.6 FastEthernet1/0 label 110
  nexthop 169.169.2.6 FastEthernet1/1 label 200
PE_2#

JAPAN-P#show ip cef 169.169.253.253 detail 
169.169.253.253/32, epoch 0, per-destination sharing
  local label info: global/17
  nexthop 192.168.198.9 FastEthernet1/0 label 20
  nexthop 192.168.198.13 FastEthernet1/1 label 18
JAPAN-P#show ip cef 169.169.254.254 detail 
169.169.254.254/32, epoch 0, per-destination sharing
  local label info: global/20
  1 RR source [no flags]
  Dependent covered prefix type rr cover NULL
  nexthop 192.168.198.9 FastEthernet1/0 label 18
  nexthop 192.168.198.13 FastEthernet1/1 label 20
JAPAN-P#

============================================
bidirectional traffic is not the same path.
========================================
```

## NEXTHOP UNCHANGED on RRs
```PY
router bgp 9000
  address-family vpnv4
   neighbor 192.168.253.253 next-hop-unchanged

TOKYO-P
router bgp 1000
 address-family vpnv4
  neighbor 169.169.253.253 next-hop-unchanged   

 
clear ip bgp vpnv4 unicast [as-number] soft [in|out] 

RR_1#show ip bgp vpnv4 rd 1000:1
BGP table version is 832, local router ID is 169.169.253.253
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 1000:1
*  111.111.111.111/32
                    192.168.251.251                        0 1000 65511 ?
*  192.168.100.0    192.168.251.251                        0 1000 65511 ?
RR_1#

RR_2#show ip bgp vpnv4 rd 1000:1
BGP table version is 5, local router ID is 169.169.254.254
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 1000:1
*  111.111.111.111/32
                    192.168.251.251                        0 1000 65511 ?
*  192.168.100.0    192.168.251.251                        0 1000 65511 ?
RR_2#

JAPAN-P#show ip bgp vpnv4 rd 9000:200
BGP table version is 6, local router ID is 192.168.253.253
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 9000:200
*  2.2.2.0/24       169.169.253.2                          0 9000 65511 i
*                   169.169.253.2                          0 9000 65511 i
JAPAN-P#
```
```PY
ABSR-1/2#sh run | sec ip prefix
ip prefix-list OPTION_C_JAPAN_RR_LOOPBACK_192_168_253_253_32 seq 5 permit 192.168.253.253/32
ip prefix-list OPTION_C_JAPAN_RR_LOOPBACK_192_168_253_253_32 seq 10 permit 192.168.251.251/32


RR_1#show ip bgp vpnv4 rd 1000:1
BGP table version is 844, local router ID is 169.169.253.253
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 1000:1
* i111.111.111.111/32
                    192.168.251.251          0    100      0 1000 65511 ?
*>                  192.168.251.251                        0 1000 65511 ?
* i192.168.100.0    192.168.251.251          0    100      0 1000 65511 ?
*>                  192.168.251.251                        0 1000 65511 ?
RR_1#

JAPAN-ASBR-1/2#sh run | sec ip prefix
ip prefix-list OPTION_C_RRs_LOOPBACK_32 seq 5 permit 169.169.253.253/32
ip prefix-list OPTION_C_RRs_LOOPBACK_32 seq 10 permit 169.169.254.254/32
ip prefix-list OPTION_C_RRs_LOOPBACK_32 seq 15 permit 169.169.253.2/32

JAPAN-P#show ip bgp vpnv4 rd 9000:200
BGP table version is 19, local router ID is 192.168.253.253
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 9000:200
*  2.2.2.0/24       169.169.253.2                          0 9000 65511 i
*>                  169.169.253.2                          0 9000 65511 i
JAPAN-P#
```
```PY
IDC-CORE#trace vrf GERMANY 111.111.111.111 source 2.2.2.254

Type escape sequence to abort.
Tracing the route to 111.111.111.111

  1 192.168.20.254 68 msec 84 msec 80 msec
  2 169.169.254.6 152 msec 128 msec 132 msec
  3 169.169.2.6 [MPLS: Labels 201/11001 Exp 0] 524 msec 360 msec 524 msec
  4 169.169.5.6 [MPLS: Labels 23/11001 Exp 0] 380 msec 368 msec 376 msec
  5 19.19.1.10 [MPLS: Labels 17/11001 Exp 0] 360 msec 396 msec 296 msec
  6 192.168.198.14 [MPLS: Labels 16/11001 Exp 0] 328 msec 472 msec 496 msec
  7 168.192.1.254 [MPLS: Label 11001 Exp 0] 316 msec 532 msec 584 msec
  8 168.192.1.1 452 msec 440 msec * 
  9 192.168.100.1 440 msec 612 msec 388 msec
IDC-CORE#

TOKYO-LAN#trace 2.2.2.254 sou lo0

Type escape sequence to abort.
Tracing the route to 2.2.2.254

  1 192.168.100.254 128 msec 68 msec 40 msec
  2 168.192.1.254 124 msec 188 msec 128 msec
  3 192.168.198.2 [MPLS: Labels 18000/2053 Exp 0] 324 msec 348 msec 416 msec
  4 192.168.198.9 [MPLS: Labels 23/2053 Exp 0] 316 msec 360 msec 364 msec
  5 91.91.91.9 [MPLS: Labels 22/2053 Exp 0] 476 msec 352 msec 404 msec
  6 169.169.5.1 [MPLS: Labels 202/2053 Exp 0] 228 msec 396 msec 320 msec
  7 169.169.254.6 [MPLS: Label 2053 Exp 0] 368 msec 356 msec 392 msec
  8 169.169.254.5 412 msec 424 msec 340 msec
  9 192.168.20.1 444 msec 380 msec 264 msec
TOKYO-LAN#
```