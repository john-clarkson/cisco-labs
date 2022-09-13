# IPv4 to IPv6 converter/refrence guide
- https://www.vultr.com/resources/ipv4-converter/
- https://community.cisco.com/t5/networking-documents/ipv6-stateful-nat64-configuration-example/ta-p/3124475
# Topology
![picture 2](../../../images/93f920125e48d32c7568d3df5c67439af515545e1a28245e1585cb34f7a74bb8.png)  

# IPv4_Only
```bash
R3#ping 10.0.0.10 repeat 1
Type escape sequence to abort.
Sending 1, 100-byte ICMP Echos to 10.0.0.10, timeout is 2 seconds:
!
Success rate is 100 percent (1/1), round-trip min/avg/max = 28/28/28 ms
IPv4_Only_R3#
*Dec 11 16:01:54.941: ICMP: echo reply rcvd, src 10.0.0.10, dst 10.0.0.1, topology BASE, dscp 0 topoid 0
```
# NAT64 router configuration
```bash
NAT64_R2#show nat64 statistics 
NAT64 Statistics

Total active translations: 2 (1 static, 1 dynamic; 1 extended)
Sessions found: 28
Sessions created: 6
Expired translations: 5
Global Stats:
   Packets translated (IPv4 -> IPv6)
      Stateless: 0
      Stateful: 17
      MAP-T: 0
   Packets translated (IPv6 -> IPv4)
      Stateless: 0
      Stateful: 17
      MAP-T: 0

Interface Statistics
   GigabitEthernet1.12 (IPv4 not configured, IPv6 configured):
      Packets translated (IPv4 -> IPv6)
         Stateless: 0
         Stateful: 0
         MAP-T: 0
      Packets translated (IPv6 -> IPv4)
         Stateless: 0
         Stateful: 17
         MAP-T: 0
      Packets dropped: 0
   GigabitEthernet1.23 (IPv4 configured, IPv6 not configured):
      Packets translated (IPv4 -> IPv6)
         Stateless: 0
         Stateful: 17
         MAP-T: 0
      Packets translated (IPv6 -> IPv4)
         Stateless: 0
         Stateful: 0
         MAP-T: 0
      Packets dropped: 0
Dynamic Mapping Statistics
   v6v4
Limit Statistics


NAT64_R2# 
```
```bash
NAT64_R2#show nat64 translations 

Proto  Original IPv4         Translated IPv4
       Translated IPv6       Original IPv6 
----------------------------------------------------------------------------

---    ---                   ---                                             
       10.0.0.10             2001::a00:a                                     
icmp   10.0.0.1:4            [3001::a00:1]:4                                 
       10.0.0.10:4           [2001::a00:a]:4                                 

Total number of translations: 2

NAT64_R2#
```
```bash
###
IPV6_ONLY-R1#
*Dec 11 16:04:53.929: ICMPv6: Received echo request, Src=3001::A00:1, Dst=2001::A00:A
*Dec 11 16:04:53.930: ICMPv6: Sent echo reply, Src=2001::A00:A, Dst=3001::A00:1
IPV6_ONLY-R1#ping 3001::a00:1
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 3001::A00:1, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 12/15/19 ms
IPV6_ONLY-R1#
```

# Verify Commands
 

- Verifying Connectivity Using Ping Command
- To verify whether the router R3 (IPv4 only network) is able to reach the router R1(IPv6 only network), use the ping command and verify the translations that happen by debug ipv6 icmp.

 

## In router R3
- Try ping router R1(IPv6 only network)which is represented by the IPv4 address 10.0.0.10. Enable debug ip icmp on router R3 and in router R1(IPv6 only network) enable debug ipv6 icmp

 
```bash
R3#debug ip icmp

ICMP packet debugging is on

 

R1#debug ipv6 icmp

ICMP Packet debugging is on

 

R3#ping 10.0.0.10
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 10.0.0.10, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 1/2/4 ms

 

R3#
*Sep  8 09:56:22.451: ICMP: echo reply rcvd, src 10.0.0.10, dst 10.0.0.1, topology BASE, dscp 0 topoid 0
*Sep  8 09:56:22.451: ICMP: echo reply rcvd, src 10.0.0.10, dst 10.0.0.1, topology BASE, dscp 0 topoid 0
*Sep  8 09:56:22.455: ICMP: echo reply rcvd, src 10.0.0.10, dst 10.0.0.1, topology BASE, dscp 0 topoid 0
*Sep  8 09:56:22.459: ICMP: echo reply rcvd, src 10.0.0.10, dst 10.0.0.1, topology BASE, dscp 0 topoid 0
*Sep  8 09:56:22.459: ICMP: echo reply rcvd, src 10.0.0.10, dst 10.0.0.1, topology BASE, dscp 0 topoid 0

 

R1#
*Sep  8 10:48:51.499: ICMPv6: Received echo request, src=3001::A00:1, Dst=2001::A00:A
*Sep  8 10:48:51.499: ICMPv6: Sent echo reply, src=2001::A00:A, Dst=3001::A00:1
*Sep  8 10:48:51.503: ICMPv6: Received echo request, src=3001::A00:1, Dst=2001::A00:A
*Sep  8 10:48:51.503: ICMPv6: Sent echo reply, src=2001::A00:A, Dst=3001::A00:1
*Sep  8 10:48:51.507: ICMPv6: Received echo request, src=3001::A00:1, Dst=2001::A00:A
*Sep  8 10:48:51.507: ICMPv6: Sent echo reply, src=2001::A00:A, Dst=3001::A00:1
*Sep  8 10:48:51.511: ICMPv6: Received echo request, src=3001::A00:1, Dst=2001::A00:A
*Sep  8 10:48:51.511: ICMPv6: Sent echo reply, src=2001::A00:A, Dst=3001::A00:1
*Sep  8 10:48:51.511: ICMPv6: Received echo request, src=3001::A00:1, Dst=2001::A00:A
*Sep  8 10:48:51.515: ICMPv6: Sent echo reply, src=2001::A00:A, Dst=3001::A00:1

 
```

