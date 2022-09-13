### 1 准备硬件环境

#### 1.1 服务器

访问节点(access node)的数量必须大于等于3, 存储节点(storage node)的数量必须大于等于3.

1. 访问节点(access node)配置
    - 内存: 256GB
    - CPU: Intel(R) Xeon(R) CPU E5-2650 v4 @ 2.20GHz * 2 (48c)
    - 网卡: Intel 82599ES 10-Gigabit * 4 (内外网各两个, 如果没有外网, 两块就够了)
    - 硬盘:
        * HDD(系统盘): 100 GB +
        * SSD(数据盘): PCIE 3T

2. 标准存储节点(storage node)
    - 内存: 64 GB
    - CPU: Intel(R) Xeon(R) CPU E5-2620 v4 @ 2.10GHz * 1 (16c)
    - 网卡: Intel 82599ES 10-Gigabit * 2
    - 硬盘(要求所有存储节点的存储盘配置一致):
        * 系统盘: 100 GB +
        * 存储盘: 6TB * 12

3. 低频存储节点(storage node)
    - 内存: 64 GB
    - CPU: Intel(R) Xeon(R) CPU D-1521 @ 2.40GHz * 1 (8c)
    - 网卡: Intel X552 10 GbE * 2
    - 硬盘(要求所有存储节点的存储盘配置一致):
        * 系统盘: 100 GB +
        * 存储盘: 8TB * 36

#### 1.2 操作系统

操作系统版本为 CentOS 7.2.1511, 所有节点的 root 账户的初始密码必须一致, 并且不需要创建额外的账户.

1. 系统分区设置
    - 存储节点不需要额外的数据盘或者数据分区, 只要有一个盘安装 OS 即可, 其它的都是存储盘.

    - 访问节点一定需要单独的数据盘(分区), 因为需要存储日志、DB 相关的数据及监控数据, 生产环境的数据盘的可用应该至少在 1.6T 之上.  
    检查安装系统的盘的分区方式, 安装系统的盘的分区方式应为:  
        * 第一个分区为系统分区
        * 第二个分区为交换分区
        * 剩下所有空间为数据分区，并挂载至 /qingstor 下
    
    
