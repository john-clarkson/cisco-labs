### 背景

+ 线上`global`的`webservice`节点系统版本太低，容易引发宕机，需要升级系统版本。

### 操作过程

+ 不支持直接升级内核，更新软件包达到升级的目的。
+ 必须逐个关停旧的`webservice`节点, 优先关闭没有`VIP`的节点，然后重新拉起虚拟机，检查无误后，重复步骤。
+ 在`firstbox`上提前准备好新系统的基础镜像和对应的软件仓库。
+ 此处以改造`2`个`webservice`节点为例。

#### 准备工作

+ 在`firstbox`上，备份所有的`settings`文件。

```bash
cp -arf /pitric/conf/settings /pitric/conf/settings.$(date +%Y%m%d)
```

+ 备份`logo`和`local_config.yaml`, 在`firstbox`节点上操作:

```bash
mkdir -p /root/webservice0/1-bak/
rsync -azPS webservice0/1:/etc/rc.local* /root/webservice0/1-bak/
rsync -azPS webservice0/1:/pitrix/lib/pitrix-webconsole/static /root/webservice0/1-bak/
rsync -azPS webservice0/1:/pitrix/lib/pitrix-webconsole/mysite/local_config.yaml /root/webservice0/1-bak/
```

+ 若之前`webservice`节点没有`floating_ip`，在此次升级时，需要补充上(若不需要补充，请跳过这一步):
  + 若环境版本`installer_version >= 4.3.0`
    + 请分配一个可用的`IP`给`/pitrix/conf/variables/variables.yaml`文件中的`webservice_floating_ip`字段。
  + 若环境版本`installer_version < 4.3.0`
    + 请分配一个可用的`IP`给`/pitrix/conf/variables/webservice_floating_ip.{zone_id}`

##### global zone

+ 通过`webservice`节点的`/pitrix/conf/client.yaml`文件，更新`firstbox`上的配置:
  + 根据`qy_access_key_id`，更新`firstbox`节点的`/pitrix/conf/variables/keys/.access_key_id`。
  + 根据`qy_secret_access_key`，更新`firstbox`节点的`/pitrix/conf/variables/keys/.access_secret_key`。
  + 通过查询`global-zone`的`account`数据库中`access_key`表中与`access_key_id`对应的`secret_access_key`字段，更新`firstbox`节点的`/pitrix/conf/variables/keys/.secret_access_key`。

+ 通过`webservice`节点的`/pitrix/conf/web_console_settings.py`文件，更新`firstbox`上的配置:
  + 根据`console_key_id`，更新`firstbox`节点的`/pitrix/conf/variables/keys/.console_key_id`。
  + 根据`console_secrect_key`，更新`firstbox`节点的`/pitrix/conf/variables/keys/.console_secret_key`。
  + 通过查询`global-zone`的`account`数据库中`console_key`表中与`console_key_id`对应的`secret_console_key`字段，更新`firstbox`节点的`/pitrix/conf/variables/keys/.secret_console_key`。

##### sub zone

+ 通过`webservice`节点的`/pitrix/conf/client.yaml`文件，更新`firstbox`上的配置:
  + 根据`qy_access_key_id`，更新`firstbox`节点的`/pitrix/conf/variables/keys/.access_key_id`。
  + 根据`qy_secret_access_key`，更新`firstbox`节点的`/pitrix/conf/variables/keys/.access_secret_key`。
  + 通过查询`global-zone`的`account`数据库中`access_key`表中与`access_key_id`对应的`secret_access_key`字段，更新`firstbox`节点的`/pitrix/conf/variables/keys/.secret_access_key`。

#### settings文件

