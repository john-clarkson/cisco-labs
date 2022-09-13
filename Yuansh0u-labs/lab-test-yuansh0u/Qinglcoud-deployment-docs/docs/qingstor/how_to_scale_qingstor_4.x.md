### 1 准备硬件环境

#### 1.1 服务器

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

### 2 收集硬件信息

- 建立 ip_list 文件，放入待扩容节点的 ip，一行一个  
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

### 3 扩容 qingstor access

- 访问节点的扩容在一般情况下可以选择扩容任意个节点.

- 扩容 qingstor access  
    `/pitrix/cli/scale-qingstor-access.py -a node1,node2 -v vip1,vip2`  
    可以利用`/pitrix/cli/get-scale-qingstor-access-status.py` 来查看执行状态  
    可以利用`/pitrix/cli/get-scale-qingstor-access-log.py` 来查看收集执行简略日志  

### 4 扩容 qingstor storage

#### 4.1 配置扩容 qingstor storage 参数

- 存储节点的扩容是以 cluster 为单位进行的, 也就说每次扩容至少需要 3 个节点.

- 从/qingstor/etc/templates目录拷贝配置文件 scale_storage.yml  
    `cp /qingstor/etc/templates/scale_storage.yml.template /root/scale_storage.yml`  
    按如下格式修改配置文件  
    ```yaml
    storage_nodes:
    - cluster_id: 2
        volume: vol1
        vol_type: "replicate"
        ec_type: 2
        replica: 3
        raid: False
        storage_class: standard
        readonly: False
        block: "sdb"
        brick_count: 1
        nodes:
          - node_id1
          - node_id2
          - node_id3
    ```
    如果一次性扩容多个 cluster, 则在配置文件中按上面的格式追加 cluster 配置.

- 扩容 qingstor storage  
    `/pitrix/cli/scale-qingstor-storage.py -s /root/scale_storage.yml`  
    可以利用`/pitrix/cli/get-scale-qingstor-storage-status.py` 来查看执行状态  
    可以利用`/pitrix/cli/get-scale-qingstor-storage-log.py` 来查看收集执行简略日志  

- 检查成功与否  
    登录一台新的存储节点上
    ```
    ssh storage0-cluster1
    gluster volume status |grep -c Y
    ```
    正常情况下输出的数字应该是 存储盘的总数 + 存储集群的节点数