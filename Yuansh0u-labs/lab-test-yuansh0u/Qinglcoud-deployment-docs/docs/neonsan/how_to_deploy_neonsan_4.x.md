### 1 准备硬件环境

#### 1.1 服务器

1. 建议所有节点必须至少双网卡，配置两路网络，一路 MGMT 网络，一路 PRIVATE 网络（可以使用私有网段不需要跟外界通信）  
2. store 节点用作数据盘的 ssd 要用裸盘直通(必须在使用前清理干净,也不要有文件系统)  
3. 服务器硬件配置推荐:  
     1) CPU 2*2630V4 及以上; 内存 64G  
     2) OS 盘 2*300G ; 数据盘 4 个 U.2 接口的 Flash 卡, 可以是 3.6T/8T  
     3) 2 个Mellanox ConnectX 4LX EN 双口以太网卡带模块, 10Gb/25Gb 两款可选  
4. ssd + 机械盘混插然后用 icas 做缓存的情况:  
     硬件RAID是否自带缓存对机械盘性能影响很大:  
     1).RAID 50: 必须使用带缓存的硬件RAID，否则XOR会用软件计算，效率低下  
     2).RAID 10: 硬件RAID可以不带缓存，避免RAID卡进行复杂的XOR计算  
     最佳实践方案：  
     1).iCAS缓存和core存储之间的容量配比最好在1:10  
     2).iCAS + 硬件RAID(带至少1G缓存) + raid 50  
     3).iCAS + 硬件RAID(不带缓存) + raid 10  


#### 1.2 操作系统

1. 推荐所有的物理节点系统版本均为 Ubuntu 16.04.5，建议大家使用我们定制的自动化部署 ISO。
2. 除了 SSH 软件之外，安装系统时不要勾选任何多余的软件包，安装后校验是不是有 ethtool 包，没有的话需要补充安装。
3. 系统安装时，根目录分配 50G，SWAP 分配 32G，全部为主分区，分区表最好为 msdos。除非必要，否则不要增加 boot 分区。
4. 安装系统时，设置用户名密码为 yop/zhu1241jie，并且建议所有节点之间账户密码一致。
5. 如果网卡需要配置 bond，需要额外手动装 ifenslave 包（pool/main/i/ifenslave/ifenslave_xxx.deb），并且 bond 名必须为 bond0/bond1。
6. 如果网卡需要配置 vlan，需要额外手动装 vlan 包（pool/main/v/vlan/vlan_xxx.deb），并且 vlan 名必须类似于 vlan123/vlan234。
7. 系统安装完成后，多重启几次服务器，确保网络依旧连通，磁盘顺序不乱。

#### 1.3 需要注意的地方

1. neonsan 的 firstbox 不能跟 qingcloud 的共用(即使是混合部署)  
2. 用来做 rdma 网络的网卡不能配置 bond  

### 2 部署 Neonsan

#### 2.1 准备安装节点

+ 选择一个`NeonSAN`节点。
+ 建立自己电脑与安装节点的`ssh`免密访问通道，访问用户为`root`，并且后面所有的安装部署均需要使用`root`用户。
+ 为此`NeonSAN`节点生成密钥: `ssh-keygen -t rsa -P "" -f '/root/.ssh/id_rsa'`。
+ 使本机可以免密访问本身: `cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys`。
+ 将部署包放置在`root`目录并解压: `tar -zxf /root/neonsan-installer_4.X-XXXX_xenial_amd64.tar.gz -C /root/`。
    + 其中`4.X`为`Installer`的版本号。
    + `XXXX`为`QingCloud`的版本号。

+ 使物理节点支持虚拟化: `/root/neonsan-installer/bootstrap/enable_vt.sh`。
    + 使用`-h`查询命令参数及说明。
    + 日志文件为`/root/enable_vt.log`。

+ 拉起`firstbox`节点: `/root/neonsan-installer/bootstrap/launch_fb.sh -m bond0 -a 10.10.10.10`。
    + 若选择的是`Hyper`节点，需要指定`-p`参数，用于挂载`/pitrix`目录到`OS`盘，不要选择数据盘。
    + 使用`-m`参数: 指定物理节点的管理网卡。
    + 使用`-a`参数: 指定`neonsan-firstbox`的管理地址。
    + 使用`-h`参数: 查询命令参数及说明。
    + 日志文件为`/root/launch_fb.log`。

+ 根据上方指定的`IP`，连接进入`firstbox`节点:
    + 解压部署包到`root`目录: `tar -zxf /root/neonsan-installer_4.X-XXXX_xenial_amd64.tar.gz -C /root/`。
    + 安装部署平台所需要的服务: `/root/neonsan-installer/bootstrap/deploy.sh`。
        + 使用`-h`查询命令参数及说明。
        + 日志文件为`/root/deploy.log`。

+ 部署成功后，重启`firstbox`节点: `shutdown -r now`。
+ 重新连入`firstbox`节点，检查服务状态: `supervisorctl status`。

#### 2.2 收集硬件信息

+ 建立`ip_list`文件，放入待部署节点的`IP`，每一行一个`IP`地址: `vim /root/ip_list`。

+ 添加新节点: `/pitrix/cli/add-nodes.py -I /root/ip_list`。
    + 查看新添加的节点: `/pitrix/cli/describe-nodes.py -s new`。

