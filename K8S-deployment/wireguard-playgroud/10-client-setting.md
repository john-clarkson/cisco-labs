djohnhttps://www.youtube.com/watch?v=7yC-gJtl9mQ&t=1002s

```sh
inside wildguardpod=by default=0

kubectl exec -ti -n wireguard wireguard bash
sysctl net.ipv4.ip_forward=1
sysctl -p
sysctl --system
sysctl -a | grep net.ipv4.ip_forward

```
```sh
# copy peer config from server
$ scp -r djohn@10.211.55.7:/mnt/data .
# modify peer dst ip
cd data/peer1
nano peer1.conf
djohn@k8s-slave1:~/data/peer1$ cat peer1.conf
[Interface]
Address = 192.168.1.2
PrivateKey = +PaZLBC3LhbsT/0qVnkVmUbjQp31Eij7ybTUHS7k228=
ListenPort = 51820
DNS = 10.22.22.10

[Peer]
PublicKey = Lc/KGs2yOHKdkBt0KLXQJcEX4n8hthPfyUUOBLTbQVY=
Endpoint = 10.211.55.7:31820
AllowedIPs = 0.0.0.0/0, ::/0
djohn@k8s-slave1:~/data/peer1$
# add peer config to nmcli
sudo nmcli connection import type wireguard file peer1.conf
# delete connection profile
sudo nmcli connection delete <uuid>
# check
sudo nmcli connection
sudo nmcli

```
```sh
$ sudo nmcli connection up peer1 
$ sudo nmcli connection down peer1 

djohn@k8s-slave1:~$ sudo nmcli connection up peer1
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/10)
djohn@k8s-slave1:~$
djohn@k8s-slave1:~$ ip route show
default via 10.211.55.1 dev enp0s5 proto static metric 100
10.22.22.0/24 dev peer1 proto static scope link metric 50
10.211.55.0/24 dev enp0s5 proto kernel scope link src 10.211.55.6 metric 100
10.255.0.0/16 dev peer1 proto static scope link metric 50
```sh
sudo nmcli dev set peer1 managed yes
sudo nmcli dev set peer1 managed no
sudo nmcli
```
```sh
# 192.168.1.1=wireguard server
# 10.255.92.15=pod ip
```sh
djohn@k8s-slave1:~/data/peer1$ tracepath 10.255.92.15
 1?: [LOCALHOST]                      pmtu 1420
 1:  192.168.1.1                                           0.819ms
 1:  192.168.1.1                                           0.348ms
 2:  10.211.55.7                                           0.556ms
 3:  10.255.92.15                                          0.996ms reached
     Resume: pmtu 1420 hops 3 back 3
djohn@k8s-slave1:~/data/peer1$ tracepath google.com
 1?: [LOCALHOST]                      pmtu 1420
 1:  192.168.1.1                                           0.632ms
 1:  192.168.1.1                                           0.682ms
 2:  10.211.55.7                                           0.762ms
```

```sh
# modify dns value to kube-dns-ip

sudo systemctl stop systemd-resolved.service 
sudo systemctl disable systemd-resolved.service
sudo nano /etc/resolv.conf
add nameserver 10.22.22.10
djohn@k8s-slave1:~$ sudo cat /etc/resolv.conf
sudo: unable to resolve host k8s-slave1: Name or service not known
# This file is managed by man:systemd-resolved(8). Do not edit.
#
# This is a dynamic resolv.conf file for connecting local clients to the
# internal DNS stub resolver of systemd-resolved. This file lists all
# configured search domains.
#
# Run "resolvectl status" to see details about the uplink DNS servers
# currently in use.
#
# Third party programs must not access this file directly, but only through the
# symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a different way,
# replace this symlink by a static file or a different symlink.
#
# See man:systemd-resolved.service(8) for details about the supported modes of
# operation for /etc/resolv.conf.
nameserver 10.22.22.10
nameserver 127.0.0.53
options edns0
```
```sh
# shortcut
sudo -i
echo "nameserver 10.22.22.10" >> /etc/resolv.conf

```

djohn@k8s-slave1:~/data/peer1$ ip a | grep peer1
4: peer1: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 192.168.1.2/32 scope global noprefixroute peer1
djohn@k8s-slave1:~/data/peer1$


─ ssh djohn@k8s-s1
djohn@k8s-s1's password:
djohn@k8s-slave1:~$ ping 10.211.55.7
PING 10.211.55.7 (10.211.55.7) 56(84) bytes of data.
64 bytes from 10.211.55.7: icmp_seq=1 ttl=64 time=0.627 ms
^C
--- 10.211.55.7 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.627/0.627/0.627/0.000 ms

