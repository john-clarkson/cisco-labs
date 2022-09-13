### 1 简介

+ 部署时，请微信联系`Ben`, 邮箱: `benwang@yunify.com`;
+ 请事先从`ftp://ins.qingcloud.com/public/bm/`中将其中的引导镜像上传到`firstbox`中。
    + 若无此`FTP`账号，请联系`杨正枫`开通，邮箱: `yangzhengfeng@yunify.com`。
    + 等待拉起`bm0/1`管理虚拟机之后，将镜像放入`bm0/1`的指定位置，注意校验`MD5`值。
    + `/pitrix/data/image/bootcore`: `15ba9f82f4c5db18606a5f612fc57852`。
    + `/pitrix/data/image/bootcorea`: `4fe4fb4be0a03e2930ea6583d4ddaf75`。
    + `/pitrix/data/image/bootcoreb`: `e0f275dde6942cab4630b35a494379cb`。
    + `/pitrix/data/image/bootcorec`: `449aa306fbae1260cb2238062ddaed42`。
+ `KS-BM`：代表着承载`bm0/1`管理虚拟机的物理服务器。
+ `bm0/1`：`BM`的管理节点，管理虚拟机。
+ `BM Node`：即`BM Hyper`。

#### 1.1 基本架构

+ `BM Node`通过`BM Network`连接到`VPC border switch`, 再通过`VPC border switch`与`VM`主机实现三层互通;

```text
VM Instance <--->  VPC Border Switch <---> SDN Switch <---> BM Node(Instance)
```

#### 1.2 网络

+ 需要为`BM`准备`4`种网络：
    + `IPMI`网络： 管理节点(`bm0/1`)通过该网络控制`BM Node`电源的开启与关闭等。
    + `PXE`网络： 管理节点(`bm0/1`)通过该网络引导`BM Node`启动到青云定制操作系统中，必须与`bm0/1`二层网络相通。
    + `BM Node`数据网络:
        + 使用万兆口通信。
        + `BM Node`通过该网络获取操作系统镜像, `IP`地址由`os_provision_subnet`决定。若网关非`.1`地址，则需要配置`os_provision_subnet_gateway`。
        + `BM Node`通过该网络与`VPC`内其他主机互通，`IP`地址由`VPC vxnet`网段决定。
        + `BM Node`通过该网络与基础网络内的主机互通，`IP`地址由预先配置的`BM`类型基础网络网段决定。

+ `BM Node`需要配置的操作：
    + 在服务器的`iDRAC`中的**网络**的**网络**中勾选**启用`LAN`上的`IPMI`**。
    + 在服务器的`iDRAC`中的**网络**的**网络**中不勾选**启用`VLAN ID`**。
    + 在服务器的`iDRAC`中的**网络**的**服务**中勾选**启用`VNC Server`**。
    + `IPMI & PXE`共有一个电口，在`iDRAC`中**网络**的**网络设置**:
        + 勾选启用`NIC`。
        + `NIC 选择`: 对应的`LOM`，不能选**专用口**。
        + 不勾选自动专有`NIC`。
        + 服务器需要重启。
    + 在服务器的`BIOS`界面中将所有光口的从`PXE`引导关闭掉，将共享口(电口)的从`PXE`引导打开，并设置为第一启动项，可多重启几次，反复确认一下。
    + 目前只有`DELL`机器支持`VNC`，如果使用的是`DELL`主机，请将微码(固件版本)升级到最新版本。
        + `Dell PowerEdge R730`: 可以使用`2.43.43.43`版本的微码。
        + `Inspur NF5270M4`:
            + `BMC`: `4.25`
            + `BIOS`: `4.1.21`
            + `ME`: `3.3.38`

#### 1.3 接线

+ 部署时，通常可按如下方式接线：
+ `BM Node`的`2`个数据网卡（万兆最好），连到`SDN switch`上，然后配置`core switch`保证与`KS`节点三层互通。

```text
KS <---> core switch <---> SDN switch <---> BM Node(Instance)
```

+ `BM Node`的`1`个`IPMI`网卡，通过交换机与管理节点(`bm0/1`)二层互通，`IPMI & PXE`网络均通过该路线打通。

```text
bm0/1 <---> layer2 switch <---> BM Node(Instance)
```

+ 共享的电口，尽量不要有`DHCP`服务，避免发生未知错误。
+ 部署`BM`服务，必须新加交换机，无法与`Iass`共用交换机，因为可能导致`Hyper`丢包，还在和`H3C`联合解决中。

