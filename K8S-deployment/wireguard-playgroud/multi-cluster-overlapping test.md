# Multi-cluster pod/service connection
## kernel version check
```sh
#slave2
$uname -a
Linux k8s-slave2 5.6.0-050600-generic #202003292333 SMP Sun Mar 29 23:35:58 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux

#slave3
$ uname -a
Linux k8s-slave3 5.6.0-050600-generic #202003292333 SMP Sun Mar 29 23:35:58 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```
## multi-master check
```sh
#slave2
$kubectl get nodes
NAME         STATUS   ROLES                  AGE   VERSION
k8s-slave2   Ready    control-plane,master   39h   v1.20.2

#slave3
$kubectl get nodes
NAME         STATUS   ROLES                  AGE    VERSION
k8s-slave3   Ready    control-plane,master   163m   v1.20.2
```
## wireguard cli tools installation
```sh
sudo apt install -y wireguard
wg genkey | tee privatekey | wg pubkey > publickey
ip link add wg0 type wireguard
ip addr add 172.16.255.2/24 dev wg0
wg set wg0 private-key privatekey
ip link set wg0 up

wg genkey | tee privatekey | wg pubkey > publickey
ip link add wg0 type wireguard
ip addr add 172.16.255.3/24 dev wg0
wg set wg0 private-key privatekey
ip link set wg0 up


interface: wg0
  public key: E0s6lo/7yI5PCidPd08lhKyByN1VfG6CP6vC6cV+lis=
  private key: (hidden)
  listening port: 38401
root@k8s-slave2:[/etc/wireguard]:

interface: wg0
  public key: guKzxfkfoRwro53sWG7ajFyNNE4kyKz4BKdStvG+Hgg=
  private key: (hidden)
  listening port: 42799
root@k8s-slave3:/etc/wireguard#

#slave2 -gw set wg0 peer <peer-public-key>
wg set wg0 listen-port 51820
wg set wg0 peer guKzxfkfoRwro53sWG7ajFyNNE4kyKz4BKdStvG+Hgg= allowed-ips 172.16.255.3/32 endpoint 10.211.55.8:51820

#slave3
wg set wg0 listen-port 51820
wg set wg0 peer E0s6lo/7yI5PCidPd08lhKyByN1VfG6CP6vC6cV+lis= allowed-ips 172.16.255.2/32 endpoint 10.211.55.7:51820
```
##
root@k8s-slave2:[/etc/wireguard]:
ping 172.16.255.3
PING 172.16.255.3 (172.16.255.3) 56(84) bytes of data.
64 bytes from 172.16.255.3: icmp_seq=1 ttl=64 time=0.897 ms
^C
--- 172.16.255.3 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.897/0.897/0.897/0.000 ms
root@k8s-slave2:[/etc/wireguard]:

##
root@k8s-slave3:/etc/wireguard# ping 172.16.255.2
PING 172.16.255.2 (172.16.255.2) 56(84) bytes of data.
64 bytes from 172.16.255.2: icmp_seq=1 ttl=64 time=0.614 ms
64 bytes from 172.16.255.2: icmp_seq=2 ttl=64 time=0.741 ms
^C
--- 172.16.255.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1023ms
rtt min/avg/max/mdev = 0.614/0.677/0.741/0.063 ms
root@k8s-slave3:/etc/wireguard#

## port-listen
root@k8s-slave2:[/etc/wireguard]:
ss -nlu
State           Recv-Q           Send-Q                     Local Address:Port                      Peer Address:Port          Process
UNCONN          0                0                          127.0.0.53%lo:53                             0.0.0.0:*
UNCONN          0                0                                0.0.0.0:31820                          0.0.0.0:*
UNCONN          0                0                                0.0.0.0:51820                          0.0.0.0:*
UNCONN          0                0                                   [::]:51820                             [::]:*
root@k8s-slave2:[/etc/wireguard]:

