## 部署步骤
### 1 交换机初始配置
+ 基本配置：
    + cisco：

        ```
        feature ssh
        no system default switchport
        username admin role network-admin
        username admin sshkey <public_key>    # 可以在拉起fb以后再到交换机上填入fb的公钥
        copp profile strict
        ```

    + 锐捷：

        ```
        service password-encryption
        enable service ssh-server
        username <username> privilege 15 password <password>
        ```

+ leaf交换机端口下联端口配置可以由脚本自动生成，自动生成下联端口配置的脚本可以在git上获得：
https://git.internal.yunify.com/chenhaiq/qingcloud-iaas-manager/blob/master/bin/gen_int_conf.py

    分配给leaf的互联地址大网段为169.254.0.0/16，依次分配给每个leaf一个24位网段：
    leaf1       169.254.1.0/24
    leaf2       169.254.2.0/24
    ....        ...

    使用方法：
    '-t' 可以为ruijie或cisco
    '-p' 要生成配置的端口数量
    '-P' 需要生成配置的起始端口号，为整数，如1，10，不指定默认为1
    '-n' 互联地址的网段，如169.254.1.0/24
    '-N' 节点的起始地址和掩码， 如10.16.0.11/16
    '-s' 端口速度，可以是“25G/10G/auto”, type是锐捷是不能是auto，公有云一般指定25G
    '-l' leaf交换机名
    '-z' zone_id，拉起fb前，不加此选项
    例如:`./gen_int_conf.py -t cisco -p 44 -P 1 -n 169.254.1.0/24 -N 10.16.80.11/24 -l leaf01`

  运行命令后会在当前gen_int_conf.py文件同级目录下生成
    1. 交换机的端口配置文件：`interfaces.leaf01`,将文件内容粘贴到对应交换机上完成下联端口配置；
    2. 交换机的端口，端口ip，对端服务器端口ip，对端服务器管理ip的对照文件：`leaf_node.leaf01`

+ leaf与spine互联端口配置：
  需手动配置leaf和spine的互联端口
  leaf上与spine的互联端口从最后一个端口往前按序分配,如eth1/54，eth1/53
  spine上与leaf相连的端口从第一个端口开始往后按序分配,如eth1/1,eth1/2， 互联网段也由大到小使用，如：169.254.0.252/30.
  交换机上所有端口的MTU必须设置为9216

+ bgp配置参考pek3c扩容的spine-leaf网络中的配置方法：https://git.internal.yunify.com/chenhaiq/qingcloud-iaas-manager/tree/master/env/pek3c/conf/settings

+ 给每个交换机的lo配上带内管理地址，以便可以和fb通信，后续可让fb对交换机进行自动配置；

    ```
    int loopback 0
    ip addr 10.16.80.1 255.255.255.255
    ```

+ 在 boarder leaf上增加对下列网段的黑洞路由，以免形成环路(非border的leaf上不配)：

    ```
    ip route 10.16.80.0/24 Null 0   服务器管理网段（掩码比管理网段的小）
    ip route 10.0.0.0/7 Null 0       基础网络网段（掩码比基础网段的小）
    ip route 169.254.0.0/16 Null 0   交换机端口网段（掩码比互联网段的小）
    ```

+ 在每个border交换机上添加默认路由,将本zone的ASR作为下一跳地址;
  如果是扩容,则将老环境的核心交换机作为下一跳地址。

### 2 服务器网卡配置
+ 第一对leaf交换机作为border交换机， ks节点需接到非border交换机上， hyper节点可以接到任意leaf交换机上；
+ 对每对leaf交换机，拷贝`config_network.sh`脚本和其中一个交换机的`leaf_node`文件（如`leaf_node.leaf01`),到这对leaf交换机所连接的所有服务器节点上的`/root/`目录下；
+ 在这对交换机上的所有ks节点上运行`/root/config_network.sh -k -f /root/leaf_node.leaf01`;
+ 在这对交换机上的所有hyper节点上运行`/root/config_network.sh -f /root/leaf_node.leaf01`;
+ 重启服务器，确保各节点的管理ip能互相ping通

注： 运行自动配置脚本之前，需确保交换机上连接服务器的端口已经配置上ip地址。

