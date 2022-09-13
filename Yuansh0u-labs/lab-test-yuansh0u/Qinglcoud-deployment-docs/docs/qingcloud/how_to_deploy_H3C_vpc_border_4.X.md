### 1 预设信息

+ `QingCloud`平台的管理网络为`10.16.120.0/24`。
  + `bm0/1`的管理`IP`分别为`10.16.120.7/10.16.120.8`。

+ 登录到`VPC-BORDER`:
  + 通过`telnet`: `telnet 100.67.8.131`, `user/password`: `admin/Zhu1241jie`。
  + 通过`ssh`: `ssh admin@100.67.8.131 -p 22`

+ `VPC-BORDER`要与所有区的`Hyper`之间的网络是互通的。

### 2 VPC-BORDER配置

### 2.1 检查版本

+ 使用如下命令检查`H3C`的版本

```bash
<VPC-BORDER.0001> display version

# H3C Comware Software, Version 7.1.070, Release 2609
# Boot image version: 7.1.070, Release 2609
# System image version: 7.1.070, Release 2609
# Patch image(s) list:
#  flash:/S6800-CMW710-SYSTEM-R2609H23.bin, version: Release 2609H23
```

### 2.2 登陆配置

+ 在管理节点获取公钥，并转换成`H3C`支持的格式:

```bash
ssh-keygen -e -m PKCS8 -f ~/.ssh/id_rsa.pub | openssl pkey -pubin -outform DER | od -t x1 -An -w4 | tr 'a-f' 'A-F' | tr -d ' ' | fmt -w 54 | sed 's/ //g'
```

+ 初始交换机配置。
+ 登陆到交换机后，按如下操作:

```text
telnet 100.67.6.129
```

```bash
# 进入配置模式, System View: return to User View with Ctrl+Z.
system-view

# 获取当前的配置
display current-configuration

show current-configuration configuration bgp

# 配置角色
line aux 0 1
    user-role network-admin

# 允许60个netconf并发连接
line vty 0 60
    authentication-mode scheme
    user-role network-operator

# 配置角色
line vty 61 63
    user-role network-operator

# 启用Telnet Setver
telnet server enable

# 启用SSH Server, 并配置免密登陆
ssh server enable
ssh user yop service-type all authentication-type publickey assign pki-domain yop
local-user yop class manage
    service-type telnet ssh
    authorization-attribute user-role network-admin
    authorization-attribute user-role network-operator

# 配置密钥(公钥转换方法见2.2小节开头)
public-key peer yop
    public-key-code begin
30820122300D06092A864886F70D01010105000382010F00
3082010A0282010100B9AC57A685575F654C72201F3BE6E7
0E424300BCF5F94D168C4E888B41939CD96F893779F65748
DB1461391C242F8F0E7ED1F4D75814C370135B61C7432F43
6BE73722923E809FD4474DF489E41019071C46C55EEB9800
98F6DF56AD75A1689372F05E9B05B6384AC45F627C00A2C4
EFB8D0CB5BBBDACF4D89A10FF8126406C40949416F502E56
2A015F0150243040B16EC61D3D843A49F38787C0103FD154
2B98A929AA19B86DEB40C70E003CEED2A236F6D45D9F5573
8300D49D302CCF717631D724E5E5C6ABF3415750A3161D30
8025C04F5B6EA1B0EF19F1DC3B4E65A5754354FBAED0D607
AFD0DD719E997D838D86B91FB951F0B9F9C1F501AAB2A23A
8D0203010001
    public-key-code end
    peer-public-key end

# 允许eipctl0/1通过netconf协议控制交换机
netconf ssh server enable
```

### 2.3 硬件资源配置

+ 登陆到交换机后，按如下操作:

```bash
ssh yop@100.67.8.131 -p 22
```

