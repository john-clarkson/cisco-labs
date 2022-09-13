# IPv6产品:
IPv6 VPC:,  IPv6 VBC, IPv6 EIP,  IPv6 LBC,  IPv6 VM image,  IPv6 FW & NACL. 

#### VLAN 模式
+ 前提:        数据中心支持IPv6 路由, DNS 服务提供商支持AAAA 记录
+ 交换机：      接入,核心, 安全设备需支持双栈
+ 基础网络：    支持IPv4和IPv6双栈，网关在用户交换设备上
+ VPC网络：	   只支持IPv4
+ 维护：        平台只负责IPv6 地址分配, 用户侧交换设备负责物理网络划分, 转发
+ 说明：        需大量人工配置,  网络问题定位需经物理设备查询

#### SDN 
##### Vxlan 基础网络	
+ 前提：	        数据中心支持IPv6 路由, DNS 服务提供商支持AAAA 记录
+ 交换机：		接入、核心, 安全需支持双栈模式
+ 基础网络：		支持IPv4, IPv6双栈, 基础网络网关在SDN hyper上,需在三层设备上添加路由配置	
+ VPC 网络：	    支持IPv4, IPv6双栈
+ 维护:	        所有网络安全管控、物理网络划分在青云平台内，用户侧增加基础网络间路由	
+ 说明:         适用于大规模网络, 故障范围缩小, 网络可跨素横向扩展

##### VPC 网络
+ 前提:	        数据中心支持IPv6 路由, DNS 服务提供商支持AAAA 记录
+ 交换机:		上联设备和S6800/X86 VG支持双栈, 核心，接入可以不支持
+ 基础网络:		支持IPv4, IPv6双栈,  基础网络网关在SDN hyper上, 需在三层设备上添加路由配置	
+ VPC 网络:     支持IPv4, IPv6 双栈, 东西向Hyper之间vxlan 封装, 南北向需通过VG
+ 维护:	        所有网络安全管控、物理网络划分在青云平台内
+ 说明:         适用于大规模网络, 故障范围缩小, 网络可跨素横向扩展


用户使用指导:    https://docs.qingcloud.com/product/quick_start/IPv6_quick_start,   https://docs.qingcloud.com/product/network/IPv6_config
+ 基本条件:
  1. 向IPv6 地址分配单位CNNIC 申请获得机构的ipv6 地址段,  并做好网络规划.
  2. ipv6 eip 公网访问,  可以通过x86 vg 或者 h3c s6800 vg 来做为公网网关提供,  也可以通过 基础网络 + 客户 FW设备来提供. 
  3. 计算节点需安装radvd,  此服务负责ipv6 路由的推送, 在私网内 推送网段ipv6 路由,  在内部绑定ipv6 eip使用时负责推送 ipv6 eip 路由.
  4. 现有主机镜像需要做IPv6 网络的相关配置, 才能正常使用 平台的dhcp v6 和 ipv6 eip 的相关功能.
  5. 对于私有云如果是vxlan 基础网络要开启IPv6, 则要求核心交换机,支持双栈.  需要给计算节点分配ipv6 地址,  在交换机上配置管理网络和 基础网络的 ipv6 路由条目.
  6. 对于私有云如果是 vlan 基础网络需要开启ipv6 功能,   需要要求交换机支持双栈, 并且能配置 RA推送功能, 在此模式先, 平台只负责进行dhcp v6 分配和管理ipv6 功能,  硬件交换机RA需配置为 M-bit=1, O-bit=1, A-bit=0, 具体请查看交换机文档.

# 升级步骤:
#### Vlan 基础网络:
1. IPv6 地址段规划,   每个需要支持IPv6 的VBC 都需要一个独立的IPv6 段, 且该段能分配的IP个数不小于 2^8, 也即掩码长度最大为 120.
2. 硬件交换机配置,   确保介入交换机支持IPv4, IPv6 双栈,  如不支持需升级交换机软件. 