### 3 准备安装节点
+ 选择一个`QingCloud`的`KS`节点。
+ 建立自己电脑与安装节点的`ssh`免密访问通道，访问用户为`root`，并且后面所有的安装部署均需要使用`root`用户。
+ 为此`KS`节点生成密钥: `ssh-keygen -t rsa -P "" -C "QingCloud" -f '/root/.ssh/id_rsa'`。
+ 使本机可以免密访问本身: `cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys`。
+ 将部署包放置在`root`目录并解压: `tar -zxf /root/qingcloud-installer_4.X-XXXX_xenial_amd64.tar.gz -C /root/`。
    + 其中`4.X`为`Installer`的版本号。
    + `XXXX`为`QingCloud`的版本号。

+ 使物理节点支持虚拟化: `/root/qingcloud-installer/bootstrap/enable_vt.sh`。
    + 使用`-h`查询命令参数及说明。
    + 日志文件为`/root/enable_vt.log`。

+ 拉起`firstbox`节点: `/root/qingcloud-installer/bootstrap/launch_fb.sh -s -a 10.16.80.10 -k 4.15-44`。
    + 使用`-s`参数: 指定网络架构是spine-leaf,会生成标志文件`/opt/installer/.is_spine_leaf`。
    + 使用`-a`参数: 指定`qingcloud-firstbox`的管理地址。
    + 使用`-h`参数: 查询命令参数及说明。
    + 使用`-k`参数: 指定系统内核版本,spine-leaf部署中需指定为4.15-44.
    + 日志文件为`/root/launch_fb.log`。

+ 根据上方指定的`IP`，连接进入`firstbox`节点:
    + 解压部署包到`root`目录: `tar -zxf /root/qingcloud-installer_4.X-XXXX_xenial_amd64.tar.gz -C /root/`。
    + 安装部署平台所需要的服务: `/root/qingcloud-installer/bootstrap/deploy.sh`。
        + 使用`-h`查询命令参数及说明。
        + 日志文件为`/root/deploy.log`。

+ 部署成功后，重启`firstbox`节点: `shutdown -r now`。
+ 重新连入`firstbox`节点，检查服务状态: `supervisorctl status`。
+ 在交换机上配置到fb的路由， 在fb所在的物理机所连的两个leaf上配置：
    + cisco: `ip route <fb_mgmt_network_address>/32 <physical_host_mgmt_network_address> track <port_number>`
    + 锐捷： `ip route <fb_mgmt_network_address> 255.255.255.255 <physical_host_mgmt_network_address> track <port_number>`

    **说明**
    1. `<fb_mgmt_network_address>`： fb的业务ip；
    2. `<physical_host_mgmt_network_address>`： vm所在物理机的业务ip；
    3. `<port_number>`： 物理机所连leaf的端口号，如1,2,3...

+ 测试fb是否能ping通所有物理节点

### 4 搜集硬件信息
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
    + 如需修改节点的硬件信息，请参考`how_to_maintain_qingcloud_v4.X.md`文档。

### 5 配置青云平台
+ 对每个leaf运行命令：`/pitrix/bin/gen_int_conf.py -t cisco -p 40 -P 1 -n 169.254.0.0/24 -N 10.16.80.11/24 -l leaf00 -z zone_id`
  生成交换机配置文件目录`/pitrix/conf/switch/`；
  生成leaf下联端口配置文件：`/pitrix/conf/switch/settings/zone_id-leaf*/interfaces.config`
  生成leaf端口规划文件：`/pitrix/conf/switch/leaf_node/zone_id-leaf*`;
  将leaf加入到交换机分组文件中：`/pitrix/conf/switch/nodes/zone_id-t3`;
  生成交换机默认用户名密码文件(锐捷交换机需要，思科交换机配置key登录，不需密码)：`/pitrix/conf/switch/default.conf`

    ```
    username=admin
    passwd=××××××
    ```

+ 进入`/pitrix/config`目录，从`templates`目录的`variables.conf.template`拷贝一个`variables.conf.ZONE_ID`出来:
    + `cp -f /pitrix/config/templates/variables.conf.template /pitrix/config/variables.conf.ZONE_ID`。
    + 此处拷贝的配置文件，必须以`ZONE_ID`为后缀，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板里的说明，按需为待部署的`ZONE`填入必要的信息。

    + **注意:**
    1. 文件中`cloud_type`，如果是公有云则填写`public`;
    2. 里面的选项可以只填写`region`和`base`相关的，`advance`里的不会写的清空，当然`advance`里填写的越多，部署越贴合实施者的意愿。
    3. 若只有一个`ZONE`，也需要将`is_region`设置为`1`，并设置`region_id`。
    4. 若想尽力准确的分配`管理虚拟机地址/floating ip`等信息，一定要仔细填写`advance`里的带`pool`的字段,可以不填。
    5. 若需要部署对接`bm/vdi/boss/neonsan/qingstor`等相关组件，需要如实填写对应`section`的信息。
    6. 将`installer_allocate_vbc`设置为`1`，无需提供`hyper.conf.ZONE_ID`。