- From the above debug output, you can see that the router R3(IPv4 only Router) is able to reach the router R1(IPv6 only router) using the static IPv4 address that we have assigned i.e.using 10.0.0.10

 

- Similarly the router R1(IPv6 only router) debug output shows that the ICMP request is received from 3001::A00:1 which is nothing but the IPv4 address 10.0.0.1 when converted to hexadecimal becomes A00:1 and is added to the prefix 3001::/.In other words the IPv4 address 10.0.0.1 is translated to 3001::A00:1 when reaching the IPv6 enabled network.

 

- The following show commands can be used to see NAT64 translations that happen in ASR router

 
```bash
Show nat64 mappings static
 

To display the information about the Network Address Translation 64 (NAT64) static mappings, use this command.


ASR Router R2#show nat64 mappings static

Static mappings configured: 1

Direction Protocol Address (Port, if any)
   Non-key Address (Port, if any)

v6v4      ---      2001::A00:A
   10.0.0.10

 

Show nat64 adjacency ipv6
 
```

- This command displays the information about the Network Address Translation 64 (NAT64) managed adjacencies.

 
```bash
ASR Router R2#show nat64 adjacency ipv6
Adjacency Counts
   Stateless Prefix Adjacencies: 0
   Stateless Prefix Adjacency Ref Count: 0
   v4v6 Stateless Prefix Adjacencies: 0
   v4v6 Stateless Prefix Adjacency Ref Count: 0
   v6v4 Stateless Prefix Adjacencies: 0
   v6v4 Stateless Prefix Adjacency Ref Count: 0
   Stateful Prefix Adjacencies: 1
   Stateful Prefix Adjacency Ref Count: 1
   IPv6 Well-Known Prefix Adjacencies: 1
   IPv6 Well-Known Prefix Adjacency Ref Count: 1
   IPv6 Static Mapping Adjacencies: 0
   IPv6 Static Mapping Adjacency Ref Count: 0
   IPv4 Route Adjacencies: 0
Adjacencies
   Stateful Prefix: ::100.0.0.1
   IPv6 Well-Known Prefix: ::100.0.0.2
   IPv6 Stateful Mask: ::100.0.0.0

 ```
 ```bash

Show nat64 prefix stateful
 

Using this command, you can check the information about Network Address Translation 64 (NAT64) stateful prefixes. Global prefixes, nat64 configured intrerfaces and prefix static-routes will be displayed.

 

ASR Router R2#show nat64 prefix stateful global (Displays the global prefixes)

 

Global Stateful Prefix: is valid, 3001::/96

IFs Using Global Prefix

   Fa0/2/6
   Fa0/2/7

 

```
```bash
ASR Router R2#show nat64 prefix stateful static-routes (Displays the static-routes)
Stateful Prefixes

NAT64 Prefix
   Static Route Ref-Count

3001::/96
   1
```
```bash
ASR Router R2#show nat64 prefix stateful interfaces (Displays the nat64 enabled interfaces)
Stateful Prefixes
Interface
   NAT64 Enabled Global Prefix
FastEthernet0/2/6
   TRUE          TRUE   3001::/96
FastEthernet0/2/7
   TRUE          TRUE   3001::/96

 

Show nat64 statistics
 
```
- To display Network Address Translation 64 (NAT64) packet count statistics use this command

 
```bash
ASR Router R2#show nat64 statistics
NAT64 Statistics

Total active translations: 1 (1 static, 0 dynamic; 0 extended)
Sessions found: 142
Sessions created: 16
Expired translations: 16
Global Stats:
   Packets translated (IPv4 -> IPv6)
      Stateless: 0
      Stateful: 79
   Packets translated (IPv6 -> IPv4)
      Stateless: 0
      Stateful: 79

Interface Statistics
   FastEthernet0/2/6 (IPv4 configured, IPv6 not configured):
      Packets translated (IPv4 -> IPv6)
         Stateless: 0
         Stateful: 79
      Packets translated (IPv6 -> IPv4)
         Stateless: 0
         Stateful: 0
      Packets dropped: 0
   FastEthernet0/2/7 (IPv4 not configured, IPv6 configured):
      Packets translated (IPv4 -> IPv6)
         Stateless: 0
         Stateful: 0
      Packets translated (IPv6 -> IPv4)
         Stateless: 0
         Stateful: 79
      Packets dropped: 0
Dynamic Mapping Statistics
   v6v4