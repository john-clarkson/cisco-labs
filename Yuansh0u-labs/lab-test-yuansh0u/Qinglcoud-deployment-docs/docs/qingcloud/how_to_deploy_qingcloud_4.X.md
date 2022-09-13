### 1 准备硬件环境

#### 1.1 服务器

+ 建议所有节点都有数据盘，其中`seed/vbr/snapshot`这类冷存储节点数据盘空间要充足。
+ `KS-BM`节点必须双网卡，配置两路网络，一路`MGMT`网络，一路`PXE`网络，默认网关在`MGMT`网络上。
+ `VG`节点必须双网卡，配置两路网络，一路`MGMT`网络，一路`EIP`网络，默认网关在`EIP`网络上。
+ 对于网络隔离模式为`VLAN`的场景，一定要确保所有的`hyper`节点的网卡名都一致且对应。
+ 如果需要在`KS`上配置一路网络用于与个人笔记本互通，务必使用`192.168.254.0/24`这个网段。

#### 1.2 磁盘要求

+ 以下所说的磁盘个数都是指逻辑上的，不是实际磁盘数，做`RAID`之后的磁盘个数。
+ 机械盘：`SAS`盘或`SATA`盘。

##### KS & VG

+ 除了`OS`盘外，其余数据盘通过`RAID`做成`1`个，用于挂载`/pitrix`目录。
+ `VG`节点可以无数据盘。

##### hyper-pair

+ `Hyper`的`role`为`hyper-pair`，即`SDS 1.0`。
+ 情况一：`1`块机械盘，`Installer`此处使用`DRBD`处理磁盘，并且平均分割容量给`drbd0`和`drbd1`。
+ 情况二：`2`块机械盘，`Installer`此处使用`DRBD`处理磁盘，并且采用容量较小的盘作为盘容量。
+ 情况三：`1`块`SSD`盘和`1`块机械盘，`Installer`此处使用`iCAS + DRBD`处理磁盘。

##### hyper-repl

+ `Hyper`的`role`为`hyper-repl`，即`SDS 2.0`。
+ 数据盘全是`SSD`盘或`SSD`盘多于机械盘，`Installer`此处使用`ZFS`处理磁盘，仅使用`SSD`盘。
+ 不再推荐混插模式使用`SDS 2.0`。

##### hyper-sanc

+ `Hyper`的`role`为`hyper-sanc`，即`NeonSAN Hyper`。
+ 情况一：`Hyper`与`NeonSAN`分开部署到不同节点，`Hyper`节点可以无数据盘。
+ 情况二：`Hyper`与`NeonSAN`融合部署到同一节点，数据盘由`NeonSAN`使用。

##### ALL

+ 硬件`RAID`是否自带缓存对机械盘性能影响很大:
    + `RAID 50`: 必须使用带缓存的硬件`RAID`，否则`XOR`会用软件计算，效率低下。
    + `RAID 10`: 硬件`RAID`可以不带缓存，避免`RAID`卡进行复杂的`XOR`计算。
+ `iCAS`应该对顺序读写使用直通模式，即`seq-cutoff`，避免顺序读写占用缓存(`Installer`处理)。
+ 为提高缓存利用率，需要缓存空间尽可能的大，所以在做`CAS`设备的时候，要避免将一张`SSD`分成多个区使用，而是将整块`SSD`做成共享的缓存设备,分给两个`drbd`使用(`Installer`处理)。

+ 最佳实践方案：
    + `iCAS`缓存和`core`存储之间的容量配比最好在`1:10`。
    + `iCAS + SDS 1.0 + 硬件RAID(带至少1G缓存) + raid 50`。
    + `iCAS + SDS 1.0 + 硬件RAID(不带缓存) + raid 10`。

#### 1.3 操作系统

+ 推荐所有的物理节点使用的系统版本均为`Ubuntu 16.04.5`，内核版本为`4.4.0.131`，建议大家使用我们定制的自动化部署`ISO`。
    + `16.04.5.1`的`ISO`: 内核版本为`4.15.0-39`，不带`offload`功能，私有云推荐使用此镜像。
    + `16.04.5.2`的`ISO`: 内核版本为`4.15.0-44`，携带`offload`功能，公有云推荐使用此镜像。
