## Diagram
```py
igmpv2
239.1.1.1
239.1.1.2
< RP = 88.88.88.88>
<       OSPF        >                              <OSPF>                                      
2*Receiver > LHP > NAT <<<<<<static-route>>>>>>  PIM > Sender 9.9.9.9
                  in out                         |
                                                 RP 8.8.8.8
```

## Destination NAT <Left = insdie, right = outside>
- 8.8.8.8 = RealRP 88.88.88.88 = Mapping Address
- 9.9.9.9 = RealSender 99.99.99.99 = Mapping Address
```py
ip nat outside source static 8.8.8.8 88.88.88.88
ip nat outside source static 9.9.9.9 99.99.99.99  

NAT#sh run | sec ip route
ip route 88.88.88.88 255.255.255.255 169.254.1.2 name TO-RP
ip route 99.99.99.99 255.255.255.255 169.254.1.2 name TO-Sender
```
## Debug NAT
```PY
NAT#debug ip nat
IP NAT debugging is on
NAT#
*Sep  1 00:58:35.307: NAT: expiring 22.1.1.1 (22.1.1.1) icmp 822 (822)
*Sep  1 00:58:35.307: NAT: Freeing nat entry, id 563
NAT#
*Sep  1 00:58:37.811: NAT: Entry assigned id 594
*Sep  1 00:58:37.811: NAT*: s=12.1.1.1, d=99.99.99.99->9.9.9.9 [1090]
*Sep  1 00:58:37.811: NAT*: s=12.1.1.1, d=99.99.99.99->9.9.9.9 [1090]
*Sep  1 00:58:38.379: NAT: expiring 12.1.1.1 (12.1.1.1) icmp 823 (823)
*Sep  1 00:58:38.379: NAT: Freeing nat entry, id 564
*Sep  1 00:58:38.715: NAT: Entry assigned id 595
*Sep  1 00:58:38.715: NAT*: s=22.1.1.1, d=99.99.99.99->9.9.9.9 [1091]
*Sep  1 00:58:38.715: NAT*: s=22.1.1.1, d=99.99.99.99->9.9.9.9 [1091]
NAT#
```
## RP assignment (NATed address)
```py
NAT#show ip pim rp mapping 
PIM Group-to-RP Mappings

Group(s): 224.0.0.0/4, Static
    RP: 88.88.88.88 (?)
NAT#
```
## Sender 
- IOS Router as sender must set pim-dr prioity = 0 on interface level
```py
Sender#sh run int f1/1
Building configuration...

Current configuration : 135 bytes
!
interface FastEthernet1/1
 ip address 11.1.1.2 255.255.255.0
 ip pim dr-priority 0
 ip pim sparse-mode
```
- Using SLA auto generate multicast feed to client
```py
Sender#sh run | sec ip sla
ip sla 1
 icmp-echo 239.1.1.1 source-ip 9.9.9.9
 frequency 5
ip sla schedule 1 start-time now
ip sla 2
 icmp-echo 239.2.2.2 source-ip 9.9.9.9
 frequency 5
ip sla schedule 2 start-time now
Sender#

```
## Sender > 239.1.1.1 239.2.2.2
```py
Sender#ping 239.1.1.1 source 9.9.9.9
Type escape sequence to abort.
Sending 1, 100-byte ICMP Echos to 239.1.1.1, timeout is 2 seconds:
Packet sent with a source address of 9.9.9.9 

Reply to request 0 from 12.1.1.1, 68 ms
Reply to request 0 from 12.1.1.1, 72 ms

Sender#ping 239.2.2.2 source 9.9.9.9  
Type escape sequence to abort.
Sending 1, 100-byte ICMP Echos to 239.2.2.2, timeout is 2 seconds:
Packet sent with a source address of 9.9.9.9 

Reply to request 0 from 22.1.1.1, 88 ms
Reply to request 0 from 22.1.1.1, 88 ms
Sender#
```

## Reciever 
- debug ip icmp enable
```py
Reciever#
*Sep  1 00:40:26.759: ICMP: echo reply sent, src 12.1.1.1, dst 99.99.99.99, topology BASE, dscp 0 topoid 0
*Sep  1 00:40:26.767: ICMP: echo reply sent, src 12.1.1.1, dst 99.99.99.99, topology BASE, dscp 0 topoid 0
Reciever#
```

```py
Reciever2#
*Sep  1 00:40:27.171: ICMP: echo reply sent, src 22.1.1.1, dst 99.99.99.99, topology BASE, dscp 0 topoid 0
*Sep  1 00:40:27.175: ICMP: echo reply sent, src 22.1.1.1, dst 99.99.99.99, topology BASE, dscp 0 topoid 0
Reciever2#
```