### 2 硬件准备

#### 2.1 交换机

+ `BM Node`目前支持`3`种网络模式：
    + `vlan`: `sdn switch`采用`vlan`，目前支持`H3C S6800`交换机, 需要部署青云的`SDN`控制器：`swctl_server`。
        + 此模式为最简配置，可以使用`2`台交换机（堆叠）作为`VPC border switch`，将`BM Node`直接接入到这`2`台交换机上。
    + `vlan_trunk`: `SDN switch`支持`vlan`即可，无需特定的交换机，需要部署青云的`SDN`控制器：`swctl_server`。
        + 此模式是预先在交换机上配置可用`vlan`段，并创建若干物理主机类型的基础网络，`BM Node`在这些基础网络中运行，能与基础网络中的虚机三层互通。
        + 注意： 此模式不支持`VPC`。
    + `vxlan`: `SDN switch`采用`evpn`，目前支持`CISCO NEXUS9000`交换机, 需要部署大地`SDN`控制器：`terra-fc controller`。
        + 此模式通常需要`6`台交换机： `2`个`spine`节点， `2`个`border leaf`节点（与`VPC border switch`互联），`2`个`leaf`节点。

+ `BM Node`的万兆口对应的交换机的端口，既要做`trunk`，也要做`lacp`, `Trunk`允许通过`ipmi、pxe`和用户`BM基础网络的VLAN`。

#### 2.2 物理主机(BM Node)

+ 在`BIOS`中设置服务器的启动方式为`Legacy`，不要设置为`UEFI`。
+ 因为`BM`需要`3`个网络，物理主机至少需要`3`个网卡（通过`Bonding`的`2`个万兆网卡用于数据传输，`1`个千兆网卡用于`IPMI & PXE`）。
+ 物理主机至少需要有`1`块盘存放`OS`，如果使用`RAID`，也需要先划分出一块盘用于存放`OS`。
+ 另外，需要收集如下信息（在注册时需要使用）：
    + 各网卡的`MAC`地址。
    + 万兆网卡接在交换机的口，例如：`port-channel101`。
    + `BM Node`的`IPMI`地址。

#### 2.3 网络规划

+ 因为`BM`需要`3`个网络，所以需要准备`3`个网段 (后面的网段只是个示例，部署时需根据实际情况修改)：
    + `IPMI`网段: `172.18.10.0/24`
    + `PXE`网段: `172.18.20.0/24`
    + 部署操作系统用的网段(`os_provision_subnet`): `10.100.100.0/24`
    + 若`PXE`网段和`IPMI`共用一个`C`类网段，切记不要设置相同的`IP`。

+ 示例中相关的网络地址：
    + `{{SWITCH_LOOPBACK_IP}}`：`Switch`(交换机)的`LoopBack IP`，示例中为`10.10.10.10`。
    + `{{BM_MGMT_ADDRESS}}`：`bm0/1`的管理网络的`IP`地址。

+ 在`Region`模式并且`BM`的网络模式为`vlan`或`vxlan`下，需确保`Switch`的`loopback ip`与所有`ZONE`的`Hyper`节点能三层互通。
    + 检测: 在`Switch`上尝试`PING`目标`ZONE`的`Hyper`的`IP`地址。

### 3 部署bm节点

#### 3.1 新环境部署

+ 在配置青云平台阶段, 编辑`variables.template.yaml`时, 如实填写`bm`相关项目：

```yaml
bm:
  # bm0/bm1's mgmt address, empty is defalut(auto generated from vm_mgmt_network_pools)
  bm_mgmt_network_address:
    - ''
    - ''
  # Valid options are [ vlan, vlan_trunk, vxlan ]
  bm_network_mode: 'vlan_trunk'
  # bm switch loopback ip
  bm_switch_loopback_ip: '127.0.0.1'
  # bm pxe network pools, 198.18.244.2/22-198.18.244.9/22 is default
  bm_pxe_network_pools:
    - '198.18.244.2/22-198.18.244.9/22'
  # bm0/bm1's pxe address, empty is defalut(auto generated from bm_pxe_network_pools)
  bm_pxe_network_address:
    - ''
    - ''
  # bm pxe subnets, 192.18.244.10-198.18.247.250 is default
  bm_pxe_subnets:
    - '198.18.244.10/22-198.18.247.250/22'
  # os provision subnet, used for bm server
  os_provision_subnet: '10.100.100.0/24'
  # os provision subnet gateway
  os_provision_subnet_gateway: '10.100.100.1'
  # os provision subnet vlan_id
  os_provision_subnet_vlan_id: 0
  installer_allocate_ipmi: 0
  # bm ipmi network pools, 198.18.240.2/22-198.18.240.9/22 is default
  bm_ipmi_network_pools:
    - '198.18.240.2/22-198.18.240.9/22'
  # bm0/bm1's ipmi address, empty is defalut(auto generated from bm_ipmi_network_pools)
  bm_ipmi_network_address:
    - ''
    - ''
```