+ 在`BIOS`中设置服务器的启动方式为`Legacy`，不要设置为`UEFI`。
+ 除了`SSH`服务之外，安装系统时不要勾选任何多余的软件包，安装后校验是不是有`ethtool`包，没有的话需要补充安装。
+ 系统安装时，根目录分配`50G`，`SWAP`分配`32G`，全部为主分区，分区表最好为`msdos`。除非必要，否则不要增加`boot`分区。
+ 安装系统时，设置用户名密码为`yop/zhu1241jie`，并且建议所有节点之间账户密码一致。
+ 如果网卡需要配置`bond`，需要额外手动装`ifenslave`包（`pool/main/i/ifenslave/ifenslave_xxx.deb`），并且`bond`名必须为`bond0/bond1`。
+ 如果网卡需要配置`vlan`，需要额外手动装`vlan`包（`pool/main/v/vlan/vlan_xxx.deb`），并且`vlan`名必须类似于`vlan123/vlan234`。
+ 系统安装完成后，多重启几次服务器，确保网络依旧连通，磁盘顺序不乱。
+ 主机名必须为采用类似: `ZONE_IDr机柜位置n机器位置`，比如: `pek3br01n01`, `pek3dr02n02`。

#### 1.4 易捷版(`Express`)特别说明

+ 正式版不再支持部署`Express`版本的云平台，`Express`版的发布方式采用的是定制化`ISO`镜像。
+ 网络模式为`SDN2.0`和`VLAN`模式，无路由器, 无`VPC`网络，无公网`IP`，无高级的`PaaS`功能。
+ 融合模式所有的节点全部为`Hyper`，如果全部为`SDS2.0`节点，节点数目还可以为奇数（`1~6`）。
+ 标准模式即传统模式，需要专门的`KS`节点，`Hyper`节点要求也和企业版一致。

### 2 部署青云平台

#### 2.1 准备安装节点

+ 选择一个`QingCloud`的`KS/Hyper`节点。
+ 建立自己电脑与安装节点的`ssh`免密访问通道，访问用户为`root`，并且后面所有的安装部署均需要使用`root`用户。
+ 将部署包放置在`root`目录并解压: `tar -zxf /root/qingcloud-installer_4.X.X-XXXX_amd64.tar.gz -C /root/`。
    + `4.X.X`: `Installer`的版本号，建议使用最新的稳定版本。
    + `XXXX`: `QingCloud`的版本号及所支持的系统版本，若全新部署，仅下载`16.04.5`的包即可，若升级环境，则需下载`all`的包。
+ 一步拉起并部署`firstbox`节点: `/root/qingcloud-installer/bootstrap/bootstrap_allinone.sh -m bond0 -a 10.10.10.10`。
    + 使用`-h`查询命令参数及说明。
    + 若选择的是`Hyper`节点，需要指定`-p`参数，用于挂载`/pitrix`目录到`OS`盘，不要选择数据盘。
    + 使用`-m`参数: 指定物理节点的管理网卡。
    + 使用`-a`参数: 指定`qingcloud-firstbox`的管理地址。
    + 日志文件: 物理节点的`/root/enable_vt.log`，物理节点的`/root/launch_fb.log`和`firstbox`节点的`/root/deploy.log`。

+ 耐心等待上一步完成后，通过`IP`地址连入`firstbox`节点，检查服务状态: `supervisorctl status`。
+ 服务正常以后，使用`CLI`继续部署`QingCloud`云平台即可，`Web`部署暂不支持。

#### 2.2 收集硬件信息

+ 建立`ip_list`文件，放入待部署节点的`IP`，每一行一个`IP`地址: `vim /root/ip_list`。

+ 添加新节点: `/pitrix/cli/add-nodes.py -I /root/ip_list`。
    + 查看新添加的节点: `/pitrix/cli/describe-nodes.py -s new`。