+ 进入`/pitrix/config`目录，从`templates`目录的`roles.conf.template`拷贝一个`roles.conf.ZONE_ID`出来:
    + `cp /pitrix/config/templates/roles.conf.template /pitrix/config/roles.conf.ZONE_ID`。
    + 此处拷贝的配置文件，必须以`ZONE_ID`为后缀，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板里的说明，按需为每个待部署节点分配角色。

    + **注意:**
    1. `pgpool`与`pgserver`可以共管理节点(`pg`端口不冲突了)，但是如果物理管理节点足够多（`4`个以上），还是建议分开。
    2. `pgpool`与`pgserver`切记不能有的虚拟机有的物理机，因为虚拟机物理机`postgresql`版本不一致，会出现`pgpool`与`postgresql`对接问题。
    3. 非常不建议同一类型角色一个位于物理机，一个位于虚拟机，这样有可能由于物理机与虚拟机系统版本不一致产生问题。
    4. spine-leaf架构下需要四个rsserver虚拟节点，除rsserver外，其余同角色的vm需分布在不通的物理机上。
    5. spine-leaf架构下zoocassa建议作为子角色部署在物理机上。

+ 生成`variables`文件及`settings`文件:
    + `/pitrix/cli/config-qingcloud.py -v '/pitrix/config/variables.conf.ZONE_ID' -r '/pitrix/config/roles.conf.ZONE_ID'`
        + 使用`-h`查询命令参数及说明。
        + 日志目录为: `/pitrix/log/config`。
        + 若需要配置多个`ZONE`，配置文件之前使用逗号隔开(`,`)。
    + 查看配置`QingCloud`任务的当前状态，使用: `/pitrix/cli/get-config-qingcloud-status.py`。
    + 查看配置`QingCloud`任务的简略日志，使用: `/pitrix/cli/get-config-qingcloud-log.py`。

    + **注意:**
    1. 生成`settings`后，可以按需修改`KS虚拟机管理地址/floating ips`等信息，切记要修改彻底，并不能出现地址冲突。
    2. 生成的`hyper-repl`节点的`setting`中`vpool`配置仅做参考，最终究竟采用`strip/mirror/raidz`需要多方面考虑而定。
    3. 如果生成`settings`后，手动调整了`settings`里的`role`信息，请务必执行下面脚本，以通知`installer`感知`role`的变更。
        + `/pitrix/bin/gen_node_list.sh`。
    4. 生成settings后， 检查hyper节点的settings文件， 如果`hyper_vip_address`不为空，手动改为空（''）。

+ 校验`variables`和`settings`文件:
    + `/pitrix/conf/variables`里的文件要合理合法，并且必要的变量不能为空。
    + `/pitrix/conf/settings`里的文件要符合配置预期，可以按需修改部分项目，使之更加匹配安装要求。

+ 在`/pitrix/conf/variables/hosts`文件中添加spine leaf交换机的信息：

    ```
    10.16.80.1 sh1b-leaf00
    10.16.80.2 sh1b-leaf01
    10.16.80.3 sh1b-leaf02
    10.16.80.4 sh1b-leaf03
    10.16.80.5 sh1b-spine00
    10.16.80.6 sh1b-spine01
    ```

### 6 构建青云软件
+ 为各个角色生成部署所用的青云软件包
    `/pitrix/build/build_pkgs_allinone.sh`
    日志文件在 /pitrix/log/build_pkgs 目录

### 9 在交换机上配置虚拟节点路由
+ 生成配置信息：`/pitrix/bin/switch.sh -t cisco|ruijie -z zone_id`(如果交换机是cisco就填cisco，是锐捷就填ruijie)；
+ 生成的配置文件在：`/pitrix/conf/switch/settings/zone_id-leaf*/routing.config`, 检查配置文件内容；
+ 将生成的配置导入leaf交换机中：`/pitrix/upgrade/update_switches zone_id-t3 routing.config`；
+ 登录到各交换机上，检查各交换机上是否已学习到虚拟节点及vip的路由信息；

注：
   1. 可在`/pitrix/conf/switch/settings/zone_id-leaf*/archive/`目录下找到每个vm，vip及subrole对应的路由配置
   2. 一些特殊配置可以在`/pitrix/conf/switch/settings/zone_id-leaf*/`目录下手动创建，运行命令`/pitrix/upgrade/update_switches zone_id-leaf* <配置文件名>`将配置导入交换机，文件名格式不限，内容格式为

    ```
    conf t
    <配置命令>
    conf t
    exit
    ```

