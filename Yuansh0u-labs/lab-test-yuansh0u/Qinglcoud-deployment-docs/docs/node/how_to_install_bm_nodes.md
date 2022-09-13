### 1 准备安装环境

1. 确保裸机节点已上电，已插好磁盘，已接好网线，ipmi 网络配置好。
2. 在执行 launch_fb.sh 时, 需加上 -i 参数来指定 pxe 网络配置的网卡，此网卡必须跟裸机节点的某 pxe 网卡是二层联通的。
3. 在执行 deploy.sh 时, 需加上 -i 和 -n 参数指定 ipmi 网卡和 ipmi 地址; 如果管理网络可以直接连接裸机 ipmi 网络，则不需要指定。
4. 为裸机节点安装的 OS 默认使用 installer 自带的 ubuntu 特定版本的虚机镜像, 目前包括 ubuntu14045 和 ubuntu16043。

### 2 使用指南

#### 2.1 获取裸机节点信息

##### 注册裸机节点

* 进入 /pitrix/cli 目录，从 examples 目录的 bms.json.example 拷贝一个 bms.json 出来  
    `cp /pitrix/node/provision/examples/bms.json.example /pitrix/node/provision/bms.json`  
    按照文件的 example 写入相关裸机节点的信息
  ``` text
  {
    "os_version": "14.04.5",                       必填项，需要跟 installer 包含的 ksnode 镜像对应的 ubuntu 版本一致
    "cpu_arch": "x86_64",                          必填项，需要跟 installer 包含的 ksnode 镜像对应的 ubuntu 架构一致
    "hostname": "test01n01",                       必填项，指明待安装 bm 的主机名
    "os_disk_name": "",                            非必填项，指明哪块磁盘作为待安装 bm 的系统盘
    "ipmi_network_address": "172.30.10.47",        必填项，指明 bm 的 ipmi 地址
    "ipmi_username": "ADMIN",                      必填项，指明 bm 的 ipmi 登录用户名
    "ipmi_password": "ADMIN",                      必填项，指明 bm 的 ipmi 登录密码
    "pxe_network_mac_addr": "0c:c4:7a:88:63:1b",   必填项，指明 bm 的 pxe 网卡 MAC 地址
    "mgmt_network_address": "172.31.11.47",        非必填项，配置 bm 的 mgmt 网络 ip 地址
    "mgmt_network_netmask": "255.255.255.0",       非必填项，配置 bm 的 mgmt 网络子网掩码； 默认为 255.255.255.0
    "mgmt_network_gateway": "172.31.11.254",       非必填项，配置 bm 的 mgmt 网络网关； 默认为 x.x.x.254
    "public_network_address": "",                  非必填项，配置 bm 的 public 网络 ip 地址
    "public_network_netmask": "",                  非必填项，配置 bm 的 public 网络子网掩码； 默认为 255.255.255.0
    "public_network_gateway": "",                  非必填项，配置 bm 的 public 网络网关； 默认为 x.x.x.1
    "is_mgmt_config_bond": 0,                      非必填项，指明 bm 的 mgmt 网络是否配置 bond； 默认0（不配置)；1（配置）
    "is_public_config_bond": 0,                    非必填项，指明 bm 的 public 网络是否配置 bond； 默认0（不配置)；1（配置）
    "is_mgmt_config_vlan": 0,                      非必填项，指明 bm 的 mgmt 网络是否配置 vlan； 默认0（不配置)；1（配置）
    "is_public_config_vlan": 0,                    非必填项，指明 bm 的 public 网络是否配置 vlan； 默认0（不配置)；1（配置）
    "mgmt_network_vlan_id": 0,                     非必填项，指明 bm 的 mgmt 网络的 vlan id； 默认为 0；如果配置 vlan 此处非 0
    "public_network_vlan_id": 0,                   非必填项，指明 bm 的 public 网络的 vlan id； 默认为 0；如果配置 vlan 此处非 0
    "serial_number": '1235343543',                 非必填项，指明 bm 的 序列号
    "brand": "dell"                                非必填项，指明 bm 的 品牌类型 如 dell/supermicro/inspur
  }
  ```

* 进入 /pitrix/cli 目录， 注册裸机节点  
    `./register-bm-nodes.py -j /pitrix/node/provision/bms.json`  

* 查看已注册节点
    `./describe-bm-nodes.py`
    如果需要修改某些属性,可以利用 `./modify-bm-node-attributes.py` 来修改

#### 2.2 安装操作系统

* 进入 /pitrix/cli 目录， 为裸机节点安装 OS  
    `./provision-bm-nodes.py -n <node_id>`  
    可以利用 `./get-provision-bm-nodes-status.py` 查看当前部署状态  
    可以利用 `./get-provision-bm-nodes-log.py` 查看日志  
    详细日志文件为 /pitrix/log/node/provision.log  

