#### 概述

+ `NeonSAN`与`QingCloud`在产品部署层面是两个独立的产品，从业务内在逻辑里又互相交融。
+ 在`QingCloud 20190729`版本之后引入了 `SANC 存储性能型主机 (instance_class 7)`和`新容量型硬盘(volume_type 6)`。
+ 此文档主要介绍如何让`QingCloud`支持`NeonSAN`，以及如何开启上面两种类型。
+ 所有的操作基于`qingcloud-installer v4.3`之后的版本, `NeonSAN`版本 >= `2.1`。
+ 对于很老的`OS`版本, 比如`Ubuntu 12.04.5`等暂不支持。

#### 对接

+ 建议`qemu`版本升级到最新: `ubuntu 14.04.3/14.04.5/16.04.3` 为 `2.11.1.4`; `ubuntu 16.04.5.x` 为 `4.0.0.3`

+ 修改`zone`的`server.yaml`。
```yaml
    common:
      resource_limits:
        default:
          min_hcs_volume_size: 100
          max_hcs_volume_size: 50000
          hcs_volume_step: 100
      volume_type_label:
        5: 'SSD'
        6: 'HDD'
      instance_class_label:
        6: 'SSD'
        7: 'HDD'

    valid_instance_classes: '0,1,5,6,7' # 增加 6/7
    valid_volume_types: '0,1,2,3,5,6'  # 增加 5/6
```

+ 刷新`server.yaml`到`hyper`/`webservice` 节点:

```bash
/pitrix/bin/sync.sh
/pitrix/upgrade/update.sh hyper pitrix-global-conf
/pitrix/upgrade/update.sh webservice pitrix-global-conf
```

+ 填写`NeonSAN`相应参数，`/pitrix/conf/variables/variables.yaml`，请确认`neonsan_zookeeper_ips`和`neonsan_cluster_name`都正确无误:

```yaml
ZONE_ID:
  support_neonsan: 1
  neonsan:
    neonsan_zookeeper_ips:
      - '172.30.80.3'
      - '172.30.80.4'
      - '172.30.80.5'
    neonsan_cluster_name: 'neonsan'
```

+ 刷新`NeonSAN`配置文件到`hyper` `vbr` 和`webservice`节点:

```bash
/pitrix/build/build_pkgs.py -p pitrix-neonsan-conf
/pitrix/upgrade/update.sh hyper pitrix-neonsan-conf,pitrix-neonsan-tool
/pitrix/upgrade/update.sh vbr pitrix-neonsan-conf,pitrix-neonsan-tool
/pitrix/upgrade/update.sh webservice pitrix-neonsan-conf,pitrix-neonsan-tool
```

+ 挑选几个`hyper`或者`vbr`节点执行如下命令检查:

```bash
qbd --version
neonsan list_store && neonsan list_ssd && neonsan list_port && neonsan list_pool && neonsan list_parameter
```

+ 如果要启用 `volume_type 6` 需要执行脚本导入价格。
```bash
cd /pitrix/lib/pitrix-scripts/pricing
./init_volume_6_price -z <region_id> -c <console_id> -U
# instance 生成价格是给预留合约用的,如果是按需计费不需要执行
./init_price_from_price_list_data -z <region_id> -c <console_id> -p ./price_data/instance_7_price_list.json -U
# 加载一下价格
cd /pitrix/cli && ./load-price
```

+ 如果使用`instance_class 7`需要添加新的 `plg`。
```bash
# 登录到 webservice 节点使用 cli 创建
./create-place-group -n <plg-name>
./create-place-group-rules  -g <plg-id> -r instance_class_7
```
创建`plg`后在boss上给对应的hyper节点添加上创建的`plg`。

+ 修改所有`global webservice`节点的前端配置文件`local_config.yaml`。
```yaml
    ZONE_CONFIG:
      default:
        valid_volume_types:
        - {enable: true, max: 10000, max_io: 36 MB/s, min: 100, step: 50, type: 6} # 增加6
        valid_snapshot_volume_type_map:
          volume_type_6: [6]
        valid_instance_classes: [0, 1, 6, 7] # 增加 7
```

+ 重新加载`apache2`，然后去`console`测试。
```bash
/pitrix/upgrade/exec_nodes.sh webservice 'service apache2 reload'
```

+ 如果使用 `s2 server` 还需要确保添加了性能型和超高性能型 `plg`。
```bash
/pitrix/bin/modify_hyper_plgs.sh xxx add plg-00000000
/pitrix/bin/modify_hyper_plgs.sh xxx add plg-00000001
```

#### BOSS2

+ 更新`boss2.yaml`配置文件:

```bash
vim /pitrix/conf/variables/boss2/boss2.yaml.ZONE_ID
```

添加 NeonSAN 相关的配置：
```yaml
neonsan:
  ZONE1:
    zk_hosts: 'NEONSAN_ZK_HOSTS'            # NeonSAN Zookeeper hosts
    cluster_name: 'NEONSAN_CLUSTER_NAME'    # NeonSAN 在 ZK 中的集群名称
    monitor_url: 'NEONSAN_MONITOR_URL'      # NeonSAN 监控API 的 URL
  ZONE2:
    zk_hosts: 'NEONSAN_ZK_HOSTS'
    cluster_name: 'NEONSAN_CLUSTER_NAME'
    monitor_url: 'NEONSAN_MONITOR_URL'
```

注释掉modules 中的 disable 中以下两行，以在界面上展示出 NeonSAN 的菜单：
```yaml
- boss2.storage_pools
- boss2.storage_nodes
```

+ `build`包并更新到节点:

```bash
/pitrix/build/build_pkgs.py -p pitrix-ks-boss2-conf
/pitrix/upgrade/update.sh boss pitrix-ks-boss2-conf
```

***
