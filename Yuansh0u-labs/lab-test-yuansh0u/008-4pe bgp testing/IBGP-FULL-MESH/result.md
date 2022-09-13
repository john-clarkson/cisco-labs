# 4PE BGP testing
### Topology
![picture 1](../../images/5a02bc62a9c72a266e1c9c2a7363e9f058ac7bb1332f04dc6c2e00c4311d4c98.png)  
# Core network BGP policy setup
- enable BGP vpnv4 AFI on all PE devices
- send BGP community value with both keywords
- IBGP full-mesh without RR
```bash
R1#sh run | sec router bgp
router bgp 1000
 template peer-policy IBGP-FULL
 exit-peer-policy
 !
 template peer-session IBGP-FULL
  remote-as 1000
  update-source Loopback0
 exit-peer-session
 !
 bgp router-id 1.1.1.1
 bgp log-neighbor-changes
 neighbor 2.2.2.2 inherit peer-session IBGP-FULL
 neighbor 3.3.3.3 inherit peer-session IBGP-FULL
 neighbor 4.4.4.4 inherit peer-session IBGP-FULL
 !
 address-family vpnv4
  neighbor 2.2.2.2 activate
  neighbor 2.2.2.2 send-community both
  neighbor 3.3.3.3 activate
  neighbor 3.3.3.3 send-community both
  neighbor 4.4.4.4 activate
  neighbor 4.4.4.4 send-community both
 exit-address-family
 !        
 address-family ipv4 vrf a
  neighbor 15.1.1.5 remote-as 500
  neighbor 15.1.1.5 activate
  neighbor 15.1.1.5 send-community
 exit-address-family
R1# 
```
# CE advertise policy setup
- R5 redistribute loopback to BGP process as incomplete origin code
- create route-map to modify BGP NLRI updates with origin code IGP with community 500:500
```bash
ip prefix-list loopback seq 5 permit 0.0.0.0/0 ge 31
!
route-map loopback permit 10
 match interface Loopback0
!
route-map community permit 10
 match ip address prefix-list loopback
 continue 20
 set community 500:500
!
route-map community permit 20
 set origin igp
!
router bgp 500
 redistribute connected route-map loopback
 neighbor 15.1.1.1 remote-as 1000
 neighbor 15.1.1.1 send-community both
 neighbor 15.1.1.1 route-map community out
 neighbor 25.1.1.2 remote-as 1000
 neighbor 25.1.1.2 send-community both
 neighbor 25.1.1.2 route-map community out 
```
## R6's point of view
```bash
R6#show bgp 5.5.5.5
BGP routing table entry for 5.5.5.5/32, version 25
Paths: (2 available, best #2, table default)
Multipath: eBGP
  Advertised to update-groups:
     3         
  Refresh Epoch 1
  1000 500
    46.1.1.4 from 46.1.1.4 (4.4.4.4)
      Origin IGP, localpref 100, valid, external, multipath(oldest)
      Community: 500:500
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  1000 500
    36.1.1.3 from 36.1.1.3 (3.3.3.3)
      Origin IGP, localpref 100, valid, external, multipath, best
      Community: 500:500
      rx pathid: 0, tx pathid: 0x0
R6#
```
## PE's point of view
```bash
R1#show bgp vpnv4 unicast rd 1:1 5.5.5.5 
BGP routing table entry for 1:1:5.5.5.5/32, version 25
Paths: (2 available, best #2, table a)
  Advertised to update-groups:
     4         
  Refresh Epoch 1
  500, imported path from 2:2:5.5.5.5/32 (global)
    2.2.2.2 (metric 2) from 2.2.2.2 (2.2.2.2)
      Origin IGP, metric 0, localpref 100, valid, internal
      Community: 500:500 ----<recieve from PE R2>
      Extended Community: RT:2:2
      mpls labels in/out IPv4 VRF Aggr:17/19
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 2
  500
    15.1.1.5 from 15.1.1.5 (5.5.5.5)
      Origin IGP, metric 0, localpref 100, valid, external, best
      Community: 500:500 ----<recieve from CE R5>
      Extended Community: RT:1:1
      mpls labels in/out IPv4 VRF Aggr:17/nolabel
      rx pathid: 0, tx pathid: 0x0
R1#
```
## R1 add community value with 1000:1, keep original community 500:500 recieve from R5
```bash
ip prefix-list loopback seq 5 permit 0.0.0.0/0 ge 31
R1#sh run | sec route-map
route-map R1-ADD-COMMUNITY permit 10
 match ip address prefix-list loopback
 set community 1000:1 additive
!
vrf definition a
 rd 1:1
 !
 address-family ipv4
  export map R1-ADD-COMMUNITY
 exit-address-family
!
```
## verification
```bash
R2#show bgp vpnv4 unicast rd 1:1 5.5.5.5
BGP routing table entry for 1:1:5.5.5.5/32, version 14
Paths: (1 available, best #1, no table)
  Not advertised to any peer
  Refresh Epoch 6
  500
    1.1.1.1 (metric 2) from 1.1.1.1 (1.1.1.1)
      Origin IGP, metric 0, localpref 100, valid, internal, best
      Community: 500:500 1000:1
      Extended Community: RT:1:1
      mpls labels in/out nolabel/17
      rx pathid: 0, tx pathid: 0x0

R6#show bgp 5.5.5.5
BGP routing table entry for 5.5.5.5/32, version 29
Paths: (2 available, best #2, table default)
Multipath: eBGP
  Advertised to update-groups:
     3         
  Refresh Epoch 1
  1000 500
    46.1.1.4 from 46.1.1.4 (4.4.4.4)
      Origin IGP, localpref 100, valid, external, multipath(oldest)
      Community: 500:500 1000:1
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  1000 500
    36.1.1.3 from 36.1.1.3 (3.3.3.3)
      Origin IGP, localpref 100, valid, external, multipath, best
      Community: 500:500 1000:1
      rx pathid: 0, tx pathid: 0x0
R6#      
```

