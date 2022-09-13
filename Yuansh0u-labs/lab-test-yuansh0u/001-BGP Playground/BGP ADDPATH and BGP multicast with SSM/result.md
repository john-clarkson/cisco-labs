## R1/R2 advertise loopback100 with 123.1.1.1 anycastIP

### RR perspective
```bash
RR#show bgp 
BGP table version is 7, local router ID is 2.2.2.2
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>i 123.1.1.1/32     1.1.1.1                  0    100      0 i
 * ia                 3.3.3.3                  0    100      0 i
 *>i 123.1.1.2/32     1.1.1.1                  0    100      0 i
 * ia                 3.3.3.3                  0    100      0 i
RR#
```
```bash
RR#show bgp 123.1.1.1
BGP routing table entry for 123.1.1.1/32, version 6
Paths: (2 available, best #1, table default)
  Path advertised to update-groups:
     7          9         
  Refresh Epoch 1
  Local, (Received from a RR-client)
    1.1.1.1 (metric 2) from 1.1.1.1 (1.1.1.1)
      Origin IGP, metric 0, localpref 100, valid, internal, best
      rx pathid: 0x0, tx pathid: 0x0
  Path advertised to update-groups:
     9         
  Refresh Epoch 1
  Local, (Received from a RR-client)
    3.3.3.3 (metric 2) from 3.3.3.3 (3.3.3.3)
      Origin IGP, metric 0, localpref 100, valid, internal, all
      rx pathid: 0x0, tx pathid: 0x1
RR#
```
## Be aware of pathID value.

```bash
router bgp 1
 address-family ipv4
  bgp additional-paths select all
  bgp additional-paths send receive
  neighbor 4.4.4.4 advertise additional-paths all
!!Then RR will send available path to R4

RR#show ip bgp neighbors 4.4.4.4 advertised-routes 
BGP table version is 7, local router ID is 2.2.2.2
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>i 123.1.1.1/32     1.1.1.1                  0    100      0 i
 * ia123.1.1.1/32     3.3.3.3                  0    100      0 i
 *>i 123.1.1.2/32     1.1.1.1                  0    100      0 i
 * ia123.1.1.2/32     3.3.3.3                  0    100      0 i

Total number of prefixes 4 
RR#
```

### R4  <ibgp multi-path is enabled>
```bash
R4#show bgp 
BGP table version is 35, local router ID is 4.4.4.4
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *mia123.1.1.1/32     3.3.3.3                  0    100      0 i
 *>i                  1.1.1.1                  0    100      0 i
 *mia123.1.1.2/32     3.3.3.3                  0    100      0 i
 *>i                  1.1.1.1                  0    100      0 i
R4#
```
# BGP multicast
```bash
R3=source ASN=1, ip pim dr-priority 0
R7=Receiver ASN=2 

interface Loopback77
 ip address 77.77.77.77 255.255.255.255
 ip pim sparse-mode
 ip igmp join-group 232.33.33.33 source 33.33.33.33
 ip igmp version 3
```
### Multicast mode SSM
```bash
R3-anycast-sender#ping 232.33.33.33 sou 33.33.33.33
Type escape sequence to abort.
Sending 1, 100-byte ICMP Echos to 232.33.33.33, timeout is 2 seconds:
Packet sent with a source address of 33.33.33.33 

Reply to request 0 from 67.1.1.7, 136 ms
Reply to request 0 from 77.77.77.77, 176 ms
Reply to request 0 from 67.1.1.7, 172 ms
Reply to request 0 from 77.77.77.77, 140 ms

!!! mtrace <source_IP>
R7#mtrace 33.33.33.33
Type escape sequence to abort.
Mtrace from 33.33.33.33 to 67.1.1.7 via RPF
From source (?) to destination (?)
Querying full reverse path... * switching to hop-by-hop:
 0  67.1.1.7
-1  67.1.1.7 ==> 67.1.1.7 PIM_MT  [33.33.33.33/32]
-2  67.1.1.6 ==> 56.1.1.6 PIM_MT  [33.33.33.33/32]
-3  56.1.1.5 ==> 45.1.1.5 PIM_MT  [33.33.33.33/32]
-4  * * * 45.1.1.4
R7#

!!! 
RR#show ip rpf 33.33.33.33 
RPF information for ? (33.33.33.33)
  RPF interface: FastEthernet1/0
  RPF neighbor: ? (23.1.1.3)
  RPF route/mask: 33.33.33.33/32
  RPF type: multicast (bgp 1)
  Doing distance-preferred lookups across tables
  RPF topology: ipv4 multicast base, originated from ipv4 unicast base
RR#sh ip mroute
RR#sh ip mroute 
!!***
Outgoing interface flags: H - Hardware switched, A - Assert winner
 Timers: Uptime/Expires
 Interface state: Interface, Next-Hop or VCD, State/Mode

(33.33.33.33, 232.33.33.33), 00:14:53/00:02:52, flags: sT
  Incoming interface: FastEthernet1/0, RPF nbr 23.1.1.3, Mbgp
  Outgoing interface list:
    FastEthernet2/0, Forward/Sparse, 00:14:53/00:02:52

(*, 224.0.1.40), 00:35:28/00:02:08, RP 0.0.0.0, flags: DCL
  Incoming interface: Null, RPF nbr 0.0.0.0
  Outgoing interface list:
    FastEthernet0/0, Forward/Sparse, 00:35:28/00:02:08