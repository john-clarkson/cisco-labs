#!bin/bash

echo "https://platform9.com/blog/container-namespaces-deep-dive-container-networking/"

sleep 5


echo -e ' 
host br-2fe89d7916b7<------------->frr eth1 
  fc00:169:254::1/64<------------->fc00:169:254::2/64
  172.22.0.1<--------------------->172.22.0.2


docker ps
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                                            NAMES
7a989e7cfc16        ajones17/frr:latest   "/sbin/tini -- /usr/…"   3 days ago          Up 50 minutes   


  pid="$(docker inspect -f '{{.State.Pid}}' "7a989e7cfc16")"
  #echo $pid
   29820
 docker run --name frr -it busyfrr
/ #
Now from another tab, run steps 1,2 and 3:

$ docker run --name frr -it busyfrr
$ pid="$(docker inspect -f '{{.State.Pid}}' "7a989e7cfc16")"
$ echo $pid
2620
$ sudo mkdir -p /var/run/netns
$ sudo ln -s /proc/$pid/ns/net /var/run/netns/frr
$ ip netns
frr
$ ip netns exec frr ip a
$ sudo ip netns exec frr ip a
ip netns exec frr ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
14: eth0@if15: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.18.0.2/16 brd 172.18.255.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fc00:f853:ccd:e793::2/64 scope global nodad 
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe12:2/64 scope link 
       valid_lft forever preferred_lft forever
27: eth1@if28: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:16:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.22.0.2/16 brd 172.22.255.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fc00:169:254::2/64 scope global nodad 
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe16:2/64 scope link 
       valid_lft forever preferred_lft forever

  unlink frr     
'