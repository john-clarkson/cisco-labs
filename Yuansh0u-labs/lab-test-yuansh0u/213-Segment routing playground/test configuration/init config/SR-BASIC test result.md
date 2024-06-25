# initial information
```bash
XR-PE1   net 49.0001.0000.0011.00
XE-PE2   net 49.0001.0000.0022.00
XR-P1    net 49.0001.0000.0001.00
XR-P2    net 49.0001.0000.0002.00
XR-P3    net 49.0001.0000.0003.00
XE-P4-RR net 49.0001.0000.0044.00
```
- SR prefix SID is independently assigned!
- for this lab design, follow the list and assign them!
```bash
XR-PE1 11  
XE-PE2 22  
XR-P1 1
XR-P2 2 
XR-P3 3
XE-P4-RR 4
```
```bash
# IOS XE 
# XE-PE2
segment-routing mpls
 !
 connected-prefix-sid-map
  address-family ipv4
   100.64.22.2/32 22 range 1
  exit-address-family
```
```bash
##IOS XR
##XR-P3
router isis djohn
interface Loopback0
address-family ipv4 unicast
prefix-sid index 3
commit 
```
```bash
####traffic flow
<CE1>-<XR-PE1>-<XR-P1>-<XE-PE2>-<CE2>
CE1#traceroute 2.2.2.2 source 1.1.1.1
Type escape sequence to abort.
Tracing the route to 2.2.2.2
VRF info: (vrf in name/id, vrf out name/id)
  1 169.254.100.254 20 msec 20 msec 13 msec 
  2 169.254.111.11 [MPLS: Labels 16022/16 Exp 0] 63 msec 134 msec 42 msec
  3 169.254.200.254 [MPLS: Label 16 Exp 0] 47 msec 43 msec 32 msec
  4 169.254.200.1 42 msec 63 msec * 
CE1#
```
```bash
##BGP VPNV4 LABEL ASSIGN
RP/0/0/CPU0:XR-PE1#show bgp vpnv4 unicast labels 
Thu Nov 16 16:52:00.081 UTC
BGP router identifier 100.64.11.1, local AS number 9000
BGP generic scan interval 60 secs
Non-stop routing is enabled
BGP table state: Active
Table ID: 0x0   RD version: 0
BGP main routing table version 45
BGP NSR Initial initsync version 1 (Reached)
BGP NSR/ISSU Sync-Group versions 0/0
BGP scan interval 60 secs

Status codes: s suppressed, d damped, h history, * valid, > best
              i - internal, r RIB-failure, S stale, N Nexthop-discard
Origin codes: i - IGP, e - EGP, ? - incomplete
   Network            Next Hop        Rcvd Label      Local Label
Route Distinguisher: 1:1 (default for vrf A)
*> 1.1.1.1/32         169.254.100.1   nolabel         24002           
*>i2.2.2.2/32         100.64.22.2     16              nolabel         
```
```bash
Processed 2 prefixes, 2 paths
RP/0/0/CPU0:XR-PE1#

XE-PE2#show bgp vpnv4 unicast all labels 
   Network          Next Hop      In label/Out label
Route Distinguisher: 1:1 (A)
   1.1.1.1/32       100.64.11.1     nolabel/24002
   2.2.2.2/32       169.254.200.1   16/nolabel

XE-PE2#
```
```bash
SR SRGB
 RP/0/0/CPU0:XR-PE1#show mpls label range 
Thu Nov 16 16:53:22.426 UTC
Range for dynamic labels: Min/Max: 24000/1048575
RP/0/0/CPU0:XR-PE1#show mpls label table det
Thu Nov 16 16:53:37.555 UTC
Table Label   Owner                           State  Rewrite
----- ------- ------------------------------- ------ -------
0     0       LSD(A)                          InUse  Yes
0     1       LSD(A)                          InUse  Yes
0     2       LSD(A)                          InUse  Yes
0     13      LSD(A)                          InUse  Yes
0     16000   ISIS(A):djohn                    InUse  No
  (Lbl-blk SRGB, vers:0, (start_label=16000, size=8000)
0     24000   ISIS(A):djohn                    InUse  Yes
  (SR Adj Segment IPv4, vers:0, index=1, type=0, intf=Gi0/0/0/0.113, nh=169.254.113.3)
0     24001   ISIS(A):djohn                    InUse  Yes
  (SR Adj Segment IPv4, vers:0, index=3, type=0, intf=Gi0/0/0/0.113, nh=169.254.113.3)
0     24002   BGP-VPNv4(A):bgp-default        InUse  No
  (IPv4, vers:0, 'A':4U, 1.1.1.1/32)
0     24003   ISIS(A):djohn                    InUse  Yes
  (SR Adj Segment IPv4, vers:0, index=1, type=0, intf=Gi0/0/0/0.111, nh=169.254.111.11)
0     24004   ISIS(A):djohn                    InUse  Yes
  (SR Adj Segment IPv4, vers:0, index=3, type=0, intf=Gi0/0/0/0.111, nh=169.254.111.11)
RP/0/0/CPU0:XR-PE1# 
```
```bash
## ISIS DB CHECK
XE-PE2#show isis database level-2 

Tag djohn:
IS-IS Level-2 Link State Database:
LSPID                 LSP Seq Num  LSP Checksum  LSP Holdtime      ATT/P/OL
XR-P1.00-00           0x000000BA   0x6D36        490               0/0/0
XR-P1.01-00           0x00000001   0xC6DB        489               0/0/0
XR-P1.09-00           0x00000013   0xE195        1057              0/0/0
XR-P2.00-00           0x00000082   0xADA8        491               0/0/0
XR-P2.01-00           0x00000071   0x85BA        418               0/0/0
XR-P2.03-00           0x00000072   0x4ECD        408               0/0/0
XR-P3.00-00           0x00000084   0x1069        1110              0/0/0
XR-P3.01-00           0x00000073   0xE348        1105              0/0/0
XR-P3.05-00           0x00000073   0x66D1        1172              0/0/0
XR-PE1.00-00          0x00000085   0x9997        491               0/0/0
XE-PE2.00-00        * 0x00000096   0x4E10        501               0/0/0
XE-P4-RR.00-00        0x00000090   0x2E6F        1117              0/0/0
XE-P4-RR.01-00        0x00000079   0x6F39        1071              0/0/0
XE-P4-RR.02-00        0x00000077   0xD5F4        968               0/0/0
XE-P4-RR.03-00        0x00000074   0xFCCD        648               0/0/0
XE-PE2#show isis database level-2 ?
  WORD       LSPID in the form of xxxx.xxxx.xxxx.xx-xx or name.xx-xx
  advertise  Internal TLV advertisement information
  detail     Detailed link state database information
  verbose    Verbose database information
  |          Output modifiers
  <cr>

XE-PE2#show isis database ?       
  WORD       LSPID in the form of xxxx.xxxx.xxxx.xx-xx or name.xx-xx
  advertise  Internal TLV advertisement information
  detail     Detailed link state database information
  l1         IS-IS Level-1 routing link state database
  l2         IS-IS Level-2 routing link state database
  level-1    IS-IS Level-1 routing link state database
  level-2    IS-IS Level-2 routing link state database
  verbose    Verbose database information
  |          Output modifiers
  <cr>

XE-PE2#show isis database XR-PE1.00-00 ?
  advertise  Internal TLV advertisement information
  detail     Detailed link state database information
  l1         IS-IS Level-1 routing link state database
  l2         IS-IS Level-2 routing link state database
  level-1    IS-IS Level-1 routing link state database
  level-2    IS-IS Level-2 routing link state database
  verbose    Verbose database information
  |          Output modifiers
  <cr>

XE-PE2#show isis database XR-PE1.00-00 ver
XE-PE2#show isis database XR-PE1.00-00 verbose ?
  advertise  Internal TLV advertisement information
  ip         IS-IS IPv4 address families
  ipv6       IPv6 address-family
  l1         IS-IS Level-1 routing link state database
  l2         IS-IS Level-2 routing link state database
  level-1    IS-IS Level-1 routing link state database
  level-2    IS-IS Level-2 routing link state database
  topology   MTR topology
  |          Output modifiers
  <cr>

XE-PE2#show isis database XR-PE1.00-00 verbose 

Tag djohn:

IS-IS Level-2 LSP XR-PE1.00-00
LSPID                 LSP Seq Num  LSP Checksum  LSP Holdtime      ATT/P/OL
XR-PE1.00-00          0x00000085   0x9997        467               0/0/0
  Area Address: 49
  NLPID:        0xCC 
  Hostname: XR-PE1
  IP Address:   100.64.11.1
  Router CAP:   100.64.11.1, D:0, S:0
    Segment Routing: I:1 V:0, SRGB Base: 16000 Range: 8000
  Metric: 10         IS-Extended XR-P3.01
    Unknown Sub TLV: 32
    Unknown Sub TLV: 32
  Metric: 10         IS-Extended XR-P1.01
    Unknown Sub TLV: 32
    Unknown Sub TLV: 32
  Metric: 0          IP 100.64.11.1/32
    Prefix-SID Index: 11, Algorithm:0, R:0 N:1 P:0 E:0 V:0 L:0
  Metric: 10         IP 169.254.111.0/24
  Metric: 10         IP 169.254.113.0/24
XE-PE2#

RP/0/0/CPU0:XR-PE1#show isis database XE-PE2 verbose 
Thu Nov 16 16:56:28.183 UTC

IS-IS djohn (Level-2) Link State Database
LSPID                 LSP Seq Num  LSP Checksum  LSP Holdtime  ATT/P/OL
XE-PE2.00-00          0x00000097   0x4c11        1184            0/0/0
  Area Address: 49
  NLPID:        0xcc
  Router Cap:   100.64.22.2, D:0, S:0
    Segment Routing: I:1 V:0, SRGB Base: 16000 Range: 8000
  Hostname:     XE-PE2
  Metric: 10         IS-Extended XE-P4-RR.01
  Metric: 10         IS-Extended XR-P1.09
  Metric: 10         IS-Extended XR-P2.03
  IP Address:   100.64.22.2
  Metric: 0          IP-Extended 100.64.22.2/32
    Prefix-SID Index: 22, Algorithm:0, R:0 N:1 P:0 E:0 V:0 L:0
  Metric: 10         IP-Extended 169.254.112.0/24
  Metric: 10         IP-Extended 169.254.222.0/24
  Metric: 10         IP-Extended 169.254.224.0/24

 Total Level-2 LSP count: 1     Local Level-2 LSP count: 0
RP/0/0/CPU0:XR-PE1#
```

