
# ubuntu20-server inet settings
## renderer: networkd
```sh
$ip address flush dev eth0
$dhclient eth0

hitler@k8s-master1:/etc/netplan$ cat 00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s5:
      dhcp4: no
      addresses:
      - 10.211.55.5/24
      gateway4: 10.211.55.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]

 $netplan try
 $netplan apply
config don't accept tab key, only blank key works.
```
## rederer: NetworkManager
```sh
$sudo apt install network-manager
$ cat /etc/netplan/00-installer-config.yaml
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
hitler@k8s-slave1:~$ nmcli
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
```