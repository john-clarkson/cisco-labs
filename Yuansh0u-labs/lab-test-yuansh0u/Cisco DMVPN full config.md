somesay# DMVPN full configuration
- [DMVPN full configuration](#dmvpn-full-configuration)
  - [INET ROUTER](#inet-router)
  - [IPSEC-VPN settings for all devices](#ipsec-vpn-settings-for-all-devices)
  - [hub-1](#hub-1)
  - [HUB-2](#hub-2)
  - [spoke-1 without NAT](#spoke-1-without-nat)
  - [with nat](#with-nat)
  - [behind NAT spoke-2](#behind-nat-spoke-2)
  - [Result](#result)
  - [spoke to spoke](#spoke-to-spoke)
## INET ROUTER
  ```bash
  interface FastEthernet0/1
 ip address 202.100.1.254 255.255.255.0
 duplex auto
 speed auto
 !
 ip dhcp pool CHINA
   network 202.100.1.0 255.255.255.0
   default-router 202.100.1.254 
```

## IPSEC-VPN settings for all devices
```bash
crypto keyring DMVPN-KEYRING 
  pre-shared-key address 0.0.0.0 0.0.0.0 key somesayERS
!
crypto isakmp policy 10
 encr aes 256
 authentication pre-share
 group 2
crypto isakmp profile DMVPN-PHASE3
   keyring DMVPN-KEYRING
   match identity address 0.0.0.0 
!
crypto ipsec security-association replay window-size 1024
!
crypto ipsec transform-set ESP/NULL/MD5/TUNNEL esp-null esp-sha-hmac 
 mode transport
!
crypto ipsec profile DMVPN-PROFILE
 set transform-set ESP/NULL/MD5/TUNNEL 
 set isakmp-profile DMVPN-PHASE3
 !
 interface tunnel x
   tunnel protection ipsec profile DMVPN-PROFILE
```
## hub-1
```bash
CHINA-1#sh run int f6/0
Building configuration...

Current configuration : 99 bytes
!
interface FastEthernet6/0
 ip address 202.100.1.1 255.255.255.0
 duplex auto
 speed auto
 !
end

CHINA-1#sh run | sec ip route
ip route 0.0.0.0 0.0.0.0 202.100.1.254 name INET

interface Tunnel301
 ip address 20.169.169.254 255.255.255.0
 no ip redirects
 ip mtu 1400
 ip nhrp map multicast dynamic
 ip nhrp map 20.169.169.253 202.100.1.2
 ip nhrp map multicast 202.100.1.2
 ip nhrp network-id 300
 ip nhrp nhs 20.169.169.253
 ip nhrp shortcut
 ip nhrp redirect
 ip tcp adjust-mss 1360
 ip ospf network point-to-multipoint
 ip ospf 30 area 0
 tunnel source FastEthernet6/0
 tunnel mode gre multipoint
 tunnel key 54321
 tunnel protection ipsec profile DMVPN-PROFILE
 !
```

## HUB-2
```bash
Current configuration : 99 bytes
!
interface FastEthernet6/0
 ip address 202.100.1.2 255.255.255.0
 duplex auto
 speed auto
 !
end

CHINA-2#sh run | sec ip route
ip route 0.0.0.0 0.0.0.0 202.100.1.254 name INET

interface Tunnel302
 ip address 20.169.169.253 255.255.255.0
 no ip redirects
 ip mtu 1400
 ip nhrp map multicast dynamic
 ip nhrp map 20.169.169.254 202.100.1.1
 ip nhrp map multicast 202.100.1.1
 ip nhrp network-id 300
 ip nhrp nhs 20.169.169.254
 ip nhrp shortcut
 ip nhrp redirect
 ip tcp adjust-mss 1360
 ip ospf network point-to-multipoint
 ip ospf 30 area 0
 tunnel source FastEthernet6/0
 tunnel mode gre multipoint
 tunnel key 54321
 tunnel protection ipsec profile DMVPN-PROFILE
 !
end
```
## spoke-1 without NAT 
```bash
   interface Loopback0
 description CHINA-CLIENT-LAN
 ip address 150.1.1.1 255.255.255.255
 ip ospf 10 area 0
 !
!
interface Tunnel0
 ip address 20.169.169.1 255.255.255.0
 no ip redirects
 ip mtu 1400
 ip nhrp map 20.169.169.254 202.100.1.1
 ip nhrp map 20.169.169.253 202.100.1.2
 ip nhrp map multicast 202.100.1.1
 ip nhrp map multicast 202.100.1.2
 ip nhrp network-id 300
 ip nhrp nhs 20.169.169.254
 ip nhrp nhs 20.169.169.253
 ip nhrp shortcut
 ip tcp adjust-mss 1360
 ip ospf network point-to-multipoint
 ip ospf 10 area 0
 tunnel source FastEthernet0/0
 tunnel mode gre multipoint
 tunnel key 54321
 tunnel protection ipsec profile DMVPN-PROFILE
 !
!
interface FastEthernet0/0
 ip address dhcp
 duplex auto
 speed auto
 ```

 ## with nat
 ```bash
   NAT Device
 interface FastEthernet0/0
 ip address dhcp
 ip nat outside
 ip virtual-reassembly
 duplex auto
 speed auto
 !
!
interface FastEthernet0/1
 ip address 10.1.1.254 255.255.255.0
 ip nat inside
 ip virtual-reassembly
 duplex auto
 speed auto

 ip nat inside source list CHINA_USER interface FastEthernet0/0 overload
!
ip access-list extended CHINA_USER
 permit ip 10.1.1.0 0.0.0.255 any
```
 ## behind NAT spoke-2
 ```bash
CHINA-CLIENT-USER2-NAT# sh run | sec ip route
ip route 0.0.0.0 0.0.0.0 10.1.1.254

interface Loopback0
 description CHINA-CLIENT-LAN
 ip address 150.1.1.2 255.255.255.255
 ip ospf 10 area 0
 !
!
interface Tunnel0
 ip address 20.169.169.2 255.255.255.0
 no ip redirects
 ip mtu 1400
 ip nhrp map 20.169.169.254 202.100.1.1
 ip nhrp map 20.169.169.253 202.100.1.2
 ip nhrp map multicast 202.100.1.1
 ip nhrp map multicast 202.100.1.2
 ip nhrp network-id 300
 ip nhrp nhs 20.169.169.254
 ip nhrp nhs 20.169.169.253
 ip nhrp shortcut
 ip tcp adjust-mss 1360
 ip ospf network point-to-multipoint
 ip ospf 10 area 0
 tunnel source FastEthernet0/1
 tunnel mode gre multipoint
 tunnel key 54321
 tunnel protection ipsec profile DMVPN-PROFILE
```
 ## Result
 ```bash
     CHINA-1#show dmvpn
Legend: Attrb --> S - Static, D - Dynamic, I - Incomplete
        N - NATed, L - Local, X - No Socket
        # Ent --> Number of NHRP entries with same NBMA peer
        NHS Status: E --> Expecting Replies, R --> Responding
        UpDn Time --> Up or Down Time for a Tunnel
==========================================================================
Tunnel31 is admin down
Tunnel31 is admin down

Interface: Tunnel301, IPv4 NHRP Details 
Type:Hub/Spoke, NHRP Peers:3, 

 # Ent  Peer NBMA Addr Peer Tunnel Add State  UpDn Tm Attrb
 ----- --------------- --------------- ----- -------- -----
     2     202.100.1.3    20.169.169.1    UP 00:11:25     D
                          20.169.169.1    UP 00:11:25    DX
     1     202.100.1.4    20.169.169.2    UP 00:10:21    DN
     1     202.100.1.2  20.169.169.253    UP 00:26:45     S

CHINA-1#

CHINA-2#show dmvpn
Legend: Attrb --> S - Static, D - Dynamic, I - Incomplete
        N - NATed, L - Local, X - No Socket
        # Ent --> Number of NHRP entries with same NBMA peer
        NHS Status: E --> Expecting Replies, R --> Responding
        UpDn Time --> Up or Down Time for a Tunnel
==========================================================================
Tunnel32 is admin down
Tunnel32 is admin down

Interface: Tunnel302, IPv4 NHRP Details 
Type:Hub/Spoke, NHRP Peers:3, 

 # Ent  Peer NBMA Addr Peer Tunnel Add State  UpDn Tm Attrb
 ----- --------------- --------------- ----- -------- -----
     1     202.100.1.3    20.169.169.1    UP 00:11:54     D
     2     202.100.1.4    20.169.169.2    UP 00:10:59    DN
                          20.169.169.2    UP 00:10:59   DNX
     1     202.100.1.1  20.169.169.254    UP 00:27:04     S
###
  CHINA-1#show ip os neighbor 

Neighbor ID     Pri   State           Dead Time   Address         Interface
150.1.1.2         0   FULL/  -        00:01:34    20.169.169.2    Tunnel301
150.1.1.1         0   FULL/  -        00:01:38    20.169.169.1    Tunnel301
31.31.31.31       0   FULL/  -        00:00:36    20.169.169.253  Tunnel301
CHINA-1#

CHINA-2#show ip os neighbor 

Neighbor ID     Pri   State           Dead Time   Address         Interface
150.1.1.2         0   FULL/  -        00:01:47    20.169.169.2    Tunnel302
150.1.1.1         0   FULL/  -        00:01:51    20.169.169.1    Tunnel302
30.30.30.30       0   FULL/  -        00:01:48    20.169.169.254  Tunnel302
CHINA-2#

CHINA-CLIENT-USER1-WITHOUT-NAT#show ip os neighbor 

Neighbor ID     Pri   State           Dead Time   Address         Interface
30.30.30.30       0   FULL/  -        00:01:32    20.169.169.254  Tunnel0
31.31.31.31       0   FULL/  -        00:01:59    20.169.169.253  Tunnel0
CHINA-CLIENT-USER1-WITHOUT-NAT#

CHINA-CLIENT-USER2-NAT# show ip os neighbor 

Neighbor ID     Pri   State           Dead Time   Address         Interface
30.30.30.30       0   FULL/  -        00:01:50    20.169.169.254  Tunnel0
31.31.31.31       0   FULL/  -        00:01:48    20.169.169.253  Tunnel0
CHINA-CLIENT-USER2-NAT#

CHINA_NAT_DEVICE# show ip nat translations 
Pro Inside global      Inside local       Outside local      Outside global
gre 202.100.1.4:0      10.1.1.1:0         202.100.1.1:0      202.100.1.1:0
gre 202.100.1.4:0      10.1.1.1:0         202.100.1.2:0      202.100.1.2:0
gre 202.100.1.4:0      10.1.1.1:0         202.100.1.3:0      202.100.1.3:0
udp 202.100.1.4:4500   10.1.1.1:4500      202.100.1.1:4500   202.100.1.1:4500
udp 202.100.1.4:4500   10.1.1.1:4500      202.100.1.2:4500   202.100.1.2:4500
CHINA_NAT_DEVICE#

CHINA-1#show cry engine connections active 
Crypto Engine Connections

   ID  Type    Algorithm           Encrypt  Decrypt LastSeqN IP-Address
    1  IPsec   SHA                       0      171      174 202.100.1.1
    2  IPsec   SHA                     175        0        0 202.100.1.1
    3  IPsec   SHA                       0       69       76 202.100.1.1
    4  IPsec   SHA                      72        0        0 202.100.1.1
    5  IPsec   SHA                       0       68       70 202.100.1.1
    6  IPsec   SHA                      72        0        0 202.100.1.1
 1001  IKE     SHA+AES256                0        0        0 202.100.1.1
 1006  IKE     SHA+AES256                0        0        0 202.100.1.1
 1007  IKE     SHA+AES256                0        0        0 202.100.1.1

CHINA-1#
```

## spoke to spoke
```bash
  CHINA-CLIENT-USER1-WITHOUT-NAT#ping 150.1.1.2

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 150.1.1.2, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 104/108/116 ms
CHINA-CLIENT-USER1-WITHOUT-NAT#trac
CHINA-CLIENT-USER1-WITHOUT-NAT#traceroute 150.1.1.2

Type escape sequence to abort.
Tracing the route to 150.1.1.2

  1 20.169.169.2 92 msec 112 msec 100 msec
CHINA-CLIENT-USER1-WITHOUT-NAT#

CHINA-CLIENT-USER1-WITHOUT-NAT#show ip nhrp       
20.169.169.1/32 via 20.169.169.1
   Tunnel0 created 00:23:04, expire 01:36:55
   Type: dynamic, Flags: router unique local 
   NBMA address: 202.100.1.3 
    (no-socket) 
20.169.169.2/32 via 20.169.169.2
   Tunnel0 created 00:17:44, expire 01:42:17
   Type: dynamic, Flags: router 
   NBMA address: 202.100.1.4 
    (Claimed NBMA address: 10.1.1.1) 
20.169.169.253/32 via 20.169.169.253
   Tunnel0 created 00:23:16, never expire 
   Type: static, Flags: used 
   NBMA address: 202.100.1.2 
20.169.169.254/32 via 20.169.169.254
   Tunnel0 created 00:23:16, never expire 
   Type: static, Flags: used 
   NBMA address: 202.100.1.1 
150.1.1.1/32 via 20.169.169.1
   Tunnel0 created 00:17:42, expire 01:42:21
   Type: dynamic, Flags: router unique local 
   NBMA address: 202.100.1.3 
    (no-socket) 
150.1.1.2/32 via 20.169.169.2
   Tunnel0 created 00:21:36, expire 01:38:33
   Type: dynamic, Flags: router used 
   NBMA address: 202.100.1.4 
    (Claimed NBMA address: 10.1.1.1) 
CHINA-CLIENT-USER1-WITHOUT-NAT#
```