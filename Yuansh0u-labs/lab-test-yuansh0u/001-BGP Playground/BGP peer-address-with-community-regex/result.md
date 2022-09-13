
# BGP peer-address LAB

- [BGP peer-address LAB](#bgp-peer-address-lab)
- [BGP peer-address testing topology](#bgp-peer-address-testing-topology)
    - [R5 set "peer-address" BGP policy outbound to R6<SP2-PE>](#r5-set-peer-address-bgp-policy-outbound-to-r6sp2-pe)
    - [Before policy apply: NEXT-HOP=45.1.1.4](#before-policy-apply-next-hop45114)
    - [After policy apply: NEXT-HOP=5.5.5.5](#after-policy-apply-next-hop5555)
    - [R6 set "peer-address" BGP policy inbound from R5<ASBR>](#r6-set-peer-address-bgp-policy-inbound-from-r5asbr)
    - [Before policy apply: NEXT-HOP=45.1.1.4](#before-policy-apply-next-hop45114-1)
    - [After policy apply: NEXT-HOP=5.5.5.5](#after-policy-apply-next-hop5555-1)
- [Note:](#note)
- [BGP community rewrite setup](#bgp-community-rewrite-setup)
  - [Requirements: R1 -> R7](#requirements-r1---r7)
    - [R4 add community outbound configuration](#r4-add-community-outbound-configuration)
    - [R5 Result: show bgp 1.1.1.1](#r5-result-show-bgp-1111)
  - [Requirements: R7 -> R1](#requirements-r7---r1)
    - [R1 Result: show bgp 7.7.7.7](#r1-result-show-bgp-7777)
      - [Before policy apply](#before-policy-apply)
      - [After policy apply](#after-policy-apply)
- [Community-list with regex setup on R5](#community-list-with-regex-setup-on-r5)
# BGP peer-address testing topology
```bash
BGP AFI: UNICAST-IPv4  
    R1-----R2-----R3-----R4------R5------R6-------R7
    CE     PE     RR    ASBR    ASBR     PE       CE
  <65511>   <-----1000---->      <---2000-->    <65511>
```

###  R5 set "peer-address" BGP policy outbound to R6<SP2-PE>
```bash 
 route-map ibgp-peer-address
    set ip next-hop peer-address
!
 router bgp 2000
    neigh 6.6.6.6 route-map ibgp-peer-address out
 do clear bgp ipv4 unicast * soft out
!
```

### Before policy apply: NEXT-HOP=45.1.1.4
```bash
SP2-R6-RR#show bgp 1.1.1.1
BGP routing table entry for 1.1.1.1/32, version 19
Paths: (1 available, no best path)
  Not advertised to any peer
  Refresh Epoch 3
  1000 65511, (received & used)
    45.1.1.4 (inaccessible) from 5.5.5.5 (5.5.5.5)
      Origin IGP, metric 0, localpref 100, valid, internal
      Community: 4293328897
      rx pathid: 0, tx pathid: 0
SP2-R6-RR#
```
### After policy apply: NEXT-HOP=5.5.5.5
```bash
SP2-R6-RR#show bgp 1.1.1.1
BGP routing table entry for 1.1.1.1/32, version 28
Paths: (1 available, best #1, table default)
  Advertised to update-groups:
     2         
  Refresh Epoch 3
  1000 65511, (received & used)
    5.5.5.5 (metric 2) from 5.5.5.5 (5.5.5.5)
      Origin IGP, metric 0, localpref 100, valid, internal, best
      Community: 4293328897
      rx pathid: 0, tx pathid: 0x0
```
### R6 set "peer-address" BGP policy inbound from R5<ASBR> 
```bash
route-map ibgp-peer-address permit 10
 set ip next-hop peer-address
router bgp 2000
 address-family ipv4
  neighbor 5.5.5.5 route-map ibgp-peer-address in
do clear bgp ipv4 unicast * soft in 
```
### Before policy apply: NEXT-HOP=45.1.1.4
```bash
SP2-R6-PE#show bgp 
BGP table version is 16, local router ID is 6.6.6.6
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 * i 1.1.1.1/32       45.1.1.4                 0    100      0 1000 65511 i
 * i 1.1.1.2/32       45.1.1.4                 0    100      0 1000 65511 ?
 * i 1.1.1.3/32       45.1.1.4                 0    100      0 1000 65511 ?
```
### After policy apply: NEXT-HOP=5.5.5.5
```bash
SP2-R6-PE#show bgp 
BGP table version is 25, local router ID is 6.6.6.6
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>i 1.1.1.1/32       5.5.5.5                  0    100      0 1000 65511 i
 *>i 1.1.1.2/32       5.5.5.5                  0    100      0 1000 65511 ?
 *>i 1.1.1.3/32       5.5.5.5                  0    100      0 1000 65511 ?
```
# Note:
- IOS 15.2 BGP IPv4 unicast/vrf_AFT as-override feature is not working for some reason. instead, do "AllowAS-in on R1/7 both sides.
- BGP NEXT-HOP-SELF setting, You can set next-hop-self (on RR-client) outbound to IBGP neighbor to change eBGP prefix next-hop value, but this is not working for RR.
- if you want to let RR in the data-plane, do "neighbor x.x.x.x next-hop-self all" command to modify it.

- Do not use the neighbor next-hop-self command to modify the next hop
attribute for a route reflector when this feature is enabled for a
route reflector client. Using the neighbor next-hop-self command on
the route reflector will modify next hop attributes only for routes
that are learned from eBGP peers and not the intended routes that are
being reflected from the route reflector clients. To modify the next
hop attribute when reflecting a route, use an outbound route map. ref link: https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/iproute_bgp/configuration/15-sy/irg-15-sy-book/irg-int-features.html

# BGP community rewrite setup

- In this lab, R1 and R7 advertise loopback interface as testing endpoints and also with BGP community setting with it, format: ASN:Site-ID,example: R1 community value equal to "65511:1", so when R1 recieves R7's updates, it marks "community: 65511:7", which is R7 and vice versa.

```bash
R1-CE#show bgp 7.7.7.7
BGP routing table entry for 7.7.7.7/32, version 41
Paths: (1 available, best #1, table default)
  Not advertised to any peer
  Refresh Epoch 3
  1000 2000 65511, (received & used)
    12.1.1.2 from 12.1.1.2 (2.2.2.2)
      Origin incomplete, localpref 100, valid, external, best
      Community: 65511:7----------------<R7 community>
      rx pathid: 0, tx pathid: 0x0
R1-CE#

R7#show bgp 1.1.1.1
BGP routing table entry for 1.1.1.1/32, version 11
Paths: (1 available, best #1, table default)
  Not advertised to any peer
  Refresh Epoch 4
  2000 1000 65511, (received & used)
    67.1.1.6 from 67.1.1.6 (6.6.6.6)
      Origin IGP, localpref 100, valid, external, best
      Community: 65511:1----------------<R1 community>
      rx pathid: 0, tx pathid: 0x0
R7#
```

## Requirements: R1 -> R7
- in this case, we want to add transit site community value on ASBR (R4), which SP<TRANSITE SITE> community value is "ASN:ASN", we keep the original community as well.

### R4 add community outbound configuration
```bash
ip community-list standard R1 permit 65511:1

route-map transit-add-community permit 10
 match community R1
 set community 1000:1000 additive
!
 router bgp 1000
 neighbor 45.1.1.5 route-map transit-add-community out
 ```
 ### R5 Result: show bgp 1.1.1.1
 ```bash
 SP2-R5-ASBR#show bgp 1.1.1.1
BGP routing table entry for 1.1.1.1/32, version 29
Paths: (1 available, best #1, table default)
  Advertised to update-groups:
     12        
  Refresh Epoch 1
  1000 65511, (received & used)
    45.1.1.4 from 45.1.1.4 (4.4.4.4)
      Origin IGP, localpref 100, valid, external, best
      Community: 1000:1000 65511:1---------------<>
      rx pathid: 0, tx pathid: 0x0
SP2-R5-ASBR#
```
## Requirements: R7 -> R1
- In this case, we want to strip the original community value from R7; then, we remark community value by setting transit site values, SP2(2000:2000) and SP1（1000：1000），apply this policy inbound on R4.

```bash
ip community-list standard R7-strip-original permit 65511:7
!
route-map R7-strip-original permit 10
 match community R7-strip-original
 set community 1000:1000 2000:2000
 !
 router bgp 1000
 neighbor 45.1.1.5 route-map R7-strip-original in
```
### R1 Result: show bgp 7.7.7.7
#### Before policy apply
```bash
R1-CE#show bgp 7.7.7.7
BGP routing table entry for 7.7.7.7/32, version 41
Paths: (1 available, best #1, table default)
  Not advertised to any peer
  Refresh Epoch 3
  1000 2000 65511, (received & used)
    12.1.1.2 from 12.1.1.2 (2.2.2.2)
      Origin incomplete, localpref 100, valid, external, best
      Community: 65511:7
      rx pathid: 0, tx pathid: 0x0
R1-CE#
```
#### After policy apply
```bash
R1-CE#
R1-CE#show bgp 7.7.7.7
BGP routing table entry for 7.7.7.7/32, version 53
Paths: (1 available, best #1, table default)
  Not advertised to any peer
  Refresh Epoch 3
  1000 2000 65511, (received & used)
    12.1.1.2 from 12.1.1.2 (2.2.2.2)
      Origin incomplete, localpref 100, valid, external, best
      Community: 1000:1000 2000:2000
      rx pathid: 0, tx pathid: 0x0
R1-CE#
```

# Community-list with regex setup on R5
```bash
SP2-R5-ABSR#show bgp 1.1.1.1
BGP routing table entry for 1.1.1.1/32, version 59
Paths: (2 available, best #1, table default)
  Advertised to update-groups:
     12        
  Refresh Epoch 1
  1000 65511, (received-only)
    45.1.1.4 from 45.1.1.4 (4.4.4.4)
      Origin IGP, localpref 100, valid, external
      Community: 1000:1000 65511:1---------<Using regex to match this value>
      rx pathid: 0, tx pathid: 0
SP2-R5-ABSR#
```

```bash
ip community-list expanded FROM-R4 permit 1...:1... 65511:.*
!
route-map FROM-R4-COMMUNITY permit 10
 match community FROM-R4
 set community 2000:2000 1000:1000 65511:1 
!
SP2-R5-ABSR#sh run | sec router bgp
 neighbor 45.1.1.4 route-map FROM-R4-COMMUNITY in
```

```bash 
R7#show bgp 1.1.1.1
BGP routing table entry for 1.1.1.1/32, version 53
Paths: (1 available, best #1, table default)
  Not advertised to any peer
  Refresh Epoch 4
  2000 1000 65511, (received & used)
    67.1.1.6 from 67.1.1.6 (6.6.6.6)
      Origin IGP, localpref 100, valid, external, best
      Community: 1000:1000 2000:2000 65511:1
      rx pathid: 0, tx pathid: 0x0 
```      