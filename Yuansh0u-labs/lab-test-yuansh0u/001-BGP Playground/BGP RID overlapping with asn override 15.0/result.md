# BGP RID Overlapping, ASN override test bed IOS 15.0
- BGP IPv4-unicast/VPNv4 AS-override is not working
## Topology
![picture 3](../../images/04ce5de40362fc8149384800973a393dfbecaf31e983ad7a178ca0699b4d471e.png)  
### R2/R4 RID overlap configuration

```bash
router bgp 1000
 bgp router-id 24.1.1.24
```
- Result: R2/R4 will drop the updates coming from R3(RR),the reason why: RID was modified by RR as Orginated-ID, I saw my own value, then drop it, it's RR loop-prevention rule.
```bash
R2#debug bgp ipv4 unicast updates 
BGP updates debugging is on for address family: IPv4 Unicast
R2#
*Sep 19 11:56:02.367: BGP: 3.3.3.3 Local router is the Originator; Discard update
*Sep 19 11:56:02.371: BGP(0): 3.3.3.3 rcv UPDATE w/ attr: nexthop 4.4.4.4, origin ?, localpref 100, metric 0, originator 24.1.1.24, clusterlist 3.3.3.3, merged path 65511, AS_PATH , community , extended community , SSA attribute 
*Sep 19 11:56:02.375: BGPSSA ssacount is 0
*Sep 19 11:56:02.375: BGP(0): 3.3.3.3 rcv UPDATE about 5.5.5.5/32 -- DENIED due to: ORIGINATOR is us;
*Sep 19 11:56:02.379: BGP(0): 3.3.3.3 rcv UPDATE about 56.1.1.0/24 -- DENIED due to: ORIGINATOR is us;
*Sep 19 11:56:02.379: BGP: 3.3.3.3 Local router is the Originator; Discard update
R2#
*Sep 19 11:56:02.383: BGP(0): 3.3.3.3 rcv UPDATE w/ attr: nexthop 3.3.3.3, origin ?, localpref 100, metric 0, originator 24.1.1.24, clusterlist 3.3.3.3, merged path 65511, AS_PATH , community , extended community , SSA attribute 
*Sep 19 11:56:02.387: BGPSSA ssacount is 0
*Sep 19 11:56:02.387: BGP(0): 3.3.3.3 rcv UPDATE about 1.1.1.1/32 -- DENIED due to: ORIGINATOR is us;
R2#
*Sep 19 11:56:10.383: BGP: TX Member message pool below threshold (0 < 0).
R2#
```
- set R2/R4 BGP RID to unique value (eg: loopback0)
```bash
router bgp 1000
 bgp router-id <loopback0>
```

# BGP Orginal-code setup
### R5 advertise OSPF-N2 route（learned via R6's loopback0） as BGP updates (redistribution), the default orginal-code is incomplete, we create a policy called original-code-IGP, then apply to outbound direction to R4(PE)

**R5 configuration** 
```bash
route-map origin-code-IGP permit 10
 set origin igp
!
router bgp 65511
 redistribute ospf 1 match internal nssa-external 2
 neighbor 45.1.1.4 route-map origin-code-IGP out
```

```BASH
R5#show bgp 6.6.6.6
BGP routing table entry for 6.6.6.6/32, version 6
Paths: (1 available, best #1, table default)
  Advertised to update-groups:
     3         
  Local
    56.1.1.6 from 0.0.0.0 (5.5.5.5)
      Origin incomplete, metric 20, localpref 100, weight 32768, valid, sourced, best
R5#
```
**R4 's perspective**

- Before policy applyed
```bash
R4#show bgp 6.6.6.6
BGP routing table entry for 6.6.6.6/32, version 13
Paths: (1 available, best #1, table default)
  Advertised to update-groups:
     4         
  65511
    45.1.1.5 from 45.1.1.5 (5.5.5.5)
      Origin incomplete, metric 20, localpref 100, valid, external, best
```
- After policy applyed
```bash      
R4#show bgp 6.6.6.6
BGP routing table entry for 6.6.6.6/32, version 14
Paths: (1 available, best #1, table default)
  Advertised to update-groups:
     4         
  65511
    45.1.1.5 from 45.1.1.5 (5.5.5.5)
      Origin IGP, metric 20, localpref 100, valid, external, best
R4#
```