## R2 import-policy with deny 6.6.6.66/32
```bash
route-map deny66 deny 10
 match ip address prefix-list deny66
route-map deny66 permit 20
!
vrf definition a
 rd 2:2
 !
 address-family ipv4
  import map deny66
```
## verification
```bash
R2#show bgp vpnv4 un all
BGP table version is 23, local router ID is 2.2.2.2
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 1:1
 *>i 5.5.5.5/32       1.1.1.1                  0    100      0 500 i
 *>i 5.5.5.55/32      1.1.1.1                  0    100      0 500 i
Route Distinguisher: 2:2 (default for vrf a)
 * i 5.5.5.5/32       1.1.1.1                  0    100      0 500 i
 *>                   25.1.1.5                 0             0 500 i
 * i 5.5.5.55/32      1.1.1.1                  0    100      0 500 i
 *>                   25.1.1.5                 0             0 500 i
 * i 6.6.6.6/32       4.4.4.4                  0    100      0 600 i
 *>i                  3.3.3.3                  0    100      0 600 i
Route Distinguisher: 3:3
 *>i 6.6.6.6/32       3.3.3.3                  0    100      0 600 i
 *>i 6.6.6.66/32      3.3.3.3                  0    100      0 600 i
Route Distinguisher: 4:4
     Network          Next Hop            Metric LocPrf Weight Path
 *>i 6.6.6.6/32       4.4.4.4                  0    100      0 600 i
 *>i 6.6.6.66/32      4.4.4.4                  0    100      0 600 i
R2#
```
### Notice RD 2:2 table has no 6.6.6.66/32
## R3 modifiy 5.5.5.5/32 next-hop to 4.4.4.4
```bash
ip prefix-list 5.5 seq 5 permit 5.5.5.5/32
route-map pbr permit 10
 match ip address prefix-list 5.5
 set ip next-hop 4.4.4.4
route-map pbr permit 20
!
vrf definition a
 rd 3:3
 !
 address-family ipv4
  import map pbr
```
### verfication