##### 配置示例:
用户私有云为Vlan模式, 已有两个 基础网络:  vxnet1:  vlan30,  10.30.30.0/24(2402:e7c0:8:4:2:1::/120),     vxnet2: vlan40, 10.30.40..0/24  ( 2402:e7c0:8:4:2:1:0:100/120)
现这两个网络都需升级支持IPv6,  为其分配的IPv6 地址段为括号内的v6 地址段.
 + 需要在交换机的相应接口上配置vbc 的v6 网关, 可遵循v4 的习惯, v4 网段用.1,  v6 网段用:1 即可:  在配置vxnet1 v4 网关 10.30.30.1上配置v6 地址: 2402:e7c0:8:4:2:1::1,   并配置路由: ipv6  route  2402:e7c0:8:4:2:1::/120 via  2402:e7c0:8:4:2:1::1; 在配置vxnet2 v4 网关 10.30.40.1上配置v6 地址: 2402:e7c0:8:4:2:1:0:101,   并配置路由: ipv6  route  2402:e7c0:8:4:2:1:0:100/120 via  2402:e7c0:8:4:2:1:0:101
 + 在交换机 网关接口上配置RA 功能,   让交换机只推送路由, 不使能进行 ipv6 地址自动配置功能,  也即RA 交互中: M-bit=1, O-bit=1, A-bit=0. 
 + 修改青云平台相关配置, 升级网络:
    1. server.yaml 修改: zone 字段下增加配置:  
    ```
    vxnet_ipv6_prefixlen: 120 		# vxnet网络 ipv6 地址掩码长度, 和上面规划的基础网络v6段的掩码长度一样.
    ```
    2. common字段下增加配置, 刷好server.yaml  安装installer 升级包 2018之后均支持. 
    ```
    enable_vbc_ipv6: 1
    vbc_ipv6_network:  
    - '2402:e7c0:8:4:2:1::/120'
    - '2402:e7c0:8:4:2:1:0:100/120'
    ```
    3. 在webservice节点上，升级现有基础网络支持IPv6即可
    ```
    cd /pitrix/cli
    modify-router-attribute -r <vbc_router_id> -v <vbc_vxnet_id> -V <vbc_ipv6_network>
    update-routers -r <vbc_router_id>
    ```
    4. 上传/修改平台主机 image,  让其支持IPv6,(IPv6 dhcp),   使用此镜像创建 主机来测试验证相关功能.

#### Vxlan 基础网络:
+ IPv6 地址段规划,   每个需要支持IPv6 的VBC 都需要一个独立的IPv6 段, 且该段能分配的IP个数不小于 2^8, 也即掩码长度最大为 120.   
+ 规划IPv6 管理网段,  需要给计算节点管理网络分配管理IPv6 地址, 并为基础网络 分配IPv6 VIP地址.
+ 硬件交换机配置,   确保介入交换机支持IPv4, IPv6 双栈,  如不支持需升级交换机软件. 

##### 配置示例1(手动):
用户私有云为Vxlan模式, 已有两个 基础网络:  vxnet1: 10.30.50.0/24 (2402:e7c0:8:4:2:2::/120), vbc2: 10.30.60.0/24  ( 2402:e7c0:8:4:2:2:0:100/120).    计算节点管理网络网段为  172.31.11.0/24,  另外给管理网预留分配v6 地址段为:  2402:e7c0:84:7::/100,  管理网络网关为: 2402:e7c0:84:7::1,  

