# XR-PE
```bash
mpls traffic-eng
 pce
  peer ipv4 150.1.255.253
  !
  segment-routing
  stateful-client
   instantiation
  !
 !
 auto-tunnel pcc
  tunnel-id min 1 max 99
 !
 reoptimize timers delay installation 0
 ```
 