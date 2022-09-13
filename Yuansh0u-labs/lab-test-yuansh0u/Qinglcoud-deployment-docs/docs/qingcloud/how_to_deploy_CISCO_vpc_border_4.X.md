### CISCO VPC BORDER 交换机配置
+ 注：
    1. CISCO VPC BORDER交换机不能配置vPC, 否则会影响evpn的配置，这意味着只有spine leaf网络可以使用CSICO交换机作为VPC BORDER
    2. 不能配置fabric forwarding anycast-gateway-mac , vpc-border程序会自动分配该mac, 已占用会出错

```
feature nv overlay
feature vn-segment-vlan-based
nv overlay evpn
feature bgp
feature interface-vlan
feature fabric forwarding

! 开启http协议服务,且端口为80
feature nxapi

! 该ip会作为vpc-border user-ip,  2个leaf节点该ip相同
interface loopback1
  ip address ****

interface nve1
  no shutdown
  source-interface loopback1
  host-reachability protocol bgp

router bgp 65001
   router-id 198.18.20.3
   address-family l2vpn evpn
    allow-vni-in-ethertag
  neighbor 172.31.20.67
    remote-as 168859257
    log-neighbor-changes
    update-source loopback0
    address-family ipv4 unicast
      route-map reject out
      soft-reconfiguration inbound always
    address-family l2vpn evpn
      send-community
      send-community extended
  neighbor 172.31.20.68
    remote-as 168859258
    log-neighbor-changes
    update-source loopback0
    address-family ipv4 unicast
      route-map reject out
      soft-reconfiguration inbound always
    address-family l2vpn evpn
      send-community
      send-community extended
```
### bm0/1配置
+ 如果平台没有有bm0/1, 则创建bm0/1的settings文件, 其中`role`填写`swctl`, `hostname`填写`ZONE_ID-bm0/1`

```
## Role
role="swctl"

## Region
is_region="1"
region_id="REGION_ID"
zone_id="ZONE_ID"

## Feature
feature_vmnode="on"
feature_ksnode="on"
feature_vgnode="off"
feature_hypernode="off"
feature_conntrack="off"

## Firstbox
firstbox_address="10.16.150.10"

## General
cpu_arch="x86_64"
cpu_cores="4"
memory_size="8000"
os_name="xenial"
os_version="16.04.5.2"
hostname="ZONE_ID-bm0"

## Mgmt Network
mgmt_network_interface="eth0"
mgmt_network_address="10.16.150.121"
mgmt_network_netmask="255.255.255.255"
mgmt_network_gateway="10.16.150.11"
mgmt_network_dns_servers="10.16.150.132"
mgmt_network_mac_address="00:16:3e:49:ac:04"

## Host
physical_host="10.16.150.11"
physical_host_network_interface="br0"
physical_host_eip_network_interface=""

```

+ 更新pitrix-hosts包, 安装swctl服务

```bash
/pitrix/upgrade/build_global_conf.sh
/pitrix/upgrade/update.sh -f all pitrix-hosts
/pitrix/install/launch_vms.sh ZONE_ID-bm0,ZONE_ID-bm1
/pitrix/install/install_nodes.sh ZONE_ID-bm0,ZONE_ID-bm1

# 在bm0/1上安装服务
apt-get install libffi-dev
pip install cffi pbr
pip install ncclient python_dracclient cryptography oslo.utils oslo.config
apt install pitrix-network-plugin pitrix-swctl-server pitrix-dep-gobgpd
```

+ 在bm0/1上编辑gobgp配置文件

```
[global.config]
    as = 65533
    router-id = "172.31.20.67"
# leaf01
[[neighbors]]
    [neighbors.config]
        neighbor-address = "172.31.22.1"
        peer-as = 65001
        local-as = 65001
      [[neighbors.afi-safis]]
        [neighbors.afi-safis.config]
          afi-safi-name = "l2vpn-evpn"
        [neighbors.ebgp-multihop.config]
            enabled = true
            multihop-ttl = 10
      [[neighbors.afi-safis]]
        [neighbors.afi-safis.config]
          afi-safi-name = "ipv4-unicast"
        [neighbors.afi-safis.mp-graceful-restart.config]
          enabled = true

# leaf02
[[neighbors]]
    [neighbors.config]
        neighbor-address = "172.31.22.2"
        peer-as = 65002
        local-as = 65002
      [[neighbors.afi-safis]]
        [neighbors.afi-safis.config]
          afi-safi-name = "l2vpn-evpn"
        [neighbors.ebgp-multihop.config]
            enabled = true
            multihop-ttl = 10
      [[neighbors.afi-safis]]
        [neighbors.afi-safis.config]
          afi-safi-name = "ipv4-unicast"
        [neighbors.afi-safis.mp-graceful-restart.config]
          enabled = true
```

+ 在bm上重启gobgp服务：`service gobgpd restart`
+ bm增加/pitrix/conf/global/switch.yaml文件, 存放leaf交换机账号密码,密码是加密后的, 需提供加密明文密码给installer，获取加密后的密码。

```
#default setting for switch
default:
#default username of switch
  username: 'admin'
#default password of switch, the password should have be encrypted
  password: 'ue+zgI51U7neUO/AqD64AA=='

#setting for switch which switch_id is 'border-leaf01'
border-leaf01:
#username of switch which switch_id is 'border-leaf01'
  username: 'admin'
#password of switch which switch_id is 'border-leaf01', the password should have be encrypted
  password: 'ue+zgI51U7neUO/AqD64AA=='

#setting for switch which switch_id is 'border-leaf02'
border-leaf02:
#username of switch which switch_id is 'border-leaf02'
  username: 'admin'
#password of switch which switch_id is 'border-leaf02', the password should have be encrypted
  password: 'ue+zgI51U7neUO/AqD64AA=='

```

### switch db修改

```
./create-switch -S VPC-BORDER.001.01 -d "" --mgmt_ip=100.67.8.131 --loopback_ip=100.67.8.131 --vender=cisco --model=93180YC-EX -r 0 -a 65534 --features=1039 -z ZONE_ID -s active
./create-switch -S VPC-BORDER.001.02 -d "" --mgmt_ip=100.67.8.131 --vender=cisco --model=93180YC-EX -r 0 --bgp_ip_addr=169.254.7.1 -a 65535 --features=1039 -z ZONE_ID -s active
```

插入2条vpc border交换机相关信息,
1. loopback_ip只有其中一个leaf配置, 另一个为空, 表示vpc-border-user-ip
2. mgmt_ip表示各自独立的管理ip,  loopback_ip与mgmt_ip要可以作为nxapi访问ip对外提供服务, 只有ks bm会访问.
3. role = 0, features = 1039
4. interconnect_ifs 表示与上联SAR链接的物理口if-name, 用于sdwan对接, 没有sdwan就不填， 如果有，更新数据库（两个border都需要）
    `update switch set interconnect_ifs = '{"ir": ["ethernet1/47", "ethernet1/48"]}' where switch_id = 'VPC-BORDER.001.01'; `
5. 要为每个交换机分配一个独立的track_ip, track ip不是真实存在的ip， 只要从bm节点上发出目标地址为track_ip的包单向能到达vpc border即可， 更新数据库（两个border都需要）：
    `update switch set track_ip = '10.16.150.251' where switch_id = 'VPC-BORDER.001.01';`

### 测试
+ 在bm上重启supervisor服务：`supervisorctl restart all`
+ 在ws上运行cli创建内网路由器： `cd /pitrix/cli;./create-vpc-borders -t 1`
