Statefull NAT64 – simple configuration example on Cisco routers
The example shows a simplified configuration of a Statefull NAT64 demo, without DNS64. I instruct the stateful NAT64 router (CSR-1 – CSR100v) to translate IPv6 packets into IPv4 packets (and vice versa) using algorithmic mapping (defined by RFC 6052) of IPv4 addresses of IPv4 routers to and from IPv6 addresses by using manually defined IPv6 prefix 2001:db8::/96). In a similar manner, the IPv6 addresses of IPv6 routes are translated to and from IPv4 addresses.

Topology

R1/R2 run 7200 IOS image., R1 is pure IPv4 router, on the other site, R2 is IPv6 only.

CSR-1 is CSR1000v router running NAT64 (7200 IOS does not support NAT64).

Initial configuration
Initial configuration includes the setting of basic IP addessing, enabling the IPv6 routing and specifiyng static routes.

R1	CSR	R2
enable
conf t
hostname v4-Only
int fa 0/0
ip address 192.168.1.1 255.255.255.0
no shut
exit
ip route 0.0.0.0 0.0.0.0 fa0/0 192.168.1.2
end	enable
conf t
hostname NAT64
ipv6 unicast-routing
int g1
ip address 192.168.1.2 255.255.255.0
no shut
int gi 2
ipv6 add 2001:FEFE::2/64
ipv6 address FE80::2 link-local
no shut
end	enable
conf t
hostname v6-Only
ipv6 unicast-routing
int fa0/0
ipv6 add 2001:FEFE::3/64
ipv6 address FE80::3 link-local
no shut
exit
ipv6 route ::/0 fa0/0 2001:FEFE::2
end
Configuration of NAT64
Case 1) Address NAT64 translation with a pool of IPv4 addresses
In this example, we are using manually defined IPv6 prefix 2001:db8::/96 and pool of IPv4 addresses <158.193.1.1 158.193.1.10>


!configuration of NAT64/Port NAT64
 ena
 conf t
 int gi 1
   ! Enables Stateful NAT64 translation
   nat64 enable
   exit
 int gi 2
   ! Enables Stateful NAT64 translation
   nat64 enable
   exit
 !
 ! Defines an IPv6 access list, that controlls the translation
 ipv6 access-list NAT-64-ACL
     permit ipv6 2001:FEFE::/64 2001:db8::/96
 !
 ! define IPv6 prefix used for NAT64 translation purposes
 nat64 prefix stateful 2001:db8::/96
!
! define IPv4 address pool used for NAT64 translation purposes
nat64 v4 pool NAT64-POOL 158.193.1.1 158.193.1.10
 ! 
 ! NAT64 translation
 nat64 v6v4 list NAT-64-ACL pool NAT64-POOL
Verification
Simple ping from v6-Only router to 192.168.1.1 of v4-Only router:

v6-Only#ping 2001:db8::192.168.1.1
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 2001:DB8::C0A8:101, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 8/8/8 ms
and watch NAT64 translation table:

NAT64(config)# do sh nat64 tranlation
 Proto  Original IPv4         Translated IPv4
        Translated IPv6       Original IPv6
 illegal ---                   ---
        158.193.1.1           2001:fefe::3
 icmp   192.168.1.1:609       [2001:db8::c0a8:101]:609
        158.193.1.1:609       [2001:fefe::3]:609
 Total number of translations: 2
Case 2) Port address NAT64 translation with a pool of IPv4 addresses
Just replace

 ! NAT64 translation
 no nat64 v6v4 list NAT-64-ACL pool NAT64-POOL
with

 ! Port NAT64 translation
 nat64 v6v4 list NAT-64-ACL pool NAT64-POOL overload
Case 3) Static address NAT64 translation
Configure NAT64 as mentioned previously and add a static NAT mapping. If the IPv4 pool is used, the IPv4 address used for mapping must be out of the pool.

nat64 v6v4 static 2001:FEFE::3 158.193.1.11
Verification
v6-Only#ping 2001:db8::192.168.1.2
 Type escape sequence to abort.
 Sending 5, 100-byte ICMP Echos to 2001:DB8::C0A8:102, timeout is 2 seconds:
 !!!!!
 Success rate is 100 percent (5/5), round-trip min/avg/max = 4/16/44 ms
and

NAT64(config)#do sh nat64 tra
 Proto  Original IPv4         Translated IPv4
        Translated IPv6       Original IPv6
 illegal ---                   ---

 icmp   192.168.1.2:736       [2001:db8::c0a8:102]:736
        158.193.1.11:736      [2001:fefe::3]:736
Case 4) Using Well Known Prefix
Cisco documentation claims that:

The Well Known Prefix 64:FF9B::/96 is supported for Stateful NAT64. During a stateful translation, if no stateful prefix is configured (either on the interface or globally), the WKP prefix is used to translate the IPv4 host addresses.

But this use case does not work for me.

Other verification commands
show nat64 aliases [lower-address-range upper-address-range]
show nat64 logging
show nat64 prefix stateful {global | {interfaces | static-routes} [prefix ipv6-address/prefix-length]}
show nat64 timeouts