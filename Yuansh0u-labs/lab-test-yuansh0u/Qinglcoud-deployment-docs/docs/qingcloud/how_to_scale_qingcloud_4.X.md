### 1 准备硬件环境

#### 1.1 服务器和系统

1. 服务器和系统的要求参见`docs/how_to_deploy_qingcloud_v4.x.md`。

#### 1.2 扩容注意事项

1. 目前扩容适用于扩容`Hyper`节点、`VG`节点或者`KS`节点(`VBR`节点、`SNAPSHOT`、`SEED`节点)。
2. `standard`部署模式环境扩容`Hyper`节点，需要成对扩容。
3. `fusion`部署模式环境扩容`Hyper`节点，可以不成对扩容。
3. 扩容`VG`节点前需要准备`EIP`段，`VG`节点的扩容没有个数要求。
4. 扩容和升级/维护是互斥操作，扩容时候建议终止其它操作。

### 2 扩容青云平台(节点)

+ 此扩容步骤为扩容单个`ZONE`中的节点个数。

#### 2.1 收集硬件信息

+ 建立`ip_list`文件，放入待扩容节点的`IP`，每一行一个`IP`地址: `vim /root/ip_list`。

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
    + 获取所有节点的详细信息: `/pitrix/cli/describe-nodes.py -s available`，查看各个节点的硬件信息。
    + 如需修改节点的硬件信息，请参考`how_to_maintain_qingcloud_v4.x.md`文档。

#### 2.2 配置青云平台

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

+ 拷贝`/pitrix/config/templates`目录中的`settings.template.yaml`文件为`settings.ZONE_ID.yaml`文件:
    + `cp -f /pitrix/config/templates/settings.template.yaml /pitrix/config/scale_settings.ZONE_ID.yaml`。
    + 此处拷贝的配置文件，必须让`ZONE_ID`在中间，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板中的说明，按需填写配置文件，若有不理解的地方，请参考示例文件及视频教程。
    + 此处支持扩容`KS`节点的子角色`seed,snapshot,vbr`，不支持其他子角色及`VM`。
    + 此处支持扩容`Hyper`节点及`VG`节点。
    + 若有`VG`节点，需要配置`eips`，`VG`节点的管理地址为`key`，允许指定多段`EIP`网络(每`-`为一项)。
    + 若需要手动分配`VBC`，需要配置`vbc`。
        + `mgmt_ips`: 指定承载该`VBC`的`Hyper`节点的管理地址。
        + `ipv4_vbc`: 指定承载的`IPV4`的`VBC`的网段。
        + `ipv4_vip`: 指定承载的`IPV4`的`VBC`的对外的管理地址和`IPV4`的`VBC`所在的`Master`节点，`Master`节点必须是`mgmt_ips`中的任意一个。

+ 生成`variables`文件及`settings`文件:
    + `/pitrix/cli/config-qingcloud.py -s '/pitrix/config/scale_settings.ZONE_ID.yaml'`。
        + 使用`-h`查询命令参数及说明。
        + 日志目录为: `/pitrix/log/config`。
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

#### 2.3 扩容青云平台(节点)

+ 扩容青云平台: `/pitrix/cli/scale-qingcloud.py -z ZONE_ID -I /root/ip_list`。
    + 此处必须指定待扩容`ZONE`的`ZONE_ID`。
    + 查看扩容青云平台的当前状态：`/pitrix/cli/get-scale-qingcloud-status.py`。
    + 查看扩容青云平台的简略日志：`/pitrix/cli/get-scale-qingcloud-log.py`。
    + 详细日志请看目录下对应`job`的日志：`/pitrix/log/deploy`。
      + `build`包的日志目录: `/pitrix/log/build_pkgs/`
      + `install`节点的日志目录: `/pitrix/log/install_nodes/`
          + 更为详细的日志在对应节点的日志目录: `/opt/install/{os,network,disk,post}`。
      + `deploy`包的日志目录: `/pitrix/log/update_nodes/`
    + 此步骤耗时较长, 耐心等待完成。

+ `fusion`模式和`devops`模式下，`hyper`节点扩容后，需要更新`hyper mirror node`，并重启`compute_server`
    + `/pitrix/bin/update_hyper_mirror.sh -n hyper`。
    + 此程序会自动重启已`update`节点的`compute_server`服务。

+ 检查扩容节点的青云服务:
    + `/pitrix/upgrade/exec_nodes.sh vg "supervisorctl status"`。
    + `/pitrix/upgrade/exec_nodes.sh hyper "supervisorctl status"`。

+ 若部署了`BOSS V2`，扩容节点后，请重建`boss`的缓存，防止统计信息不更新:

```bash
/pitrix/bin/boss2-manager/django_manage.sh rebuild_cache
```

#### 2.4 获取 VBC 回程路由

+ 为`hyper`节点获取`VBC`回程路由，可以同时包含`SDS1.0`和`SDS2.0`节点:
    + 文件路径：`/pitrix/log/deploy/vbc_route_JOB_ID`
    + 将生成的静态路由添加到节点管理网络网关路由器上，`vlan`隔离的环境无需配置此回程路由。
    + 备用命令：`/pitrix/bin/dump_vbc_route.sh hyper`。