root@k8s-slave3:/etc/wireguard# ss -nlu
State           Recv-Q           Send-Q                     Local Address:Port                      Peer Address:Port          Process
UNCONN          0                0                          127.0.0.53%lo:53                             0.0.0.0:*
UNCONN          0                0                                0.0.0.0:31820                          0.0.0.0:*
UNCONN          0                0                                0.0.0.0:51820                          0.0.0.0:*
UNCONN          0                0                                   [::]:51820                             [::]:*
root@k8s-slave3:/etc/wireguard#

## wg0-conf generation
cd /etc/wireguard/
wg showconf wg0 >> wg0.conf

## this command is not working!!!! wg setconf wg0 wg0.conf

##use this one !!!!
$wg-quick up/down wg0

djohn@k8s-slave3:~$ ping 10.255.92.58
PING 10.255.92.58 (10.255.92.58) 56(84) bytes of data.
64 bytes from 10.255.92.58: icmp_seq=1 ttl=63 time=0.531 ms
^C
--- 10.255.92.58 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.531/0.531/0.531/0.000 ms
djohn@k8s-slave3:~$ ping 10.255.92.59
PING 10.255.92.59 (10.255.92.59) 56(84) bytes of data.
64 bytes from 10.255.92.59: icmp_seq=1 ttl=63 time=1.96 ms
^C
--- 10.255.92.59 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.962/1.962/1.962/0.000 ms
djohn@k8s-slave3:~$


###slave2 wg0.conf
cat wg0.conf
[Interface]
Address = 172.16.255.2
ListenPort = 51820
PrivateKey = yKSggj08f6UBugWNKHH9L8IeTWN1DwmTdFU+dn1Q/1o=
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o enp0s5 -j MASQUERADE;
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o enp0s5 -j MASQUERADE;


[Peer]
#to slave3
PublicKey = guKzxfkfoRwro53sWG7ajFyNNE4kyKz4BKdStvG+Hgg=
AllowedIPs = 172.16.255.3/32, 10.233.0.0/16, 10.33.33.0/24
Endpoint = 10.211.55.8:51820



###slave3 wg0.conf
root@k8s-slave3:/etc/wireguard# cat wg0.conf
[Interface]
Address = 172.16.255.3
ListenPort = 51820
PrivateKey = uKFMlURr0P6w7KlHfqySTvUeKOS0VJMw4AZAEpdZ3XU=
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o enp0s5 -j MASQUERADE;
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o enp0s5 -j MASQUERADE;

[Peer]
#to slave2
PublicKey = E0s6lo/7yI5PCidPd08lhKyByN1VfG6CP6vC6cV+lis=
AllowedIPs = 172.16.255.2/32, 10.255.0.0/16, 10.22.22.0/24
Endpoint = 10.211.55.7:51820


##ping test
djohn@k8s-slave3:~$ ping 10.255.92.58
PING 10.255.92.58 (10.255.92.58) 56(84) bytes of data.
64 bytes from 10.255.92.58: icmp_seq=1 ttl=63 time=0.531 ms
^C
--- 10.255.92.58 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.531/0.531/0.531/0.000 ms
djohn@k8s-slave3:~$ ping 10.255.92.59
PING 10.255.92.59 (10.255.92.59) 56(84) bytes of data.
64 bytes from 10.255.92.59: icmp_seq=1 ttl=63 time=1.96 ms
^C
--- 10.255.92.59 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.962/1.962/1.962/0.000 ms
djohn@k8s-slave3:~$


##curl svc
root@k8s-slave2:[/etc/wireguard]:
curl 10.33.33.53
<!DOCTYPE html>
<html>
<head>
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
root@k8s-slave2:[/etc/wireguard]:



root@k8s-slave3:/etc/wireguard# curl 10.22.22.245
<!DOCTYPE html>
<html>
<head>
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
root@k8s-slave3:/etc/wireguard#


## iptables cli
sudo iptables -L -t nat

## dnsbox can apk update, busybox nope!!! maybe some bugs..

### overlapping subnet k8s
slave3 podIP 10.233.0.0/16 clusterip 10.33.33.0/24  
                mapping 192.33.0.0/16(dnat)
slave4 podIP 10.233.0.0/16 clusterip 10.33.33.0/24
                mapping 192.44.0.0/16(dnat)