+ 若节点不是默认的用户名和密码(`yop/zhu1241jie`)，需要手动建立`ssh`免密访问: `/pitrix/node/collect/establish_ssh.sh /root/ip_list SSH_PORT USER PASSWD`。
    + 使用`-h`查询命令参数及说明。
    + 日志文件为`/pitrix/log/node/establish_ssh.log`。

+ 收集硬件信息: `/pitrix/cli/collect-nodes.py -I /root/ip_list`。
    + 查看收集节点的当前状态, 使用: `/pitrix/cli/get-collect-nodes-status.py`。
    + 查看收集节点的简略日志, 使用: `/pitrix/cli/get-collect-nodes-log.py`。
    + 详细日志文件为: `/pitrix/log/node/collect.log`。
    + 在正式部署之前，该收集程序可以重复执行以修正硬件信息的错误, 正式部署之后，建议不要再次执行，如有硬件信息错误需要手动去数据库修改。
    + **注意事项:**
      + 若收集节点信息时，收集到了多余的移动存储设备，需要使用`modify-node-attributes.py`修改磁盘的状态为不可用。
      + 若待收集节点数据磁盘有脏数据，可能会导致收集硬件信息失败，建议收集前格式化一下待部署节点数据磁盘，也可以使用`installer`提供的工具`/pitrix/bin/erase_data_disks.sh`。
          + 使用`-h`查询命令参数及说明。
          + 日志文件为`/pitrix/log/node/erase_data_disks.log`。
          + 建立`hyper_ip_list`文件，放入待部署节点的`IP`，每一行一个`hyper`节点的`IP`地址: `vim /root/hyper_ip_list`。
          + 命令示例: `/pitrix/bin/erase_data_disks.sh -i /root/hyper_ip_list -d nvme0n1`。
      + 若使用 `ICAS`, 收集节点可能会将做了`RAID`的`SSD`识别成`SATA`, 需要调用`/pitrix/cli/modify-node-attributes.py`去修改。
          + 使用`-h`查询命令参数及说明。
          + 修改磁盘的`tyep`: `/pitrix/cli/modify-node-attributes.py -i 172.16.80.10 -d sdb -t ssd`。
          + 修改磁盘的`size`: `/pitrix/cli/modify-node-attributes.py -i 172.16.80.10 -d sdc -S 3200`。
          + 修改磁盘的`status`: `/pitrix/cli/modify-node-attributes.py -i 172.16.80.10 -d sdd -s 0`。

+ 校验硬件信息:
    + 获取所有节点的详细信息: `/pitrix/cli/describe-nodes.py`，查看各个节点的硬件信息。
    + 如需修改节点的硬件信息，请参考`how_to_maintain_qingcloud_v4.X.md`文档。

#### 2.3 配置青云平台