```bash
R3#show bgp vpnv4 un all 
BGP table version is 85, local router ID is 3.3.3.3
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 1:1
 *>i 5.5.5.5/32       1.1.1.1                  0    100      0 500 i
 *>i 5.5.5.55/32      1.1.1.1                  0    100      0 500 i
Route Distinguisher: 2:2
 *>i 5.5.5.5/32       2.2.2.2                  0    100      0 500 i
 *>i 5.5.5.55/32      2.2.2.2                  0    100      0 500 i
Route Distinguisher: 3:3 (default for vrf a)
 *>i 5.5.5.5/32       4.4.4.4                  0    100      0 500 i
 * i                  4.4.4.4                  0    100      0 500 i
 *>i 5.5.5.55/32      1.1.1.1                  0    100      0 500 i
 *mi                  2.2.2.2                  0    100      0 500 i
 *>  6.6.6.6/32       36.1.1.6                 0             0 600 i
 *mi                  4.4.4.4                  0    100      0 600 i
 *mi 6.6.6.66/32      4.4.4.4                  0    100      0 600 i
 *>                   36.1.1.6                 0             0 600 i
Route Distinguisher: 4:4
 *>i 6.6.6.6/32       4.4.4.4                  0    100      0 600 i
 *>i 6.6.6.66/32      4.4.4.4                  0    100      0 600 i
R3#
```

