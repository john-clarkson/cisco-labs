djohn# Multi-cluster pod/service connection
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






hitler@k8s-slave3:~$ ping 10.255.92.58
PING 10.255.92.58 (10.255.92.58) 56(84) bytes of data.
64 bytes from 10.255.92.58: icmp_seq=1 ttl=63 time=0.531 ms
^C
--- 10.255.92.58 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.531/0.531/0.531/0.000 ms
hitler@k8s-slave3:~$ ping 10.255.92.59
PING 10.255.92.59 (10.255.92.59) 56(84) bytes of data.
64 bytes from 10.255.92.59: icmp_seq=1 ttl=63 time=1.96 ms
^C
--- 10.255.92.59 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.962/1.962/1.962/0.000 ms
hitler@k8s-slave3:~$



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
hitler@k8s-slave3:~$ ping 10.255.92.58
PING 10.255.92.58 (10.255.92.58) 56(84) bytes of data.
64 bytes from 10.255.92.58: icmp_seq=1 ttl=63 time=0.531 ms
^C
--- 10.255.92.58 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.531/0.531/0.531/0.000 ms
hitler@k8s-slave3:~$ ping 10.255.92.59
PING 10.255.92.59 (10.255.92.59) 56(84) bytes of data.
64 bytes from 10.255.92.59: icmp_seq=1 ttl=63 time=1.96 ms
^C
--- 10.255.92.59 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.962/1.962/1.962/0.000 ms
hitler@k8s-slave3:~$


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

##dnsbox can apk update, busybox nope!!! maybe some bugs..
