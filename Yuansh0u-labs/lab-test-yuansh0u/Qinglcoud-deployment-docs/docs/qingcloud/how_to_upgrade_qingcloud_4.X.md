### 1 升级青云平台

#### 1.1 初始化新软件包

+ 确认已经升级`Installer`到`4.X.X`，若还未升级，请先参考文档: `how_to_migrate_installer_v4.X.md`。
+ 拷贝新的`Installer`软件包到 `firstbox`节点，并重命名旧的`installer`目录:
    + `mv /root/qingcloud-installer /root/qingcloud-installer_XXXX`
    + 其中`XXXX`建议为老的`Installer`的版本号。

+ 解压新的`Installer`软件包:
    + `tar -zxf /root/qingcloud-installer_4.X.X-XXXX_amd64.tar.gz -C /root/`
    + 其中`4.X.X-XXXX`为新`Installer`软件包的版本号。

+ 检查`variables`:
    + `4.2`版本及之前版本:
        + 检查云平台类型: `/pitrix/conf/variables/cloud_type.*`，确保为`private`。
        + 检查`ZONE`的类型: `/pitrix/conf/variables/is_global_zone.*`，`/pitrix/conf/variables/is_sub_zone.*`。
    + `4.3`版本及之后版本:
        + 配置文件: `/pitrix/conf/variables/variables.yaml`。
        + 检查`cloud_type`，确保为`private`。
        + 检查`ZONE`的类型: `is_global_zone`, `is_sub_zone`。

+ 初始化新的`Installer`软件包:
    + `/root/qingcloud-installer/bootstrap/upgrade.sh`
    + 日志文件: `/root/upgrade.log`，若环境存在多次，注意查看升级日期对应的日志。
    + 过程中会备份现有`/pitrix`目录下的文件, 备份文件位置在`/pitrix/backup/XXXX/installer/`, `XXXX`为版本号。
    + 过程中会备份现有`repo`, 备份文件位置在`/pitrix/backup/XXXX/qingcloud/`, `XXXX`为版本号。

+ 校验所有服务是否正常: `supervisorctl status`。

+ 校验环境的`QEMU`版本:
    + 有些环境很老, `OS`可能还有`Ubuntu12.04`, 有的甚至`SDN2.0`都不支持, `ubuntu os/qemu/libvirt`都不能升级。
    + 需要在`/pitrix/repo`目录里，根据`server.yaml.*`中`emulator`的真实`QEMU`版本情况，移除不需要的高版本的`QEMU`。
    + 若更新了`repo`，需要重新扫描`repo`: `/pitrix/bin/scan_all.sh`。

#### 1.2 配置青云平台

+ 刷新整个云平台节点列表，防止有些节点没有正确的被`Installer`识别到:
    + `/pitrix/bin/gen_node_list.py`

+ 检查整个平台，确保各个节点均正常工作:
    + `/pitrix/upgrade/exec_nodes.sh all "apt-get clean; apt-get autoclean; apt-get update"`
    + 如果有的节点青云服务不正常或者`apt`服务不正常，需要先修正问题，然后再进行升级操作。
    + **注意事项:**
        + 如果一些节点问题实在无法修正，需要将节点`setting`文件从`/pitrix/conf/settings`目录移除。
        + 移除后，需要执行命令: `/pitrix/bin/gen_node_list.py`，重新刷新整个云平台的节点列表，为升级做好准备。

+ 检查相关`repo`:
    + 检查`/pitrix/repo`目录下的各个子目录，确保目录的包准确正确，没有包混乱或重复多余包的情况。

+ 为防止升级过程中宕机迁移，关闭灾难迁移:

```bash
/pitrix/upgrade/exec_nodes.sh hyper "touch /pitrix/conf/disable_hyperpair_rescue"
```

#### 1.3 升级青云软件

+ 准备升级平台的文件:
    + `/pitrix/upgrade/pre_upgrade.sh`。
    + 日志文件: `/pitrix/log/upgrade/pre_upgrade.log`。
    + 过程中会备份, 备份文件位置在`fb``/pitrix/backup/XXXX/qingcloud/conf` 以及第一个`snapshot`节点的`/pitrix/qingcloud-bak.XXXX`, `XXXX`为版本号。

+ 开始升级平台的软件:
    + `/pitrix/upgrade/upgrade_pkgs.sh -i`
    + 默认为全自动模式，建议使用`-i`参数，使用交互方式进行升级，因为交互方式升级可以按需跳过或者忽略一些无关紧要的错误。
    + 整体升级日志和各个节点的详细升级日志均在目录: `/pitrix/log/update_nodes`。

+ 平台升级完成:
    + `/pitrix/upgrade/post_upgrade.sh`。
    + 打开`/pitrix/upgrade/upgrades/manual-operations`，需要手动按照提示操作。
    + 日志文件: `/pitrix/log/upgrade/post_upgrade.log`。

+ 校验升级后服务有无异常:
    + `/pitrix/check/check.py -n all`


#### 1.4 配置青云平台

+ 恢复灾难迁移:

```bash
/pitrix/upgrade/exec_nodes.sh hyper "rm /pitrix/conf/disable_hyperpair_rescue"
```

### 2 特殊环境

+ 如果升级的`sub zone`为`qingcloud`管理下的特殊`sub zone`，需要额外升级`website`:
    + `/pitrix/upgrade/update.sh webservice global-website`

***