+ hyper 节点上安装radvd:  apt-get install radvd
+ hyper 节点上配置IPv6地址,  在交换机上为hyper 管理v6网段配置ipv6 网关:2402:e7c0:84:7::1,  在hyper 节点上物理网卡eth2 添加管理ipv6 信息,  例如 hyper1 mgmt ipv6 地址为   2402:e7c0:84:7::10,  则在 /etc/network/interfaces  加上:
```
iface eth2 inet6 static
  address 2402:e7c0:84:7::10 		# 管理ipv6 地址
  netmask 100 					    # 管理ipv6 地址所在网络掩码长度
  gateway 2402:e7c0:84:7::1 		# 网关
```
+ 为每个基础网络规划好IPv6网段对应的IPv6 VIP,   此地址在hyper 管理网段里 分一个空闲ip 即可:  vxnet1:   2402:e7c0:84:7::129,  vxnet2:  2402:e7c0:84:7::130,  对应的在核心交换机上配置 基础网络对应路由:  ipv6 route 2402:e7c0:8:4:2:2::/120 via 2402:e7c0:84:7::129  , ipv6 route  2402:e7c0:8:4:2:2:0:100/120 via  2402:e7c0:84:7::130,  并将此ipv6 vbc vip 以及vbc ipv6 network 信息更新到zone db 里的hyper_base_network 表中的 ipv6_vip_addr 和 base_ipv6_network 字段: 
```
update hyper_base_network set base_ipv6_network = '2402:e7c0:8:4:2:2::/120' where base_network = '10.30.50.0/24';
update hyper_base_network set ipv6_vip_addr = '2402:e7c0:84:7::129' where base_ipv6_network='2402:e7c0:8:4:2:2::/120';
update hyper_base_network set base_ipv6_network = '2402:e7c0:8:4:2:2:0:100/120' where base_network = '10.30.60.0/24';
update hyper_base_network set ipv6_vip_addr = '2402:e7c0:84:7::130' where base_ipv6_network='2402:e7c0:8:4:2:2:0:100/120';
```
+ 在核心交换机上配置hyper的mgmt ipv6网段和基础网络ipv6网段路由；
+ 在hyper节点上配置到ipv6 基础网络大段的路由，并将其加到 /etc/rc.local.tail 里, 以免计算节点重启时丢失. 
```
 # vbc ipv6 routing rule
ip -6 route add 2402:e7c0:8:4:2:2::/119 via 2402:e7c0:84:7::1 metric 256 
```

+ 修改平台相关配置, 升级网络: 
    1. server.yaml 修改,  zone 字段下增加配置:  
    ```
    vxnet_ipv6_prefixlen: 120   # vxnet网络 ipv6 地址掩码长度, 和上面规划的基础网络v6段的掩码长度一样.
    ```    
    2. common字段下增加配置,   刷好server.yaml  安装installer 升级包 2018之后均支持:
    ```
    enable_vbc_ipv6: 1
    vbc_ipv6_network:  
    - '2402:e7c0:8:4:2:2::/120'
    - '2402:e7c0:8:4:2:2:0:100/120'
    ```
    3. 在webservice节点上，升级现有基础网络支持IPv6即可: 
    ```
    cd /pitrix/cli 
    modify-router-attribute -r <vbc_router_id> -v <vbc_vxnet_id> -V <vbc_ipv6_network>
    update-routers -r <vbc_router_id> 
    ```

+ 若要扩容创建新的 基础网络并支持ipv6, 则按照上面的步骤 划分正确的网段 和 vip, 插入到db 中, 重启节点compute_server 即可.
+ 上传/修改平台主机 image,  让其支持IPv6,(IPv6 dhcp),   使用此镜像创建 主机来测试验证相关功能.

##### 配置示例2（自动：新环境部署基础网络支持ipv6）
installer版本要求： 4.2+

+ 在配置青云平台阶段, 编辑`variables.ZONE_ID.yaml`:
    + 将`enable_vbc_ipv6`设置为`1`;
    + 为hyper节点设置IPv6管理网段`mgmt_ipv6_network`(必填);
    + 设置基础网络IPv6承载的大网段`vm_base_ipv6_network`(必填，注意掩码长度不能大于`vxnet_ipv6_prefixlen`的值);
    + 设置基础网络IPv6承载的小网段的起始网络段`vm_base_ipv6_network_start`(非必填);
    + 选择是否自动为hyper节点分配IPv6管理IP地址，`installer_allocate_vbc_ipv6_mgmt`的值为`1`时表示自动分配(建议设置为`1`)；

+ 若`installer_allocate_vbc`的值为`0`, 还需编辑`/pitrix/config/settings.ZONE_ID.yaml`:
    + 填写ipv4_vbc字段(本文档不对ipv4配置作说明);
    + 填写ipv6_vbc字段, 为每个hyper节点分配基础网络IPv6网段;(注: 承载同一个基础网络IPv6网段的hyper节点共用一个vip，且该vip只能指定在一个hyper节点上，示例见模板)
    + 若`installer_allocate_vbc_ipv6_mgmt`的值为`0`, 则还需在`[ipv6_mgmt]`字段下对每个hyper节点指定IPv6管理地址，否则不用填写。

