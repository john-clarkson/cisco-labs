﻿
hostname XR-P6
interface Loopback0
 ipv4 address 100.64.1.6 255.255.255.255
!
interface MgmtEth0/0/CPU0/0
 shutdown
!
interface GigabitEthernet0
 no shutdown
interface GigabitEthernet0/0/0/0.16
 ipv4 address 169.254.16.6 255.255.255.0
 encapsulation dot1q 16
!
interface GigabitEthernet0/0/0/0.56
 ipv4 address 169.254.56.6 255.255.255.0
 encapsulation dot1q 56
!

router isis fuck
 log ad ch
 is-type level-2-only
 net 49.0001.0000.0006.00
 address-family ipv4 unicast
  metric-style wide
  segment-routing mpls
 !
 interface Loopback0
  address-family ipv4 unicast
   prefix-sid index 6
  !
 !
 interface GigabitEthernet0/0/0/0.16
  point-to-point
  address-family ipv4 unicast
   fast-reroute per-prefix
 fast-reroute per-prefix ti-lfa

  !
 !
 interface GigabitEthernet0/0/0/0.56
  point-to-point
  address-family ipv4 unicast
   fast-reroute per-prefix
 fast-reroute per-prefix ti-lfa
  !
 !
 
 !
!
segment-routing
!
commit
end