### 7 安装物理节点
+ 由于fb位于其中一个 ks节点之上，需要先安装此节点
    `/pitrix/install/_install_comp.sh xxx os/network/disk/optimize/post`
    其中 xxx 代表安装节点的主机名
    日志文件在被安装节点 /opt/install/xx 目录，以 install_xx.log 命名

    **注意:**
    由于每一 component 均要重启一到两次，故开启下一个 component 安装前，建议检查上一个 component 是否 Done

+ 安装其它物理节点，包括 os network disk post 等
    `/pitrix/install/install_nodes.sh phy`
    概览日志文件在 /pitrix/log/install_nodes 目录
    详尽日志文件在被安装节点 /opt/install/xx 目录，以 install_xx.log 命名

+ 检查物理节点安装是否成功
    `/pitrix/upgrade/exec_nodes.sh phy "supervisorctl status"`
    安装完物理节点之后，可以使用此命令查看是否安装成功，如果所有节点的服务器状态都是 RUNNING 的，则证明物理节点安装配置成功
    如果服务状态为 FATAL 或 BACKOFF，可以尝试重启物理服务器解决

### 8 启动并管理虚拟机

+ 启动管理虚拟机，并建立 ssh 连接通道
    `/pitrix/install/launch_vms.sh vm`
    日志文件在 /pitrix/log/launch_vms 目录

    **说明:**
    如果由于部署失败或者修改了虚拟机的 setting 文件，想重新 launch 所有虚拟机，可以在命令后加 -f 以强制重新生成

### 10 安装管理虚拟机
+ 检查虚拟机是否启动成功
    `/pitrix/upgrade/exec_nodes.sh vm "uptime"`
    如果可以看到各个虚拟机的 uptime 信息，即表面虚拟机启动成功，建议启动虚拟机 10 秒后执行此检查命令

+ 为管理虚拟机安装必要的组件，包括 os network disk post 等
    `/pitrix/install/install_nodes.sh vm`
    概览日志文件在 /pitrix/log/install_nodes 目录
    详尽日志文件在被安装节点 /opt/install/xx 目录，以 install_xx.log 命名

### 11 部署青云软件

* 为所有的节点部署青云软件
    `/pitrix/deploy/deploy_nodes_allinone.sh`
    日志文件在 /pitrix/log/deploy_nodes 目录 和 /pitrix/log/update_nodes 目录

    **说明:**
    1. 如果部署 webservice 青云软件过程中出现 pgserver 或者 cassandra 服务问题，需要人人工介入修正后再部署
    2. 如果 pgserver 或者 cassandra 初始化有问题，可以依次执行如下两条命令重新初始化解决：
        * `/pitrix/upgrade/exec_nodes.sh webservice "rm -f /pitrix/ks/webservice-base/conf/init_database.Done"`
        * `/pitrix/upgrade/update.sh webservice pitrix-ks-webservice-base`
    3. 如果部署中间失败，可以通过添加 -i 参数的方式打开交互模式，跳过已经部署成功的角色，而不必重新将所有角色都重复部署一遍

* 检查所有节点的青云服务
    `/pitrix/upgrade/exec_nodes.sh all "supervisorctl status"`
    如果所有的服务都是保持 RUNNING 即部署正常，如果出现 STARTING BACKOFF 等其它状态，说明部署出现问题，需要修复后才能测试
    `/pitrix/upgrade/exec_nodes.sh all "supervisorctl restart all"`
    如果修改过配置或者出现其它怪异的问题，可以使用此命令重启所有服务来尝试修复，此命令比较暴力，建议不要反复多次执行

### 12 数据库增加条目
+ 在zone数据库中的switch表中增加leaf switch的信息，例如：

    ```sql
    INSERT INTO switch (switch_id, loopback_ip, mgmt_ip, vender, model, role, as_number, zone_id, features) VALUES ('BJ-PEK3D-MJQ-3-2-LEAF.01', '', '198.18.130.148', 'cisco', 'N93180', 5, '300001', 'pek3d', 0);
    INSERT INTO switch (switch_id, loopback_ip, mgmt_ip, vender, model, role, as_number, zone_id, features) VALUES ('BJ-PEK3D-MJQ-3-3-LEAF.02', '', '198.18.130.149', 'cisco', 'N93180', 5, '300002', 'pek3d', 0);
    ```