+ 继续按照正常部署流程完成云平台部署。
+ 在核心交换机上配置hyper的mgmt ipv6网段和基础网络ipv6网段路由；
+ 在hyper节点上配置到ipv6 基础网络大段的路由，并将其加到 /etc/rc.local.tail 里, 以免计算节点重启时丢失. 
```
 # vbc ipv6 routing rule
 ip -6 route add 2402:e7c0:8:4:2:2::/119 via 2402:e7c0:84:7::1 metric 256 
```

##### 配置示例3（自动：追加支持基础网络ipv6）
+ 运行激活脚本: `/pitrix/bin/enable_vbc_ipv6.py -M <mgmt_ipv6_network> -V <vm_base_ipv6_network> -z <zone_id>`
    + 注1: `mgmt_ipv6_network`为hyper节点的IPv6管理网段，installer将从该网段下为hyper节点自动分配IPv6管理地址；
    + 注2: `vm_base_ipv6_network`为基础网络IPv6的大网段，installer将从该网段下为hyper节点自动分配其承载的基础网络IPv6小网段；
    + 注3： `zone_id`为待激活vbc ipv6的zone id，若不指定该参数，默认激活所有zone的vbc ipv6；

+ 更新`server.yaml`文件(`/pitrix/conf/variables/global/server.yaml.ZONE_ID`)，在`common`字段下修改/添加如下选项：
`enable_vbc_ipv6: 1`
`vbc_ipv6_network: 'VBC_IPV6_NETWORK'` (此处将`VBC_IPV6_NETWORK`替换为上一步骤中的`<vm_base_ipv6_network>`值)
+ 重新构建pitrix-global-conf包:
`/pitrix/build/build_pkgs.py -p pitrix-global-conf`
+ 重新部署pitrix-global-conf包：
`/pitrix/upgrade/update_nodes.sh -f all pitrix-global-conf`
+ 在核心交换机上配置hyper的mgmt ipv6网段和基础网络ipv6网段路由；
+ 在hyper节点上配置到ipv6 基础网络大段的路由，并将其加到 /etc/rc.local.tail 里, 以免计算节点重启时丢失. 
```
 # vbc ipv6 routing rule
 ip -6 route add 2402:e7c0:8:4:2:2::/119 via 2402:e7c0:84:7::1 metric 256 
```
+ 在webservice节点上，升级现有基础网络支持IPv6即可: 
```
cd /pitrix/cli 
modify-router-attribute -r <vbc_router_id> -v <vbc_vxnet_id> -V <vbc_ipv6_network>
update-routers -r <vbc_router_id> 
```
+ 完成激活

#### IPv6  VPC + IPv6 EIP
+ 规划 平台IPv6 地址段,   包括 VPC 的v6 掩码长度:  私网掩码长度不大于 /120.   对应每个VPC 分配的IPv6 段掩码不大于 /112.  
+ 将平台v6 地址段 根据配置的vpc 掩码长度进行注册vpc ipv6 pool 到数据库.
+ 配置x86 vg/ s6800vg ipv6 相关配置,  以及公网接入路由器/ 核心交换机上的 互联地址.  并注册ipv6 eip 段
+ 此架构下(s6800 vg), hyper 管理网络无需改造,  核心交换设备也无需改造.
##### 配置示例1 H3C S6800 VG:
用户私有云标准模式部署,  两台 h3c s6800堆叠作为 vg 网关,  先改造 VPC支持ipv6, 并使用ipv6 eip相关功能,   网段规划 业务网段: 2402:7240:2000::/64,     设备互联网段:  2402:7240:0:3::/64 .  (理解下面步骤之前 先去看下用户文档, 了解平台提供的两种eip:  vpc ipv6 + ipv6 eip)

+ hyper 节点上安装radvd:   
```
 # 安装 radvd
root@sr01n20:~# apt-get install radvd
 # 确认安装成功
root@sr01n20:~# dpkg -l | grep radvd
ii  radvd                                1:2.11-1                                   amd64        Router Advertisement Daemon
```