+ `bm_mgmt_network_address`: 指定`bm0/1`管理网络的`IP`地址，可以不指定。
+ `bm_network_mode`: 配置使用`BM`的网络模式。
+ `bm_switch_loopback_ip`: `BM`交换机上配置的`loopback IP`，`vlan_trunk`模式保持不变。
+ `os_provision_subnet`: 指定`os_provision_subnet`的网络。
+ `os_provision_subnet_gateway`: 指定`os_provision_subnet`的网络的网关。
+ `os_provision_subnet_vlan_id`: 指定`os_provision_subnet`的网络的`VLAN ID`。
+ `bm_pxe_network`网络是部署`BM Node`时所使用的网络，不需要与外界相通:
    + `bm_pxe_network_pools`：用于为管理虚拟节点(`bm0/1`)分配`PXE`网络的`IP`地址。
    + `bm_pxe_network_address`: 指定`bm0/1`的`PXE`网络的`IP`地址，可以不指定。
    + `bm_pxe_subnets`：为`QingCloud`的代码中使用。
    + 这`2`个`pools`别有交集，一般情况`bm_pxe_network`等于`2`者之和，`bm_pxe_network_pools`一般分配`10`个就够了。
+ `bm_ipmi_network`网络是`IPMI`网络，默认需`PXE`网络共用同一个网口:
    + `installer_allocate_ipmi`: 是否由`Installer`为`bm0/1`配置`IPMI`网络，若`IPMI`网络与管理网络互通则设置为`0`即可。
    + `bm_ipmi_network_pools`: 用于为管理虚拟节点(`bm0/1`)分配`IPMI`网络的`IP`地址。
    + `bm_ipmi_network_address`: 指定`bm0/1`的`IPMI`网络的`IP`地址，可以不指定。

#### 3.2 老环境追加

+ 老环境需要根据具体环境具体分析，暂时没有通行的办法，以下方法仅做一些参考。
+ 在`fb`上更新`server.yaml`配置文件：

```text
common:
  enable_bm_vbc: 1
  resource_limits:
    REGION_ID:
      bm_zones:
        - 'ZONE_ID'
      # 包含类型 5
      valid_instance_classes: '0,1,5'

compute_server:
  # pxe的范围，可以根据bm数量调整
  pxe_subnets:
    - '172.18.20.10-172.18.20.254'
　# 指定拷贝BM镜像的超时时间，默认为 600
  bm_image_transfer_timeout: 600
  # PXE网络的掩码位数
  pxe_netmask: '/24'
  # 是否显示PXE网卡，默认为 0
  bm_show_pxe_nic: 0
  # vxnet-ks的网段，跟交换机定义的vlan 需要匹配
  os_provision_subnet: '10.100.100.0/24'
  # vxnet-ks的网关
  os_provision_subnet_gateway: '10.100.100.1'
  # 使用h3c vlan 模式连接bm, 填写具体的模式 ['vlan', 'vlan_trunk', 'vxlan']
  bm_network_mode: 'vlan'
  # vlan模式不起作用，保持默认
  bm_border_as_number: 65101
  # 边界交换机的 bgp as number, 保持默认
  vpc_border_as_number: 65534
  # vlan/vxlan模式，需要设置
  bm_vlan_id_range: '2500~4000'
  # Cisco控制器插件，H3C、华为交换机无需填写
  network_ml2_plugin: "networking_terra.ml2.mech_terra.TerraMechanismDriver"
  network_l3_plugin: "networking_terra.l3.terra_l3.TerraL3RouterPlugin"
  network_qcext_plugin: "networking_terra.qcext.qcext_terra.TerraQcExtDriver"
  network_driver_config_file: "/pitrix/conf/network_driver.ini"
```

+ 然后重新 `build` 包: `/pitrix/upgrade/build_global_conf.sh`;
+ 重新安装 `pitrix-global-conf` 包: `/pitrix/upgrade/update.sh -f all pitrix-global-conf`;

