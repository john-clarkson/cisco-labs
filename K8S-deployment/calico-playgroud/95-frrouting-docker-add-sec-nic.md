# How to add sec nic inside container by using docker

# Description 
## You can use portainer WEB GUI to add additional network bridge naming SEC-BGP-TESTING
```
http://localhost:9000
Network>add network
Name:
 SEC-BGP-TESTING
Driver:bridge
ipv4 network configuration
subnet:
 100.64.255.0/24
gateway:
 100.64.255.254/24
ip range:
 100.64.255.0/24 
click create network 
```
## SEC-BGP-TESTING is the 2nd bridge that we created, frrouting is the name of the container.
##  
### $docker network connect SEC-BGP-TESTING frrouting
### $docker exec -ti frrouting sh
## 
```sh
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
25: eth0@if26: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:12:00:05 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.18.0.5/16 brd 172.18.255.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fc00:f853:ccd:e793::5/64 scope global nodad 
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe12:5/64 scope link 
       valid_lft forever preferred_lft forever
28: eth1@if29: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:64:40:ff:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 100.64.255.2/24 brd 100.64.255.255 scope global eth1
       valid_lft forever preferred_lft forever
/ # 
```
