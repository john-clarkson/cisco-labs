## UK->GERMANY
```py
IDC-CORE#traceroute vrf UK ip 
Target IP address: 2.2.2.254
Source address: 1.1.1.254
Numeric display [n]: 
Resolve AS number in (G)lobal table, (V)RF or(N)one [G]: 
Timeout in seconds [3]: 
Probe count [3]: 
Minimum Time to Live [1]: 
Maximum Time to Live [30]: 
Port Number [33434]: 
Loose, Strict, Record, Timestamp, Verbose[none]: 
Type escape sequence to abort.
Tracing the route to 2.2.2.254

  1 192.168.10.254 48 msec 72 msec 68 msec
  2 169.169.254.2 96 msec 88 msec 108 msec
  3 169.169.1.2 [MPLS: Labels 103/2015 Exp 0] 104 msec 128 msec 124 msec 
  4 169.169.254.6 [MPLS: Label 2015 Exp 0] 120 msec 116 msec 80 msec
  5 169.169.254.5 148 msec 164 msec 116 msec
  6 192.168.20.1 180 msec 116 msec 156 msec
IDC-CORE#

IDC-CORE#traceroute vrf UK IPV6 ?
  WORD  Trace route to destination address or hostname
  <cr>

IDC-CORE#traceroute vrf UK IPV6   

Target IPv6 address: fc00:2:2:2::254
Source address: fc00:1:1:1::254
Insert source routing header? [no]: 
Numeric display? [no]: 
Timeout in seconds [3]: 
Probe count [3]: 
Minimum Time to Live [1]: 
Maximum Time to Live [30]: 
Priority [0]: 
Port Number [0]: 
Type escape sequence to abort.
Tracing the route to FC00:2:2:2::254

  1 FC00:192:168:10::254 84 msec 44 msec 60 msec
  2 FC00:169:169:254A::2 84 msec 56 msec 108 msec
  3 ::FFFF:169.169.2.2 [MPLS: Labels 203/2008 Exp 0] 156 msec 128 msec 96 msec
  4 FC00:169:169:254B::6 [MPLS: Label 2008 Exp 0] 128 msec 128 msec 132 msec
  5 FC00:169:169:254B::5 152 msec 112 msec 96 msec
  6 FC00:192:168:20::1 124 msec 132 msec 144 msec
IDC-CORE#

```
# {UK-->PE_1 --> P1--> PE2-->GERMANY}