+ 在hypernode_switch中插入hyper节点与leaf的对应关系，例如：

    ```sql
    INSERT INTO hypernode_switch (hypernode_id, switch_id) VALUES ('pekt3dr01n02', 'MJQ-3-6-ruijie-sw1');
    INSERT INTO hypernode_switch (hypernode_id, switch_id) VALUES ('pekt3dr01n03', 'MJQ-3-6-ruijie-sw1');
    INSERT INTO hypernode_switch (hypernode_id, switch_id) VALUES ('pekt3dr02n02', 'MJQ-3-6-ruijie-sw1');
    INSERT INTO hypernode_switch (hypernode_id, switch_id) VALUES ('pekt3dr02n03', 'MJQ-3-6-ruijie-sw1');
    INSERT INTO hypernode_switch (hypernode_id, switch_id) VALUES ('pekt3dr01n02', 'MJQ-3-5-ruijie-sw2');
    INSERT INTO hypernode_switch (hypernode_id, switch_id) VALUES ('pekt3dr01n03', 'MJQ-3-5-ruijie-sw2');
    INSERT INTO hypernode_switch (hypernode_id, switch_id) VALUES ('pekt3dr02n02', 'MJQ-3-5-ruijie-sw2');
    INSERT INTO hypernode_switch (hypernode_id, switch_id) VALUES ('pekt3dr02n03', 'MJQ-3-5-ruijie-sw2');
    ```

### 13 拉起rsservers下发vbc路由
+ rsserver上需要配置 vxlan的默认端口

    ```
    # cat /etc/modprobe.d/vxlan-port.conf
    options vxlan udp_port=4789

    # 重启生效
    update-initramfs -u

    # check
    # cat /sys/module/vxlan/parameters/udp_port
    4789
    ```

### 14 到所有leaf交换机上配置rsserver作为bgp邻居
+ 可参考pek3c扩容的spine-leaf网络中的配置方法：https://git.internal.yunify.com/chenhaiq/qingcloud-iaas-manager/tree/master/env/pek3c/conf/settings

## 常见问题
### 手动新建的虚拟机如何配置路由
+ 在虚拟机所在的物理机的settings文件中添加条目：`ks_vm_routing_rule_<zone_id>_<vm>="ip route replace <vm_mgmt_network_address>/32 dev br0"`；
+ 在物理机上运行`ip route replace <vm_mgmt_network_address>/32 dev br0`，并将该命令添加到/etc/rc.local.tail中；
+ 在fb的`/pitrix/conf/switch/settings/<zone_id>-leaf*/`目录下(宿主物理机所连的一对leaf)，新建文件vm_config.<zone_id>-<vm>：

    ```
    conf
    ip route <vm_mgmt_network_address>/32 <physical_host_mgmt_network_address> track <port_number>
    conf
    exit
    ```

+ 运行命令将配置导入leaf(对物理机所连的两个leaf都要执行)：

    ```
    /pitrix/upgrade/update_switches.sh <zone_id>-leaf* vm_config.<zone_id>-<vm>
    ```

+ 将配置文件拷贝到archive目录留作记录：`cp /pitrix/conf/switch/settings/<zone_id>-leaf*/vm_config.<zone_id>-<vm> cp /pitrix/conf/switch/settings/<zone_id>-leaf*/archive/`

**说明**
1. `<zone_id>`： zone id；
2. `<vm>`： 不带zone id的vm名称，如proxy0，rsserver0；
3. `<vm_mgmt_network_address>`： vm的业务ip；
4. `<physical_host_mgmt_network_address>`： vm所在物理机的业务ip；
5. `<port_number>`： 物理机所连leaf的端口号，如1,2,3...

### 检查交换机的MTU
+ 运行脚本`/pitrix/check/check_switch.sh -z <zone_id>`可检查`/pitrix/conf/variables/hosts`文件中所列的leaf/spine交换机的已连接端口的MTU;
+ RDMA网络的交换机因不能从fb直接连接，目前只能通过登录到RDMA的交换机人工检查；
+ 交换机各端口的MTU应配置为9216，如果检查出不是9216的，会显示结果为Abnormal;

### 配置与部署注意事项：
1. track的目标必须是服务器。交换机之间用bfd检测
2. null的路由只在boarder交换机上配置
3. default-information originate只在boarder交换机上配置
4. hyper上安装： pitrix-network-agent, pitrix-dep-gobgpd, pitrix-dep-bgpnetd, pitrix-bot-router3,
5. ks节点的mtu必须是1500， hyper节点的mtu必须是1550，交换机的mtu必须是9216