+ 配置文件示例的目录: `/pitrix/config/archives/`。
    + 每种模式都根据不同的`ZONE_ID`放置了模板:
        + `devops`模式:
            + `devops1a`: `1KS + 1VG + 6Hyper`，`MGMT`网络和`EIP`网络都由`Installer`自动获取并分配, `VBC`网络由`Installer`根据`vm_base_network_start`字段分配。
            + `devops1b`: `3KS + 1VG + 6Hyper`，`MGMT`网络和`EIP`网络都手动指定了各自的`POOL`段, `VBC`网络由`Installer`根据`vm_base_network_start`字段分配。
        + `fusion`模式:
            + `devops1a`: `3Hyper`，`MGMT`网络由`Installer`自动获取并分配，管理虚机所在的节点由`Installer`分配, `VBC`网络由`Installer`根据`vm_base_network_start`字段分配。
            + `devops1b`: `2VG + 3Hyper`，`MGMT`网络和`EIP`网络都手动指定了各自的`POOL`段，管理虚机所在的节点由`Installer`分配, `VBC`网络由`Installer`根据`vm_base_network_start`字段分配。
            + `devops1c`: `3Hyper`，`MGMT`网络由`Installer`自动获取并分配，管理虚机所在的物理节点手动分配, `VBC`网络由`Installer`根据`vm_base_network_start`字段分配。
        + `standard`模式:
            + `devops1a`: `3KS + 2VG + 20Hyper`，`MGMT`网络和`EIP`网络都手动指定了各自的`POOL`段，管理虚机所在的物理节点手动分配, `VBC`网络由`Installer`根据`settings.ZONE_ID.yaml`中指定的`vbc`分配。
            + `devops1b`: `10KS + 25Hyper`，`MGMT`网络由`Installer`自动获取并分配，`pgpool`、`pgserver`和`zoocassa`放置在物理机上，管理虚机所在的物理节点手动分配。

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 拷贝`/pitrix/config/templates`目录中的`variables.template.yaml`文件为`variables.ZONE_ID.yaml`文件:
    + `cp -f /pitrix/config/templates/variables.template.yaml /pitrix/config/variables.ZONE_ID.yaml`。
    + 此处拷贝的配置文件，必须让`ZONE_ID`在中间，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板里的说明，按需为待部署的`ZONE`填入必要的信息。
    + **注意事项:**
        + 当字段上方标注`auto generated`字样时，即代表`Installer`程序可以自动生成。
        + 配置文件中`cloud_type`切记不要填写成`public`，`public`这个字段是留给公有云的。
        + 配置文件中可以只填写`common`和`base`中相关的配置信息，`advance`中不会填写的可以清空，当然`advance`里填写的越多，部署越贴合实施者的意愿。
        + 若需要手动控制分配`管理虚拟机地址/floating ip`等信息，请参考以下`2`种方式:
          + 方式`1`: 仔细填写`advance`中带`pool`的字段，注意每段`pool`需要加上**子网掩码**。
          + 方式`2`: 手动指定每种管理角色的`mgmt_network_address`，优先级高于方式`1`，若为`fusion`模式，仅需指定`zoocassa`角色的相关配置即可。
        + 若需要部署对接`bm/v2v/boss/cronus/warehouse/neonsan/qingstor`等相关组件，需要填写`advance`及角色名称对应的`section`中的配置。
        + `VLAN`模式无需指定`VBC`，请设置`installer_allocate_vbc`设置为`0`。
        + 若需要`Installer`自动分配`VBC`，需要将`installer_allocate_vbc`设置为`1`，并且无需在`settings.ZONE_ID.yaml`中指定`VBC`。
        + 若需要手动分配`VBC`，需要将`installer_allocate_vbc`设置为`0`，并且需要在`settings.ZONE_ID.yaml`中指定`VBC`。
        + 若需要部署三网分离模式, 则需要将`network_separated`设置为`1`，再根据模式填写对应的字段:
          + `SDN`模式: 将`user_networks`上填写业务网络的网段。
          + `VLAN`模式: 将`user_network_interface`上填写业务网所在的网卡。

+ 拷贝`/pitrix/config/templates`目录中的`settings.template.yaml`文件为`settings.ZONE_ID.yaml`文件:
    + `cp -f /pitrix/config/templates/settings.template.yaml /pitrix/config/settings.ZONE_ID.yaml`。
    + 此处拷贝的配置文件，必须让`ZONE_ID`在中间，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板中的说明，按需填写配置文件，若有不理解的地方，请参考示例文件及视频教程。
    + **注意事项:**
        + 允许`pgpool`与`pgserver`可以共管理节点(端口不再冲突了)，但是如果物理管理节点足够多(`4`个以上)，建议分开部署。
        + 禁止同一类型角色(`pgpool`、`pgserver`、`zoocassa`)，一个位于物理机，一个位于虚拟机，这样有可能由于物理机与虚拟机系统版本不一致，导致服务异常。
        + 融合模式(`fusion`)下，仅允许`seed/vbr/snapshot`要放置在`hyper`上，其他角色会自动放置到`ks0/ks1/ks2`中。
    + 若有`VG`节点，需要配置`eips`，`VG`节点的管理地址为`key`，允许指定多段`EIP`网络(每`-`为一项)。
    + 若需要手动分配`VBC`，需要配置`vbc`。
        + `mgmt_ips`: 指定承载该`VBC`的`Hyper`节点的管理地址。
        + `ipv4_vbc`: 指定承载的`IPV4`的`VBC`的网段。
        + `ipv4_vip`: 指定承载的`IPV4`的`VBC`的对外的管理地址和`IPV4`的`VBC`所在的`Master`节点，`Master`节点必须是`mgmt_ips`中的任意一个。