### 3 扩容青云平台(`ZONE`)

+ 此扩容步骤为`REGION`扩容单个`ZONE`。

#### 3.1 收集硬件信息

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
          + 命令示例: `/pitrix/bin/erase_data_disks.sh -i /root/ip_list -d nvme0n1`。
      + 若使用 `ICAS`, 收集节点可能会将做了`RAID`的`SSD`识别成`SATA`, 需要调用`/pitrix/cli/modify-node-attributes.py`去修改。
          + 使用`-h`查询命令参数及说明。
          + 修改磁盘的`tyep`: `/pitrix/cli/modify-node-attributes.py -i 172.16.80.10 -d sdb -t ssd`。
          + 修改磁盘的`size`: `/pitrix/cli/modify-node-attributes.py -i 172.16.80.10 -d sdc -S 3200`。
          + 修改磁盘的`status`: `/pitrix/cli/modify-node-attributes.py -i 172.16.80.10 -d sdd -s 0`。

+ 校验硬件信息:
    + 获取所有节点的详细信息: `/pitrix/cli/describe-nodes.py -s available`，查看各个节点的硬件信息。
    + 如需修改节点的硬件信息，请参考`how_to_maintain_qingcloud_v4.x.md`文档。

#### 3.2 配置青云平台

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
        + 将`is_global_zone`设置为`0`。

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

#### 3.3 扩容青云平台(`ZONE`)

+ 扩容青云平台: `/pitrix/cli/scale-qingcloud-zone.py -z ZONE_ID -I /root/ip_list`。
    + 此处必须指定待扩容`ZONE`的`ZONE_ID`。
    + 查看扩容青云平台的当前状态：`/pitrix/cli/get-scale-qingcloud-zone-status.py`。
    + 查看扩容青云平台的简略日志：`/pitrix/cli/get-scale-qingcloud-zone-log.py`。
    + 详细日志请看目录下对应`job`的日志：`/pitrix/log/deploy`。
      + `build`包的日志目录: `/pitrix/log/build_pkgs/`
      + `install`节点的日志目录: `/pitrix/log/install_nodes/`
          + 更为详细的日志在对应节点的日志目录: `/opt/install/{os,network,disk,post}`。
      + `deploy`包的日志目录: `/pitrix/log/update_nodes/`
    + 此步骤耗时较长, 耐心等待完成。

+ 在`global webservice`节点上清理`memcache`的缓存:

```bash
# 若为源码包，则该脚本需要带 *.py 执行
# 注意将 zoocassa 节点的 hostname 修改为实际的
/pitrix/lib/pitrix-scripts/cache/operate_cache_by_re -S "zoocassa0:11211;zoocassa1:11211;zoocassa2:11211" -A delete -P "Pitrix.Zone.Zone.UserZone.yunify" -F
# 如果./describe-users -u xxx region_infos 还是看不到多个zone 可以尝试重启 global 的 memcached 服务, 这会导致一小段时间 console 登录有问题
```

+ 在`global webservice`节点上重启相关服务:

```bash
supervisorctl restart ws_server billing_resource
```

+ 修改`sub proxy`节点的`haproxy`的配置:

```bash
listen api-front
    bind 0.0.0.0:7777
    mode tcp
    balance source
    # 若 Global 为 https，则端口为 443, global-webservice0/1 替换为实际环境对应的节点hostname或者ip
    server  apiserver_0 <global-webservice0>:443 check
    server  apiserver_1 <global-webservice1>:443 check
    # 若 Global 为 http，则端口为 7777
    server  apiserver_0 <global-webservice0>:7777 check
    server  apiserver_1 <global-webservice1>:7777 check

listen ws-front
    bind 0.0.0.0:8565
    mode tcp
    balance roundrobin
    server  ws_server_0 <global-webservice0>:8565 check
    server  ws_server_1 <global-webservice1>:8565 check

listen io-front
    bind 0.0.0.0:8000
    mode tcp
    balance source
    server  io_server_0 <global-webservice0>:8000 check
    server  io_server_1 <global-webservice1>:8000 check
```

+ 依次重启`sub proxy`节点的`haproxy`服务:

```bash
service haproxy restart
```

### 维护青云平台

#### QEMU版本

+ 若新扩容的节点或者新扩容的`ZONE`的`QEMU`版本与旧节点不一致，需要修改`server.yaml`，并且为旧节点装上对应版本的`QEMU incremental`包:

```yaml
compute_server
  emulator:
    2.4.1.2:
        bin: '/usr/bin'
    2.11.1.1:
        bin: '/opt/qemu-2.11.1.1/usr/bin'
    default: '2.11.1.1'
```

+ 重新`build`包: `/pitrix/upgrade/build_global_conf.sh`。
+ 下发`pitrix-global-conf`包: `/pitrix/upgrade/update.sh all pitrix-global-conf`;

***