djohn@k8s-slave1:~$ scp -r djohn@10.211.55.7:/mnt/data .
The authenticity of host '10.211.55.7 (10.211.55.7)' can't be established.
ECDSA key fingerprint is SHA256:tWRGUsxb+DdcgdejffU6pO6J3lyAMIYAOpeJaU3lAKo.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.211.55.7' (ECDSA) to the list of known hosts.
djohn@10.211.55.7's password:
sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
publickey-server                              100%   45    73.5KB/s   00:00
privatekey-server                             100%   45    75.8KB/s   00:00
peer.conf                                     100%  255   503.6KB/s   00:00
server.conf                                   100%  383   538.7KB/s   00:00
peer1.png                                     100% 1026     1.8MB/s   00:00
privatekey-peer1                              100%   45    73.6KB/s   00:00
publickey-peer1                               100%   45   105.1KB/s   00:00
peer1.conf                                    100%  267   543.1KB/s   00:00
.donoteditthisfile                            100%  171   353.1KB/s   00:00
wg0.conf                                      100%  487   768.2KB/s   00:00
Corefile                                      100%   45   124.5KB/s   00:00
djohn@k8s-slave1:~$

djohn@k8s-slave1:~$ cd data/
djohn@k8s-slave1:~/data$ ls
coredns  peer1  server  templates  wg0.conf
djohn@k8s-slave1:~/data$ cat wg0.conf
[Interface]
Address = 192.168.1.1
ListenPort = 51820
PrivateKey = 0OeBPf8KF6BEfG2D7H52wsUWp9zOjKljY4L/LhnZX2Q=
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
# peer1
PublicKey = S32Y4gLi/mdMU6trWiE3+yH9Bdm46ptaXyfKrHwxWHQ=
AllowedIPs = 192.168.1.2/32

djohn@k8s-slave1:~/data$ cd pper
-bash: cd: pper: No such file or directory
djohn@k8s-slave1:~/data$ cd pper
-bash: cd: pper: No such file or directory
djohn@k8s-slave1:~/data$ cd peer1/
djohn@k8s-slave1:~/data/peer1$ ls
peer1.conf  peer1.png  privatekey-peer1  publickey-peer1
djohn@k8s-slave1:~/data/peer1$ ls
peer1.conf  peer1.png  privatekey-peer1  publickey-peer1
djohn@k8s-slave1:~/data/peer1$ cat peer1.conf
[Interface]
Address = 192.168.1.2
PrivateKey = oFriYU6NRukv5Wep3ljpKeiVT5M9ukOiPlI59tNXRVk=
ListenPort = 51820
DNS = 10.22.22.10

[Peer]
PublicKey = C6ut8ZYgiLHjA5WRDPtIc9rs215K8AyXvyJ7SNtlr1s=
Endpoint = 45.117.99.230:51820
AllowedIPs = 10.255.0.0/16, 10.22.22.0/24
djohn@k8s-slave1:~/data/peer1$ nano peer1.conf
djohn@k8s-slave1:~/data/peer1$
djohn@k8s-slave1:~/data/peer1$ cat peer1.conf
[Interface]
Address = 192.168.1.2
PrivateKey = oFriYU6NRukv5Wep3ljpKeiVT5M9ukOiPlI59tNXRVk=
ListenPort = 51820
DNS = 10.22.22.10

[Peer]
PublicKey = C6ut8ZYgiLHjA5WRDPtIc9rs215K8AyXvyJ7SNtlr1s=
Endpoint = 10.211.55.7:31820
AllowedIPs = 10.255.0.0/16, 10.22.22.0/24
djohn@k8s-slave1:~/data/peer1$ ip route show
default via 10.211.55.1 dev enp0s5 proto static
10.211.55.0/24 dev enp0s5 proto kernel scope link src 10.211.55.6
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown
djohn@k8s-slave1:~/data/peer1$ docker ps
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.40/containers/json: dial unix /var/run/docker.sock: connect: permission denied

