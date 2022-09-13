### 1 部署gpu

#### 1.1 简介

+ `gpu`服务是主要提供虚拟或者物理直通`gpu`卡给客户使用。

+ `gpu`服务依赖`hyper`。

#### 1.2 新环境部署

+ BIOS启动`VT-d`(intel的io虚拟化), 有的`bios`没有`vt-d`的配置, 需要进入`bios`中确认。

+ `settings.ZONE_ID.yaml`对应节点的`sub_roles`字段加上`hyper,gpu`。

+ 登录到`gpu`节点确认`vendor_id`, 举例如下。

```bash
lspci -nn | egrep 'ATI|NVIDIA'
42:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Cape Verde GL [FirePro W4100] [1002:682c]
42:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AMD/ATI] Cape Verde/Pitcairn HDMI Audio [Radeon HD 7700/7800 Series] [1002:aab0]

VGA是显卡, Audio是声卡, 有的卡是不带声卡的; 获取到id为1002:682c 1002:aab0,
并修改 fb 节点的 /pitrix/install/components/data/vfio-driver.sh
gpu_vendor_devices='1002:692f 10de:15f7 10de:15f8 1002:6861 1002:aab0 1002:682c'
```

+ 正常部署云平台完成后, 查看 zone 数据库 gpu_type 表, 如果没有对应的就需要插入。

```postgres-psql
-- gpu_type_name 规则: 显卡是vga-型号; 声卡是 audio-型号
-- gpu_class 规则: 根据 GPU processing capacity 来划分, 一般 NVIDIA 设置为 0; AMD 设置为 1
-- hide_kvm 规则: gtx卡请设置为 1
insert into gpu_type (vendor_device,gpu_type_name,gpu_class,hide_kvm) values ('1002:682c','vga-W4100',1,0);
insert into gpu_type (vendor_device,gpu_type_name,gpu_class,hide_kvm) values ('1002:aab0','audio-W4100',1,0);

```

+ 配置 plg 。

```bash
如果是让其他类型的主机能够安置在 gpu 的 hyper , 需要为该节点添加 plg-g0000000, 并删除规则
/pitrix/bin/modify_hyper_plgs.sh xxx add plg-g0000000
ssh xxx-webservice
cd /pitrix/cli
./delete-place-group-rules -r plr-00000036,plr-00000038
如果是 gpu 主机独占 hyper ,那么除了添加 plg-g0000000 , 还需要去掉该节点上其他的 plg
/pitrix/bin/modify_hyper_plgs.sh xxx add plg-g0000000
/pitrix/bin/modify_hyper_plgs.sh xxx remove plg-xxx
```

+ 重启该`gpu`节点的`compute_agent`服务, 并登录`boss`查看虚拟资源`gpus`, 成功后再重启下`compute_server`服务。

#### 1.3 配置使用gpu

+ 登录`fb`修改`global zone`的`server.yaml`
```yaml
  resource_limits:
    <region_id/zone_id>:  # 这里查找实际的region/zone
      gpu_zones:
        - '<region_id>,<zone_id>'
```

+ 刷新`server.yaml`到`hyper`/`webservice` 节点:

```bash
/pitrix/bin/sync.sh
/pitrix/upgrade/update.sh hyper pitrix-global-conf
/pitrix/upgrade/update.sh webservice pitrix-global-conf
```

+ 登录`webservice`节点修改前端配置文件`/pitrix/lib/pitrix-webconsole/mysite/local_config.yaml`。

```yaml
    support_gpu: true
    max_gpu_count: 3
    valid_gpu_class: [1] # 与locales两项配置与安装gpuhyper的zone数据库中的gpu_type表对应
    valid_instance_classes_for_gpu: [1]
    locales:
      gpu_class_0: {en: 'NVIDIA Tesla P100', zh-cn: 'NVIDIA Tesla P100'}
      gpu_class_1: {en: 'AMD FirePro S7150', zh-cn: 'AMD FirePro S7150'}
    valid_cpu_memory_pairs_class_gpu:
      - cpu: 16
        memory: [65536]
        gpu: [1]
      - cpu: 32
        memory: [131072]
```

+ 重新加载`apache2`
```bash
service apache2 reload
```

***