```bash
# 进入配置模式, System View: return to User View with Ctrl+Z.
system-view

# 我们需要去掉 ingress-port，修改为五元组:
ip load-sharing mode per-flow dest-ip src-ip ip-pro dest-port src-port global

# 配置vxlan参数, 支持 40k VIP, 8k hyper
hardware-resource switch-mode 2
hardware-resource vxlan border40k

# 启用 L2 VPN
l2vpn enable

# 启用 VTEP
vtep enable

# 配置loopback_ip地址(可选)
interface LoopBack1
    ip address 100.67.8.131 255.255.255.255


# 修改名字(可选)
sysname PEK3C-VPC-BORDER.001

# 如果使用了 evpn，需要启用BGP（此处使用ibgp）
bgp 65534
  # 配置 nsr，保证 h3c-master 宕机时 bgp 连接不中断
  non-stop-routing
  # 配置 gr, 保证 bm 重启时不清除 h3c 中的 bgp 规则
  graceful-restart
  graceful-restart timer restart 600
  graceful-restart timer wait-for-rib 3600
  graceful-restart timer purge-time 6000

  # h3c 与 bm 之间的 evpn bgp
  # h3c loopback_ip
  router-id 100.67.8.131
  # bm0 的管理 ip
  peer 10.16.120.7 as-number 65534
  # 内存不足时不释放连接
  peer 10.16.120.7 low-memory-exempt
  peer 10.16.120.7 timer keepalive 21845 hold 65535
  # h3c 主动向 bm 建立连接时使用的源 ip（h3c loopback_ip）
  peer 10.16.120.7 source-address 100.67.8.131

  # bm1 的管理 ip
  peer 10.16.120.8 as-number 65534
  peer 10.16.120.8 low-memory-exempt
  peer 10.16.120.8 timer keepalive 30 hold 90
  # h3c 主动向 bm 建立连接时使用的源 ip（h3c loopback_ip）
  peer 10.16.120.8 source-address 100.67.8.131

  address-family l2vpn evpn
    # bm0 的管理 ip
    peer 10.16.120.7 enable
    # 禁止 vpc border 向 bm 同步 bgp 路由
    peer 10.16.120.7 route-policy DenyAll export
    # bm1 的管理 ip
    peer 10.16.120.8 enable
    peer 10.16.120.8 route-policy DenyAll export

# h3c 向 bm 同步路由策略
route-policy DenyAll deny node 10

# 所有配置完毕后，建议保存下配置
save

# 退出配置模式
exit

# 重启交换机
reboot
```

### 2.4 ACL配置

+ `ACL`配置主要用于限制对`VPC-BORDER`的访问, `ACL`规则如下:

```bash
acl advanced 3000
  description telnet-ssh
  # 允许管理网络访问，示例: 允许(10.16.120.0/24)访问，需要根据实际情况进行修改
  rule 10 permit ip source 10.16.120.0 0.0.0.255
  # 允许带外所有网络访问
  rule 15 permit ip vpn-instance management
  # 禁止其他所有访问
  rule 20 deny ip
```

+ 将`ACL`规则应用到`telnet/ssh`上:

```bash
# 可以先只配置telnet的acl，用于检测acl是否正确，然后再配置ssh的acl
telnet server acl 3000
ssh server acl 3000
```

### 3 平台配置

#### 3.1 bm0/1
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

```bash
# /etc/gobgpd.conf

[global.config]
  as = 65534
  # bm mgmt_ip
  router-id = "10.16.120.7"

[[neighbors]]
  [neighbors.config]
    # h3c loopback_ip
    neighbor-address = "100.67.8.131"
    peer-as = 65534
  [neighbors.timers.config]
    connect-retry = 5
    keepalive-interval = 21845
    hold-time = 65535
  [[neighbors.afi-safis]]
    [neighbors.afi-safis.config]
      afi-safi-name = "l2vpn-evpn"
    [neighbors.afi-safis.mp-graceful-restart.config]
        enabled = true
  [neighbors.graceful-restart.config]
    enabled = true
    restart-time = 600
```
#### 3.2 在`webservice`节点使用`CLI`添加记录:

```bash
cd /pitrix/cli

# features为 1027: 不支持BM, features为 3: 支持BM, 支持EVPN， H3C交换机堆叠后仍需插入两条数据
# --mgmt_ip --bgp_ip_addr --loopback_ip 可以都填lo的ip
# --bgp_if_name 不能为空，也没有要求，可以直接使用下面两条sql中对应的值
./create-switch -S VPC-BORDER.001.01 -d "" --mgmt_ip=100.67.8.131 --loopback_ip=100.67.8.131 --vender=h3c --model=s6800 -r 0 --bgp_ip_addr=169.254.7.1 -a 65534 --bgp_if_name=FortyGigE1/0/51 -G border1 --features=3 -z pek3c -s down
./create-switch -S VPC-BORDER.001.02 -d "" --mgmt_ip=100.67.8.131 --vender=h3c --model=s6800 -r 0 --bgp_ip_addr=169.254.7.1 -a 65534 --bgp_if_name=FortyGigE2/0/51 -G border1 --features=3 -z pek3c -s down
```