## RP Status
- RP knows Senders (S,G) & Receiver (*,G)
```py
RP#show ip mroute 
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

(*, 239.1.1.1), 00:24:42/00:02:35, RP 8.8.8.8, flags: S
  Incoming interface: Null, RPF nbr 0.0.0.0
  Outgoing interface list:
    FastEthernet2/0, Forward/Sparse, 00:10:07/00:02:35

(9.9.9.9, 239.1.1.1), 00:20:34/00:01:18, flags: PT
  Incoming interface: FastEthernet2/0, RPF nbr 123.1.1.1
  Outgoing interface list: Null
          
(*, 239.2.2.2), 00:16:56/00:02:44, RP 8.8.8.8, flags: S
  Incoming interface: Null, RPF nbr 0.0.0.0
  Outgoing interface list:
    FastEthernet2/0, Forward/Sparse, 00:10:07/00:02:44

(9.9.9.9, 239.2.2.2), 00:16:56/00:02:24, flags: PT
  Incoming interface: FastEthernet2/0, RPF nbr 123.1.1.1
  Outgoing interface list: Null

(*, 224.0.1.40), 00:38:04/00:03:15, RP 8.8.8.8, flags: SJCL
  Incoming interface: Null, RPF nbr 0.0.0.0
  Outgoing interface list:
    FastEthernet2/0, Forward/Sparse, 00:38:02/00:03:15

RP# 
```

## Last-hop status
- enable "ip pim spt-threshold infinity"
- (*,G) only
```py
LHP#show ip pim rp mapping 
PIM Group-to-RP Mappings

Group(s): 224.0.0.0/4, Static
    RP: 88.88.88.88 (?)
```
```py
LHP#sh ip mroute 
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

(*, 239.1.1.1), 00:46:23/00:02:52, RP 88.88.88.88, flags: SC
  Incoming interface: FastEthernet1/1, RPF nbr 23.1.1.3
  Outgoing interface list:
    FastEthernet0/0, Forward/Sparse, 00:46:23/00:02:52

(*, 239.2.2.2), 00:18:43/00:02:21, RP 88.88.88.88, flags: SC
  Incoming interface: FastEthernet1/1, RPF nbr 23.1.1.3
  Outgoing interface list:
    FastEthernet1/0, Forward/Sparse, 00:18:43/00:02:21

(*, 224.0.1.40), 00:49:12/00:02:51, RP 88.88.88.88, flags: SCL
  Incoming interface: FastEthernet1/1, RPF nbr 23.1.1.3
  Outgoing interface list:
    FastEthernet0/0, Forward/Sparse, 00:49:09/00:02:51

LHP#
```
## Mtrace
```py
LHP#mtrace 99.99.99.99
Type escape sequence to abort.
Mtrace from 99.99.99.99 to 23.1.1.2 via RPF
From source (?) to destination (?)
Querying full reverse path... * switching to hop-by-hop:
 0  23.1.1.2
-1  23.1.1.2 ==> 23.1.1.2 PIM  [default]
-1  99.99.99.99
LHP#
```
## Delete static-route on PIM
- Even Unicast connectivity is broken, the multicast is also fine.
- For receiver point of view, the unicast routing is just served for RPF check to pass
```py
LHP#show ip rpf 99.99.99.99
RPF information for ? (99.99.99.99)
  RPF interface: FastEthernet1/1
  RPF neighbor: ? (23.1.1.3)
  RPF route/mask: 0.0.0.0/0
  RPF type: unicast (ospf 1)
  Doing distance-preferred lookups across tables
  RPF topology: ipv4 multicast base, originated from ipv4 unicast base
LHP#
```
```py
NAT#show ip rpf 99.99.99.99
RPF information for ? (99.99.99.99)
  RPF interface: FastEthernet0/0
  RPF neighbor: ? (169.254.1.2)
  RPF route/mask: 99.99.99.99/32
  RPF type: unicast (static)
  Doing distance-preferred lookups across tables
  RPF topology: ipv4 multicast base, originated from ipv4 unicast base
NAT#
```

```py
PIM(config)#no ip route 12.1.1.0 255.255.255.0 169.254.1.1
PIM(config)#no ip route 22.1.1.0 255.255.255.0 169.254.1.1
```
- Multicast feed is normal
```py
Sender#ping 239.1.1.1 source 9.9.9.9 re 100
Type escape sequence to abort.
Sending 100, 100-byte ICMP Echos to 239.1.1.1, timeout is 2 seconds:
Packet sent with a source address of 9.9.9.9 

Reply to request 0 from 12.1.1.1, 60 ms
Reply to request 0 from 12.1.1.1, 64 ms
```