+ 确定 vpc, vxnet  ipv6 掩码长度, 考虑因素有二:   此环境使用vpc的体量有多大,   ipv6 特性之一为: 一个设备(网卡) 能有多个ipv6 地址,  但现青云平台一个网卡暂只支持一个ipv6 地址,  规划时可为此功能留有余量,   故在这个例子里取  vpc_ipv6_prefixlen: 78,  vxnet_ipv6_prefixlen: 86,  并修改配置文件相关字段: 
```
 # server.yaml
 # common ---> resource_limits ---> zone_id字段下增加: 
     vpc_ipv6_prefixlen: 78
     vxnet_ipv6_prefixlen: 86
 # common 字段下增加 
  vxnet_ipv6_subnets:
    - '2402:7240:2000::/64'
```

+ 在webservice 节点执行如下脚本 注册 vpc ipv6 地址池,  注册完毕后可在 BOSS 管理页面进行查看,  然后可启用脚本注册的vpc v6 地址段, 启用之后 vpc 就能申请使用这些ipv6 段.
```
  root@webservice0:/pitrix/lib/pitrix-scripts# python ./init_vpc_ipv6_network_pool.py -v 2402:7240:2000::/64
  #私有云环境可能是 编译后的二机制文件, 则执行:
  root@webservice0:/pitrix/lib/pitrix-scripts# ./init_vpc_ipv6_network_pool -v 2402:7240:2000::/64
```