+ 若节点不是默认的用户名和密码(`yop/zhu1241jie`)，需要手动建立`ssh`免密访问: `/pitrix/bin/establish_ssh.sh /root/ip_list SSH_PORT USER PASSWD`。
    + 使用`-h`查询命令参数及说明。
    + 日志文件为`/pitrix/log/node/establish_ssh.log`。

+ 收集硬件信息: `/pitrix/cli/collect-nodes.py -I /root/ip_list`。
    + 查看收集节点的当前状态, 使用: `/pitrix/cli/get-collect-nodes-status.py`。
    + 查看收集节点的简略日志, 使用: `/pitrix/cli/get-collect-nodes-log.py`。
    + 详细日志文件为: `/pitrix/log/node/collect.log`。
    + 在正式部署之前，该收集程序可以重复执行以修正硬件信息的错误, 正式部署之后，建议不要再次执行，如有硬件信息错误需要手动去数据库修改。
    + **注意:**
    1. 如果待收集节点数据磁盘有脏数据，可能会导致收集硬件信息失败，建议收集前格式化一下待部署节点数据磁盘，也可以使用`installer`提供的工具`/pitrix/bin/erase_data_disks.sh`。
        + 使用`-h`查询命令参数及说明。
        + 日志文件为`/pitrix/log/node/erase_data_disks.log`。
        + 命令示例: `/pitrix/bin/erase_data_disks.sh -i /root/ip_list -d nvme0n1`。
    2. 如果使用 `ICAS`, 收集节点可能会将做了 `RAID` 的 `SSD` 识别成 `SATA`, 需要调用 `/pitrix/cli/modify-node-attributes.py` 或者去数据库修改 `Type` 为 `SSD`。

+ 校验硬件信息:
    + 获取所有节点的详细信息: `/pitrix/cli/describe-nodes.py`，查看各个节点的硬件信息。
    + 如需修改节点的硬件信息，请参考`how_to_maintain_neonsan_v4.X.md`文档。
    
#### 2.3 配置 Neonsan

* 进入 /pitrix/config 目录，从 templates 目录的 variables.conf.template 拷贝一个 variables.conf 出来  
    `cp /pitrix/config/templates/variables.conf.template /root/variables.conf`  

    **注意：**  
    1) 参数 repl_networks 是为自动配置节点存储网络准备的  

* 进入 /pitrix/config 目录，从 templates 目录的 roles.conf.template 拷贝一个 roles.conf 出来  
    `cp /pitrix/config/templates/roles.conf.template /root/roles.conf`  
    按照模板里的说明，按需为每个待部署节点分配角色  

    **注意：**  
    1) 由于要组建集群，所以所有的子角色节点数量 >= 3, 一般 neonsan-db/neonsan-zk/neonsan-center 3个或者5个就够了  
    2) 建议所有 role 都放在物理机上, 不推荐起 vm 来部署 neonsan-db/neonsan-zk   

* 生成配置文件  
    `/pitrix/cli/config-neonsan.py -v /root/variables.conf -r /root/roles.conf`  
    可以利用`/pitrix/cli/get-config-neonsan-status.py` 来查看执行状态  
    可以利用`/pitrix/cli/get-config-neonsan-log.py` 来查看收集执行简略日志  
    详细日志文件为 /pitrix/log/config/variables.log 和 /pitrix/log/config/settings.log  

* 校验 variables 和 settings 文件  
    /pitrix/conf/variables 里的文件要合理合法，并且必要的变量不能为空  
    /pitrix/conf/settings 里的文件要符合配置预期，可以按需修改部分项目，使之更加匹配安装要求  

* 快速清理`conf`目录下配置文件(谨慎使用):
```bash
rm -rf /pitrix/conf/settings /pitrix/config/neonsan_ip_reserved.json
find /pitrix/conf/variables/* ! -name 'firstbox_address' -a ! -name 'ssh_port' -delete
```

#### 2.4 安装 Neonsan
* 安装部署 neonsan 相关包
    `/pitrix/cli/deploy-neonsan.py -I /root/ip_list`  
    可以利用`/pitrix/cli/get-deploy-neonsan-status.py` 来查看执行状态  
    可以利用`/pitrix/cli/get-deploy-neonsan-log.py` 来查看收集执行简略日志  

#### 2.5 整体测试环境  
* 检查各个服务状态  
    zookeeper 服务状态  
    到所有具体部署 neonan-zk 服务的节点上 `/opt/zookeeper/bin/zkServer.sh status`  

    mysql 集群状态  
    到任一部署 neonsan-db 服务的节点上 `/opt/galera/bin/galera_cluster status`  
    
    supervisor 服务状态  
    在 firstbox 上 `/pitrix/upgrade/exec_nodes.sh all 'supervisorctl status'`  

* 检查 neonsan  
    1). 在任一节点上 `neonsan list_store && neonsan list_ssd && neonsan list_port && neonsan list_pool && neonsan list_parameter && neonsan list_rg -detail`  
        检查输出是否符合实际情况,另外 list_pool 包含 vol ; list_parameter 包含 auto_recovery/auto_balance 为 1; list_rg 包含 default 以及 store 节点 id,如果不正确参考 how_tomaintain_neonsan_4.x.md 来修改  
    2). 登录到所有 neonsan 节点, 检查 ssd 空间 `curl http://<STORE_IP>:2601/stat?ssd`  
    3). 如果 neonstore 一直起不来或者 list_ssd 的 count 一直为 0,可能是 ssd 盘不干净需要清理, /pitrix/bin/erase_data_disks.sh 可以清理