```bash
##MPLS FORWARDING TABLE CHECK
RP/0/0/CPU0:XR-PE1#show mpls forwarding 
Thu Nov 16 16:56:45.612 UTC
Local  Outgoing    Prefix             Outgoing     Next Hop        Bytes       
Label  Label       or ID              Interface                    Switched    
------ ----------- ------------------ ------------ --------------- ------------
16001  Pop         SR Pfx (idx 1)     Gi0/0/0/0.111 169.254.111.11  0           
16002  16002       SR Pfx (idx 2)     Gi0/0/0/0.111 169.254.111.11  0           
16003  Pop         SR Pfx (idx 3)     Gi0/0/0/0.113 169.254.113.3   0           
16004  16004       SR Pfx (idx 4)     Gi0/0/0/0.111 169.254.111.11  169638      
       16004       SR Pfx (idx 4)     Gi0/0/0/0.113 169.254.113.3   0           
16022  16022       SR Pfx (idx 22)    Gi0/0/0/0.111 169.254.111.11  3698        
24000  Pop         SR Adj (idx 1)     Gi0/0/0/0.113 169.254.113.3   0           
24001  Pop         SR Adj (idx 3)     Gi0/0/0/0.113 169.254.113.3   0           
24002  Unlabelled  1.1.1.1/32[V]      Gi0/0/0/0.100 169.254.100.1   993198      
24003  Pop         SR Adj (idx 1)     Gi0/0/0/0.111 169.254.111.11  0           
24004  Pop         SR Adj (idx 3)     Gi0/0/0/0.111 169.254.111.11  0           
RP/0/0/CPU0:XR-PE1#

RP/0/0/CPU0:XR-PE1#show mpls forwarding PREfix IPV4 UNicast 100.64.22.2/32
Thu Nov 16 16:58:22.065 UTC
Local  Outgoing    Prefix             Outgoing     Next Hop        Bytes       
Label  Label       or ID              Interface                    Switched    
------ ----------- ------------------ ------------ --------------- ------------
16022  16022       SR Pfx (idx 22)    Gi0/0/0/0.111 169.254.111.11  3698        
RP/0/0/CPU0:XR-PE1#

##Explicit null feature do not support on IOS XE Version 15.5(3)S!