+ 上一步注册的ipv6 地址段分配给 vpc 之后,  其私网的主机拿到IPv6 地址默认只有内网通信能力,  要使用此 ipv6 地址来访问公网,  则必须配置 vg  ipv6 网关.    step3 中将业务网段都注册到ipv6 地址池里,   其下的地址需访问公网,   和ipv4 eip 一样,   需要在vg 上配置ipv6网关(通常我们会选 最开始的几个ip),    这里可将地址池里第一个 /78网段为预留:  2402:7240:2000::/78, 更新数据库,   并选择 2402:7240:2000::2 为 ipv6 eip 网关,    此/78 段里剩下的ipv6 地址都可以作为可以申请的 ipv6 eip 一样注册到eip pool 里, 为了便于管理, 我们可以将此 /78 段地址分为 2402:7240:2000::/79,   2402:7240:2000:0:2::/79,  ipv6 eip 先用后面一个/79 段开始注册.  
```
 #占用vpc_ipv6_network_pool 里的第一地址段, 用来配置 vg上 ipv6 eip 网关以及ipv6 eip  
 update vpc_ipv6_network_pool set status= 'occupied' where ipv6_network= ' 2402:7240:2000::/78',
 #2402:7240:2000::/79  中选用 2402:7240:2000::2 为vg 上网关地址 
 #注册 ipv6 eip group:
 insert into eip_group (status, eip_group_id, eip_group_name, console_id, owner, controller, visibility, root_user_id, ip_version) values ('available', 'eipg-60000000', 'IPv6 IP Group for VPC', 'qingcloud', 'system', 'self', 'private', 'system', 6);
 insert into eip_group (status, eip_group_id, eip_group_name, console_id, owner, controller, visibility, root_user_id, ip_version) values ('available', 'eipg-60000001', 'IPv6 IP Group', 'qingcloud', 'system', 'self', 'public', 'system', 6); 
 #2402:7240:2000:0:2::/79 用作ipv6 eip 地址池, 先选取其下 2402:7240:2000:0:2::/120 来注册到db里: 
 root@webservice0:/pitrix/lib/pitrix-scripts# python ./register_ipv6_eip.py -n 2402:7240:2000:0:2::/120  -g  eipg-60000001  -e 1
```
+ 注册ipv6 eip,  先在zone  db里创建ipv6 eip group,   并且在billing_resource db注册ipv6的价格,  针对新部署的环境在 installer4.3  (iaas 版本 20190729) 版本之后,  installer 代码已经完成了此信息的注册,  则可以跳过次步. 
```
    # init ipv6 price list
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000', 3600, 'elastic', 975, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000', 3600, 'elastic', 1170, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000', 3600, 'elastic', 139, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_1', 3600, 'elastic', 300, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_1', 3600, 'elastic', 360, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_1', 3600, 'elastic', 43, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_2', 3600, 'elastic', 600, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_2', 3600, 'elastic', 720, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_2', 3600, 'elastic', 86, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_3', 3600, 'elastic', 980, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_3', 3600, 'elastic', 1176, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_3', 3600, 'elastic', 140, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_4', 3600, 'elastic', 1300, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_4', 3600, 'elastic', 1560, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_4', 3600, 'elastic', 186, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_5', 3600, 'elastic', 1700, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_5', 3600, 'elastic', 2040, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_5', 3600, 'elastic', 243, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_6', 3600, 'elastic', 3100, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_6', 3600, 'elastic', 3720, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_6', 3600, 'elastic', 443, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_7', 3600, 'elastic', 4500, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_7', 3600, 'elastic', 5400, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_7', 3600, 'elastic', 643, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_8', 3600, 'elastic', 5900, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_8', 3600, 'elastic', 7080, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_8', 3600, 'elastic', 843, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_9', 3600, 'elastic', 7250, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_9', 3600, 'elastic', 8700, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_9', 3600, 'elastic', 1036, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_10', 3600, 'elastic', 8650, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_10', 3600, 'elastic', 10380, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_10', 3600, 'elastic', 1236, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_11', 3600, 'elastic', 10000, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_11', 3600, 'elastic', 12000, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_11', 3600, 'elastic', 1429, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_12', 3600, 'elastic', 11450, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_12', 3600, 'elastic', 13740, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_12', 3600, 'elastic', 1636, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_addr', 3600, 'elastic', 0, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_addr', 3600, 'elastic', 0, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000000_addr', 3600, 'elastic', 0, 'usd');
    
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001', 3600, 'elastic', 975, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001', 3600, 'elastic', 1170, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001', 3600, 'elastic', 139, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_1', 3600, 'elastic', 300, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_1', 3600, 'elastic', 360, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_1', 3600, 'elastic', 43, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_2', 3600, 'elastic', 600, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_2', 3600, 'elastic', 720, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_2', 3600, 'elastic', 86, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_3', 3600, 'elastic', 980, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_3', 3600, 'elastic', 1176, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_3', 3600, 'elastic', 140, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_4', 3600, 'elastic', 1300, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_4', 3600, 'elastic', 1560, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_4', 3600, 'elastic', 186, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_5', 3600, 'elastic', 1700, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_5', 3600, 'elastic', 2040, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_5', 3600, 'elastic', 243, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_6', 3600, 'elastic', 3100, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_6', 3600, 'elastic', 3720, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_6', 3600, 'elastic', 443, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_7', 3600, 'elastic', 4500, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_7', 3600, 'elastic', 5400, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_7', 3600, 'elastic', 643, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_8', 3600, 'elastic', 5900, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_8', 3600, 'elastic', 7080, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_8', 3600, 'elastic', 843, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_9', 3600, 'elastic', 7250, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_9', 3600, 'elastic', 8700, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_9', 3600, 'elastic', 1036, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_10', 3600, 'elastic', 8650, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_10', 3600, 'elastic', 10380, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_10', 3600, 'elastic', 1236, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_11', 3600, 'elastic', 10000, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_11', 3600, 'elastic', 12000, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_11', 3600, 'elastic', 1429, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_12', 3600, 'elastic', 11450, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_12', 3600, 'elastic', 13740, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_12', 3600, 'elastic', 1636, 'usd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_addr', 3600, 'elastic', 0, 'cny');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_addr', 3600, 'elastic', 0, 'hkd');
    INSERT INTO price_list(price_key_id, resource_info, duration, charge_mode, price, currency) VALUES ('pk-00000001', 'eipg-60000001_addr', 3600, 'elastic', 0, 'usd');
```

