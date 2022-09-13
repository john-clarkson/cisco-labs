﻿

## eve-ng setting fortigate firewall bridge to pnet0 interface as the mgmt.
```bash
FortiGate-VM64-KVM # config system interface

FortiGate-VM64-KVM (interface) # edit port1

FortiGate-VM64-KVM (port1) # set ip 150.1.54.254 255.255.0.0

FortiGate-VM64-KVM (port1) # set allowaccess ping http https ssh

FortiGate-VM64-KVM (port1) # end

FG-1 # show router static 
seq-num    Entry number. (0-4294967295)
1  

FG-1 # show router static 
config router static
    edit 1
        set gateway 10.21.0.1
        set device "port2"
    next
end

FG-1 # execute ping 10.21.0.1
PING 10.21.0.1 (10.21.0.1): 56 data bytes
64 bytes from 10.21.0.1: icmp_seq=0 ttl=255 time=7.3 ms
64 bytes from 10.21.0.1: icmp_seq=1 ttl=255 time=5.0 ms
^C

```



