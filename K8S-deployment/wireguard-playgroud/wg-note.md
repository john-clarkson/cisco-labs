


```sh

cd wg/
hitler@k8s-slave2:[~/wg]:
ls
00-wg-ns.yaml  01.pv.yaml  02-wg-pvc.yaml  03-wg-configmap.yaml  04-wg-pod.yaml  05-wg-svc-nordport.yaml
hitler@k8s-slave2:[~/wg]:
kubectl delete -f .
namespace "wireguard" deleted
persistentvolume "task-pv-volume" deleted
persistentvolumeclaim "pv-claim-wireguard" deleted
configmap "wireguard-configmap" deleted
pod "wireguard" deleted
service "wireguard-service" deleted

kubectl apply -f .
namespace/wireguard created
persistentvolume/task-pv-volume created
persistentvolumeclaim/pv-claim-wireguard created
configmap/wireguard-configmap created
pod/wireguard created
service/wireguard-service created
hitler@k8s-slave2:[~/wg]:
kubectl get svc -n wireguard
NAME                TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
wireguard-service   NodePort   10.22.22.128   <none>        51820:31820/UDP   9s
hitler@k8s-slave2:[~/wg]:
kubectl get svc -n wireguard
NAME                TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
wireguard-service   NodePort   10.22.22.128   <none>        51820:31820/UDP   11s
hitler@k8s-slave2:[~/wg]:
kubectl get svc -n wireguard
NAME                TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
wireguard-service   NodePort   10.22.22.128   <none>        51820:31820/UDP   12s
hitler@k8s-slave2:[~/wg]:
kubectl get all -n wireguard
NAME            READY   STATUS    RESTARTS   AGE
pod/wireguard   1/1     Running   0          21s

NAME                        TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
service/wireguard-service   NodePort   10.22.22.128   <none>        51820:31820/UDP   21s
hitler@k8s-slave2:[~/wg]:
hitler@k8s-slave2:[~/wg]:
hitler@k8s-slave2:[~/wg]:
hitler@k8s-slave2:[~/wg]:
clear
hitler@k8s-slave2:[~/wg]:

```

