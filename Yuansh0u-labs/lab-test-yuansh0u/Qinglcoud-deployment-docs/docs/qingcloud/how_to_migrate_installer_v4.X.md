### 背景概述

+ `QingCloud Installer`从推出至今，已经经历了数代的演进，简单总结，可以分为`4`代，如下:
    + `V1.X`: `2012~2015`年，主要是`step by step`的文档配合简单的工具，已经废弃，无法维护和升级。
    + `V2.X`: `2016~2017`年, 主要是丰富的脚本配合简单的文档，广泛应用于公私有云，已经废弃，建议升级。
    + `V3.X`: `2017~2018`年, 主要是丰富的脚本配合简单的文档，广泛应用于公私有云，准备废弃，建议升级。
    + `V4.X`: `2017~2018`年, 主要是`Installation as a Service`，使用`CLI`或`Web`进行部署，已经通过`POC`验证成熟稳定，并少量应用于公私有云。

+ 由于项目设计与各种历史原因，`Installer V2.X`已经暴露出了越来越多的问题，主要体现在代码难维护，易用性差，升级困难，难以扩展新模块等，建议升级。
    + 从`Installer 2.X`的`20171112`先升级到`Installer 3.5 sp11`。
+ 由于项目设计与各种历史原因，`Installer V3.X`已经暴露出了越来越多的问题，主要体现在不支持部署`Region`，部署过程繁琐等，建议升级。
    + 从`Installer 3.5`升级到`Installer 3.6 sp9`，不可省略，涉及到数据库的迁移。
    + 从`Installer 3.6 sp9`升级到`Installer 3.7 sp6`，不可省略。

+ 为平滑升级，建议从`Installer 3.7`升级到`Installer 4.X`，跟随文档逐步进行。
+ 此文档仅负责升级`Installer`的版本，不负责升级`IaaS`的版本，需要升级`IaaS`版本，请先升级`Installer`，然后参考`how_to_upgrade_qingcloud_4.X.md`文档。

### 拉起新的firstbox

+ 新的`firstbox`更名为`qingcloud-firstbox`，为了方便与其他产品的`firstbox`区分。
+ 准备`Installer 4.X`的安装包, 将其拷贝到任意的`KS`或`Hyper`(融合模式)节点的`/root`目录下，并解压。

```bash
tar -zxf /root/qingcloud-installer_4.X.X-XXXX_all_amd64.tar.gz -C /root
```

+ 拉起新的`qingcloud-firstbox`节点:

```bash
# 查看脚本支持的参数
/root/qingcloud-installer/upgrade-installer/launch_fb.sh -h

# 拉起节点
/root/qingcloud-installer/upgrade-installer/launch_fb.sh -a <new_firstbox_address>
```

+ 程序会自动初始化`qingcloud-firstbox`节点，请耐心等待。

### 检查数据

+ 在旧的`firstbox`上, 检查`/pitrix/conf/settings`目录中，各`setting`文件是否正确。
  + 在`setting`文件的末尾添加缺失的字段。
  + 补齐`settings`中缺少的`role`字段:
    + 不确定节点角色，可以`ssh`到节点，通过查看服务确定。
    + `ks`节点，如果只承载管理虚机，`role="TBD"`。
    + `ks`节点，如果承载了`snapshot,vbr,seed,pgserver,zoocassa,pgpool`, `role`改为对应的角色。
    + `vg`节点，改为`role="vgateway"`。
    + `hyper`节点，改为`role="hyper"`。
  + 补齐`hyper`节点的`container_mode`字段:
    + 根据使用的存储方式修改。
    + `drbd`的改为`container_mode="pair"`。
    + `zfs`的改为`container_mode="repl"`。
    + `neonsan`的改为`container_mode="sanc"`。
+ 在旧的`firstbox`上, 检查`/pitrix/version`文件，是否存在，且格式如下:

```text
=== current ===
installer: 3.7.0
upgrade: 20180910
qingcloud: 20180910

===== old =====
installer: 3.6.0
upgrade: 20180702
qingcloud: 20180701

===== old =====
installer: 3.5.0
upgrade: 20180325
qingcloud: 20180325

===== old =====
installer: 3.3.1
upgrade: 20180121
frontend: 20180123
backend: 20180123
```

+ 在旧的`firstbox`上, 检查一些`repo`目录:
    + 检查`/var/www/repo`目录下的文件夹，将无意义的目录移除，以加快迁移速度。
    + 检查`/pitrix/repo`目录下的文件夹，将无意义的目录移除，以加快迁移速度。
    + 检查`/pitrix/kernels`目录下的`Ubuntu ISO`文件，使现在正在使用的`repo`都有一个对应的`ISO`。

### 迁移Installer

+ 在之前的`KS`或`Hyper`(融合模式)节点上，执行如下脚本:

```bash
# 查看脚本支持的参数
/root/qingcloud-installer/upgrade-installer/upgrade_installer.sh -h

# 方式1: 不主动更新sources.list和hosts等
/root/qingcloud-installer/upgrade-installer/upgrade_installer.sh -o <old_firstbox_address> -n <new_firstbox_address>

# 方式2: 主动更新sources.list和hosts等
/root/qingcloud-installer/upgrade-installer/upgrade_installer.sh -o <old_firstbox_address> -n <new_firstbox_address> -u
```

+ 日志为: `/root/upgrade_installer.log`。

+ 检查`qingcloud-firstbox`的`version.json`文件:
    + `current`: 当前版本。
        + `installer`: `Installer`的版本号。
        + `patch`: `IaaS`的`patch`的版本号, `Installer`的`4.1`版本及更高版本拥有此字段。
        + `upgrade`: `IaaS`的`upgrade`的版本号。
        + `qingcloud`: `IaaS`的版本号。
    + `old`: 历史版本。

```text
{
    "current": {
        "installer": "3.7",
        "upgrade": "20180910",
        "qingcloud": "20180910"
    },
    "old": [
        {
            "installer": "3.6.0",
            "upgrade": "20180702",
            "qingcloud": "20180701"
        },
        {
            "installer": "3.5.0",
            "upgrade": "20180325",
            "qingcloud": "20180325"
        },
        {
            "installer": "3.3.1",
            "upgrade": "20180114",
            "frontend": "20180116",
            "backend": "20180116"
        }
    ]
}
```

+ 校验`qingcloud-firstbox`上的配置:
    + `/pitrix/conf/variables/variables.yaml`中重要变量均不为空且不为`TBD`。
    + `/pitrix/conf/settings`目录里的`setting`文件，`firstbox`地址均正确。
        + 会自动将之前版本的`setting`配置文件，转换为支持`Installer 4.X`版本的`settings`。
    + `/pitrix/conf/nodes`目录里所有的`node list`文件内容均符合预期。
    + `/pitrix/repo`目录里是否正确。
    + 如果环境有`VG`节点，需要如实修正`/pitrix/conf/variables/variables.yaml`中的`vg_mgmt_network_gateway`变量。

+ 若之前未更新`hosts`及`sources.list`，请执行如下脚本:

```bash
# qingcloud-firstbox
/root/qingcloud-installer/upgrade-installer/tools/finish-migrate.sh -o <old_firstbox_address>
```

+ 关闭旧`firstbox`虚拟机:

```bash
virsh destroy firstbox
virsh undefine firstbox
```

***
