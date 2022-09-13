### 背景

+ 线上`global`的`proxy`节点系统版本太低，容易引发宕机，需要升级系统版本。

### 操作过程

+ 不支持直接升级内核，更新软件包达到升级的目的。
+ 在做改造升级之前，一定要将环境信息整理清楚，如网络规划、内部路由等。
+ 本方案为临时占用`2`个管理地址`IP`，然后重新拉起虚拟机，检查无误后，关闭旧节点。
+ 在`firstbox`上提前准备好新系统的基础镜像和对应的软件仓库。
+ 此处以改造`2`个`proxy`节点为例。

#### 准备工作

+ 在`firstbox`上，备份所有的`settings`文件。

```bash
cp -arf /pitric/conf/settings /pitric/conf/settings.$(date +%Y%m%d)
```

#### settings文件

+ 仿造以下配置，编写`settings`文件，文件名为`proxy0`和`proxy1`:
  + 根据实际情况修改`os_name`和`os_version`。
  + 按照实际环境修改`{{ mgmt_network_gateway }}`, 若有`VG`节点，则此处为空。
  + 使用`/pitrix/bin/gen_mac.py`脚本生成一个`MAC`地址替换`{{ mgmt_network_mac_address }}`和`{{ eip_network_mac_address }}`。
  + 按照实际环境修改`{{ mgmt_network_routing_rule }}`:
    + 若无`VG`节点，则设置为空。
    + 若`VG`节点与`KS`节点的管理网属于同一个`C`类网段，则设置为空。
    + 若`VG`节点与`KS`节点的管理网属于不同的`C`类网段，则设置为`ip route add {{ mgmt_network }} via {{ vg_mgmt_network_gateway }}`
  + 按照实际环境修改`{{ vm_network_routing_rule }}`，若有`VG`节点，则该值中的`{{ mgmt_network_gateway }}`，应该为`{{ vg_mgmt_network_gateway }}`的值。
  + 若无`VG`节点，则去掉`## Eip Network`一项，若有则设置一个内部未被使用任意的`IP`，比如`2.2.2.2`。
  + 按照实际环境修改`{{ physical_host }}`，放置此管理虚机的物理机的`IP`地址，若有`VG`节点，则必须从`VG`节点中选取，此方案不允许与旧节点放置在同一物理节点，可交叉互换使用。
  + 按照实际环境修改`{{ physical_host_network_interface }}`，放置此管理虚机的物理机的`MGMT`网络的`bridge`的名称，一般是`br0`。
  + 按照实际环境修改`{{ physical_host_eip_network_interface }}`，放置此管理虚机的物理机的`EIP`网络的`bridge`的名称，一般是`br1`。
  + 其他配置按照老的`settings`文件修改。

```ini
## Role
role="proxy"

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
hostname="proxy0/1"

## Mgmt Network
mgmt_network_interface="eth0"
mgmt_network_address="{{ mgmt_network_address }}"
mgmt_network_netmask="{{ mgmt_network_netmask }}"
mgmt_network_gateway="{{ mgmt_network_gateway }}"
mgmt_network_dns_servers="{{ mgmt_network_dns_servers }}"
mgmt_network_mac_address="{{ mgmt_network_mac_address }}"
mgmt_network_routing_rule="{{ mgmt_network_routing_rule }}"

## VM Network
vm_network_routing_rule="ip route add {{ vm_base_network }} src {{ mgmt_network_address }} via {{ mgmt_network_gateway }}"

## Eip Network
eip_network_interface="eth1"
eip_network_address="{{ eip_network_address }}"
eip_network_netmask="{{ eip_network_netmask }}"
eip_network_gateway="{{ eip_network_gateway }}"
eip_network_mac_address="{{ eip_network_mac_address }}"

## Host
physical_host="{{ physical_host }}"
physical_host_network_interface="br0"
physical_host_eip_network_interface="{{ physical_host_eip_network_interface }}"
```

+ 若环境版本`installer_version >= 4.3.0`:
  + 刷新整个云平台节点列表: `/pitrix/bin/gen_node_list.py`。
  + 构建包: `/pitrix/build/build_pkgs_allinone.py`。
+ 若环境版本`installer_version < 4.3.0`:
  + 刷新整个云平台节点列表: `/pitrix/bin/gen_node_list.sh`。
  + 构建包: `/pitrix/build/build_pkgs_allinone.sh`。
+ 此时，千万不要更新任何包到其他节点。

#### 拉起管理节点

```bash
/pitrix/install/launch_vms.sh proxy
```

#### 安装管理节点

```bash
/pitrix/install/install_nodes.sh proxy
```

#### 部署青云服务

```bash
# 安装完之后，可能会影响VIP的漂移，从而导致console访问异常
/pitrix/upgrade/update.sh proxy pitrix-ks-proxy
# 部署了 boss v1，则需要执行
/pitrix/upgrade/update.sh proxy pitrix-ks-proxy-boss
# 部署了 boss v2，则需要执行
/pitrix/upgrade/update.sh proxy pitrix-ks-proxy-boss2
# 部署了 warehouse，则需要执行
/pitrix/upgrade/update.sh proxy pitrix-ks-proxy-warehouse
```

#### 检查服务

+ 对比`haproxy.cfg`:
  + 配置文件中关于**端口绑定**的位置发生了变化，此处可忽略。
  + 忽略对`website`的端口转发，端口是`8081`。
  + 若为`sub region/sub zone`，注意修改`api-server`、`ws-front`和`io-front`的中对应的后端节点。

+ 对比`rc.local`、`rc.local.head`、`rc.local.tail`文件。

+ 检查青云服务:

```bash
/pitrix/upgrade/exec_nodes.sh -f proxy "supervisorctl status"
```

#### 切换节点

+ 更新`firstbox`节点的`proxy/1`的`settings`文件中的`MGMT`和`EIP`网络配置。

```bash
vim /pitrix/conf/settings/proxy0/1
/pitrix/upgrade/build_global_conf.sh
```

+ 将新`proxy/1`的`IP`地址改成旧`proxy0/1`的`IP`地址。

```bash
vim /etc/network/interfaces
```

+ 通过`IP`地址连接到旧的`proxy0/1`上，执行关机操作。

```bash
supervisorctl stop all
shutdown -h now
```

+ 通过`IP`地址连接到新的`proxy0/1`上，执行重启操作。

```bash
supervisorctl stop all
apt-get update
apt-get --yes --allow-unauthenticated install pitrix-hosts
shutdown -r now
```

#### 检查服务

+ 在`firstbox`节点执行，删除`ssh`的异常提示:
    + 修改`IP0/1`为实际的`proxy0/1`的`IP`地址。

```bash
ssh-keygen -f '/root/.ssh/known_hosts' -R proxy0/1
ssh-keygen -f '/root/.ssh/known_hosts' -R IP0/1
/pitrix/upgrade/exec_nodes.sh -f all "ssh-keygen -f '/root/.ssh/known_hosts' -R proxy0/1"
/pitrix/upgrade/exec_nodes.sh -f all "ssh-keygen -f '/root/.ssh/known_hosts' -R IP0/1"
```

+ 检查青云服务:

```bash
/pitrix/upgrade/exec_nodes.sh -f proxy "supervisorctl status"
```

+ 通过`console`页面来检查。

#### 备份管理节点

```bash
# 连接到旧 proxy 所在物理节点，备份管理虚机的镜像
ssh ${physical_host}
virsh list --all
cd /pitrix/kernels/
mv proxy0/1.img old-proxy0/1.img
mv proxy0/1.xml old-proxy0/1.xml
virsh undefine proxy0
```

***
