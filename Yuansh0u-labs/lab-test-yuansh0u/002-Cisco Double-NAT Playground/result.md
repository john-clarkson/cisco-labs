# Cisco double-NAT Lab setup (IOS 15.2)
- R1=Internal server with IP address=1.1.1.1 (Real-IP)
- R2=ISR NAT (double-nat), mapping IP 1.1.1.1>11.11.11.11, 4.4.4.4>44.44.44.44
- R3=vendor edge (static route to 11.11.11.11)
- R4=vendor server with IP address=4.4.4.4 (Real-IP)
#
- R1---EBGP---R2----static-route---R3-OSPFa0--R4
#
# Packet of life
```bash
1.1.1.1(realIP)                     4.4.4.4(realIP) 
internal_server--->(inside)NAT(outside)--->Vendor_serverIP
# initial flow
sIP 1.1.1.1                   sIP 11.11.11.11
dIP 44.44.44.44               dIP 4.4.4.4-----> 
# reverse flow
                    
           sIP 44.44.44.44                 sIP 4.4.4.4  
        <------dIP 1.1.1.1                 dIP 11.11.11.11
``` 
# NAT configuration optionA(without ”add-route“ keyword)
```bash
ISR-NAT-EDGE#sh run | sec ip nat
 ip nat inside
 ip nat outside
ip nat inside source static 1.1.1.1 11.11.11.11 extendable
ip nat outside source static 4.4.4.4 44.44.44.44 add-route
ISR-NAT-EDGE#
```
```bash
ISR-NAT-EDGE#show ip nat translations 
Pro Inside global      Inside local       Outside local      Outside global
--- ---                ---                44.44.44.44        4.4.4.4
--- 11.11.11.11        1.1.1.1            ---                ---
ISR-NAT-EDGE#
ISR-NAT-EDGE#sh run | sec ip route
ip route 44.44.44.44 255.255.255.255 23.1.1.3
*Sep 26 12:45:02.511: NAT: Entry assigned id 48
#*Sep 26 12:45:02.511: NAT*: s=1.1.1.1->11.11.11.11, d=44.44.44.44 [76]
#*Sep 26 12:45:02.511: NAT*: s=11.11.11.11, d=44.44.44.44->4.4.4.4 [76]
```
```bash
internal#ping 4.4.4.4 sou lo0
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 4.4.4.4, timeout is 2 seconds:
Packet sent with a source address of 1.1.1.1 
UUUUU >>>> (correct output)
Success rate is 0 percent (0/5)
internal#ping r4 sou lo0
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 44.44.44.44, timeout is 2 seconds:
Packet sent with a source address of 1.1.1.1 
!!!!! >>>> (correct output)
Success rate is 100 percent (5/5), round-trip min/avg/max = 56/68/76 ms
internal#
```

# optionB with add-route keyword
```bash
ISR-NAT-EDGE#sh run | sec ip nat
 ip nat inside
 ip nat outside
ip nat inside source static 1.1.1.1 11.11.11.11 extendable
ip nat outside source static 4.4.4.4 44.44.44.44 add-route
ISR-NAT-EDGE#sh run | sec ip route
ip route 4.4.4.4 255.255.255.255 23.1.1.3
```

```bash
ISR-NAT#show ip route
      1.0.0.0/32 is subnetted, 1 subnets
B        1.1.1.1 [20/0] via 12.1.1.1, 00:45:57
      2.0.0.0/32 is subnetted, 1 subnets
C        2.2.2.2 is directly connected, Loopback0
      4.0.0.0/32 is subnetted, 1 subnets
S        4.4.4.4 [1/0] via 23.1.1.3----<we add this route to trigger NAT add-route feature to help us add recursive route 44.44.44.44->4.4.4.4>
      12.0.0.0/8 is variably subnetted, 2 subnets, 2 masks
C        12.1.1.0/24 is directly connected, FastEthernet0/0
L        12.1.1.2/32 is directly connected, FastEthernet0/0
      23.0.0.0/8 is variably subnetted, 2 subnets, 2 masks
C        23.1.1.0/24 is directly connected, FastEthernet1/0
L        23.1.1.2/32 is directly connected, FastEthernet1/0
      44.0.0.0/32 is subnetted, 1 subnets
S        44.44.44.44 [1/0] via 4.4.4.4>>>> （auto-gen）
```
# caveats
- For internal server point of view, it also can connect directly to real vendorIP, which in this case, not acceptable. so we fallback to our original configuration(without add-route)
```bash
internal#ping 4.4.4.4 sou lo0
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 4.4.4.4, timeout is 2 seconds:
Packet sent with a source address of 1.1.1.1 
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 48/59/80 ms
internal#
```