+ 为承载管理虚拟节点(`bm0/1`)的`ks-bm`节点添加`PXE&IPMI`网络：

```text
# /etc/network/interfaces

auto {{BM_PXE_INTERFACE}}
iface {{BM_PXE_INTERFACE}} inet manual

# bm network
auto br1
iface br1 inet static
  address {{BM_PXE_ADDRESS}}
  netmask {{BM_PXE_NETMASK}}
  bridge_ports {{BM_PXE_INTERFACE}}
  bridge_stp off
  bridge_waitport 0
  bridge_fd 0
```

```bash
# 不要轻易重启网络或者重启节点

# 添加 bridge
brctl addbr br1
brctl addif br1 {{BM_PXE_INTERFACE}}

# 删除 bridge(忽略，不用做)
ifconfig br1 down
brctl delif br1 {{BM_PXE_INTERFACE}}
brctl delbr br1
```

+ 将如下信息添加到`firstbox`中对应`KS-BM`节点的`setting`文件中：

```text
## BM Network
# interface: eth1
bm_pxe_network_interface="{{BM_PXE_INTERFACE}}"
# bridge ports: br1
bm_pxe_network_bridge_ports="br1"
bm_pxe_network_address="{{BM_PXE_ADDRESS}}"
bm_pxe_network_netmask="{{BM_PXE_NETMASK}}"
bm_pxe_network_netmask_num="{{BM_PXE_NETMASK_NUM}}"
# bridge ports: br1, 若不共用同一链路，将值设置为空
bm_ipmi_network_bridge_ports="br1"
bm_ipmi_network_address="{{BM_IPMI_ADDRESS}}"
bm_ipmi_network_netmask="{{BM_IPMI_NETMASK}}"
bm_ipmi_network_netmask_num="{{BM_IPMI_NETMASK_NUM}}"
```

+ 由于`IPMI & PXE`共用一个链路，所以将`IPMI`的`IP`地址也需要绑定到承载`PXE`网络的网络接口上(`KS-BM`节点)：

```bash
# 若不共用同一链路，可忽略此步骤
echo "# bm ipmi network" >> /etc/rc.local.tail
echo "ip addr add {{BM_IPMI_ADDRESS}}/{{BM_IPMI_NETMASK_NUM}} dev br1" >> /etc/rc.local.tail
echo "" >> /etc/rc.local.tail
```

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 进入`/pitrix/config`目录，从`templates`目录的`vm_variables.template.yaml`拷贝一个`vm_variables.ZONE_ID.yaml`出来:
    + `cp -f /pitrix/config/templates/vm_variables.template.yaml /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 此处拷贝的配置文件，必须让`ZONE_ID`在中间，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板里的说明，按需为需要追加部署组件的`ZONE`填入必要的信息。
    + 一次仅允许追加部署一种组件。

+ 更改配置文件:
    + 将`deploy_bm`设置为`1`。
    + 将`bm_network_mode`修改为实际值，支持`vlan_trunk`，`vlan`，`vxlan`。
    + 将`bm_switch_loopback_ip`修改为实际值，若为`vlan_trunk`模式，无需更改。
    + 其他参数参照全新部署时对各参数的释义。

+ 部署管理节点: `/pitrix/cli/deploy-qingcloud-component.py -v /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 查看部署管理节点的当前状态：`/pitrix/cli/get-deploy-qingcloud-component-status.py`。
    + 查看部署管理节点的简略日志：`/pitrix/cli/get-deploy-qingcloud-component-log.py`。
    + 详细日志请看目录下对应`job`的日志：`/pitrix/log/deploy`。
    + 此步骤耗时较长, 耐心等待完成。

#### 3.3 部署检查

+ 如果采用`3.1`节描述方式部署, 部署完毕后, 请参考`3.2`检查`server.yaml`配置是否正确, 尤其是`bm_network_mode`。
+ 在`bm0/1`上, 检查如下端口:

```bash
# Ubuntu 16.04.3
netstat -4nlp  | egrep 'ietd|tftpd'
tcp        0      0 0.0.0.0:3260            0.0.0.0:*               LISTEN      1176/ietd
udp        0      0 0.0.0.0:69              0.0.0.0:*                           1154/in.tftpd

# Ubuntu 16.04.5
netstat -4nlp  | egrep 'tftpd'
udp        0      0 0.0.0.0:69              0.0.0.0:*                           1154/in.tftpd
```

***
