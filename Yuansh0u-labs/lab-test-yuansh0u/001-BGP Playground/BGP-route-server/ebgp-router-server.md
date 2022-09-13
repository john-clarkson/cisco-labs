# BGP Router-server lab

- R6=route-server
```bash
R6#show bgp 
BGP table version is 8, local router ID is 6.6.6.6
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  1.1.1.1/32       169.254.1.1              0             0 1 i
 *>  2.2.2.2/32       169.254.1.2              0             0 2 i
 *>  3.3.3.3/32       169.254.1.3              0             0 3 i
 *>  4.4.4.4/32       169.254.1.4              0             0 4 i
 *>  6.6.6.6/32       0.0.0.0                  0         32768 i
R6#
```


- R1=CLIENT= ios 15.2 bug??? can not install route-server updates...
https://bst.cloudapps.cisco.com/bugsearch/bug/CSCus01544/?rfs=iqvred

```bash
R1#
*Oct 14 13:44:00.647: %BGP-6-MSGDUMP_LIMIT: unsupported or mal-formatted message received from 169.254.1.6: 
FFFF FFFF FFFF FFFF FFFF FFFF FFFF FFFF 0031 0200 0000 1540 0101 0040 0200 4003 
04A9 FE01 0680 0404 0000 0000 2006 0606 06
*Oct 14 13:44:00.651: %BGP-6-MALFORMEDATTR: Malformed attribute in (BGP(0) Prefixes: 6.6.6.6/32 ) received from 169.254.1.6, 


R1#show bgp 
BGP table version is 14, local router ID is 1.1.1.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  1.1.1.1/32       0.0.0.0                  0         32768 i
 *>  2.2.2.2/32       169.254.1.2              0             0 2 i
 *>  3.3.3.3/32       169.254.1.3              0             0 3 i
 *>  4.4.4.4/32       169.254.1.4              0             0 4 i
R1#

r3-r5 enable ebgp
r2-r7 enable ebgp


R6#show bgp 
BGP table version is 8, local router ID is 6.6.6.6
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *   1.1.1.1/32       169.254.1.3                            0 3 1 i
 *                    169.254.1.2                            0 2 1 i
 *>                   169.254.1.1              0             0 1 i
 *   2.2.2.2/32       169.254.1.3                            0 3 2 i
 *>                   169.254.1.2              0             0 2 i
 *   3.3.3.3/32       169.254.1.2                            0 2 3 i
 *>                   169.254.1.3              0             0 3 i
 *   4.4.4.4/32       169.254.1.3                            0 3 4 i
 *                    169.254.1.2                            0 2 4 i
 *>                   169.254.1.4              0             0 4 i
 *   5.5.5.5/32       169.254.1.2                            0 2 3 5 i
 *>                   169.254.1.3                            0 3 5 i
 *>  6.6.6.6/32       0.0.0.0                  0         32768 i
 *   7.7.7.7/32       169.254.1.3                            0 3 2 7 i
 *>                   169.254.1.2                            0 2 7 i
R6#


R1#show bgp label
   Network          Next Hop      In label/Out label
   1.1.1.1/32       0.0.0.0         imp-null/nolabel
   2.2.2.2/32       169.254.1.2     nolabel/imp-null
   3.3.3.3/32       169.254.1.3     nolabel/imp-null
   4.4.4.4/32       169.254.1.4     nolabel/imp-null
   5.5.5.5/32       169.254.1.3     nolabel/16
   7.7.7.7/32       169.254.1.2     nolabel/16




R5#ping vrf a 10.0.0.1 sou lo1
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 10.0.0.1, timeout is 2 seconds:
Packet sent with a source address of 10.0.0.5 
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 52/67/76 ms
R5#trac vrf a 10.0.0.1 sou lo1
Type escape sequence to abort.
Tracing the route to 10.0.0.1
VRF info: (vrf in name/id, vrf out name/id)
  1 35.1.1.3 [MPLS: Labels 33/18 Exp 0] 92 msec 80 msec 48 msec
  2 169.254.1.6 [AS 1] [MPLS: Label 18 Exp 0] 76 msec 72 msec 72 msec
  3 10.0.0.1 72 msec 72 msec 52 msec



as-path in out section

R5#sh run | sec route-map
route-map aspathin permit 10
 set as-path prepend 1 2 3 4
route-map aspathout permit 10
 set as-path prepend 4 3 2 1

router bgp 5
 bgp router-id 5.5.5.5
 bgp log-neighbor-changes
 no bgp default ipv4-unicast
 neighbor 35.1.1.3 remote-as 3
 neighbor 169.254.1.6 remote-as 6
 neighbor 169.254.1.6 ebgp-multihop 255
 neighbor 169.254.1.6 update-source Loopback0
 !
 address-family ipv4
  network 5.5.5.5 mask 255.255.255.255
  redistribute connected
  neighbor 35.1.1.3 activate
  neighbor 35.1.1.3 route-map aspathin in
  neighbor 35.1.1.3 route-map aspathout out
  neighbor 35.1.1.3 send-label
 exit-address-family

 R5#show bgp
BGP table version is 12, local router ID is 5.5.5.5
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  1.1.1.1/32       35.1.1.3                               0 1 2 3 4 3 1 i
 *>  2.2.2.2/32       35.1.1.3                               0 1 2 3 4 3 2 i
 *>  3.3.3.3/32       35.1.1.3                 0             0 1 2 3 4 3 i
 *>  4.4.4.4/32       35.1.1.3                               0 1 2 3 4 3 4 i
 *>  5.5.5.5/32       0.0.0.0                  0         32768 i
 *>  7.7.7.7/32       35.1.1.3                               0 1 2 3 4 3 2 7 i
 *>  27.1.1.0/24      35.1.1.3                               0 1 2 3 4 3 2 ?
 *>  27.1.1.7/32      35.1.1.3                               0 1 2 3 4 3 2 ?
 *>  35.1.1.0/24      0.0.0.0                  0         32768 ?
 *>  35.1.1.3/32      0.0.0.0                  0         32768 ?
 *>  169.254.1.6/32   35.1.1.3                               0 1 2 3 4 3 1 ?
R5#


R3#sh run | sec router bgp
router bgp 3
 bgp router-id 3.3.3.3
 no bgp enforce-first-as
 bgp log-neighbor-changes
 no bgp default ipv4-unicast
 neighbor 35.1.1.5 remote-as 5
 neighbor 169.254.1.6 remote-as 6
 !
 address-family ipv4
  network 3.3.3.3 mask 255.255.255.255
  neighbor 35.1.1.5 activate
  neighbor 35.1.1.5 allowas-in
  neighbor 35.1.1.5 send-label
  neighbor 169.254.1.6 activate
  neighbor 169.254.1.6 send-label
 exit-address-family
 

R3#show bgp 
BGP table version is 40, local router ID is 3.3.3.3
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  1.1.1.1/32       169.254.1.1              0             0 1 i
 *>  2.2.2.2/32       169.254.1.2              0             0 2 i
 *>  3.3.3.3/32       0.0.0.0                  0         32768 i
 *>  4.4.4.4/32       169.254.1.4              0             0 4 i
 *>  5.5.5.5/32       35.1.1.5                 0             0 5 4 3 2 1 i
 *>  7.7.7.7/32       169.254.1.2              0             0 2 7 i
 *>  27.1.1.0/24      169.254.1.2              0             0 2 ?
 *>  27.1.1.7/32      169.254.1.2              0             0 2 ?
 r>  35.1.1.0/24      35.1.1.5                 0             0 5 4 3 2 1 ?
 r>  35.1.1.3/32      35.1.1.5                 0             0 5 4 3 2 1 ?
 r>  169.254.1.6/32   169.254.1.1              0             0 1 ?
R3#




