# HSRP/VRRP BGP NEXT-HOP Active-standby Lab
## Lab env description
- R1-R4 = same L2 domain, IPs: 100.64.1.1/2/3/4
- R1-R2 = HSRP group 12 VIP 100.64.1.254
- R3-R4 = HSRP group 34 VIP 100.64.1.253
- R3-R4 = VRRP 34 VIP 100.64.1.252

- R1/R3 = HSRP/VRRP ACTIVE/MASTER

# R5 = VRF-aware client
  ## R1-R5 R2-R5 
  - VRF 12 = R5-loopback0 5.5.5.12
  ## R3-R5 R4-R5 
  - VRF 34 = R5-loopback0 5.5.5.34
## R1-R2->R5 HSRP group 125 as GW
- VIP 169.254.125.254 
## R3-R4->R5 HSRP group 345 as GW
- VIP 169.254.34.254
# R1/R2 HSRP/VRRP configuration
```bash
! R1
interface FastEthernet0/0
 ip address 100.64.1.1 255.255.255.0
 standby version 2
 standby 12 ip 100.64.1.254
 standby 12 priority 101
 standby 12 preempt
 standby 12 mac-address 1212.1212.1212
! R2
 interface FastEthernet0/0
 ip address 100.64.1.2 255.255.255.0
 standby version 2
 standby 12 ip 100.64.1.254
 standby 12 priority 90
 standby 12 preempt
 standby 12 mac-address 1212.1212.1212
```
# R3/R4 HSRP/VRRP configuration
```bash
! R3
interface FastEthernet0/0
 ip address 100.64.1.3 255.255.255.0
 standby version 2
 standby 34 ip 100.64.1.253
 standby 34 priority 101
 standby 34 preempt
 standby 34 mac-address 3434.3434.3434
 duplex full
 vrrp 34 ip 100.64.1.252
 vrrp 34 priority 101
! R4
 interface FastEthernet0/0
 ip address 100.64.1.4 255.255.255.0
 standby version 2
 standby 34 ip 100.64.1.253
 standby 34 priority 90
 standby 34 preempt
 standby 34 mac-address 3434.3434.3434
 duplex full
 vrrp 34 ip 100.64.1.252
 vrrp 34 priority 90
```
# BGP Next-hop value modify policy
```bash
route-map nhp permit 10
 set ip next-hop 100.64.1.253 <up-layer HSRP/VRRP VIP>
router bgp X
 neighbor (ebgp-peer) route-map nhp in
 neighbor (ebgp-peer) route-map nhp in
```

### R1 R3 BGP configuration
```bash
router bgp 12
 bgp log-neighbor-changes
 network 1.1.1.1 mask 255.255.255.255
 network 5.5.5.12 mask 255.255.255.255
 neighbor 100.64.1.2 remote-as 12
 neighbor 100.64.1.2 next-hop-self
 neighbor 100.64.1.2 soft-reconfiguration inbound
 neighbor 100.64.1.3 remote-as 34
 neighbor 100.64.1.3 soft-reconfiguration inbound
 neighbor 100.64.1.3 route-map nhp in
 neighbor 100.64.1.3 filter-list 1 out
 neighbor 100.64.1.4 remote-as 34
 neighbor 100.64.1.4 soft-reconfiguration inbound
 neighbor 100.64.1.4 route-map nhp in
 neighbor 100.64.1.4 filter-list 1 out
```
```bash
router bgp 34
 bgp log-neighbor-changes
 network 3.3.3.3 mask 255.255.255.255
 network 5.5.5.34 mask 255.255.255.255
 neighbor 100.64.1.1 remote-as 12
 neighbor 100.64.1.1 soft-reconfiguration inbound
 neighbor 100.64.1.1 route-map nhp in
 neighbor 100.64.1.1 filter-list 1 out
 neighbor 100.64.1.2 remote-as 12
 neighbor 100.64.1.2 soft-reconfiguration inbound
 neighbor 100.64.1.2 route-map nhp in
 neighbor 100.64.1.2 filter-list 1 out
 neighbor 100.64.1.4 remote-as 34
 neighbor 100.64.1.4 next-hop-self
 neighbor 100.64.1.4 soft-reconfiguration inbound
 ```
# BGP best route verfication 
- even BGP path-selection is working for 5.5.5.34 (oldest-route from eBGP), it chooses R4 as best-path, but in this case, we change inbound BGP NLRI update-source (next-hop-value) to HSRPvip(100.64.1.253<R3-R4>)
```bash
R1#show bgp 5.5.5.34
BGP routing table entry for 5.5.5.34/32, version 19
Paths: (3 available, best #2, table default)
  Advertised to update-groups:
     8         
  Refresh Epoch 2
  34, (received & used)
    100.64.1.253 from 100.64.1.3 (3.3.3.3)
      Origin IGP, metric 0, localpref 100, valid, external
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 2
  34, (received & used)
    100.64.1.253 from 100.64.1.4 (4.4.4.4)  ---> pay attention here
      Origin IGP, metric 0, localpref 100, valid, external, best
      rx pathid: 0, tx pathid: 0x0
  Refresh Epoch 1
  34, (received & used)
    100.64.1.2 from 100.64.1.2 (2.2.2.2)
      Origin IGP, metric 0, localpref 100, valid, internal
      rx pathid: 0, tx pathid: 0
R1#
```

- So when issuing the (show bgp) command, we will see the next-hop-value is not R4<100.64.1.4>, instead of 100.64.1.253. this means, the BGP path-selection is overriden by Next-hop-value inbound policy.
```bash
R1#show bgp         
BGP table version is 20, local router ID is 1.1.1.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 <****> 
 *   5.5.5.34/32      100.64.1.253  (R3)            0             0 34 i
 *>                   100.64.1.253  (R4)           0             0 34 i
 * i                  100.64.1.2    (IBGP-R2)          0    100      0 34 i
R1#
```
- Then let's trace 5.5.5.34 from R5 VRF12 table cross the infra
```bash
R5#tr vrf 12 5.5.5.34 sou 5.5.5.12  
Type escape sequence to abort.
Tracing the route to 5.5.5.34
VRF info: (vrf in name/id, vrf out name/id)
  1 169.254.125.1 56 msec 28 msec 48 msec  --->R1
  2 100.64.1.3 48 msec 52 msec 48 msec     --->R3
  3 169.254.34.5 100 msec 76 msec 100 msec --->R5 VRF 34 TABLE
R5#  
R5#PING vrf 12 5.5.5.34 sou 5.5.5.12  
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 5.5.5.34, timeout is 2 seconds:
Packet sent with a source address of 5.5.5.12 
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 108/138/152 ms
R5#
```





