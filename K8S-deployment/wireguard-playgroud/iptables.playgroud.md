# 1.slave3 wireguard pod testing

iptables -t nat -A = add rule
iptables -t nat -D = del rule

## login wireguard pod
kubectl exec -ti -n wireguard wireguard bash

## one to one base DNAT
iptables -t nat -A PREROUTING -d <dnat-ip-address> -j DNAT --to-destination <real-ip-address>

iptables -t nat -A PREROUTING -d 1.2.3.4 -j DNAT --to-destination 10.233.158.244

iptables -L -t nat

## network subnet base DNAT
root@wireguard:/# iptables -t nat -A PREROUTING -d <dnat-subnet/24> -j NETMAP --to <real-subnet/24>

root@wireguard:/# iptables -t nat -A PREROUTING -d 172.16.33.0/24 -j NETMAP --to 10.233.158.0/24
## check
root@wireguard:/# iptables -L -t nat
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
DNAT       all  --  anywhere             1.2.3.4              to:10.233.158.244
NETMAP     all  --  anywhere             172.16.33.0/24      to:10.233.158.0/24

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  anywhere             anywhere
root@wireguard:/#


## macos client
╰─ ping 172.16.33.242
PING 172.16.33.242 (172.16.33.242): 56 data bytes
64 bytes from 172.16.33.242: icmp_seq=0 ttl=62 time=0.986 ms
64 bytes from 172.16.33.242: icmp_seq=1 ttl=62 time=1.096 ms
^C
--- 172.16.33.242 ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.986/1.041/1.096/0.055 ms


## packets flow
macos ip---<wg vpn> wgserver--->pod
                       |wg-iptables
s-ip 192.168.33.2-------|snat->wg-eth0
d-ip 172.16.33.242-----|dnat->10.233.158.242
## network subnet base snat
iptables -t nat -A POSTROUTING -s <snat-subnet/24> -j NETMAP --to <real-subnet/24>


# 2. host os ubuntu for overlapping k8s testing
iptables -t nat -A PREROUTING -d 10.252.0.0/24 -j NETMAP --to 10.255.0.0/24
iptables -L -t nat | grep NETMAP


iptables -t nat -A PREROUTING -d 192.168.44.0/24  -j NETMAP --to 10.233.0.0/24