```sql
# SD-WAN 需要的， 没有SD-WAN则不需要
SELECT * FROM switch WHERE switch_id = 'VPC-BORDER.001.01';
UPDATE switch SET interconnect_ifs='{"ir": ["Route-Aggregation1", "Route-Aggregation2"]}' WHERE switch_id = 'VPC-BORDER.001.01';
```

```bash
# 检查字段, active switch
./modify-switch-attributes -S VPC-BORDER.001.01 -s active
./modify-switch-attributes -S VPC-BORDER.001.02 -s active
```

### 4 检查配置

#### 4.1 检查BGP连接

+ 启动`bm`上`gobgp`服务:

```bash
# 若是已有其他 neighbors，请按个重启 gobgpd 服务
/pitrix/upgrade/exec_nodes.sh ZONE_ID-bm0 "service gobgpd restart"
/pitrix/upgrade/exec_nodes.sh ZONE_ID-bm1 "service gobgpd restart"
```

+ 在`VPC-BORDER`上执行如下命令检查:

```bash
[H3C_VG_01] display bgp peer l2vpn evpn

BGP local router ID: 1.0.0.10
Local AS number: 65534
Total number of peers: 2        Peers in established state: 2

* - Dynamically created peer
Peer                    AS  MsgRcvd  MsgSent OutQ PrefRcv Up/Down  State

10.16.120.7          65534        3        4    0       0 00:01:37 Established
10.16.120.8          65534        3        3    0       0 00:01:56 Established
```

+ 在`bm`上执行如下命令检查:

```bash
root@bm0:~# gobgp neighbor
Peer            AS Up/Down State       |#Received  Accepted
100.67.8.131 65534 00:03:57 Establ     |        0         0
```

+ 重启`swctl_server`观察日志:

```bash
# 若是已有其他 neighbors，请按个重启 swctl_server 服务
/pitrix/upgrade/exec_nodes.sh bm "supervisorctl restart swctl_server"
```

#### 4.2 检查配置

```bash
# 获取当前vxlan参数
display hardware-resource vxlan
display hardware-resource switch-mode
```

### 5 使用方法

#### 5.1 测试方法

+ 重启`swctl_server`:

```bash

```

+ 调整内网路由器的配额:

```sql
ALTER TABLE quota ALTER COLUMN intranet_router SET DEFAULT 1;
UPDATE quota SET intranet_router = 1 WHERE intranet_router = 0;
ALTER TABLE quota alter column ir_max_vxnet_cnt SET default 3;
UPDATE quota SET ir_max_vxnet_cnt = 3 WHERE ir_max_vxnet_cnt < 3;
```

+ 在`webservice`节点使用`CLI`创建内网路由器(`ir`)测试:

```bash
./create-vpc-borders -t 1
```

+ 通知前端开放公有云上对应区的`VPC BORDER`。

如果有SD-WAN，继续下面的步骤：
+ 与大地云网对接`SD-WAN`:

```bash
cd /pitrix/cli
# 尝试着运行，然后观察global job日志 wanctl 在global-proxy1 2上
./wan/sync_phynet -d 1
# 未发现问题后，正式运行
./wan/sync_phynet -d 0
```

```sql
# driver_peif_id 和 wan_peif_name 由 大地云网提供
SELECT * FROM wan_pe_iface WHERE driver_peif_id = '4530dc82-da4b-4103-917e-71ef25451085' AND wan_peif_name = 'Bundle-Ether30' AND iface_type = 'LAN';
SELECT * FROM wan_pe_iface WHERE driver_peif_id = 'c82aac95-7ce8-4654-9a75-613149e1efd5' AND wan_peif_name = 'Bundle-Ether30' AND iface_type = 'LAN';

# 执行如下sql前 , 根据上面查询的结果,对比如下命令中的 driver_peif_id, wan_peif_name
UPDATE wan_pe_iface SET connected_device_name = 'PEK3C-VPC-BORDER.001.01', connected_device_port = 'Route-Aggregation1' WHERE driver_peif_id='4530dc82-da4b-4103-917e-71ef25451085' AND wan_peif_name='Bundle-Ether30' AND iface_type='LAN';

UPDATE wan_pe_iface SET connected_device_name = 'PEK3C-VPC-BORDER.001.01', connected_device_port = 'Route-Aggregation2' WHERE driver_peif_id='c82aac95-7ce8-4654-9a75-613149e1efd5' AND wan_peif_name='Bundle-Ether30' AND iface_type='LAN';
```

+ `SD-WAN`序列号: `8cea1b00436e`。

***
