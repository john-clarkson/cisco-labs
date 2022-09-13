# BGP Aggregation
### Can be applied at any point in the network as long as one subnets is in the BGP table.
 
 configured as aggregate-address [network] [mask] [args]
 


## USA
```bash
155.155.155.1/24
155.155.155.2/24
            0000 0001
            0000 0010
            25 26 27 28 29 30

 155.155.155.0/28 = 255.255.255.248


185.51.0.0/16
185.52.0.0/16
185.53.0.0/16

    0000 0000
    128 64 32 16 8 4 2 1
    0   0  1   1 0 0 1 1 =51
    0   0  1   1 0 1 0 0 =52
    0   0  1   1 0 1 0 1 =53
185.48.0.0/13 = 255.248.0.0
```
```bash
USA-1/2#sh run | sec router bgp
router bgp 65556
 address-family ipv4
  aggregate-address 185.48.0.0 255.248.0.0 as-set summary-only
  aggregate-address 155.155.155.0 255.255.255.240 as-set summary-only

USA-1# show ip bgp
BGP table version is 263, local router ID is 50.50.50.50
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
.....
* i155.155.155.0/28 142.100.65.2        101376    100      0 ?
*>                  0.0.0.0                       100  32768 ?
s> 155.155.155.1/32 55.55.55.1          156160         32768 ?
s> 155.155.155.2/32 15.15.15.1          156160         32768 ?
*> 169.169.254.8/30 169.169.254.22                         0 9000 65533 i
.....
* i185.48.0.0/13    142.100.65.2        101376    100      0 ?
*>                  0.0.0.0                       100  32768 ?
s> 185.51.0.0       192.168.5.1         156160         32768 ?
s> 185.52.0.0       192.168.5.1         156160         32768 ?
s> 185.53.0.0       192.168.5.1         156160         32768 ?
USA-1#  
```
```bash
USA-1#show ip bgp neighbors 169.169.254.22 advertised-routes 
BGP table version is 263, local router ID is 50.50.50.50
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 5.5.5.0/24       192.168.5.1          28416         32768 ?
*> 15.15.15.0/24    0.0.0.0                  0         32768 ?
*> 25.25.25.0/24    15.15.15.1           30720         32768 ?
*> 50.50.50.0/24    0.0.0.0                  0         32768 ?
*> 51.51.51.0/24    192.168.5.1         156416         32768 ?
*> 52.52.52.0/24    55.55.55.1           30720         32768 ?
*> 55.55.55.0/24    0.0.0.0                  0         32768 ?
*> 155.155.155.0/28 0.0.0.0                       100  32768 ?
*> 169.169.254.20/30
                    0.0.0.0                  0         32768 i
*> 169.169.254.24/30
                    192.168.5.1         101376         32768 ?
*> 185.48.0.0/13    0.0.0.0                       100  32768 ?
*> 192.168.5.0      0.0.0.0                  0         32768 ?
*> 192.168.50.0     192.168.5.1          28416         32768 ?

Total number of prefixes 13 
USA-1# 
```
```bash
ip route 155.155.155.0 255.255.255.240 Null0 name REPLACE-BGP-NULL0
ip route 185.48.0.0 255.248.0.0 Null0 name REPLACE-BGP-NULL0
```
## CHINA
```bash
 USA-1#show ip bgp regexp 9000|65533
BGP table version is 291, local router ID is 50.50.50.50
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 3.3.3.0/24       169.169.254.22                         0 9000 65533 ?
* i                 142.100.65.2             0    100      0 9000 65533 ?
*> 30.30.30.0/24    169.169.254.22                         0 9000 65533 i
* i                 142.100.65.2             0    100      0 9000 65533 i
*> 31.31.31.0/24    169.169.254.22                         0 9000 65533 i
* i                 142.100.65.2             0    100      0 9000 65533 i
*> 38.38.38.0/24    169.169.254.22                         0 9000 65533 ?
* i                 142.100.65.2             0    100      0 9000 65533 ?
*> 39.39.39.0/24    169.169.254.22                         0 9000 65533 ?
* i                 142.100.65.2             0    100      0 9000 65533 ?
*> 169.169.254.8/30 169.169.254.22                         0 9000 65533 i
* i                 142.100.65.2             0    100      0 9000 65533 i
*> 183.31.0.0       169.169.254.22                         0 9000 65533 ?
* i                 142.100.65.2             0    100      0 9000 65533 ?
*> 183.32.0.0       169.169.254.22                         0 9000 65533 ?
* i                 142.100.65.2             0    100      0 9000 65533 ?
*> 183.33.0.0       169.169.254.22                         0 9000 65533 ?
* i                 142.100.65.2             0    100      0 9000 65533 ?
*> 192.168.3.0      169.169.254.22                         0 9000 65533 ?
* i                 142.100.65.2             0    100      0 9000 65533 ?
*> 192.168.30.0     169.169.254.22                         0 9000 65533 ?
* i                 142.100.65.2             0    100      0 9000 65533 ?
USA-1#
```
```bash
30.30.30.0
31.31.31.0

38.38.38.0
39.39.39.0

0001 1110 =30
0001 1111 =31
 30.0.0.0/7 = 254.0.0.0

0010 0110 =38
0010 0111 =39
 38.0.0.0/7 = 254.0.0.0





183.31.0.0
183.32.0.0
183.33.0.0
    0001 1111 =31
    0010 0000 =32
    0010 0001 =33
183.0.0.0/8+2=10 255.192.0.0
```
```bash
router bgp 65533
 address-family ipv4
  aggregate-address 30.0.0.0 254.0.0.0 as-set summary-only
  aggregate-address 38.0.0.0 254.0.0.0 as-set summary-only
  aggregate-address 183.0.0.0 255.192.0.0 as-set summary-only

  ip route 183.0.0.0 255.192.0.0 Null0 name REPLACE-BGP-NULL0
  ip route 38.0.0.0 254.0.0.0 Null0 name REPLACE-BGP-NULL0
  ip route  30.0.0.0 254.0.0.0 Null0 name REPLACE-BGP-NULL0

  ====================
  USA-1#show ip bgp regexp ^$
BGP table version is 344, local router ID is 50.50.50.50
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 5.5.5.0/24       192.168.5.1          28416         32768 ?
* i                 142.100.65.2         28416    100      0 ?
* i15.15.15.0/24    142.100.65.2         30720    100      0 ?
*>                  0.0.0.0                  0         32768 ?
* i25.25.25.0/24    142.100.65.2             0    100      0 ?
*>                  15.15.15.1           30720         32768 ?
* i50.50.50.0/24    142.100.65.2        156416    100      0 ?
*>                  0.0.0.0                  0         32768 ?
*> 51.51.51.0/24    192.168.5.1         156416         32768 ?
* i                 142.100.65.2             0    100      0 ?
* i52.52.52.0/24    142.100.65.2             0    100      0 ?
*>                  55.55.55.1           30720         32768 ?
* i55.55.55.0/24    142.100.65.2         30720    100      0 ?
*>                  0.0.0.0                  0         32768 ?
r i155.155.155.0/28 142.100.65.2             0    100      0 ?
r>                  0.0.0.0                       100  32768 ?
s> 155.155.155.1/32 55.55.55.1          156160         32768 ?
s> 155.155.155.2/32 15.15.15.1          156160         32768 ?
* i169.169.254.20/30
                    142.100.65.2        101376    100      0 ?
*>                  0.0.0.0                  0         32768 i
*> 169.169.254.24/30
                    192.168.5.1         101376         32768 ?
* i                 142.100.65.2             0    100      0 i
r i185.48.0.0/13    142.100.65.2             0    100      0 ?
r>                  0.0.0.0                       100  32768 ?
s> 185.51.0.0       192.168.5.1         156160         32768 ?
s> 185.52.0.0       192.168.5.1         156160         32768 ?
s> 185.53.0.0       192.168.5.1         156160         32768 ?
*> 192.168.5.0      0.0.0.0                  0         32768 ?
*> 192.168.50.0     192.168.5.1          28416         32768 ?
* i                 142.100.65.2             0    100      0 ?
USA-1#
```

```bash
USA-1#show ip bgp rib-failure 
Network            Next Hop                      RIB-failure   RIB-NH Matches
155.155.155.0/28   0.0.0.0             Higher admin distance              n/a
185.48.0.0/13      0.0.0.0             Higher admin distance              n/a

```