# eibgp multipath enable
## before multipath
- R1 has two 6.6.6.6 updates from R3 R4, by default, R3 with lower RID wins
```bash
R1#show bgp vpnv4 un all 
BGP table version is 60, local router ID is 1.1.1.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 1:1 (default for vrf a)
 * i 5.5.5.5/32       2.2.2.2                  0    100      0 500 i
 *>                   15.1.1.5                 0             0 500 i
 * i 5.5.5.55/32      2.2.2.2                  0    100      0 500 i
 *>                   15.1.1.5                 0             0 500 i
 *>i 6.6.6.6/32       3.3.3.3                  0    100      0 600 i
 * i                  4.4.4.4                  0    100      0 600 i
 * i 6.6.6.66/32      4.4.4.4                  0    100      0 600 i
 *>i                  3.3.3.3                  0    100      0 600 i
Route Distinguisher: 2:2
 *>i 5.5.5.5/32       2.2.2.2                  0    100      0 500 i
 *>i 5.5.5.55/32      2.2.2.2                  0    100      0 500 i
Route Distinguisher: 3:3
 *>i 6.6.6.6/32       3.3.3.3                  0    100      0 600 i
     Network          Next Hop            Metric LocPrf Weight Path
 *>i 6.6.6.66/32      3.3.3.3                  0    100      0 600 i
Route Distinguisher: 4:4
 *>i 6.6.6.6/32       4.4.4.4                  0    100      0 600 i
 *>i 6.6.6.66/32      4.4.4.4                  0    100      0 600 i
R1#
```
## enable eibgp function on all PE devices per vrf basis
```bash
Router bgp 1000
address-family ipv4 vrf a
  maximum-paths eibgp 32
```
## After policy applied (m flags shows up)
```bash
R1#show bgp vpnv4 un all
BGP table version is 78, local router ID is 1.1.1.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 1:1 (default for vrf a)
 *mi 5.5.5.5/32       2.2.2.2                  0    100      0 500 i
 *>                   15.1.1.5                 0             0 500 i
 *mi 5.5.5.55/32      2.2.2.2                  0    100      0 500 i
 *>                   15.1.1.5                 0             0 500 i
 *>i 6.6.6.6/32       3.3.3.3                  0    100      0 600 i
 *mi                  4.4.4.4                  0    100      0 600 i
 *mi 6.6.6.66/32      4.4.4.4                  0    100      0 600 i
 *>i                  3.3.3.3                  0    100      0 600 i
Route Distinguisher: 2:2
 *>i 5.5.5.5/32       2.2.2.2                  0    100      0 500 i
 *>i 5.5.5.55/32      2.2.2.2                  0    100      0 500 i
Route Distinguisher: 3:3
 *>i 6.6.6.6/32       3.3.3.3                  0    100      0 600 i
     Network          Next Hop            Metric LocPrf Weight Path
 *>i 6.6.6.66/32      3.3.3.3                  0    100      0 600 i
Route Distinguisher: 4:4
 *>i 6.6.6.6/32       4.4.4.4                  0    100      0 600 i
 *>i 6.6.6.66/32      4.4.4.4                  0    100      0 600 i
R1#
```
## Routing table check
```bash
R1#show ip route vrf a 6.6.6.6

Routing Table: a
Routing entry for 6.6.6.6/32
  Known via "bgp 1000", distance 200, metric 0
  Tag 600, type internal
  Last update from 4.4.4.4 00:12:36 ago
  Routing Descriptor Blocks:
    4.4.4.4 (default), from 4.4.4.4, 00:12:36 ago
      Route metric is 0, traffic share count is 1
      AS Hops 1
      Route tag 600  (R6 asn)
      MPLS label: 20
      MPLS Flags: MPLS Required
  * 3.3.3.3 (default), from 3.3.3.3, 00:12:36 ago
      Route metric is 0, traffic share count is 1
      AS Hops 1
      Route tag 600
      MPLS label: 20
      MPLS Flags: MPLS Required
R1#

R6#sh ip route 5.5.5.5
Routing entry for 5.5.5.5/32
  Known via "bgp 600", distance 20, metric 0
  Tag 1000, type external
  Last update from 36.1.1.3 00:29:07 ago
  Routing Descriptor Blocks:
  * 46.1.1.4, from 46.1.1.4, 00:29:07 ago
      Route metric is 0, traffic share count is 1
      AS Hops 2
      Route tag 1000
      MPLS label: none
    36.1.1.3, from 36.1.1.3, 00:29:07 ago
      Route metric is 0, traffic share count is 1
      AS Hops 2
      Route tag 1000
      MPLS label: none
R6#

R6#sh ip route        
Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP
       D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area 
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
       E1 - OSPF external type 1, E2 - OSPF external type 2
       i - IS-IS, su - IS-IS summary, L1 - IS-IS level-1, L2 - IS-IS level-2
       ia - IS-IS inter area, * - candidate default, U - per-user static route
       o - ODR, P - periodic downloaded static route, H - NHRP, l - LISP
       + - replicated route, % - next hop override

Gateway of last resort is not set

      5.0.0.0/32 is subnetted, 2 subnets
B        5.5.5.5 [20/0] via 46.1.1.4, 00:29:14
                 [20/0] via 36.1.1.3, 00:29:14
B        5.5.5.55 [20/0] via 46.1.1.4, 00:29:14
                  [20/0] via 36.1.1.3, 00:29:14
      6.0.0.0/32 is subnetted, 2 subnets
C        6.6.6.6 is directly connected, Loopback0
C        6.6.6.66 is directly connected, Loopback0

R6#show bgp        
BGP table version is 30, local router ID is 6.6.6.6
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *m  5.5.5.5/32       46.1.1.4                               0 1000 500 i
 *>                   36.1.1.3                               0 1000 500 i
 *m  5.5.5.55/32      46.1.1.4                               0 1000 500 i
 *>                   36.1.1.3                               0 1000 500 i
 *>  6.6.6.6/32       0.0.0.0                  0         32768 ?
 *>  6.6.6.66/32      0.0.0.0                  0         32768 ?
R6#
```
## connectivity check
```bash
R5#ping 6.6.6.6 sou 5.5.5.55
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 6.6.6.6, timeout is 2 seconds:
Packet sent with a source address of 5.5.5.55 
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 48/63/80 ms
R5#tra 6.6.6.6 sou 5.5.5.55 
Type escape sequence to abort.
Tracing the route to 6.6.6.6
VRF info: (vrf in name/id, vrf out name/id)
  1 15.1.1.1 52 msec
    25.1.1.2 52 msec
    15.1.1.1 48 msec
  2 46.1.1.4 [MPLS: Label 20 Exp 0] 52 msec
    36.1.1.3 [MPLS: Label 20 Exp 0] 64 msec
    24.1.1.4 [MPLS: Label 20 Exp 0] 76 msec
  3 36.1.1.6 72 msec
    46.1.1.6 76 msec
    36.1.1.6 76 msec
R5#
```