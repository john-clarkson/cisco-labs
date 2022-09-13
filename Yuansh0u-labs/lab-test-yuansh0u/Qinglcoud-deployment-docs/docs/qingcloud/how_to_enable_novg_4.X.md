#### 部署条件

+ `NoVG`复用了`SDN 3.0`中将`VBC`中将`/32`路由通过`bgp`同步到上联交换机的方式, 所以部署`NoVG`需要环境支持`SDN 3.0`。
+ 请参考`how_to_enable_sdn3.0_4.X.md`文档，开启`VPC 3.0`和`VBC 3.0`。
+ 假设`eip`网段为`192.168.100.0/24`, 平台外网入口是`asr`设备。

#### 部署步骤

+ 先安装无`VG`的环境，将青云平台部署好;
+ 部署rsserver，如已部署则跳过，部署步骤见`how_to_deploy_rsserver_4.X.md`;
+ 修改`server.yaml`配置文件

```yaml
common:
  zone_settings:
    <zone_id>:
      virtual_gateways:
        - 'novg_0'

# VG 相关配置项
virtual_gateway:
  novg_0:
    eips:
      192.168.100.0/24|HA: '192.168.100.2(.1)'
    type: 'novg'                # type指定为novg
    mgmt_ip: '192.168.100.2'    # 无特定业务意义，不与其他vg mgmt_ip冲突即可， 在eip网段内随意选取一个
    user_ip:
      10.0.0.0/8: ''            # 该字段暂无业务意义，照搬本例即可
```

+ 在`server.yaml`中的`route_server`下增加配置:

```yaml
# rsserver相关配置项
route_server:
  switch_asns:
    <zone_id>:             # 注意替换成实际的<zone_id>
      - 4200000000         # 修改为上联交换机bgp as num
```

+ 构建`global-conf`包:

```bash
/pitrix/upgrade/build_global_conf.sh
```

+ 更新到所有节点:

```bash
/pitrix/upgrade/update.sh -f all pitrix-global-conf
```

#### 测试

+ 在环境中注册`eip`，绑定到`vm`，测试连通性即可。

***