+ 生成`variables`文件及`settings`文件:
    + `/pitrix/cli/config-qingcloud.py -v '/pitrix/config/variables.ZONE_ID.yaml' -s '/pitrix/config/settings.ZONE_ID.yaml'`。
        + 使用`-h`查询命令参数及说明。
        + 日志目录为: `/pitrix/log/config`。
        + 若需要配置多个`ZONE`，配置文件之前使用逗号隔开(`,`)。
    + 查看配置`QingCloud`任务的当前状态，使用: `/pitrix/cli/get-config-qingcloud-status.py`。
    + 查看配置`QingCloud`任务的简略日志，使用: `/pitrix/cli/get-config-qingcloud-log.py`。
    + **注意事项:**
        + 生成的`hyper-repl`节点的`setting`中`vpool`配置仅做参考，最终究竟采用`strip/mirror/raidz`需要多方面考虑而定。
        + 若生成`settings`后，手动调整了`settings`里的`role`信息，请务必执行下面脚本，以通知`installer`感知`role`的变更。
          + `/pitrix/bin/gen_node_list.py`。
        + 若需要强制重新配置平台，请加`-f`参数:
          + 若改变的字段为`zone_id`，请手动修改数据库`qingcloud`和`qingcloud_zone`表中的数据。

+ 校验`variables`和`settings`文件:
    + `/pitrix/conf/variables/variables.yaml`中的配置是否合理合法，并且必要的变量不能为空。
    + `/pitrix/conf/settings`里的文件要符合配置预期，可以按需修改部分字段，使之更加匹配安装要求。

#### 2.4 部署青云平台

+ 若有宝存`SSD`，需要先批量为服务器安装`os`模块，然后修改`settings`文件中磁盘为`by-id`模式:

```bash
/pitrix/build/build_pkgs_allinone.sh
# 先安装FB所在的节点
/pitrix/install/install_nodes_os.sh HOSTNAME
# 再安装剩余的其他节点
/pitrix/install/install_nodes_os.sh phy
```

+ 部署青云平台: `/pitrix/cli/deploy-qingcloud.py -I /root/ip_list`。
    + 查看部署青云平台的当前状态：`/pitrix/cli/get-deploy-qingcloud-status.py`。
    + 查看部署青云平台的简略日志：`/pitrix/cli/get-deploy-qingcloud-log.py`。
    + 详细日志请看目录下对应`job`的日志：`/pitrix/log/deploy`。
      + `build`包的日志目录: `/pitrix/log/build_pkgs/`
          + 如何确认`build`包失败的位置: `/pitrix/log/build_pkgs/build_pkgs.log`。
          + 每一个包对应详细的日志: `/pitrix/log/build_pkgs/build_ks_proxy.log`。
      + `install`节点的日志目录: `/pitrix/log/install_nodes/`
          + 更为详细的日志在对应节点的日志目录: `/opt/install/{os,network,disk,post}`。
      + `deploy`包的日志目录: `/pitrix/log/update_nodes/`
    + 此步骤耗时较长, 耐心等待完成。

#### 2.5 获取 VBC 回程路由

+ 为`hyper`节点获取`VBC`回程路由，可以同时包含`SDS1.0`和`SDS2.0`节点:
    + 文件路径：`/pitrix/log/deploy/vbc_route_JOB_ID`
    + 将生成的静态路由添加到节点管理网络网关路由器上，`vlan`隔离的环境无需配置此回程路由。
    + 备用命令：`/pitrix/bin/dump_vbc_route.sh hyper`。

