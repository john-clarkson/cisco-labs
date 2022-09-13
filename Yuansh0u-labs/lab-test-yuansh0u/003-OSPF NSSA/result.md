## Turn off nssa 75 election for OSPF OE2 ECMP

             +-- A2 --R1---A0---R2---A1-NSSA----+
             |        |                         |
        <lo0>R6       A0                        R4<lo0>
             |        |                         |
             +-- A2 --R5---A0---R3---A1-NSSA----+

- R2/R3(ABR) translate type7 to type 5 both as the same time.
```py
 router ospf 1
    area 1 nssa translate type7 always suppress-fa

ospf database external LSA check
R2#sh ip ospf database external 4.4.4.4

            OSPF Router with ID (2.2.2.2) (Process ID 1)

                Type-5 AS External Link States

  LS age: 439
  Options: (No TOS-capability, DC, Upward)
  LS Type: AS External Link
  Link State ID: 4.4.4.4 (External Network Number )
  Advertising Router: 2.2.2.2
  LS Seq Number: 80000001
  Checksum: 0xF295
  Length: 36
  Network Mask: /32
        Metric Type: 2 (Larger than any link state path)
        MTID: 0 
        Metric: 20 
        Forward Address: 0.0.0.0
        External Route Tag: 0
  LS age: 514
  Options: (No TOS-capability, DC, Upward)
  LS Type: AS External Link
  Link State ID: 4.4.4.4 (External Network Number )
  Advertising Router: 3.3.3.3
  LS Seq Number: 80000002
  Checksum: 0xD2B0
  Length: 36
  Network Mask: /32
        Metric Type: 2 (Larger than any link state path)
        MTID: 0 
        Metric: 20 
        Forward Address: 0.0.0.0
        External Route Tag: 0
```
```py
R3#show ip os database external 4.4.4.4

            OSPF Router with ID (3.3.3.3) (Process ID 1)

                Type-5 AS External Link States

  LS age: 467
  Options: (No TOS-capability, DC, Upward)
  LS Type: AS External Link
  Link State ID: 4.4.4.4 (External Network Number )
  Advertising Router: 2.2.2.2
  LS Seq Number: 80000001
  Checksum: 0xF295
  Length: 36
  Network Mask: /32
        Metric Type: 2 (Larger than any link state path)
        MTID: 0 
        Metric: 20 
        Forward Address: 0.0.0.0
        External Route Tag: 0

  LS age: 558
  Options: (No TOS-capability, DC, Upward)
  LS Type: AS External Link
  Link State ID: 4.4.4.4 (External Network Number )
  Advertising Router: 3.3.3.3
  LS Seq Number: 80000002
  Checksum: 0xD2B0
  Length: 36
  Network Mask: /32
        Metric Type: 2 (Larger than any link state path)
        MTID: 0 
        Metric: 20 
        Forward Address: 0.0.0.0
        External Route Tag: 0

R3#  
```
```bash

R6#show ip os da external 

            OSPF Router with ID (6.6.6.6) (Process ID 1)

                Type-5 AS External Link States

  Routing Bit Set on this LSA in topology Base with MTID 0
  LS age: 510
  Options: (No TOS-capability, DC, Upward)
  LS Type: AS External Link
  Link State ID: 4.4.4.4 (External Network Number )
  Advertising Router: 2.2.2.2
  LS Seq Number: 80000001
  Checksum: 0xF295
  Length: 36
  Network Mask: /32
        Metric Type: 2 (Larger than any link state path)
        MTID: 0 
        Metric: 20 
        Forward Address: 0.0.0.0
        External Route Tag: 0

  Routing Bit Set on this LSA in topology Base with MTID 0
  LS age: 593
  Options: (No TOS-capability, DC, Upward)
  LS Type: AS External Link
  Link State ID: 4.4.4.4 (External Network Number )
  Advertising Router: 3.3.3.3
  LS Seq Number: 80000002
  Checksum: 0xD2B0
  Length: 36
  Network Mask: /32
        Metric Type: 2 (Larger than any link state path)
        MTID: 0 
        Metric: 20 
        Forward Address: 0.0.0.0
        External Route Tag: 0


R6#sh ip route 4.4.4.4
Routing entry for 4.4.4.4/32
  Known via "ospf 1", distance 110, metric 20, type extern 2, forward metric 2
  Last update from 16.1.1.1 on FastEthernet1/1, 00:09:02 ago
  Routing Descriptor Blocks:
  * 56.1.1.5, from 3.3.3.3, 00:12:17 ago, via FastEthernet1/0
      Route metric is 20, traffic share count is 1
    16.1.1.1, from 2.2.2.2, 00:09:02 ago, via FastEthernet1/1
      Route metric is 20, traffic share count is 1
R6#

R6#sh ip cef 4.4.4.4
4.4.4.4/32
  nexthop 16.1.1.1 FastEthernet1/1
  nexthop 56.1.1.5 FastEthernet1/0
R6#

R4# sh ip cef 6.6.6.6
6.6.6.6/32
  nexthop 24.1.1.2 FastEthernet1/0
  nexthop 34.1.1.3 FastEthernet1/1
R4#


R4#sh ip ospf database summary 6.6.6.6

            OSPF Router with ID (4.4.4.4) (Process ID 1)

                Summary Net Link States (Area 1)

  Routing Bit Set on this LSA in topology Base with MTID 0
  LS age: 755
  Options: (No TOS-capability, DC, Upward)
  LS Type: Summary Links(Network)
  Link State ID: 6.6.6.6 (summary Network Number)
  Advertising Router: 2.2.2.2
  LS Seq Number: 80000001
  Checksum: 0xFB18
  Length: 28
  Network Mask: /32
        MTID: 0         Metric: 3 

  Routing Bit Set on this LSA in topology Base with MTID 0
  LS age: 749
  Options: (No TOS-capability, DC, Upward)
  LS Type: Summary Links(Network)
  Link State ID: 6.6.6.6 (summary Network Number)
  Advertising Router: 3.3.3.3
  LS Seq Number: 80000002
  Checksum: 0xDB33
  Length: 28
  Network Mask: /32
        MTID: 0         Metric: 3 

```
# virtual-link
```py
R1-R5

R1
router ospf 1
 router-id 1.1.1.1
 area 2 virtual-link 5.5.5.5
R5
router ospf 1
 router-id 5.5.5.5
 area 2 virtual-link 1.1.1.1


R1#sh ip os virtual
Virtual Link OSPF_VL0 to router 5.5.5.5 is up
  Run as demand circuit
  DoNotAge LSA allowed.
  Transit area 2, via interface FastEthernet1/1
 Topology-MTID    Cost    Disabled     Shutdown      Topology Name
        0           2         no          no            Base
  Transmit Delay is 1 sec, State POINT_TO_POINT,
  Timer intervals configured, Hello 10, Dead 40, Wait 40, Retransmit 5
    Hello due in 00:00:00
    Adjacency State FULL (Hello suppressed)
    Index 2/3, retransmission queue length 0, number of retransmission 0
    First 0x0(0)/0x0(0) Next 0x0(0)/0x0(0)
    Last retransmission scan length is 0, maximum is 0
    Last retransmission scan time is 0 msec, maximum is 0 msec
R1#

R5#show ip ospf virtual-links 
Virtual Link OSPF_VL0 to router 1.1.1.1 is up
  Run as demand circuit
  DoNotAge LSA allowed.
  Transit area 2, via interface FastEthernet1/0
 Topology-MTID    Cost    Disabled     Shutdown      Topology Name
        0           2         no          no            Base
  Transmit Delay is 1 sec, State POINT_TO_POINT,
  Timer intervals configured, Hello 10, Dead 40, Wait 40, Retransmit 5
    Hello due in 00:00:03
    Adjacency State FULL (Hello suppressed)
    Index 2/3, retransmission queue length 0, number of retransmission 0
    First 0x0(0)/0x0(0) Next 0x0(0)/0x0(0)
    Last retransmission scan length is 0, maximum is 0
    Last retransmission scan time is 0 msec, maximum is 0 msec
R5#


R1#sh ip os database summary 3.3.3.3

            OSPF Router with ID (1.1.1.1) (Process ID 1)

                Summary Net Link States (Area 0)

  Routing Bit Set on this LSA in topology Base with MTID 0
  LS age: 64 (DoNotAge)
  Options: (No TOS-capability, DC, Upward)
  LS Type: Summary Links(Network)
  Link State ID: 3.3.3.3 (summary Network Number)
  Advertising Router: 3.3.3.3
  LS Seq Number: 80000001
  Checksum: 0xAE75
  Length: 28
  Network Mask: /32
        MTID: 0         Metric: 1 


                Summary Net Link States (Area 2)

  LS age: 2 (DoNotAge)
  Options: (No TOS-capability, DC, Upward)
  LS Type: Summary Links(Network)
  Link State ID: 3.3.3.3 (summary Network Number)
  Advertising Router: 5.5.5.5
  LS Seq Number: 80000001
  Checksum: 0x7C9E
  Length: 28
  Network Mask: /32
        MTID: 0         Metric: 2 

R1#

R5#sh ip ospf da summary 2.2.2.2

            OSPF Router with ID (5.5.5.5) (Process ID 1)

                Summary Net Link States (Area 0)

  Routing Bit Set on this LSA in topology Base with MTID 0
  LS age: 72 (DoNotAge)
  Options: (No TOS-capability, DC, Upward)
  LS Type: Summary Links(Network)
  Link State ID: 2.2.2.2 (summary Network Number)
  Advertising Router: 2.2.2.2
  LS Seq Number: 80000001
  Checksum: 0xFA31
  Length: 28
  Network Mask: /32
        MTID: 0         Metric: 1 


                Summary Net Link States (Area 2)

  LS age: 2 (DoNotAge)
  Options: (No TOS-capability, DC, Upward)
  LS Type: Summary Links(Network)
  Link State ID: 2.2.2.2 (summary Network Number)
  Advertising Router: 1.1.1.1
  LS Seq Number: 80000001
  Checksum: 0x230C
  Length: 28
  Network Mask: /32
        MTID: 0         Metric: 2 

R5#



```
```bash
R1#sh ip route ospf
Gateway of last resort is not set

      2.0.0.0/32 is subnetted, 1 subnets
O IA     2.2.2.2 [110/2] via 12.1.1.2, 00:10:31, FastEthernet0/0
      3.0.0.0/32 is subnetted, 1 subnets
O IA     3.3.3.3 [110/4] via 16.1.1.6, 00:09:15, FastEthernet1/1

R5#sh ip route ospf
Gateway of last resort is not set

      1.0.0.0/32 is subnetted, 1 subnets
O        1.1.1.1 [110/3] via 56.1.1.6, 00:09:16, FastEthernet1/0
      2.0.0.0/32 is subnetted, 1 subnets
O IA     2.2.2.2 [110/4] via 56.1.1.6, 00:09:16, FastEthernet1/0
      3.0.0.0/32 is subnetted, 1 subnets
O IA     3.3.3.3 [110/2] via 35.1.1.3, 00:10:24, FastEthernet2/1
```