2. 需要注意的地方
    - 数据盘需要使用额外参数格式化，是由于修复Centos的一个docker兼容问题需要 (http://ppabc.cn/1415.html)
	e.g. 查看/qingtor 所挂载的分区
	```
    root@ks0:~# lsblk
    NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    sda      8:0    0 557.9G  0 disk
    ├─sda1   8:1    0    50G  0 part /
    ├─sda2   8:2    0    32G  0 part [SWAP]
    └─sda3   8:3    0 475.9G  0 part /qingstor
	```

	```
    umount /qingstor
    mkfs.xfs -f -n ftype=1 /dev/sdaX
    mount /dev/sdax /qingstor
	```

    - 重新格式化后分区的UUID会发生变化, 需要用新的UUID替换 /etc/fstab 中 /qingstor 所对应的UUID.
    e.g. 查看UUID:
    ```
    root@ks0:~# blkid
    /dev/sda1: UUID="f62f61f6-b4de-4127-9a04-b3016b52d77a" TYPE="xfs"
    /dev/sda2: UUID="16dbe33b-6434-4c1e-8b3b-f71cf2797275" TYPE="swap"
    /dev/sda3: UUID="d59a6432-3ea0-4e81-9581-ad3573fe3576" TYPE="xfs"
    ```

    - 如果机器既有ssd也有普通硬盘组成的raid，普通硬盘 mount 到 /qingstor, ssd mount到 /qingstor/data/ssd.

    - 检查数据分区的挂载参数, 正确参数应为:

    ```
    UUID=c66c1d3d-454f-4284-9e9b-149ea297d722 /qingstor xfs defaults 0 0
    ```

#### 1.3 网络

1. 网络要求

    - 访问节点分别接物理网络和外网, 并且需要跟 iaas(如果有) 环境(物理网络+基础网络) 双向互通
    - 两块万兆网卡做BOND(mode 4), 一定要加 `BONDING_OPTS="mode=4 miimon=100 lacp_rate=1 xmit_hash_policy=1"` 参数,
      否则不能利用两个网卡带宽叠加。
    - 如果是poc环境, 只要求网络互通即可

2. 网络配置

    - 万兆网卡命名类似 enp*f*

    - 修改第一块万兆网卡配置如下:

    ```
    TYPE=Ethernet
    BOOTPROTO=none
    DEVICE=ens1f0
    ONBOOT=yes
    MASTER=bond0
    SLAVE=yes
    NM_CONTROLLED=no
    ```

    - 修改第二块万兆网卡配置如下:

    ```
    TYPE=Ethernet
    BOOTPROTO=none
    DEVICE=ens1f1
    ONBOOT=yes
    MASTER=bond0
    SLAVE=yes
    NM_CONTROLLED=no
    ```

    - 创建bond0配置如下:

    ```
    DEVICE=bond0
    TYPE=Bond
    NAME=bond0
    BONDING_MASTER=yes
    BONDING_OPTS="mode=4 miimon=100 lacp_rate=1 xmit_hash_policy=1"
    BOOTPROTO=static
    IPADDR=10.16.51.11
    NETMASK=255.255.255.0
    GATEWAY=10.16.51.254
    ONBOOT=yes
    NM_CONTROLLED=no
    DELAY=0
    ```

    - /etc/sysconfig/network-scripts/route-bond0 静态路由示例

	```
    100.0.0.0/8 via 100.126.0.253
	```

    **注意**:  
    假如有内网和外网接口, 内网不要配置默认路由(GATEWAY), 外网配置默认路由

    - 重启主机 or 网络 (systemctl restart network)

    - 检查网络是否稳定

    网卡配置 /etc/sysconfig/network-scripts/ifcfg-xxx 需要写 UUID=... 以防止网卡名称变化

    可以用iperf或iperf3测试机器之间的网络带宽，如一台机器做流量接收者，运行`iperf3 -s`，一台机器做流量发送者 `iperf3 -c <ip>`。
    一般万兆接口能跑到9G，若是万兆 bonding 能更高。

    配置完网络后，最好重启看看能否正常启动并初始化网络接口。确认 ethtool bond0 和 ethtool bond1 速度是 20000M。


### 2 更新配置文件

qingstor-installer 的默认配置文件是位于 firstbox /qingstor/etc 下的 qs_installer_env_config.yml

基本配置
***********************

- ansible_ssh_pass: 设置为 access node 和 storage node 的 root 密码(所有节点的密码必须一致)

- zone_id: 设置为当前环境的 zone id (e.g : pek3a, sh1a)

- iaas_domain: 当前环境的域名 (e.g : qingcloud.com)

- global_domain: 对象存储的 global 的域名(私有云一般配置为 stor.\<iaas_domain>, e.g: stor.qingstor.me, 如果设置其他域名也可以)

- firstbox: firstbox 的宿主机的 ip 地址

- qs_network: 对象存储服务器的内网 ip 地址所属的网段.

- iptables_enabled: 是否开启 iptables 防火墙, 默认为 False, 如果开启了 iptables 默认情况下, 只对外开放 80 443 53 22 6023端口, 以及 qs_network 中定义的网段访问对象存储的服务器;

- network_access_allow: iptables_enabled 设置为 True 的情况此参数有效; 填写需要访问对象存储的网段(除了 qs_network 中定义的)或者单个 IP 地址

- change_hostname: 是否自动更改服务器的主机名称

- allow_passwd_login: 是否允许使用密码远程(ssh 等.)登录系统.  
如果设置 False, 则表示禁止使用密码登录,只能通过 ssh key 登录系统;  
如果设置为 True , 则表示允许使用密码远程(ssh 等.)登录系统; 这个配置对除 firstbox 之外的所有节点有效.  
如果在实施部署的时候没有对机器的完全控制权, 比如不能 IPMI 或者不方便进出机房, 建议将此值 设置为 True, 防止机器重启后 firstbox 出现异常状况而导致无法登录系统.  
**注意**:
如果在实施部署的时候没有对机器的完全控制权, 比如不能 IPMI 或者不方便进出机房, 建议将此值 设置为 True, 防止机器重启后 firstbox 出现异常状况而导致无法登录系统. 在部署完成确认没问题后, 为了安全性, 应该将此值改为 False, 然后运行
    ```
    ./qs_installer init --common --tags ssh
    ```

- use_cassandra: 是否使用 cassandra 替代 scylla db, 默认为 False 如无特殊说明, 保持默认即可.

- customed_zones: 因为 zone id 需要作为访问对象的 url 的一部分，所以对象存储的 zone id 必须是小写, 但是有些环境在安装 IAAS 的时候将 zone id 定义成了大写的, 在这种情况下对象存储与 IaaS 的交互会有出现异常; customed_zones 就是为了兼容这种情况而加的, 如果碰到这种情况, 将大小写 zone id 的对应关系写到这个字段即可;
    ```yaml
    customed_zones:
        pek3a: PEK3A      # <lower_zone_id>: <upper_zone_id>
        sh1a: SH1A       # <lower_zone_id>: <upper_zone_id>
        example: EXAMPLE  # <lower_zone_id>: <upper_zone_id>
    ```

计费配置
***********************

- need_qs_agent: 如果与 IaaS 一起部署并且 *需要开启计费功能* 则设置为 True; 如不需要开启计费则设为 False.

- iaas_fg_servers: IaaS fg server 的地址列表; 如果 "need_qs_agent" 为 False 忽略此选项.

- iaas_nf_servers: IaaS nf server 的地址列表; 如果 "need_qs_agent" 为 False 忽略此选项.

- iaas_nf_server_port: IaaS nf server 的 ssh 端口; 如果 "need_qs_agent" 为 False 忽略此选项.

- intranet_addrs: 禁用对网络流量进行计费的地址段, 默认值是所有的私有网络地址段; 如果需要只对特定的网段禁用计费, 则将对应的网段添加到列表中, 如果 "need_qs_agent" 为 False 忽略此选项.  
e.g.:
    ```
    intranet_addrs: ["10.0.0.0/8", "100.64.0.0/10", "192.168.0.0/16", "172.16.0.0/12", "127.0.0.0/8"]
    ```

dns 配置
***********************

- debug_lifecycle: 是否开启 lifecycle 的调试功能, 默认情况下, 至少 1 天 删除 object 和未完成的分段上传，30天转低频存储;开启此项(True)后, 允许设置任意时间(比如几秒钟);  
**注意**: 这个参数只可以在测试阶段设置为 True, 测试完毕后必须将其改为 False 并更新 qs-index 的配置. 否则会影响正常的业务逻辑.
    ```
    ./qs_install update --configs --tags qs_index -l gateway
    ```

- ntp_servers: 如果是与 IaaS 一起部署, 此处填写 IaaS 的 NTP 服务 的 IP 地址, 可填写多个.  
e.g:
    ```
    ntp_servers: ["127.0.0.1", "127.0.0.2", ...]
    ```
- dns_domain: 每个节点的 /etc/resolv.conf 中 search 字段的域名, 为 null 即可.

- dns_servers: 每个节点的 /etc/resolv.conf 中配置的 nameserver 的地址, 可以写多个; 默认配置的是 qingstor 的 dns server 的地址, 如果跟 IaaS 一起部署, 可以改成 IaaS 的 dns server的地址; 如果有公网或者其他 dns server 负责 qingstor 的域名解析, 则改成对应的 dns server 的地址(*注意*: qingstor 的服务器必须可以访问这些 dns server).

- trusted_networks_for_dns: 默认情况下, qingstor 的 dns 服务只允许本网段的 ip 地址的解析请求, 如果有其他网段的 ip 地址需要访问qingstor 的 dns 服务, 可以将其所在的网段添加到这.  
e.g:
    ```
    trusted_networks_for_dns: ["127.0.0.1/24", "127.0.0.2/24", ...]
    ```

节点配置
***********************

- access_nodes: 访问节点的相关设置

  * intranet: 内网地址相关设置

    + interface: 网卡的名称(如, bond0, eth0 ...), 所有的节点的网卡名称必须相同(Keepalived 的限制?); 如果各个节点的网卡名称不同, 可以通过做 BOND 来统一命.

    + nodes: 存储节点的 node_id 或者 ip 地址.

    + vips: virtual ip address, 与访问节点的数量相同, 即, 如果有3个访问节点则对应3个vip.

    + bridge_vip： bridge virtual ip address.

  * has_external: 是否有外网地址, 如果有则 设置为 true, 如果没有则设置为 false, 并忽略"external" 的配置.

  * external: 外网地址的相关设置, 如果 has_external 为 True 则需要配置此字段, 每个字段的含义与 "intranet" 相同.

- storage_nodes: 存储节点相关配置
    * cluster_id: 当前 storage cluster 的 id, 从 0 开始顺序排列

    * volume: 保持默认 "vol0" 就好, 不用改

    * vol_type: 卷的类型, 目前可选有两种, "replicate" (副本) 和 "ec" (纠删码), 默认是 "replicate";  
    **注意**: ec 目前还在测试当中, 不可在生产环境使用.

    * ec_type: ec volume 的类型, 可选填数字 0 - 25, 当 vol_type 为 "ec" 时, 此参数有效且必填, 没有默认值;每个数字对应的配置类型可在 [EC TYPE](installer/ec_type.md) 中查阅, 强烈建议使用从 "推荐选择的 EC 类型" 中选择适当的类型.

    * replica: 副本数, 可以设置为 1 或者 3; 当 vol_type 为 "replicate" 时此参数有效.  
    **注意**: 如果设置为 1, 就是单副本模式, 没有 HA.

    * raid: 如果存储盘使用 RAID 模式则设置为 True; 如果使用直通模式则改为 False, 默认为 False

    * readonly: 当前的 storage cluster 是否为只读的;

    * storage_class: 存储级别, 目前仅支持标准存储(standard) 和 低频存储(standard_ia), 默认为 standard.

    * block: 磁盘的设备名称, 多个磁盘用逗号分隔, e.g: "sdb,sdc,sdd...", 注意, 逗号之间不能有空格.

    * brick_count: brick 的数量, 如果是直通模式则改为存储盘的数量; 如果使用 RAID 模式, 则按照 "raid总容量"/4T 填写, 即如果RAID 的卷大小为 64T, 则 brick_count 为 16.

    * nodes: 该副本的存储节点的 node_id 或者 ip 地址.

- need_qs_global: 是否需要需要部署 qingstor global gateway server, 每个私有云只需要一个 global server, 如果有多个 zone,则只需要在其中一个 zone 中部署 global server即可.

- need_portal_global: 是否需要 portal global server, 每个私有云只需要部署一个. 如果有多个 zone, 则只需要在其中一个 zone 部署 portal global 即可.

- portal_domain: 默认情况下, 访问 portal 的 URL 地址是 portal.\<iaas_domain>; 如果需要更改 portal 的 URL 可以将自定义的 URL 填写
到这个字段(e.g: qsportal.qingstor.me), 如果不需要自定义 URL, 设置 null 即可.
另外, 这个变量在部署 portal 的 global server 的时候才会用到.

- need_portal_zone: 是否需要部署 portal zone server, 如果需要部署 portal, 则每个 zone 需要一个  portal zone server.

- need_qs_webconsole: 如果与 IAAS 一起部署, 则填写 False.

- need_qs_transcoder: 是否需要部署视频转码相关的服务, 如果需要为 True, 不需要为 False.  
**注意**: transcoder 服务的运行非常消耗硬件资源, 所以如果在生产环境部署 transcoder 服务则需要单独的物理机.

- need_account: 如果与 IaaS 一起部署则使用IaaS的 account 服务, 此处填写 False, 反之为 True

告警配置
***********************

```
monitor:
group_interval: 1m 
repeat_interval: 60m
log_alert: false # 是否发送日志告警, 默认为 false 即可
smtp: # 邮件告警配置
    send_emal: true # 是否发送告警邮件
    host: smtp.example.com:25
    tls: false
    from: alert@example.com
    username: alert@example.com
    password: password
    receiver: dev@example.com # 接收告警的邮箱, 建议创建为邮件组
slack: # slack 告警配置
    send_slack: true # 是否发送 slack 告警
    webhook: https://hooks.slack.com/services/xxxxxxx # slack incoming webhook, 需要在 slack 上预先创建
    channel: '#alerts' # 接受告警的 slack channel, 也需要在 slack 上预先创建好
```

配置 https 支持(gateway or global gateway)
***********************
Notes:如果不需要 https 支持, 则跳过本步骤

- 准备工作:  
    私有云需要用户提供可用的 SSL 证书  
    一共需要三个证书: global gateway (*.stor.\<domain>) zone gateway(*.\<zone_id>.stor.\<doamin>  *.s3.\<zone_id>.stor.\<domain>)

- gateway  
	编辑 env/zone/group_vars/gateway/nginx 中的, 按照证书文件和密钥文件把下边变量改成相应的名字。
	（如果不需要部署https, 那就将下边这些变量注释掉）

	```
	ssl_certificate: server-chained.pem
	ssl_certificate_key: server-key.pem

	s3_ssl_certificate: s3-server-chained.pem
	s3_ssl_certificate_key: s3-server-key.pem
	```

    分别对应 *.zone.stor.poccloud.com 和 *.zone.s3.stor.poccloud.com 域名的证书

- global gateway, 同理 env/globa/group_vars/global-gateway/nginx 中的

	```
	global_ssl_certificate: server-chained.pem
	global_ssl_certificate_key: server-key.pem

	s3_global_ssl_certificate: s3-server-chained.pem
	s3_global_ssl_certificate_key: s3-server-key.pem
	```

	分别对应 *.stor.poccloud.com 和 *.s3.stor.poccloud.com 域名的证书

- 将证书拷贝到 env/\<zone>/configs/cert/下, 并重命名为对应的文件名

IAAS相关配置
***********************
Notes:如果不与 iaas 一起部署, 则跳过本步骤

- qingcloud 在部署完成后就已经创建好了 qingstor 的账户, user_id 是 'qingstor', email 是 qingstor@{iaas_domain}.  
分别将 user_id 和 email 填入 qs_user_id 和 qs_user_email 字段

- 查询 qingcloud 相关信息得到用户 qingstor 的 access_key_id 和 secret_access_key 分别填入 qs_access_key_id 和 qs_secret_access_key.  
  查询 qingcloud 相关信息得到 console_key_id, secret_console_key, access_key_id, secret_access_key, 分别填入 access_keys 中的 console_key_id, secret_console_key, admin_access_key_id, admin_secret_access_key.


### 3 部署qingstor

#### 3.1 创建firstbox

- 选择一个 access node 作为 firstbox 的宿主机, 建立自己电脑与安装节点的 ssh 无密码访问通道，访问用户为 root，并且后面所有的安装部署均需要使用 root 用户.

- 从 installer 发布服务器上下载最新的安装包 到 firstbox 的宿主机的 root 目录, 然后解压  
`tar -xzf /root/qingstor-installer_4.x-xxx_xenial_amd64.tar.gz -C /root/`  
安装包名称 qingstor-installer_4.x-xxx_xenial_amd64.tar.gz（其中 xxx 为 qingstor 版本号） 

- 执行 `./enable_vt.sh` 开启宿主机的虚拟化功能, 日志文件为 /root/enable_vt.log.

- 准备 firstbox 虚拟机  
    `/root/qingstor-installer/bootstrap/enable_vt.sh`  
    给该节点安装虚拟化工具, 可以加 -h 查询命令的参数说明，程序日志文件为 /root/enable_vt.log  

    `/root/qingstor-installer/bootstrap/launch_fb.sh -p sda3 -m bond0 -a 10.16.100.2`  
    拉起 firstbox 虚机, 可以加 -h 查询命令的参数说明，程序日志文件为 /root/launch_fb.log  
    其中 -p 参数指定 qingstor 节点的 pitrix 目录的挂载点,不要选择数据盘 

- 根据上面指定的 ip 进入 firstbox 节点  
    * 解压安装包  
        `tar xf /root/qingstor-installer_4.x-xxx_xenial_amd64.tar.gz -C /root/`  

    * 安装部署平台需要的服务  
        `/root/qingstor-installer/bootstrap/deploy.sh`  
        可以加 -h 查询命令的参数说明，程序日志文件为 /root/deploy.log 

- 初始化完成后，检查是否成功  
    `supervisorctl status`  
    检查服务状态正常, 并且 /root/deploy.log 没有致命错误，即可判定初始化成功 

#### 3.2 收集硬件信息

- 建立 ip_list 文件，放入待部署节点的 ip，一行一个  
    `vim /root/ip_list`  

- 进入 /pitrix/cli 目录，添加节点  
    `/pitrix/cli/add-nodes.py -I /root/ip_list`  
    可以利用 `/pitrix/cli/describe_nodes.py -s new` 来查看添加的节点  

- 如果节点不是默认的用户名和密码(root/Zhu88jie), 需要执行脚本建立节点直接的 ssh 无密码访问  
    `/pitrix/bin/establish_ssh.sh /root/ip_list ssh_port username passwd`  
    日志文件为 /pitrix/log/node/establish_ssh.log  

- 收集硬件信息  
    `/pitrix/cli/collect-nodes.py -I /root/ip_list`  
    可以利用`/pitrix/cli/get-collect-nodes-status.py` 来查看收集节点的状态  
    可以利用`/pitrix/cli/get-collect-nodes-log.py` 来查看收集节点的简略日志  
    详细日志文件为 /pitrix/log/node/collect.log  
    在正式部署之前，该收集程序可以重复执行以修正硬件信息的错误；正式部署之后，建议不要再次执行，如有硬件信息错误需要去数据库修改

- 校验硬件信息  
    可以登录到 firstbox 节点的 postgresql 数据库的 installer 库 node 表，查看各个节点的硬件信息，也可以按需修改硬件信息，以匹配部署要求  
    也可以到每个待部署节点的 /root/collect 目录，查看目录里的 xxx.json 文件，来校验硬件信息是否有问题，如有想修改，依旧需要登录数据库来修改  

#### 3.3 部署qingstor

##### 3.3.1 配置qingstor
- 从 /qingstor/etc/templates 目录中拷贝一个 qingstor.yaml 出来, 按照节 2 中的介绍配置 qingstor.yml 文件.  
`cp /qingstor/etc/templates/qingstor.yml.template /root/qingstor.yml`

- 生成配置文件  
    `/pitrix/cli/config-qingstor.py -c /root/qingstor.yml`  
    可以利用`/pitrix/cli/get-config-qingstor-status.py` 来查看执行状态  
    可以利用`/pitrix/cli/get-config-qingstor-log.py` 来查看收集执行简略日志  

##### 3.3.2 部署qingstor
- 部署qingstor  
    `/pitrix/cli/deploy-qingstor.py`  
    可以利用`/pitrix/cli/get-deploy-qingstor-status.py` 来查看执行状态  
    可以利用`/pitrix/cli/get-deploy-qingstor-log.py` 来查看收集执行简略日志  
    
#### 3.4 与 iaas 对接
Notes:如果不与 iaas 一起部署, 则跳过本步骤, 本节操作都在 qingcloud firstbox 上执行

- 查询 qingstor 得到相关信息, 将 qingcloud 的 firstbox 中的 variable.yaml 配置文件中的 support_qingstor 改为 1, 将 dns_trusted_segment, qs_network, qs_bridge_vip, qs_public_key, qs_dns_master, qs_dns_slave 填入该文件中对应的字段

- 生成新的安装包  
    `/pitrix/build/build_pkgs_allinone.sh` 重新打包安装包.  

- 在 iaas 部署 qingstor 相关包  
    `/pitrix/upgrade/update_nodes.sh <zone_id>-dnsmaster pitrix-ks-dnsmaster-qingstor`  
    `/pitrix/upgrade/update_nodes.sh <zone_id>-proxy pitrix-ks-proxy-qingstor`  
    `/pitrix/upgrade/update_nodes.sh <zone_id>-webservice pitrix-ks-webservice-website-qingstor`  

- 更新global-conf
    `/pitrix/upgrade/update_nodes.sh all pitrix-global-conf`
