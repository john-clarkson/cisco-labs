### 背景

+ 线上`global`的`dnsmaster`节点系统版本太低，容易引发宕机，需要升级系统版本。

### 操作过程

+ 不支持直接升级内核，更新软件包达到升级的目的。
+ 必须逐个关停旧的`dnsmaster`节点, 优先关闭没有`VIP`的节点，然后重新拉起虚拟机，检查无误后，重复步骤。
+ 在`firstbox`上提前准备好新系统的基础镜像和对应的软件仓库。
+ 此处以改造`2`个`dnsmaster`节点为例。

#### 准备工作

+ 在`firstbox`上，备份所有的`settings`文件。

```bash
cp -arf /pitric/conf/settings /pitric/conf/settings.$(date +%Y%m%d)
```

+ 备份旧的`dnsmaster`的配置文件:

```bash
mkdir -p /root/dnsmaster0/1-bak/
rsync -azPS dnsmaster0/1:/etc/bind /root/dnsmaster0/1-bak/
rsync -azPS dnsmaster0/1:/etc/keepalived /root/dnsmaster0/1-bak/
rsync -azPS dnsmaster0/1:/etc/rc.local* /root/dnsmaster0/1-bak/
```

#### settings文件

+ 仿造以下配置，编写`settings`文件，文件名为`dnsmaster0`和`dnsmaster1`:
  + 根据实际情况修改`os_name`和`os_version`。
  + 按照实际环境修改`{{ mgmt_network_gateway }}`，管理网络的网关，若有`VG`节点，则为放置此管理虚机的`VG`节点的`IP`地址。
  + 按照实际环境修改`{{ vm_network_routing_rule }}`，若有`VG`节点，则该值中的`{{ mgmt_network_gateway }}`，应该为`{{ vg_mgmt_network_gateway }}`的值。
  + 按照实际环境修改`{{ physical_host }}`，放置此管理虚机的物理机的`IP`地址，若有`VG`节点，则必须从`VG`节点中选取。
  + 按照实际环境修改`{{ physical_host_network_interface }}`，放置此管理虚机的物理机的`bridge`的名称，一般是`br0`。
  + 其他配置按照老的`settings`文件修改。

```ini
## Role
role="dnsmaster"

## Region
is_region="0"
region_id=""
zone_id="{{ zone_id }}"

## Feature
feature_vmnode="on"
feature_ksnode="on"
feature_vgnode="off"
feature_hypernode="off"
feature_conntrack="off"

## Firstbox
firstbox_address="{{ firstbox_address }}"

## General
cpu_arch="x86_64"
cpu_cores="4"
memory_size="8000"
os_name="xenial"
os_version="16.04.5"
hostname="dnsmaster0/1"

## Mgmt Network
mgmt_network_interface="eth0"
mgmt_network_address="{{ mgmt_network_address }}"
mgmt_network_netmask="{{ mgmt_network_netmask }}"
mgmt_network_gateway="{{ mgmt_network_gateway }}"
mgmt_network_dns_servers="1.2.4.8 119.29.29.29 114.114.114.114"
mgmt_network_mac_address="{{ mgmt_network_mac_address }}"

## VM Network
vm_network_routing_rule="ip route add {{ vm_base_network }} src {{ mgmt_network_address }} via {{ mgmt_network_gateway }}"

## Host
physical_host="{{ physical_host }}"
physical_host_network_interface="{{ physical_host_network_interface }}"
physical_host_eip_network_interface=""
```

+ 若环境版本`installer_version >= 4.3.0`
  + 刷新整个云平台节点列表: `/pitrix/bin/gen_node_list.py`。
  + 构建包: `/pitrix/build/build_pkgs_allinone.py`。
+ 若环境版本`installer_version < 4.3.0`
  + 刷新整个云平台节点列表: `/pitrix/bin/gen_node_list.sh`。
  + 构建包: `/pitrix/build/build_pkgs_allinone.sh`。


#### 备份管理节点

```bash
# 连接到管理节点，停止所有服务, 然后关机
supervisorctl stop all
shutdown -h now

# 连接到dnsmaster vm所在的物理节点，备份管理虚机的镜像
ssh ${physical_host}
virsh list --all
cd /pitrix/kernels/
rm -f dnsmaster0/1.Done
mv dnsmaster0/1.img old-dnsmaster0/1.img
mv dnsmaster0/1.xml old-dnsmaster0/1.xml
```

#### 拉起管理节点

```bash
/pitrix/install/launch_vms.sh dnsmaster0/1
```

#### 安装管理节点

```bash
/pitrix/install/install_nodes.sh dnsmaster0/1
```

#### 部署青云服务

```bash
/pitrix/upgrade/update.sh dnsmaster0/1 pitrix-ks-dnsmaster
```

#### 所有新部署的dns节点还原配置
```
# 用之前备份的老的/etc/bind目录覆盖掉新部署节点对应目录,一定要确保/etc/bind目录权限是 bind: bind 然后执行下面命令
rndc sync -clean
/pitrix/bin/ns_restore rebuild
service bind9 restart
```

#### 检查服务

+ 在`firstbox`节点执行，删除`ssh`的异常提示:
    + 修改`IP0/1`为实际的`dnsmaster0/1`的`IP`地址。

```bash
ssh-keygen -f '/root/.ssh/known_hosts' -R dnsmaster0/1
ssh-keygen -f '/root/.ssh/known_hosts' -R IP0/1
/pitrix/upgrade/exec_nodes.sh -f all "ssh-keygen -f '/root/.ssh/known_hosts' -R dnsmaster0/1"
/pitrix/upgrade/exec_nodes.sh -f all "ssh-keygen -f '/root/.ssh/known_hosts' -R IP0/1"
```

+ 检查青云服务:

```bash
/pitrix/upgrade/exec_nodes.sh -f dnsmaster0/1 "supervisorctl status"
```

+ 通过`console`页面来检查。

```
# 在console起一台主机然后执行 查看结果
nslookup www.baidu.com $vip
nslookup www.baidu.com $dnsA_ip
nslookup www.baidu.com $dnsB_ip

# 找一台路由器
nslookup rtr-xxx.sh1a.qingcloud.com $ip
```
***
