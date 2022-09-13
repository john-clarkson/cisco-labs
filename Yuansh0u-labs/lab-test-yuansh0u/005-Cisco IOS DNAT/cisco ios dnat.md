# cisco ios dnat

- r1=internal
- r2=c95
- r3=proxy-server

## r1 12.1.1.1--r2 12.1.1.2-23.1.1.2 r3 23.1.1.3

- r1 loopback 1.1.1.1
- r3 loopback 3.3.3.3/185.1.1.1

**r1-r2 ip nat inside**

**r2-r3 ip nat outside**


# 
- r3-r1
- telnet 23.1.1.254->1.1.1.1 <dnat> =ip nat insdie source static=reverse packet
- r1->r3
- telnet 10.189.138.254 --->185.1.1.1 <dnat> = ip nat outside source static=origin packet

# test r3-r1
```bash
internal#ping 10.189.138.254        
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 10.189.138.254, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 44/52/76 ms
internal#

c95#sh run | sec ip nat
 ip nat inside-to internal
 ip nat outside-to proxyserver
ip nat outside source static 185.1.1.1 10.189.138.254 add-route
c95#

c95#
*Feb 26 14:48:43.979: NAT: Entry assigned id 22
*Feb 26 14:48:43.983: NAT: s=12.1.1.1, d=10.189.138.254->185.1.1.1 [70]
*Feb 26 14:48:44.055: NAT: s=185.1.1.1->10.189.138.254, d=12.1.1.1 [70]
*Feb 26 14:48:44.131: NAT: s=12.1.1.1, d=10.189.138.254->185.1.1.1 [71]
*Feb 26 14:48:44.203: NAT: s=185.1.1.1->10.189.138.254, d=12.1.1.1 [71]
*Feb 26 14:48:44.279: NAT: s=12.1.1.1, d=10.189.138.254->185.1.1.1 [72]
*Feb 26 14:48:44.327: NAT: s=185.1.1.1->10.189.138.254, d=12.1.1.1 [72]
*Feb 26 14:48:44.399: NAT: s=12.1.1.1, d=10.189.138.254->185.1.1.1 [73]
*Feb 26 14:48:44.471: NAT: s=185.1.1.1->10.189.138.254, d=12.1.1.1 [73]
c95#
*Feb 26 14:48:44.547: NAT: s=12.1.1.1, d=10.189.138.254->185.1.1.1 [74]
*Feb 26 14:48:44.619: NAT: s=185.1.1.1->10.189.138.254, d=12.1.1.1 [74]
c95#


proxy-server#
*Feb 26 14:52:40.359: ICMP: echo reply sent, src 185.1.1.1, dst 12.1.1.1, topology BASE, dscp 0 topoid 0
*Feb 26 14:52:40.419: ICMP: echo reply sent, src 185.1.1.1, dst 12.1.1.1, topology BASE, dscp 0 topoid 0
*Feb 26 14:52:40.471: ICMP: echo reply sent, src 185.1.1.1, dst 12.1.1.1, topology BASE, dscp 0 topoid 0
*Feb 26 14:52:40.527: ICMP: echo reply sent, src 185.1.1.1, dst 12.1.1.1, topology BASE, dscp 0 topoid 0
*Feb 26 14:52:40.579: ICMP: echo reply sent, src 185.1.1.1, dst 12.1.1.1, topology BASE, dscp 0 topoid 0
proxy-server#