djohn@k8s-slave1:~/data/peer1$
djohn@k8s-slave1:~/data/peer1$
djohn@k8s-slave1:~/data/peer1$ clear
djohn@k8s-slave1:~/data/peer1$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:1c:42:4d:9e:6a brd ff:ff:ff:ff:ff:ff
    inet 10.211.55.6/24 brd 10.211.55.255 scope global enp0s5
       valid_lft forever preferred_lft forever
    inet6 fdb2:2c26:f4e4:0:21c:42ff:fe4d:9e6a/64 scope global dynamic mngtmpaddr noprefixroute
       valid_lft 2591629sec preferred_lft 604429sec
    inet6 fe80::21c:42ff:fe4d:9e6a/64 scope link
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:7c:ae:03:e1 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
djohn@k8s-slave1:~/data/peer1$ ip link add dev wg0 type wireguard
RTNETLINK answers: Operation not permitted
djohn@k8s-slave1:~/data/peer1$ sudo ip link add dev wg0 type wireguard
djohn@k8s-slave1:~/data/peer1$ wg
Unable to access interface wg0: Operation not permitted
djohn@k8s-slave1:~/data/peer1$ sudo wg
interface: wg0
djohn@k8s-slave1:~/data/peer1$ sudo wg setconf wg0 peer1.conf
Line unrecognized: `Address=192.168.1.2'
Configuration parsing error
djohn@k8s-slave1:~/data/peer1$ nmcli

Command 'nmcli' not found, but can be installed with:

sudo snap install network-manager  # version 1.2.2-28, or
sudo apt  install network-manager  # version 1.22.10-1ubuntu2.2

See 'snap info network-manager' for additional versions.

djohn@k8s-slave1:~/data/peer1$ sudo apt  install network-manager
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  libbluetooth3 libjansson4 libmbim-glib4 libmbim-proxy libmm-glib0 libndp0
  libnl-route-3-200 libnm0 libpcsclite1 libqmi-glib5 libqmi-proxy libteamdctl0
  modemmanager network-manager-pptp ppp pptp-linux usb-modeswitch usb-modeswitch-data
  wpasupplicant
Suggested packages:
  pcscd avahi-autoipd libteam-utils comgt wvdial wpagui libengine-pkcs11-openssl
The following NEW packages will be installed:
  libbluetooth3 libjansson4 libmbim-glib4 libmbim-proxy libmm-glib0 libndp0
  libnl-route-3-200 libnm0 libpcsclite1 libqmi-glib5 libqmi-proxy libteamdctl0
  modemmanager network-manager network-manager-pptp ppp pptp-linux usb-modeswitch
  usb-modeswitch-data wpasupplicant
0 upgraded, 20 newly installed, 0 to remove and 94 not upgraded.
Need to get 5756 kB of archives.
After this operation, 23.5 MB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://hk.archive.ubuntu.com/ubuntu focal/main amd64 libbluetooth3 amd64 5.53-0ubuntu3 [60.1 kB]
Get:2 http://hk.archive.ubuntu.com/ubuntu focal/main amd64 libjansson4 amd64 2.12-1build1 [28.9 kB]
Get:3 http://hk.archive.ubuntu.com/ubuntu focal/main amd64 libmbim-glib4 amd64 1.22.0-2 [101 kB]
Get:4 http://hk.archive.ubuntu.com/ubuntu focal/main amd64 libmbim-proxy amd64 1.22.0-2 [5908 B]
Get:5 http://hk.archive.ubuntu.com/ubuntu focal/main amd64 libmm-glib0 amd64 1.12.8-1 [185 kB]
Get:6 http://hk.archive.ubuntu.com/ubuntu focal/main amd64 libndp0 amd64 1.7-0ubuntu1 [10.9 kB]
Get:7 http://hk.archive.ubuntu.com/ubuntu focal/main amd64 libnl-route-3-200 amd64 3.4.0-1 [149 kB]
Get:8 http://hk.archive.ubuntu.com/ubuntu focal-updates/main amd64 libnm0 amd64 1.22.10-1ubuntu2.2 [369 kB]
Get:9 http://hk.archive.ubuntu.com/ubuntu focal/main amd64 libpcsclite1 amd64 1.8.26-3 [22.0 kB]
Get:10 http://hk.archive.ubuntu.com/ubuntu focal/main amd64 libqmi-glib5 amd64 1.24.8-1 [529 kB]
Get:11 http://hk.archive.ubuntu.com/ubuntu focal/main amd64 libqmi-proxy amd64 1.24.8-1 [5856 B]
Get:12 http://hk.archive.ubuntu.com/ubuntu focal/main amd64 libteamdctl0 amd64 1.30-1 [11.8 kB]
Get:13 http://hk.archive.ubuntu.com/ubuntu focal/main amd64 modemmanager amd64 1.12.8-1 Created symlink /etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service → /lib/systemd/system/NetworkManager-wait-online.service.
Created symlink /etc/systemd/system/multi-user.target.wants/NetworkManager.service → /lib/systemd/system/NetworkManager.service.
Setting up network-manager-pptp (1.2.8-2) ...
Setting up libqmi-proxy (1.24.8-1) ...
Setting up modemmanager (1.12.8-1) ...
Created symlink /etc/systemd/system/dbus-org.freedesktop.ModemManager1.service → /lib/systemd/system/ModemManager.service.
Created symlink /etc/systemd/system/multi-user.target.wants/ModemManager.service → /lib/systemd/system/ModemManager.service.
Processing triggers for systemd (245.4-4ubuntu3.2) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for dbus (1.12.16-2ubuntu2.1) ...
Processing triggers for libc-bin (2.31-0ubuntu9) ...
djohn@k8s-slave1:~/data/peer1$ sudo ip del add dev wg0 type wireguard
Object "del" is unknown, try "ip help".
djohn@k8s-slave1:~/data/peer1$ sudo ip del add dev wg0
Object "del" is unknown, try "ip help".
djohn@k8s-slave1:~/data/peer1$ sudo ip del dev wg0
Object "del" is unknown, try "ip help".
djohn@k8s-slave1:~/data/peer1$ sudo ip del dev wg0 type wireguard
Object "del" is unknown, try "ip help".
djohn@k8s-slave1:~/data/peer1$ ip help
Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }
       ip [ -force ] -batch filename
where  OBJECT := { link | address | addrlabel | route | rule | neigh | ntable |
                   tunnel | tuntap | maddress | mroute | mrule | monitor | xfrm |
                   netns | l2tp | fou | macsec | tcp_metrics | token | netconf | ila |
                   vrf | sr | nexthop }
       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |
                    -h[uman-readable] | -iec | -j[son] | -p[retty] |
                    -f[amily] { inet | inet6 | mpls | bridge | link } |
                    -4 | -6 | -I | -D | -M | -B | -0 |
                    -l[oops] { maximum-addr-flush-attempts } | -br[ief] |
                    -o[neline] | -t[imestamp] | -ts[hort] | -b[atch] [filename] |
                    -rc[vbuf] [size] | -n[etns] name | -N[umeric] | -a[ll] |
                    -c[olor]}
djohn@k8s-slave1:~/data/peer1$ sudo ip link del dev wg0 type wireguard
djohn@k8s-slave1:~/data/peer1$
djohn@k8s-slave1:~/data/peer1$
djohn@k8s-slave1:~/data/peer1$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:1c:42:4d:9e:6a brd ff:ff:ff:ff:ff:ff
    inet 10.211.55.6/24 brd 10.211.55.255 scope global enp0s5
       valid_lft forever preferred_lft forever
    inet6 fdb2:2c26:f4e4:0:21c:42ff:fe4d:9e6a/64 scope global dynamic mngtmpaddr noprefixroute
       valid_lft 2591838sec preferred_lft 604638sec
    inet6 fe80::21c:42ff:fe4d:9e6a/64 scope link
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:7c:ae:03:e1 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
djohn@k8s-slave1:~/data/peer1$
djohn@k8s-slave1:~/data/peer1$
djohn@k8s-slave1:~/data/peer1$
djohn@k8s-slave1:~/data/peer1$ nmcli
docker0: unmanaged
        "docker0"
        bridge, 02:42:7C:AE:03:E1, sw, mtu 1500

enp0s5: unmanaged
        "Red Hat Virtio"
        ethernet (virtio_net), 00:1C:42:4D:9E:6A, hw, mtu 1500

lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

Use "nmcli device show" to get complete information about known devices and
"nmcli connection show" to get an overview on active connection profiles.

Consult nmcli(1) and nmcli-examples(7) manual pages for complete usage details.
djohn@k8s-slave1:~/data/peer1$ nmcli
con  dev  nm
djohn@k8s-slave1:~/data/peer1$ nmcli con
delete  down    list    status  up
djohn@k8s-slave1:~/data/peer1$ nmcli connect

djohn@k8s-slave1:~/data/peer1$ nmcli connection import type wireguard file peer1.conf
Error: Failed to add 'peer1' connection: Insufficient privileges
djohn@k8s-slave1:~/data/peer1$ sudo nmcli connection import type wireguard file peer1.conf
Connection 'peer1' (0adbd503-a393-4603-a003-5f905697f2f0) successfully added.
djohn@k8s-slave1:~/data/peer1$ nmcli connection up peer1
Error: Connection activation failed: Not authorized to control networking.
djohn@k8s-slave1:~/data/peer1$ sudo nmcli connection up peer1
Error: Connection activation failed: Activation failed because the device is unmanaged
djohn@k8s-slave1:~/data/peer1$ cat peer1.conf
[Interface]
Address = 192.168.1.2
PrivateKey = oFriYU6NRukv5Wep3ljpKeiVT5M9ukOiPlI59tNXRVk=
ListenPort = 51820
DNS = 10.22.22.10

[Peer]
PublicKey = C6ut8ZYgiLHjA5WRDPtIc9rs215K8AyXvyJ7SNtlr1s=
Endpoint = 10.211.55.7:31820
AllowedIPs = 10.255.0.0/16, 10.22.22.0/24
djohn@k8s-slave1:~/data/peer1$ sudo nmcli connection up peer1
Error: Connection activation failed: Connection 'peer1' is not available on device peer1 because device is strictly unmanaged
djohn@k8s-slave1:~/data/peer1$
djohn@k8s-slave1:~/data/peer1$ nmcli
docker0: unmanaged
        "docker0"
        bridge, 02:42:7C:AE:03:E1, sw, mtu 1500

enp0s5: unmanaged
        "Red Hat Virtio"
        ethernet (virtio_net), 00:1C:42:4D:9E:6A, hw, mtu 1500

lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

peer1: unmanaged
        "peer1"
        wireguard, sw, mtu 1420

Use "nmcli device show" to get complete information about known devices and
djohn@k8s-slave1:~/data/peer1$ nmcli
docker0: unmanaged
        "docker0"
        bridge, 02:42:7C:AE:03:E1, sw, mtu 1500

enp0s5: unmanaged
        "Red Hat Virtio"
        ethernet (virtio_net), 00:1C:42:4D:9E:6A, hw, mtu 1500

lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

peer1: unmanaged
        "peer1"
        wireguard, sw, mtu 1420

Use "nmcli device show" to get complete information about known devices and
djohn@k8s-slave1:~/data/peer1$ nmcli
con  dev  nm
djohn@k8s-slave1:~/data/peer1$ nmcli nm
enable       sleep        wifi         wwan
permissions  status       wimax
djohn@k8s-slave1:~/data/peer1$ nmcli nm enable
Error: argument 'nm' not understood. Try passing --help instead.
djohn@k8s-slave1:~/data/peer1$ cd /etc/
djohn@k8s-slave1:/etc$ cd NetworkManager/
djohn@k8s-slave1:/etc/NetworkManager$ ls
NetworkManager.conf  dispatcher.d      dnsmasq.d
conf.d               dnsmasq-shared.d  system-connections
djohn@k8s-slave1:/etc/NetworkManager$ cat NetworkManager.conf
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=false

[device]
wifi.scan-rand-mac-address=no
djohn@k8s-slave1:/etc/NetworkManager$ sudo nano NetworkManager.conf
djohn@k8s-slave1:/etc/NetworkManager$ cat NetworkManager.conf
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=no
djohn@k8s-slave1:/etc/NetworkManager$ nmcli
docker0: unmanaged
        "docker0"
        bridge, 02:42:7C:AE:03:E1, sw, mtu 1500

enp0s5: unmanaged
        "Red Hat Virtio"
        ethernet (virtio_net), 00:1C:42:4D:9E:6A, hw, mtu 1500

lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

peer1: unmanaged
        "peer1"
        wireguard, sw, mtu 1420

Use "nmcli device show" to get complete information about known devices and
djohn@k8s-slave1:/etc/NetworkManager$ systemctl restart NetworkManager
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to restart 'NetworkManager.service'.
Authenticating as: djohn
Password:
==== AUTHENTICATION COMPLETE ===
djohn@k8s-slave1:/etc/NetworkManager$ sudo systemctl restart NetworkManager
djohn@k8s-slave1:/etc/NetworkManager$ sudo systemctl status NetworkManager
● NetworkManager.service - Network Manager
     Loaded: loaded (/lib/systemd/system/NetworkManager.service; enabled; vendor preset>
     Active: active (running) since Sat 2021-01-30 15:11:36 UTC; 6s ago
       Docs: man:NetworkManager(8)
   Main PID: 17065 (NetworkManager)
      Tasks: 4 (limit: 2271)
     Memory: 3.6M
     CGroup: /system.slice/NetworkManager.service
             └─17065 /usr/sbin/NetworkManager --no-daemon

Jan 30 15:11:36 k8s-slave1 NetworkManager[17065]: <info>  [1612019496.6353] ifupdown:  >
Jan 30 15:11:36 k8s-slave1 NetworkManager[17065]: <info>  [1612019496.6436] device (lo)>
Jan 30 15:11:36 k8s-slave1 NetworkManager[17065]: <info>  [1612019496.6438] manager: (l>
Jan 30 15:11:36 k8s-slave1 NetworkManager[17065]: <info>  [1612019496.6443] manager: (d>
Jan 30 15:11:36 k8s-slave1 NetworkManager[17065]: <info>  [1612019496.6448] device (enp>
Jan 30 15:11:36 k8s-slave1 NetworkManager[17065]: <info>  [1612019496.6484] manager: (e>
Jan 30 15:11:36 k8s-slave1 NetworkManager[17065]: <info>  [1612019496.6500] manager: (p>
djohn@k8s-slave1:/etc/NetworkManager$
djohn@k8s-slave1:/etc/NetworkManager$ nm
nm-online       nmtui           nmtui-edit
nmcli           nmtui-connect   nmtui-hostname
djohn@k8s-slave1:/etc/NetworkManager$ nm
nm-online       nmtui           nmtui-edit
nmcli           nmtui-connect   nmtui-hostname
djohn@k8s-slave1:/etc/NetworkManager$ nm-applet

Command 'nm-applet' not found, but can be installed with:

sudo apt install network-manager-gnome

djohn@k8s-slave1:/etc/NetworkManager$ nmcli
docker0: unmanaged
        "docker0"
        bridge, 02:42:7C:AE:03:E1, sw, mtu 1500

enp0s5: unmanaged
        "Red Hat Virtio"
        ethernet (virtio_net), 00:1C:42:4D:9E:6A, hw, mtu 1500

lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

peer1: unmanaged
        "peer1"
        wireguard, sw, mtu 1420

Use "nmcli device show" to get complete information about known devices and
"nmcli connection show" to get an overview on active connection profiles.

Consult nmcli(1) and nmcli-examples(7) manual pages for complete usage details.
djohn@k8s-slave1:/etc/NetworkManager$ nmcli d
DEVICE   TYPE       STATE      CONNECTION
docker0  bridge     unmanaged  --
enp0s5   ethernet   unmanaged  --
lo       loopback   unmanaged  --
peer1    wireguard  unmanaged  --
djohn@k8s-slave1:/etc/NetworkManager$ nmcli dev set peer1 managed yes
djohn@k8s-slave1:/etc/NetworkManager$ nmcli d
DEVICE   TYPE       STATE      CONNECTION
docker0  bridge     unmanaged  --
enp0s5   ethernet   unmanaged  --
lo       loopback   unmanaged  --
peer1    wireguard  unmanaged  --
djohn@k8s-slave1:/etc/NetworkManager$ sudo nmcli dev set peer1 managed yes
djohn@k8s-slave1:/etc/NetworkManager$ nmcli d
DEVICE   TYPE       STATE      CONNECTION
docker0  bridge     unmanaged  --
enp0s5   ethernet   unmanaged  --
lo       loopback   unmanaged  --
peer1    wireguard  unmanaged  --
djohn@k8s-slave1:/etc/NetworkManager$ nmcli d
DEVICE   TYPE       STATE      CONNECTION
docker0  bridge     unmanaged  --
enp0s5   ethernet   unmanaged  --
lo       loopback   unmanaged  --
peer1    wireguard  unmanaged  --
djohn@k8s-slave1:/etc/NetworkManager$ cd ..
djohn@k8s-slave1:/etc$ ls
NetworkManager                 hosts.deny           popularity-contest.conf
PackageKit                     ifplugd              ppp
X11                            init                 preload.conf
adduser.conf                   init.d               profile
alternatives                   initramfs-tools      profile.d
apparmor                       inputrc              protocols
apparmor.d                     iproute2             python3
apport                         iscsi                python3.8
apt                            issue                rc0.d
at.deny                        issue.net            rc1.d
bash.bashrc                    kernel               rc2.d
bash_completion                kubernetes           rc3.d
bash_completion.d              landscape            rc4.d
bindresvport.blacklist         ld.so.cache          rc5.d
binfmt.d                       ld.so.conf           rc6.d
byobu                          ld.so.conf.d         rcS.d
ca-certificates                ldap                 resolv.conf
ca-certificates.conf           legal                rmt
ca-certificates.conf.dpkg-old  libaudit.conf        rpc
calendar                       libnl-3              rsyslog.conf
chatscripts                    locale.alias         rsyslog.d
cloud                          locale.gen           screenrc
cni                            localtime            security
console-setup                  logcheck             selinux
crictl.yaml                    login.defs           services
cron.d                         logrotate.conf       shadow
cron.daily                     logrotate.d          shadow-
cron.hourly                    lsb-release          shells
cron.monthly                   ltrace.conf          skel
cron.weekly                    lvm                  sos.conf
crontab                        machine-id           ssh
cryptsetup-initramfs           magic                ssl
crypttab                       magic.mime           subgid
dbus-1                         mailcap              subgid-
dconf                          mailcap.order        subuid
debconf.conf                   manpath.config       subuid-
debian_version                 mdadm                sudoers
default                        mime.types           sudoers.d
deluser.conf                   mke2fs.conf          sysctl.conf
depmod.d                       modprobe.d           sysctl.d
dhcp                           modules              systemd
dnsmasq.d                      modules-load.d       terminfo
docker                         mtab                 thermald
dpkg                           multipath            timezone
e2scrub.conf                   multipath.conf       tmpfiles.d
environment                    nanorc               ubuntu-advantage
ethertypes                     netplan              ucf.conf
fonts                          network              udev
fstab                          networkd-dispatcher  ufw
fuse.conf                      networks             update-manager
fwupd                          newt                 update-motd.d
gai.conf                       nsswitch.conf        update-notifier
groff                          opt                  usb_modeswitch.conf
group                          os-release           usb_modeswitch.d
group-                         overlayroot.conf     vim
grub.d                         pam.conf             vmware-tools
gshadow                        pam.d                vtrgb
gshadow-                       passwd               wgetrc
gss                            passwd-              wireguard
hdparm.conf                    perl                 wpa_supplicant
host.conf                      pki                  xattr.conf
hostname                       pm                   xdg
hosts                          polkit-1             zsh_command_not_found
hosts.allow                    pollinate
djohn@k8s-slave1:/etc$ cd netplan/
djohn@k8s-slave1:/etc/netplan$ ls
00-installer-config.yaml  00-installer-config.yaml.bak
djohn@k8s-slave1:/etc/netplan$ cat 00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s5:
      dhcp4: no
      addresses:
      - 10.211.55.6/24
      gateway4: 10.211.55.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
djohn@k8s-slave1:/etc/netplan$ nano 00-installer-config.yaml
djohn@k8s-slave1:/etc/netplan$ sudo nano 00-installer-config.yaml
djohn@k8s-slave1:/etc/netplan$ netplan try
ERROR: cannot create directory /run/NetworkManager/system-connections: Permission denied

An error occurred: the configuration could not be generated

Reverting.
Something really bad happened while reverting config: [Errno 13] Permission denied: '10-netplan-enp0s5.network'
You should verify the netplan YAML in /etc/netplan and probably run 'netplan apply' again.
djohn@k8s-slave1:/etc/netplan$ netplan apply
ERROR: cannot create directory /run/NetworkManager/system-connections: Permission denied
djohn@k8s-slave1:/etc/netplan$ sudo netplan apply
djohn@k8s-slave1:/etc/netplan$ sudo netplan try
Do you want to keep these settings?


Press ENTER before the timeout to accept the new configuration


Changes will revert in 118 seconds
Configuration accepted.
djohn@k8s-slave1:/etc/netplan$ nmcli d
DEVICE   TYPE       STATE      CONNECTION
enp0s5   ethernet   connected  netplan-enp0s5
peer1    wireguard  connected  peer1
docker0  bridge     unmanaged  --
lo       loopback   unmanaged  --
djohn@k8s-slave1:/etc/netplan$ cat 00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp0s5:
      dhcp4: no
      addresses:
      - 10.211.55.6/24
      gateway4: 10.211.55.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
djohn@k8s-slave1:/etc/netplan$
djohn@k8s-slave1:/etc/netplan$ ls
00-installer-config.yaml  00-installer-config.yaml.bak
djohn@k8s-slave1:/etc/netplan$ nmcli
enp0s5: connected to netplan-enp0s5
        "Red Hat Virtio"
        ethernet (virtio_net), 00:1C:42:4D:9E:6A, hw, mtu 1500
        ip4 default
        inet4 10.211.55.6/24
        route4 10.211.55.0/24
        route4 0.0.0.0/0
        inet6 fe80::21c:42ff:fe4d:9e6a/64
        route6 ff00::/8
        route6 fe80::/64

peer1: connected to peer1
        "peer1"
        wireguard, sw, mtu 1420
        inet4 192.168.1.2/32
        route4 10.255.0.0/16
        route4 10.22.22.0/24

docker0: unmanaged
        "docker0"
        bridge, 02:42:7C:AE:03:E1, sw, mtu 1500

lo: unmanaged
        "lo"
djohn@k8s-slave1:/etc/netplan$
djohn@k8s-slave1:/etc/netplan$ nmcli connection up peer1
Error: Connection activation failed: Not authorized to control networking.
djohn@k8s-slave1:/etc/netplan$ sudo nmcli connection up peer1
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/3)
djohn@k8s-slave1:/etc/netplan$ ip route show
default via 10.211.55.1 dev enp0s5 proto static metric 100
10.22.22.0/24 dev peer1 proto static scope link metric 50
10.211.55.0/24 dev enp0s5 proto kernel scope link src 10.211.55.6 metric 100
10.255.0.0/16 dev peer1 proto static scope link metric 50
djohn@k8s-slave1:/etc/netplan$ sudo ip link add dev wg0 type wireguard
djohn@k8s-slave1:/etc/netplan$ ip route show
default via 10.211.55.1 dev enp0s5 proto static metric 100
10.22.22.0/24 dev peer1 proto static scope link metric 50
10.211.55.0/24 dev enp0s5 proto kernel scope link src 10.211.55.6 metric 100
10.255.0.0/16 dev peer1 proto static scope link metric 50
djohn@k8s-slave1:/etc/netplan$ sudo nmcli connection down peer1
Connection 'peer1' successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/3)
djohn@k8s-slave1:/etc/netplan$ nmcli
enp0s5: connected to netplan-enp0s5
        "Red Hat Virtio"
        ethernet (virtio_net), 00:1C:42:4D:9E:6A, hw, mtu 1500
        ip4 default
        inet4 10.211.55.6/24
        route4 10.211.55.0/24
        route4 0.0.0.0/0
        inet6 fe80::21c:42ff:fe4d:9e6a/64
        route6 ff00::/8
        route6 fe80::/64

docker0: unmanaged
        "docker0"
        bridge, 02:42:7C:AE:03:E1, sw, mtu 1500

lo: unmanaged
        "lo"
lines 1-17...skipping...
enp0s5: connected to netplan-enp0s5
        "Red Hat Virtio"
        ethernet (virtio_net), 00:1C:42:4D:9E:6A, hw, mtu 1500
        ip4 default
        inet4 10.211.55.6/24
        route4 10.211.55.0/24
        route4 0.0.0.0/0
        inet6 fe80::21c:42ff:fe4d:9e6a/64
        route6 ff00::/8
        route6 fe80::/64

docker0: unmanaged
        "docker0"
        bridge, 02:42:7C:AE:03:E1, sw, mtu 1500

lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536
lines 1-18...skipping...
enp0s5: connected to netplan-enp0s5
        "Red Hat Virtio"
        ethernet (virtio_net), 00:1C:42:4D:9E:6A, hw, mtu 1500
        ip4 default
        inet4 10.211.55.6/24
        route4 10.211.55.0/24
        route4 0.0.0.0/0
        inet6 fe80::21c:42ff:fe4d:9e6a/64
        route6 ff00::/8
        route6 fe80::/64

docker0: unmanaged
        "docker0"
        bridge, 02:42:7C:AE:03:E1, sw, mtu 1500

lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

wg0: unmanaged
        "wg0"
        wireguard, sw, mtu 1420

DNS configuration:
lines 1-24...skipping...
enp0s5: connected to netplan-enp0s5
        "Red Hat Virtio"
        ethernet (virtio_net), 00:1C:42:4D:9E:6A, hw, mtu 1500
        ip4 default
        inet4 10.211.55.6/24
        route4 10.211.55.0/24
        route4 0.0.0.0/0
        inet6 fe80::21c:42ff:fe4d:9e6a/64
        route6 ff00::/8
        route6 fe80::/64

docker0: unmanaged
        "docker0"
        bridge, 02:42:7C:AE:03:E1, sw, mtu 1500

lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

wg0: unmanaged
        "wg0"
        wireguard, sw, mtu 1420

DNS configuration:
        servers: 8.8.8.8 8.8.4.4
        interface: enp0s5

lines 1-27...skipping...
enp0s5: connected to netplan-enp0s5
        "Red Hat Virtio"
        ethernet (virtio_net), 00:1C:42:4D:9E:6A, hw, mtu 1500
        ip4 default
        inet4 10.211.55.6/24
        route4 10.211.55.0/24
        route4 0.0.0.0/0
        inet6 fe80::21c:42ff:fe4d:9e6a/64
        route6 ff00::/8
        route6 fe80::/64

docker0: unmanaged
        "docker0"
        bridge, 02:42:7C:AE:03:E1, sw, mtu 1500

lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

wg0: unmanaged
        "wg0"
        wireguard, sw, mtu 1420

DNS configuration:
        servers: 8.8.8.8 8.8.4.4
        interface: enp0s5

Use "nmcli device show" to get complete information about known devices and
"nmcli connection show" to get an overview on active connection profiles.

Consult nmcli(1) and nmcli-examples(7) manual pages for complete usage details.
djohn@k8s-slave1:/etc/netplan$ sudo nmcli dev set wg0 managed yes
djohn@k8s-slave1:/etc/netplan$ nmcli
enp0s5: connected to netplan-enp0s5
        "Red Hat Virtio"
        ethernet (virtio_net), 00:1C:42:4D:9E:6A, hw, mtu 1500
        ip4 default
        inet4 10.211.55.6/24
        route4 10.211.55.0/24
        route4 0.0.0.0/0
        inet6 fe80::21c:42ff:fe4d:9e6a/64
        route6 ff00::/8
        route6 fe80::/64

wg0: disconnected
        "wg0"
        wireguard, sw, mtu 1420

docker0: unmanaged
        "docker0"
        bridge, 02:42:7C:AE:03:E1, sw, mtu 1500

lo: unmanaged
        "lo"
        loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

DNS configuration:
        servers: 8.8.8.8 8.8.4.4
        interface: enp0s5

Use "nmcli device show" to get complete information about known devices and
"nmcli connection show" to get an overview on active connection profiles.
djohn@k8s-slave1:/etc/netplan$ ip route show
default via 10.211.55.1 dev enp0s5 proto static metric 100
10.211.55.0/24 dev enp0s5 proto kernel scope link src 10.211.55.6 metric 100
djohn@k8s-slave1:/etc/netplan$ sudo nmcli connection up peer1
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/4)
djohn@k8s-slave1:/etc/netplan$ cd ..
djohn@k8s-slave1:/etc$ cd NetworkManager/
djohn@k8s-slave1:/etc/NetworkManager$ ls
NetworkManager.conf  dispatcher.d      dnsmasq.d
conf.d               dnsmasq-shared.d  system-connections
djohn@k8s-slave1:/etc/NetworkManager$ cat NetworkManager.conf
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=no
djohn@k8s-slave1:/etc/NetworkManager$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:1c:42:4d:9e:6a brd ff:ff:ff:ff:ff:ff
    inet 10.211.55.6/24 brd 10.211.55.255 scope global noprefixroute enp0s5
       valid_lft forever preferred_lft forever
    inet6 fe80::21c:42ff:fe4d:9e6a/64 scope link
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:7c:ae:03:e1 brd ff:ff:ff:ff:ff:ff
7: wg0: <POINTOPOINT,NOARP> mtu 1420 qdisc noop state DOWN group default qlen 1000
    link/none
8: peer1: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    link/none
    inet 192.168.1.2/32 scope global noprefixroute peer1
       valid_lft forever preferred_lft forever
djohn@k8s-slave1:/etc/NetworkManager$ ping 192.168.1.1
PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
64 bytes from 192.168.1.1: icmp_seq=1 ttl=128 time=15.7 ms
64 bytes from 192.168.1.1: icmp_seq=2 ttl=128 time=11.5 ms
^C
--- 192.168.1.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 11.522/13.623/15.724/2.101 ms
djohn@k8s-slave1:/etc/NetworkManager$ ping 192.168.1.2
PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
64 bytes from 192.168.1.2: icmp_seq=1 ttl=64 time=0.048 ms
^C
--- 192.168.1.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.048/0.048/0.048/0.000 ms
djohn@k8s-slave1:/etc/NetworkManager$
djohn@k8s-slave1:/etc/NetworkManager$
djohn@k8s-slave1:/etc/NetworkManager$ ip route show
default via 10.211.55.1 dev enp0s5 proto static metric 100
10.22.22.0/24 dev peer1 proto static scope link metric 50
10.211.55.0/24 dev enp0s5 proto kernel scope link src 10.211.55.6 metric 100
10.255.0.0/16 dev peer1 proto static scope link metric 50
djohn@k8s-slave1:/etc/NetworkManager$ pinng 10.255.92.15

Command 'pinng' not found, did you mean:

  command 'ping' from deb iputils-ping (3:20190709-3)
  command 'ping' from deb inetutils-ping (2:1.9.4-11)

Try: sudo apt install <deb name>

djohn@k8s-slave1:/etc/NetworkManager$ ping 10.255.92.15
PING 10.255.92.15 (10.255.92.15) 56(84) bytes of data.
64 bytes from 10.255.92.15: icmp_seq=1 ttl=62 time=13.0 ms
^C
--- 10.255.92.15 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 13.004/13.004/13.004/0.000 ms
djohn@k8s-slave1:/etc/NetworkManager$ curl 10.255.92.16
<!DOCTYPE html>
<html>
<head>_
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
djohn@k8s-slave1:/etc/NetworkManager$