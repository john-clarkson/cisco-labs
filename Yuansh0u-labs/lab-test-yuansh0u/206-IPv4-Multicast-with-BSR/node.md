# Mutlticast control-plane with BSR
- Receiver <igmp report> <pim-router><pim join/prune>->RP
- Sender <pim register> over tunnel >RP
- RP <pim register stop> over underlay >sender
## Sender settings
- R1=igmp receiver R3=bsr rp R5=sender with ip pim dr-proirity 0
### ping test
 
```yaml
sender_source#ping 224.1.1.1 re 100
Type escape sequence to abort.
Sending 100, 100-byte ICMP Echos to 224.1.1.1, timeout is 2 seconds:

Reply to request 0 from 12.1.1.1, 100 ms
Reply to request 0 from 12.1.1.1, 104 ms
Reply to request 1 from 12.1.1.1, 64 ms
Reply to request 2 from 12.1.1.1, 52 ms
```
### pim tunnels for register message
```yaml
sender_source#show ip pim tunnel 
Tunnel0 
  Type  : PIM Encap
  RP    : 3.3.3.3
  Source: 45.1.1.5
sender_source#
```
### tunnel interface
```yaml
sender_source#show ip int b
Interface              IP-Address      OK? Method Status                Protocol
FastEthernet0/0        45.1.1.5        YES manual up                    up      
FastEthernet1/0        unassigned      YES unset  administratively down down    
FastEthernet1/1        unassigned      YES unset  administratively down down    
FastEthernet2/0        unassigned      YES unset  administratively down down    
FastEthernet2/1        unassigned      YES unset  administratively down down    
Loopback0              5.5.5.5         YES manual up                    up      
Tunnel0                45.1.1.5        YES unset  up                    up  
```
### BSR RP inband PIM messages
```yaml
sender_source#show ip pim rp mapping 
PIM Group-to-RP Mappings

Group(s) 224.0.0.0/4
  RP 3.3.3.3 (?), v2
    Info source: 3.3.3.3 (?), via bootstrap, priority 0, holdtime 150
         Uptime: 00:15:37, expires: 00:01:45
sender_source#
```
### RPF check based on unicast underlay infra<OSPF>

```yaml
R2#show ip rpf 45.1.1.5
RPF information for ? (45.1.1.5)
  RPF interface: FastEthernet2/0
  RPF neighbor: ? (24.1.1.4)
  RPF route/mask: 45.1.1.0/24
  RPF type: unicast (ospf 1)
  Doing distance-preferred lookups across tables
  RPF topology: ipv4 multicast base, originated from ipv4 unicast base
R2#
```
```yaml
BSR_RP#show ip mroute 
IP Multicast Routing Table
Flags: D - Dense, S - Sparse, B - Bidir Group, s - SSM Group, C - Connected,
       L - Local, P - Pruned, R - RP-bit set, F - Register flag,
       T - SPT-bit set, J - Join SPT, M - MSDP created entry, E - Extranet,
       X - Proxy Join Timer Running, A - Candidate for MSDP Advertisement,
       U - URD, I - Received Source Specific Host Report, 
       Z - Multicast Tunnel, z - MDT-data group sender, 
       Y - Joined MDT-data group, y - Sending to MDT-data group, 
       G - Received BGP C-Mroute, g - Sent BGP C-Mroute, 
       Q - Received BGP S-A Route, q - Sent BGP S-A Route, 
       V - RD & Vector, v - Vector
Outgoing interface flags: H - Hardware switched, A - Assert winner
 Timers: Uptime/Expires
 Interface state: Interface, Next-Hop or VCD, State/Mode

(*, 224.5.5.5), 00:10:03/00:03:15, RP 3.3.3.3, flags: S
  Incoming interface: Null, RPF nbr 0.0.0.0
  Outgoing interface list:
    FastEthernet1/0, Forward/Sparse, 00:10:03/00:03:15

(*, 224.1.1.1), 00:19:11/00:02:56, RP 3.3.3.3, flags: S
  Incoming interface: Null, RPF nbr 0.0.0.0
  Outgoing interface list:
    FastEthernet1/0, Forward/Sparse, 00:19:11/00:02:56
          
(*, 224.0.1.40), 00:22:01/00:02:06, RP 0.0.0.0, flags: DCL
  Incoming interface: Null, RPF nbr 0.0.0.0
  Outgoing interface list:
    Loopback0, Forward/Sparse, 00:21:59/00:02:06
          
```
### mtrace from reciever to sender

```yaml
IGMP-Receiver#mtrace 45.1.1.5
Type escape sequence to abort.
Mtrace from 45.1.1.5 to 12.1.1.1 via RPF
From source (?) to destination (?)
Querying full reverse path... 
 0  12.1.1.1
-1  12.1.1.1 ==> 12.1.1.1 PIM  [45.1.1.0/24]
-2  12.1.1.2 ==> 24.1.1.2 PIM  [45.1.1.0/24]
-3  24.1.1.4 ==> 45.1.1.4 PIM_MT  [45.1.1.0/24]
-4  45.1.1.5
IGMP-Receiver#
```