```sh
kubectl -n wireguard logs wireguard
[s6-init] making user provided files available at /var/run/s6/etc...exited 0.
[s6-init] ensuring user provided files have correct perms...exited 0.
[fix-attrs.d] applying ownership & permissions fixes...
[fix-attrs.d] done.
[cont-init.d] executing container initialization scripts...
[cont-init.d] 01-envfile: executing...
[cont-init.d] 01-envfile: exited 0.
[cont-init.d] 10-adduser: executing...

-------------------------------------
          _         ()
         | |  ___   _    __
         | | / __| | |  /  \
         | | \__ \ | | | () |
         |_| |___/ |_|  \__/


Brought to you by linuxserver.io
-------------------------------------

To support the app dev(s) visit:
WireGuard: https://www.wireguard.com/donations/

To support LSIO projects visit:
https://www.linuxserver.io/donate/
-------------------------------------
GID/UID
-------------------------------------

User uid:    1000
User gid:    1000
-------------------------------------

[cont-init.d] 10-adduser: exited 0.
[cont-init.d] 30-config: executing...
Uname info: Linux wireguard 5.6.0-050600-generic #202003292333 SMP Sun Mar 29 23:35:58 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
**** It seems the wireguard module is already active. Skipping kernel header install and module compilation. ****
**** Server mode is selected ****
**** SERVERURL var is either not set or is set to "auto", setting external IP to auto detected value of 45.117.99.230 ****
**** External server port is set to 31820. Make sure that port is properly forwarded to port 51820 inside this container ****
**** Internal subnet is set to 10.255.0.0 ****
**** AllowedIPs for peers 0.0.0.0/0, ::/0 ****
**** Peer DNS servers will be set to 10.22.22.10 ****
**** No wg0.conf found (maybe an initial install), generating 1 server and 2 peer/client confs ****
grep: /config/peer*/*.conf: No such file or directory
PEER 1 QR code:
█████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████
████ ▄▄▄▄▄ █▀▄ ▄▀▄█▀█ ▀▄▀▄█ ▄▀▄▀▄▀▄▄██▀ █▄▀▄▀▀▄ ▄▄▄ ██ ▄▄▄▄▄ ████
████ █   █ █▀██▀ ▄▄█▄██████▀ █▄▄█▀▄ ▄▄▀  █▀██▀▀ ▄ ▄ ██ █   █ ████
████ █▄▄▄█ █▀ ▀█▄█ ▄███▄  ▀▀   ▄▄▄ ▄█▀▄█ ▀▄▀█ ▄▄▄ ▀▄██ █▄▄▄█ ████
████▄▄▄▄▄▄▄█▄▀ █▄▀ ▀▄█ ▀ ▀ █ ▀ █▄█ █▄▀▄█ ▀▄█▄█▄▀ ▀▄█▄█▄▄▄▄▄▄▄████
████   ▄▄▀▄▄ ▄▀██ ▀▄█  ▀  ██▄█▄ ▄▄ ▄▄▄▀█▀▄▀▄▄█ ▄██ ▀  █▄▀▄█▄█████
████▄▄▀▀▀▀▄▀▀ █▄▄▄ ▀ ▀ ▄▀▀ ▄▀██▀▀▄ ▀  █ ▄▄█▀ █▀▀▀▀ █▄▄▄   ▀▀█████
████▄▄█ ▄█▄ ▀█ █▄▄▄ ▀▀ ▄█▀▄▄▄  ▄██▄▄▀▀▄██▀██▀▄▀█▀▄▄█  ▄▀▀▀ █ ████
████  ▀██▄▄ ▀▀ ▀█▀▀   ▄██▀▄▄▄▀▄   ▀▀  ███▄▀ ▄█▀▀ ▄▀ ▄██▄▀ ▀▄ ████
████▄▀██ ▄▄▀ ▀ ▀██ ▄█  ▀███  ▄█▀▄▀ ▀█▄▄▄  █▀▀█▀ █▄▄▀  █████▀▀████
████    ▄▄▄ ▀ ▀▀▀▀█▀▀█  ▄▄███▄ ▄▀██▄▀▀ █ ▄  ▄▄█▀▀ ▄█ ▀▄ ▀▀ ▀▀████
████▄▀ ▄▄▀▄█ █▄▀█▀█▄▀█ ▄███▀▄█  ▀█ ▄▀▀ █ ▄▄██▀█ ██▀▀▄▀▄█▀▄  █████
█████▄█▄ ▀▄▄▄ █▄███▄ █▄▄█  ▀██▀ ▄▄█ ▀▀▄ ▄█▄██▄▄▄█  ▄█▀▄ ▀   █████
█████▄█▄█ ▄ █ █  █ █▄█▄ ▄  █▄  ▀▀███▄ ▀▄▀▄██▄▄ ███ ▄▀▄██▀█▄▄▀████
████▀ █  ▄▄▄ ▀▀    ▀▄▄█▄ ▄█▄█▀ ▄▄▄ █▀▀ ▀▄▀ ▀▄█ ██▀▄▀ ▄▄▄    ▄████
████▀▄ █ █▄█  ▄▄ █▀█▀▄▀▄█▄█▄ █ █▄█ █▀▄▄ ▄▄▄▄ █ ▀▀██▄ █▄█ ██▀█████
████▀▄▄▀  ▄ ▄▄▄  ▀▀ ▄█ █▄█▀█ ▄▄    ▀ ██▀ █▄ █ ▀██  ▄▄  ▄▄▀▀▀ ████
█████▄▄▀ ▄▄█ ▀▀▄▀██▀▄▀▄▀█▄▀▀▀▄▀█▄▄▀██ █▄▄ ▄▄█▀ ▄█▄███▀ █▄█ ▀▄████
████ ▀▀▀█▀▄█ █▀▀▄ ▄███▄▄▄ ██ ▄███▄▀▀▀  ▄█▄ █▄█▀█  ▀█▀▀█████▄▀████
████  █▀█▀▄ █▀ ██▀▀▀█▄▄▀▀███ ▀▀ ▀   █▄ █ ▄ ▄ ▀▀▄▀▀█▄█ █▄▀▀▄ █████
████▄█ ▀▄█▄ ▀█▀█▄█▀▀█▀█▀ ▄▀█▄▀▄ █▄ █▄ ▀█▀▀▄█▀▀▀▀█ █  ▀▀ ▄█▄██████
████▄▄█▀█▀▄█▀▄   ▀█ ▀ ▄██▀██ ▀▄▀ █▄▄▄▄▀█▀ █▄▄▄▄█ ▄█▀▀▀█▀█ ███████
████ ▀ ▀ █▄▀  ███ ▄▀▄▀ █▄▀ █▀█▄▀█▀▄█▄ █▄▀██ █ █▄█▄▄▄▄▄▀▀ ▀▀▀█████
████▀█▀ ▄▀▄ █  ▀▀█▀██▀ █▀▀▄█▀██ █▀▄█▀▄█ █ ██▄▄ ▄ ▄████▀▄█ ██▀████
████ ▀ ▀▀▄▄█ ▄█   ▀ ██▀▀▀▄▀ ▄▄  █▄▄█ ▀▄█▄▀▄▄ ▀█▀▀▄▄▀▄▄█    ▀▀████
██████████▄█ ▀ ▀█▀▀▄█ ▄▀▄▀█  █ ▄▄▄ ▀█ █  ▀█▄▀▀▀██▄▄▀ ▄▄▄ █▀█▄████
████ ▄▄▄▄▄ █▄▄  ▀▀ ▄██ ▄█▀▄▄▀█ █▄█ ▄ ▀ ▄▄█ █▄██▀  ▄▄ █▄█ ▄█ █████
████ █   █ █ ▄▀▀█  ▄▀  ▄█▀ █▀▀   ▄ ▄▀ ▄█▀█  █▀█▄█▄ ▀ ▄   █▀██████
████ █▄▄▄█ █ ▀▄▀▄▄▄▄ ▀▄▄█▄▀█ █ █▀█▄▀▀ ██ ▄█▄▀█  █▀▀ █▀▄▀█▀ ██████
████▄▄▄▄▄▄▄█▄███▄▄▄▄▄█▄▄█▄█▄███▄▄▄██▄▄█▄█▄█▄▄▄▄██▄▄█▄▄████▄▄█████
█████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████
PEER 2 QR code:
█████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████
████ ▄▄▄▄▄ ████▀▄ ▀▄ ▀▄  ▀ ▄ █ ▀▀█ ▄▄  ▀▄ ▄▀▀█▄█▀▄▄ ██ ▄▄▄▄▄ ████
████ █   █ █▄▀██ ▀▀ ▄▀▄█▄  ▀█▀▄█▄▀▀▄█▀▀▀██▀▄▄▀▀▄█▄▄ ██ █   █ ████
████ █▄▄▄█ ██ ▄▀ ▀  ▀  █▄ ▄ ▀▄ ▄▄▄  ▄█▀▀▄   ▄█  █▀▀▄██ █▄▄▄█ ████
████▄▄▄▄▄▄▄█ █ █▄█ █ █▄▀▄█ █ █ █▄█ █ █▄█ █ █▄▀▄▀▄▀▄▀ █▄▄▄▄▄▄▄████
████▄▄ █ ▄▄▄▄ ▀ ▄ ▄▄█ ▀▄█▀█▀ ▀▄  ▄▄▀█▀  █  ▄██▄▀▄█▄▀█▄▄██▀ ▀▀████
████ ▄▀▄██▄▀██▀▀▀█▄ █ ▀ ▀█▄ ▀▀▄▀▀ ▀▀ █ █  ▄ █ █▀▄▀ ▀  █▀ ▄█▄█████
████▄▀█▀▄█▄ ▄ ▄▄▀█▄▄  █ ▄█▄ ▄▄██▄█ ▀ ▀█▄ █▄█▀ ██ ██▀▄▄█  ▀ █▄████
████▀██▄▄▀▄█▄█▄█▄█▀▀██▄▀█ ▀▀▄█▄▀██▄█▀█ █▄▄ ▀▄███▄▀▄▄ ▀█▀▄▀▄█▀████
████▀ ▀▀██▄█ ▄ ▀▄▄ ▄██ █▄ ▄▀█▀▄▀██▄▀▄▄█  █▄█▄▄▀▀ ▀▄  ▄▄ ▀ █▀▀████
██████▀▄  ▄▄ ▀█▀  ▀ ▄  ▀▄▄▄▀  ▀█ ▀█▀  █ █▀█ █▀▀█▀  ▄ ▄██▄█▀▄ ████
████ ▀▀███▄▄█▀▀▄█ █ ▄▀▀█  ▄▀▄  ██ ▄  ▄▀▀▄▀▀▄▄▄▄▄▄ ▄▀████ ▀▀█▄████
████ ▄▄██▀▄ █▀█▄▄ ▄ ▄▀██▀▀▀▀ █ ▀▄ █ ▄▀▄ ▄▄▄▄  ▀▄▄▀▄ ▀██▀█ ▄▄▄████
████▄▄▀▄ █▄▄▄▀▄  ▄█▀ ▄▄▀▄▀▄▀▄█▀▀▄ █ ██ ▀█  ██▀▄▀▀▄▀▄█▀▄▄ ▀  ▄████
████▀ ▄▀ ▄▄▄ ▀ ▄▄▀  ██▄▀█ ▀▀██ ▄▄▄ ▀█▀  █▄ ▀▄▀█ ▄ ██ ▄▄▄ ▄▄█▄████
████ ▀▄▀ █▄█  █▀  ▀▄▄█▄▀  █▀█▀ █▄█ ▀ ██▄▀ █▄█▀▄ ▀▄▄█ █▄█ ██▀ ████
████▄▀▄█  ▄▄  ▄▀▀▀▄▀▄▀▄█ ▄▀▄ ▄▄ ▄▄▄▀▀ ▄▀ ▀▀█▀▄▀█ ██  ▄  ▄▄▄█ ████
████▀ ██▄ ▄▄█▄▀▀██▀ █▄▄▄▄█ █▄ █▄█▀▄█▄██▄▄▄▄▀ ▀ ▄▄ █▀▀█ ▄█▀ ▀█████
████▀  █ ▀▄█▀▄█ ▀ █▄▄▀▄▄▀█▄▀█▀▀▄▄█▀▄▀ ▀▄  ▀██▀▀▀ ▀█▀▀ ▄▄▄█▄▄▄████
████ █ ▄█▄▄▄▀█ ▄▀█▀█ ▀▄ ▄▄▄▀█▄  ▀▄▄▄▄ ▀▀▄ ██▀█▀  ▄ ▄██▄█▄ ▄██████
████▀▄█▀██▄▄▄▀  ▄▀▄█▀▀  ▄▀▀▀▄▄▄▀▄ ▄█▀ █▀█▀█▄   █▄▀▀▀▀  ▀▄▄▄▀▄████
████▀▄ ▀▄█▄█▀██▄ ▄▄▀█▀  ▄▀▀ ██▄██▀█▀█▀ ▄█ ▄██ ▄▀ ▄▀█▄█▄▀▀█ ▀ ████
████▀▄▄  ▀▄▄█ ██▀█  █ ▀ ██▄▀▀   ██ ▀▄ ██▄▀█▀▄█ ██▄█     ████▀████
████▄▀▀▄▀█▄▀█ █▀▀▀ ▄▄ ██▀█▄ █▀▄ █▀▀▀ █▄▀▀▄▄ ▀ ▄ ▀█▄▀ ██▄█▄█▀ ████
████ ▀ ▀▀▄▄▀███   ▄▀▄█ █ ▀ ▀▄▀█▀████▀▄█▀▀▀██████▄▀██   ▀▀▄▄█ ████
██████████▄▄▀ ▀▄██▄██  ██  █▄█ ▄▄▄ ▀▄▀▄ ▄▄█▀▄▀▄ █▀ █ ▄▄▄ ▀▄█ ████
████ ▄▄▄▄▄ █ ▀▄▀▀▄█▄▀▀ ▄▄▀▄ █  █▄█ ▀ ▀▀   ▀█▄▀▄█▀▀   █▄█ ▀▀▀▄████
████ █   █ █▄▄ ▀    ▄  █ ▄▄█ ▀   ▄   █▀▀█ ▀▀▄██ ▄ ▄█     █ ▀▄████
████ █▄▄▄█ █ ▄ ▀ ▀▄ ▄█▀█▀█ █ █▄▄ █ ▀▄▀ ▀▄███ ██  ▀▄█▄ █ ▄▀ ▀▄████
████▄▄▄▄▄▄▄█▄█▄▄▄██▄█▄▄█▄▄▄█▄▄████▄▄██▄▄▄▄▄██▄▄▄▄█▄▄▄▄▄▄▄▄█▄▄████
█████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████
[cont-init.d] 30-config: exited 0.
[cont-init.d] 99-custom-scripts: executing...
[custom-init] no custom files found exiting...
[cont-init.d] 99-custom-scripts: exited 0.
[cont-init.d] done.
[services.d] starting services
[services.d] done.
[#] ip link add wg0 type wireguard
[#] wg setconf wg0 /dev/fd/63
.:53
CoreDNS-1.8.1
linux/amd64, go1.15.7, 95622f4
[#] ip -4 address add 10.255.0.1 dev wg0
[#] ip link set mtu 1360 up dev wg0
[#] ip -4 route add 10.255.0.3/32 dev wg0
[#] ip -4 route add 10.255.0.2/32 dev wg0
[#] iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
hitler@k8s-slave2:[~/wg]:



$ nmcli connection import type wireguard file ~/peer1.conf
And activate or deactivate the connection
$ nmcli connection up peer1 
$ nmcli connection down peer1



hitler@k8s-slave1:/etc/NetworkManager$ cat NetworkManager.conf
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=no

$ nmcli connection import type wireguard file ~/peer1.conf
And activate or deactivate the connection
$ nmcli connection up peer1 
$ nmcli connection down peer1 