+ 仿造以下配置，编写`settings`文件，文件名为`webservice0`和`webservice1`:
  + 使用一个未被使用的`IP`地址替换`{{ mgmt_network_address }}`，此`IP`临时被占用，最终会改为原先的`IP`地址。
  + 使用`/pitrix/bin/gen_mac.py`脚本生成一个`MAC`地址替换`{{ mgmt_network_mac_address }}`。
  + 将原`webservice0/1`的`{{ physical_host }}`交叉互换使用。
  + 到物理节点确认`bridge`来修改`{{ physical_host_network_interface }}`，一般是`br0`或者`br1`。
  + 其他配置根据环境的实际值来修改。

```ini
## Role
role="webservice"

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
hostname="webservice0/1"

## Mgmt Network
mgmt_network_interface="eth0"
mgmt_network_address="{{ mgmt_network_address }}"
mgmt_network_netmask="{{ mgmt_network_netmask }}"
mgmt_network_gateway="{{ mgmt_network_gateway }}"
mgmt_network_dns_servers="{{ mgmt_network_dns_servers }}"
mgmt_network_mac_address="{{ mgmt_network_mac_address }}"

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

# 连接到webservice vm所在的物理节点，备份管理虚机的镜像
ssh ${physical_host}
virsh list --all
cd /pitrix/kernels/
rm -f webservice0/1.Done
mv webservice0/1.img old-webservice0/1.img
mv webservice0/1.xml old-webservice0/1.xml
```

#### 拉起管理节点

```bash
/pitrix/install/launch_vms.sh -f webservice0/1
```

#### 安装管理节点

```bash
/pitrix/install/install_nodes.sh webservice0/1

scp /pitrix/build/packages/deb/pitrix-ks-webservice-base/pitrix/ks/webservice-base/conf/nginx/nginx.conf webservice0/1:/etc/nginx/
/pitrix/upgrade/exec_nodes.sh -f webservice0/1 "service nginx restart"
```

+ 添加`floating_ip`(若不需要，请跳过):

```bash
rsync -azPS /pitrix/build/packages/deb/pitrix-ks-webservice-base/etc/keepalived/chk_health_webservice.sh webservice0/1:/etc/keepalived/
rsync -azPS /pitrix/build/packages/deb/pitrix-ks-webservice-base/etc/keepalived/rc.local.keepalived.webservice webservice0/1:/etc/keepalived/
rsync -azPS /pitrix/build/packages/deb/pitrix-ks-webservice-base/etc/keepalived/keepalived.conf.webservice.webservice0/1 webservice0/1:/etc/keepalived/keepalived.conf

ssh webservice0/1 "service keepalived restart"
ssh webservice0/1 "sed -i /^'exit 0'/d /etc/rc.local"
ssh webservice0/1 "cat /etc/keepalived/rc.local.keepalived.webservice >> /etc/rc.local"
ssh webservice0/1 "echo 'exit 0' >> /etc/rc.local"
ssh webservice0/1 "rm -f /etc/keepalived/rc.local.keepalived.webservice"
```

#### 部署青云服务

```bash
# global zone
/pitrix/upgrade/update.sh webservice0/1 global-webservice,global-website

# sub zone
/pitrix/upgrade/update.sh webservice0/1 pitrix-ks-api,pitrix-ks-cli,zone-webservice
```

#### 检查服务

+ 在`firstbox`节点执行，删除`ssh`的异常提示:
    + 修改`IP0/1`为实际的`webservice0/1`的`IP`地址。

```bash
ssh-keygen -f '/root/.ssh/known_hosts' -R webservice0/1
ssh-keygen -f '/root/.ssh/known_hosts' -R IP0/1
/pitrix/upgrade/exec_nodes.sh -f all "ssh-keygen -f '/root/.ssh/known_hosts' -R webservice0/1"
/pitrix/upgrade/exec_nodes.sh -f all "ssh-keygen -f '/root/.ssh/known_hosts' -R IP0/1"
```

+ 检查青云服务:

```bash
/pitrix/upgrade/exec_nodes.sh -f webservice0/1 "supervisorctl status"
```

+ 通过`console`页面来检查。

***