+ 确保 h3c s6800 vg 设备版本正确,  用display version 来进行检查. 固件版本为 2609, 并打上H09 的补丁,  并且需要 修改 ipv6 routing-mode,  其他配置和 原来ipv4 h3c vg 保持一致即可.
```
    # s6800 固件版本
    <VG-01>display version
    H3C Comware Software, Version 7.1.070, Release 2609
    Copyright (c) 2004-2017 New H3C Technologies Co., Ltd. All rights reserved.
    H3C S6800-54QF uptime is 19 weeks, 0 days, 14 hours, 20 minutes
    Last reboot reason : User reboot
    
    Boot image: flash:/s6800-cmw710-boot-r2609.bin
    Boot image version: 7.1.070, Release 2609
      Compiled Nov 07 2017 16:00:00
    System image: flash:/s6800-cmw710-system-r2609.bin
    System image version: 7.1.070, Release 2609
      Compiled Nov 07 2017 16:00:00
    Patch image(s) list:
      flash:/S6800-CMW710-SYSTEM-R2609H09.bin, version: Release 2609H09
        Compiled Nov 07 2017 16:00:00
    # ipv6 routing-mode 
    <VG-01> display current-configuration | include routing-mode
    hardware-resource routing-mode ipv6-128
```

+ 在 s6800 和上联的三层接口上创建子接口,  并且在两设备上分配配上 互联ipv6 地址,    其他和核心交换机的配置,   还是和v4 h3c vg 保持一致即可, 无需修改,  另外也在eipctl 节点上配置好 eipctl 与h3c vg 之间的evpn bgp,  eipctl 节点可以新增部署节点, 也可以是原来已有的eipctl   节点.  上联设备上配置到业务网段的静态路由指向 s6800: 
```
    # NOTES, s6800 和上联设备的ipv6互联接口必须配置vlan子接口,  不配置的话,经过H3C设备ipv6报文默认会加上4095的vlan tag,  从而导致上联设备到青云平台的 ipv6 eip不通, 现象是在hyper 上抓包能看到上联 --> vg --> hyper 的报文带有 vlan 4095 的tag, 见下图.
    # 上联设备配置到 ipv6 eip_network 的 静态路由到 s6800 vg:
    ipv6 route 2402:7240:2000::/64 via 2402:7240:0:1::1     # 2402:7240:0:1::1 为 h3c vg 设备上和 上联的v6 互联地址
    ipv6 route 2402:7240:2000::/64 via 2402:7240:0:1::3    # 2402:7240:0:1::3 为 h3c vg 设备上和 上联的v6 互联地址
```

+ 和ipv4 配置一样,  在s6800 vg 设备上 default vrf 里配置ipv6 默认 路由:  
```
    # s6800 vg 上配置 default vrf 默认路由到 上联
    ipv6 route-static vpn-instance default :: 0 <interface> 2402:7240:0:1::0     # interface 为 s6800 设备上配的和上联的三层互联接口, 2402:7240:0:1::0 为 上联设备接口上的互联地址
    ipv6 route-static vpn-instance default :: 0 <interface> 2402:7240:0:1::2 
```

+ 给添加新加ipv6 h3c vg 设备到数据库:  
```
insert into switch(switch_id, description, loopback_ip, mgmt_ip, vender, model, role, status, zone_id) values('h3c-vg-ipv6', 'vg3.0', '<your-loopback-ip>', '<your-mgmt-ip>', 'h3c', 's6800', 4, 'active', '<your_zone_id>');
```

+ 修改server.yaml ,  在eip 字段下对应 h3c 字段下 增加  v6 网段:   ipv6 2402:7240:2000::/64 |HA1: '2402:7240:2000::2(:3)',  刷环境节点.
```
  <your-ipv6-h3c>:
    eips:
      2402:7240:2000::/64|HA1: '2402:7240:2000::2(:3)'
    type: 'h3c-s6800'
    user_ip:
      10.91.0.0/16: '<your-vg-user-ip>'
```

+ 为ipv6 eip 段分配vni 并插入zone db,  重启eipctl_server 服务, 在服务正常后, 检查h3c 设备上为新增ipv6 网段创建的vsi interface 2000  及端口信息.  
```
    # 向vxnet_key 里插入 ipv6 eip 网段 vni 信息
    insert into vxnet_key values(2000, '2402:7240:2000::/64')
    #  eipctl_server 重启正常后, check vsi 2000  和vsi 1 均正常
    [VG-01]interface Vsi-interface 2000
    [H3C_VG_01-Vsi-interface2000]display this 
    #
    interface Vsi-interface2000
     mtu 1500
     ip binding vpn-instance default
     mac-address 5254-d5eb-3364
     ipv6 address 2402:7240:2000::2/64
    #
    return
    # vsi 1 上配置正常,  此配置是双栈lbc 基础
    [VG-01]interface Vsi-interface 1
    [H3C_VG_01-Vsi-interface2000]display this 
    #
    interface Vsi-interface1
     mtu 1500
     ip binding vpn-instance lb
     ip address 198.255.255.254 255.0.0.0
     mac-address 5254-d553-269c
     ipv6 address FD00::C6FF:FFFE/96
    #
    return
```