```py
SP:
global config
  mpls traffic-eng tunnels

  PE1:
   router ospf 10
     mpls traffic-eng area 0
     mpls traffic-eng router-id loopback 0
     do write
  PE2:
   router ospf 10
     mpls traffic-eng area 0
     mpls traffic-eng router-id loopback 0
     do write
  P1:
   router ospf 10
     mpls traffic-eng area 0
     mpls traffic-eng router-id loopback 0
     do write
  P2:
  router ospf 10
     mpls traffic-eng area 0
     mpls traffic-eng router-id loopback 0
     do write       

interfae level
 mpls traffic-eng tunnels
 ip rsvp bandwidth 75000


P1#sh run | in interface|ip rsvp|mpls traffic 
interface Loopback0
interface FastEthernet0/0
interface FastEthernet0/1
interface FastEthernet1/0
 mpls traffic-eng tunnels
 ip rsvp bandwidth 75000
interface FastEthernet1/1
 mpls traffic-eng tunnels
 ip rsvp bandwidth 75000
interface FastEthernet2/0
 mpls traffic-eng tunnels
 ip rsvp bandwidth 75000
```
```py
 P1#show ip ospf database self-originate 

            OSPF Router with ID (169.169.253.11) (Process ID 10)

                Router Link States (Area 0)

Link ID         ADV Router      Age         Seq#       Checksum Link count
169.169.253.11  169.169.253.11  683         0x80000014 0x00FC5D 7

                Net Link States (Area 0)

Link ID         ADV Router      Age         Seq#       Checksum
169.169.1.2     169.169.253.11  683         0x80000006 0x00EBE7

                Type-10 Opaque Link Area Link States (Area 0)

Link ID         ADV Router      Age         Seq#       Checksum Opaque ID
1.0.0.0         169.169.253.11  1439        0x80000005 0x002154 0       
1.0.0.3         169.169.253.11  186         0x80000005 0x00B1DF 3       
1.0.0.4         169.169.253.11  186         0x80000005 0x006227 4       
1.0.0.5         169.169.253.11  186         0x80000005 0x0085F6 5       
P1# 

P1#show mpls traffic-eng topology 
My_System_id: 169.169.253.11 (ospf 10  area 0)

Signalling error holddown: 10 sec Global Link Generation 21

IGP Id: 169.169.253.1, MPLS TE Id:169.169.253.1 Router Node  (ospf 10  area 0)
      link[0]: Broadcast, DR: 169.169.2.1, nbr_node_id:5, gen:13
          frag_id 4, Intf Address:169.169.2.1
          TE metric:1, IGP metric:1, attribute flags:0x0
          SRLGs: None 
          physical_bw: 100000 (kbps), max_reservable_bw_global: 75000 (kbps)
          max_reservable_bw_sub: 0 (kbps)

                                 Global Pool       Sub Pool
               Total Allocated   Reservable        Reservable
               BW (kbps)         BW (kbps)         BW (kbps)
               ---------------   -----------       ----------
        bw[0]:            0            75000                0
        bw[1]:            0            75000                0
        bw[2]:            0            75000                0
        bw[3]:            0            75000                0
        bw[4]:            0            75000                0
        bw[5]:            0            75000                0
        bw[6]:            0            75000                0
        bw[7]:            0            75000                0

      link[1]: Broadcast, DR: 169.169.1.2, nbr_node_id:1, gen:13
          frag_id 3, Intf Address:169.169.1.1
          TE metric:1, IGP metric:1, attribute flags:0x0
          SRLGs: None 
          physical_bw: 100000 (kbps), max_reservable_bw_global: 75000 (kbps)
          max_reservable_bw_sub: 0 (kbps)
```
```py
PE1 
ip explicit-path name FRR_EXPLICIT_PATH_FROM_PE1_P1_P2_PE2 enable
 next-address 169.169.253.11
 next-address 169.169.253.22
 next-address 169.169.253.2

interface Tunnel9000
 description MPLS-TE_tunnel_FROM_PE1_P1_P2_PE2
 ip unnumbered Loopback0
 shutdown
 tunnel mode mpls traffic-eng
 tunnel destination 169.169.253.2
 tunnel mpls traffic-eng path-option 1 explicit name FRR_EXPLICIT_PATH_FROM_PE1_P1_P2_PE2
 tunnel mpls traffic-eng path-option 2 dynamic
 no shutdown


ip route 169.169.253.2 255.255.255.255 Tunnel9000 name MPLS_TE

PE_1#debug ip rsvp signalling 
PE2

ip explicit-path name FRR_EXPLICIT_PATH_FROM_PE2_P2_P1_PE1 enable
 next-address 169.169.253.22
 next-address 169.169.253.11
 next-address 169.169.253.1
!
!
interface Tunnel9000
 description MPLS-TE_tunnel_FROM_PE2_P2_P1_PE1
 ip unnumbered Loopback0
 tunnel mode mpls traffic-eng
 tunnel destination 169.169.253.1
 tunnel mpls traffic-eng path-selection metric te
 tunnel mpls traffic-eng path-option 1 explicit name FRR_EXPLICIT_PATH_FROM_PE2_P2_P1_PE1
 tunnel mpls traffic-eng path-option 2 dynamic

 !
 no routing dynamic
end

ip route 169.169.253.1 255.255.255.255 Tunnel9000 name MPLS_TE


IDC-CORE#traceroute vrf GERMANY 1.1.1.254 SOU 2.2.2.254

Type escape sequence to abort.
Tracing the route to 1.1.1.254

  1 192.168.20.254 104 msec 76 msec 36 msec
  2 169.169.254.6 212 msec 112 msec 136 msec
  3 169.169.2.6 [MPLS: Labels 210/1009 Exp 0] 240 msec 284 msec 260 msec
  4 169.169.3.9 [MPLS: Labels 109/1009 Exp 0] 272 msec 180 msec 300 msec
  5 169.169.254.2 [MPLS: Label 1009 Exp 0] 236 msec 260 msec 244 msec
  6 169.169.254.1 260 msec 232 msec * 
  7 192.168.10.1 320 msec 320 msec 300 msec
IDC-CORE#PING vrf GERMANY 1.1.1.254 SOU 2.2.2.254 RE 100000

Type escape sequence to abort.
Sending 100000, 100-byte ICMP Echos to 1.1.1.254, timeout is 2 seconds:
Packet sent with a source address of 2.2.2.254 
!!!.!!!!!!!..!!!.!!!!!!!!!!.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!.!!!!!!!!
!!!!!!!!!!!!!!.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!.!!!!.!!!!!!.!!!!!!.
Success rate is 92 percent (127/138), round-trip min/avg/max = 192/293/1036 ms

P2
 interface f2/1
   shutdown


PE_2#show mpls traffic-eng tunnels 

Name: MPLS-TE_tunnel_FROM_PE2_P2_P1_PE... (Tunnel9000) Destination: 169.169.253.1
  Status:
    Admin: up         Oper: up     Path: valid       Signalling: connected
    path option 2, type dynamic (Basis for Setup, path weight 2)
    path option 1, type explicit FRR_EXPLICIT_PATH_FROM_PE2_P2_P1_PE1

IDC-CORE#traceroute vrf GERMANY 1.1.1.254 SOU 2.2.2.254    

Type escape sequence to abort.
Tracing the route to 1.1.1.254

  1 192.168.20.254 64 msec 164 msec 112 msec
  2 169.169.254.6 72 msec *  140 msec
  3 169.169.2.6 [MPLS: Labels 208/1009 Exp 0] 336 msec 208 msec 216 msec
  4 169.169.254.2 [MPLS: Label 1009 Exp 0] 260 msec 184 msec 168 msec
  5 169.169.254.1 260 msec 232 msec 236 msec
  6 192.168.10.1 340 msec 276 msec 304 msec
IDC-CORE#
```

## Frr
```PY 
 PE_1/2
  interface tunnel 9000
    tunnel mpls traffic-eng fast-reroute
```    