## working config
### slave3
iptables -t nat -A PREROUTING -d 192.33.0.0/16 -j NETMAP --to 10.233.0.0/16

$sudo cat /etc/wireguard/wg0.conf
[Interface]
Address = 172.16.255.3
ListenPort = 51820
PrivateKey = uKFMlURr0P6w7KlHfqySTvUeKOS0VJMw4AZAEpdZ3XU=
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o enp0s5 -j MASQUERADE;
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o enp0s5 -j MASQUERADE;

[Peer]
#to slave2
PublicKey = E0s6lo/7yI5PCidPd08lhKyByN1VfG6CP6vC6cV+lis=
AllowedIPs = 172.16.255.2/32, 10.255.0.0/16, 10.22.22.0/24
Endpoint = 10.211.55.7:51820

[Peer]
#to slave4
PublicKey = 9iq4e3AsBnxP3W+lU0bgY1qhjxqhfIqE1UAU2ysYiHo=
AllowedIPs = 172.16.255.4/32, 192.44.0.0/16
Endpoint = 10.211.55.9:51820
djohn@k8s-slave3:[~]:


### slave4
iptables -t nat -A PREROUTING -d 192.44.0.0/16 -j NETMAP --to 10.233.0.0/16

wg0.conf
[Interface]
Address = 172.16.255.4
ListenPort = 51820
PrivateKey = YEqZrBPaZbhsvvTvdNNCIjZMFQ4tYPsi/AfKEfGwwWo=
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o enp0s5 -j MASQUERADE;
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o enp0s5 -j MASQUERADE;

[Peer]
#to slave3
PublicKey = guKzxfkfoRwro53sWG7ajFyNNE4kyKz4BKdStvG+Hgg=
AllowedIPs = 172.16.255.3/32, 192.33.0.0/16
Endpoint = 10.211.55.8:51820

## slave3/4 wg-quick up wg0

### 3ping4
djohn@k8s-slave3:[~]:
$kubectl exec -ti dnsbox-k8s-slave3-5f56984b58-p5kjp sh
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
/ #
/ #
/ # ping 192.44.206.198
PING 192.44.206.198 (192.44.206.198): 56 data bytes
64 bytes from 192.44.206.198: seq=0 ttl=62 time=1.588 ms
64 bytes from 192.44.206.198: seq=1 ttl=62 time=0.564 ms
^C
--- 192.44.206.198 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.564/1.076/1.588 ms
/ #
/ #
/ # ping 192.44.206.198
PING 192.44.206.198 (192.44.206.198): 56 data bytes
64 bytes from 192.44.206.198: seq=0 ttl=62 time=1.672 ms
64 bytes from 192.44.206.198: seq=1 ttl=62 time=0.553 ms
64 bytes from 192.44.206.198: seq=2 ttl=62 time=0.472 ms
64 bytes from 192.44.206.198: seq=3 ttl=62 time=0.776 ms
64 bytes from 192.44.206.198: seq=4 ttl=62 time=1.353 ms
^C
--- 192.44.206.198 ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max = 0.472/0.965/1.672 ms
/ #

## 4ping3
djohn@slave4:[~/deployment]:
$kubectl exec -ti dnsbox-k8s-slave3-5f56984b58-kklhf sh
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
4: eth0@if21: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1440 qdisc noqueue state UP
    link/ether 82:cb:4d:78:b3:0e brd ff:ff:ff:ff:ff:ff
    inet 10.233.206.196/32 scope global eth0
       valid_lft forever preferred_lft forever
/ # ping 192.33.158.253
PING 192.33.158.253 (192.33.158.253): 56 data bytes
64 bytes from 192.33.158.253: seq=0 ttl=62 time=3.564 ms
^C
--- 192.33.158.253 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 3.564/3.564/3.564 ms
/ #
## slave3 dnat rule
root@k8s-slave3:~# iptables -L -t nat | grep NETMAP
NETMAP     all  --  anywhere             192.33.0.0/16        to:10.233.0.0/16

## slave4 dnat rule
root@slave4:~# iptables -L -t nat | grep NETMAP
NETMAP     all  --  anywhere             192.44.0.0/16        to:10.233.0.0/16