### 3 维护青云平台

#### 3.1 转移`/pitrix`数据

+ 融合部署模式，由于不存在物理`KS`节点，`seed/vbr/snapshot`均在`hyper`节点上，会造成`/pitrix`目录空间不足问题，可以按照如下方法处理：

+ 使用`installer`提供的工具，相关脚本为`/pitrix/bin/transfer_pitrix_data.sh，-h`可以查看帮助。
    + `/pitrix/bin/transfer_pitrix_data.sh hyper`。
    + 日志文件为`/pitrix/log/deploy/transfer_pitrix_data.log`。

+ 手动处理，相关操作请参考`docs/how_to_maintain_qingcloud_v4.x.md`。

#### 3.2 整体检查环境

+ 通过如下命令检查环境(详细):

```bash
/pitrix/check/check.py -n all -v
```

+ 通过如下命令检查环境(简略):

```bash
/pitrix/check/check.py -n all
```

+ 输出的信息中:
    + `Normal/ok`: 正常，可忽略。
    + `Abnormal/Unknown/error`: 不正常，请检查并修复。
    + `Ignored`: 忽略检查的配置项。

+ 获取所有不正常的项:

```bash
cat /pitrix/check/formatted_result | egrep 'Abnormal|Unknown|error'
```

+ 更多使用方式，请自行使用`-h`参数。

#### 3.3 整体测试环境

+ 同步青云`images`到环境:
    + 将青云`images`拷贝到环境`seed`服务所在的节点，目录为`/pitrix/images-repo`。
    + 只需同步到任意一台`seed`节点即可，平台会自动同步镜像到所有的`seed`节点。

+ 配置本机`hosts`访问环境
    + 文件路径：`/pitrix/log/deploy/hosts_JOB_ID`
    + 可以使用`installer`提供的工具，相关脚本为`/pitrix/bin/dump_hosts.py`，`-h`可以查看使用帮助。

+ 设置`hyper`节点状态为`active`:
    + 方式`1`: 登录`boss2`界面调整`hyper`节点状态，某些情况修改后需要刷新界面才能看到修改后的结果。
    + 方式`2`: 在`firstbox`节点使用批量修改命令，命令为`/pitrix/bin/modify_hyper_status.sh hyper active`，`-h`可以查看使用帮助。
    + 方式`3`: 在`webservice`节点使用`cli`命令修改，命令为`/pitrix/cli/modify-hyper-node-attributes -n HOSTNAME -s active`，`-h`可以查看使用帮助。

+ 查看调整`hyper`节点的`plg`:
    + 方式`1`: 登录`boss2`界面调整`hyper`节点的`PLG`，某些情况修改后需要刷新界面才能看到修改后的结果，其中`plg-00000000(SAS)`这个`PLG`一定不能缺少。
    + 方式`2`: 在`firstbox`节点使用批量修改命令，命令为`/pitrix/bin/modify_hyper_plgs.sh hyper add sas,ssd,sata`，`-h`可以查看使用帮助。
    + 方式`3`: 在`webservice`节点使用`cli`命令修改，命令为`/pitrix/cli/associate-place-groups-to-hypernode -H HOSTNAME -g plg-00000000`，`-h`可以查看使用帮助。

#### 3.3 激活青云平台

+ 现阶段部署完的试用版环境`license`功能默认开启并自动注册一个三个月的试用版`license`，超期需要重新激活。
+ 获得平台识别码(`platform_id`)，并以此向`license`管理员申请`license code`:
    + 在`firstbox`节点通过`/pitrix/cli/describe-qingcloud.py`命令获取。
      + `region`环境，请获取`qingcloud`下的`platform_id`、`region_id`、节点数量。
      + 非`region`环境，请获取`qingcloud`下`zone_info`中`platform_id`、`zone_id`、节点数量。
+ `license code`:
    + 激活`license`: `/pitrix/cli/activate-qingcloud-licenses.py -l <license_code>`。
    + 获取已激活过的`license`列表: `/pitrix/cli/describe-qingcloud-licenses.py`。

***