+ 至此就能申请ipv6 eip,  并能将其绑定到主机或者负载均衡器,  也可以测试vpc ipv6 内网功能以及 接入公网之后的 公网访问能力.   

注:   h3c s6800 的 ipv6 容量有限,  按照推荐配置 ipv6 lb 容量大小 为 8(ecmp group) *1024,   也即最多支持 1024 个ipv6 lb eip, 这个和 ipv4 是一致的,  另外由于ipv6 eip数目众多, 目前 一对堆叠设备, 按照之前测试的结果 最多支持 tunnel: 8K,  arp/nd 40k.  其中 lb eip 的容量  代码有做监控处理, 当使用超过门限时会产生告警, 对于普通eip 暂时还无此告警,    之后会针对ipv6 也加上此功能.  鉴于现在ipv6 使用不算多,   目前容量没有问题.   

##### 配置示例2 X86 VG:
+ x86 vg 节点上需安装 arpsend  包来用于给ipv6 eip 发送ndp 消息, 对应的为ipv4 免费arp.
+ 核心交换机上 与 x86 vg 相连的二层接口上需 具备双栈能力.
  
用户私有云标准模式部署,  希望在原有x86 vg 上新增ipv6接入功能.  要用户私有云公网入口路由设备支持双栈,  还要求与X86 vg 项链的核心交换设备也具有双栈能力.
+ ipv6 vpc 地址池的注册和 ipv6 eip 的注册 都和上面 h3c vg 一样.  
+ 在上联asr 和 core switch 的互联端口上都配置好 ipv6 互联地址,  在asr 上配置 ip route 2402:7240:2000::/64 via 2402:7240:2000::3. 
+ 在x86-vg 的br_vg_out 上配置 ipv6 eip 的公网网关: 2402:7240:2000::2/64 ,    并在核心交换机同 x86-vg 二层接口上配置 x86-vg 的v6 段网关:  2402:7240:2000::3/64,  这样公网IPv6 地址经asr 到 核心交换机后, 就二层转发到了x86-vg.   x86-vg 上配置的eip 地址也需要添加在 /etc/rc.local.tail 里:
```
    # 配置 x86 vg 上br_vg_out 上地址
    ip addr add 2402:7240:2000::2/64 dev br_vg_out
```
+ 和上面 s6800 vg 步骤一样, 修改 server.yaml, 在 virtual_gateway 字段下添加相应的配置, 具体可参考已有的ipv4 的配置.
+ 启动ipv6 主机, LBC 来进行IPv6 相关测试.

#### 前端开启ipv6
需要确保 console 的版本是支持ipv6 的（20190801之后的都支持）, 更新后更改如下配置，步骤如下: 
```
    # 在/pitrix/lib/pitrix-webconsole/mysite/  下找到config.yaml，如果有local_config.yaml修改local_config.yaml即可。
    在不同区下修改或者增加如下配置（例如zone_a）：
    ZONE_CONFIG => zone_a =>
    support_ipv6_network:
        eip: true              #设置为true，开启申请ipv6功能
        loadbalancer: true     #设置为true，在LB页面开启绑定ipv6功能
        instance: true         #设置为true，主机页支持绑定ipv6
        vpc: true              #设置为true，vpc页面支持开启/关闭ipv6
        nic: true              #设置为true，页面列表可展示ipv6项
        vxnet: true            #设置为true，页面可展示出ipv6项
    
    注：已设置默认关闭ipv6相关功能（即全为false）。注意如果之前有support_ipv6_network:true/false的配置记得删除，避免覆盖新增配置
```