

```
R7 = nat router
ms 
    real ip 10.25.1.1/32 mapping 6.25.1.1/32
vendor
    real ip 6.6.6.6/32 mapping 10.25.96.1/32
```

```py
R6#ping 10.25.96.1 sou lo1

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 10.25.96.1, timeout is 2 seconds:
Packet sent with a source address of 10.25.1.2 
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 24/44/88 ms
```
```py
R6#
*Aug  6 04:30:13.687: ICMP: echo reply rcvd, src 10.25.96.1, dst 10.25.1.2, topology BASE, dscp 0 topoid 0
*Aug  6 04:30:13.719: ICMP: echo reply rcvd, src 10.25.96.1, dst 10.25.1.2, topology BASE, dscp 0 topoid 0
*Aug  6 04:30:13.763: ICMP: echo reply rcvd, src 10.25.96.1, dst 10.25.1.2, topology BASE, dscp 0 topoid 0
*Aug  6 04:30:13.795: ICMP: echo reply rcvd, src 10.25.96.1, dst 10.25.1.2, topology BASE, dscp 0 topoid 0
*Aug  6 04:30:13.819: ICMP: echo reply rcvd, src 10.25.96.1, dst 10.25.1.2, topology BASE, dscp 0 topoid 0
R6#
```
```py
R7#779: NAT*: s=6.6.6.6->10.25.96.1, d=6.25.1.4 [463]
*Aug  6 04:30:13.779: NAT*: s=10.25.96.1, d=6.25.1.4->10.25.1.2 [463]
*Aug  6 04:30:13.791: NAT*: s=10.25.1.2->6.25.1.4, d=10.25.96.1 [464]
*Aug  6 04:30:13.791: NAT*: s=6.25.1.4, d=10.25.96.1->6.6.6.6 [464]
*Aug  6 04:30:13.803: NAT*: s=6.6.6.6->10.25.96.1, d=6.25.1.4 [464]
*Aug  6 04:30:13.803: NAT*: s=10.25.96.1, d=6.25.1.4->10.25.1.2 [464]
R7#
```
```py
R7#sh run | sec ip route
ip route 10.25.96.1 255.255.255.255 78.1.1.8
R7#

R7#sh run | sec ip nat
 ip nat inside
 ip nat outside
ip nat inside source static 10.25.1.1 6.25.1.2
ip nat inside source static 10.25.1.1 6.25.1.3 extendable
ip nat inside source static 10.25.1.2 6.25.1.4 extendable <hit>
ip nat inside source static 10.25.1.3 6.25.1.5 extendable
ip nat outside source static 6.6.6.6 10.25.96.1
```
```py
R8#
*Aug  6 04:30:13.599: ICMP: echo reply sent, src 6.6.6.6, dst 6.25.1.4, topology BASE, dscp 0 topoid 0
*Aug  6 04:30:13.671: ICMP: echo reply sent, src 6.6.6.6, dst 6.25.1.4, topology BASE, dscp 0 topoid 0
*Aug  6 04:30:13.703: ICMP: echo reply sent, src 6.6.6.6, dst 6.25.1.4, topology BASE, dscp 0 topoid 0
*Aug  6 04:30:13.747: ICMP: echo reply sent, src 6.6.6.6, dst 6.25.1.4, topology BASE, dscp 0 topoid 0
*Aug  6 04:30:13.771: ICMP: echo reply sent, src 6.6.6.6, dst 6.25.1.4, topology BASE, dscp 0 topoid 0
R8#
```