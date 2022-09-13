### SDN 3.0

#### 服务简介

+ 启用`SDN 3.0`(`BGP`同步及点对点互联)。
+ `SDN 3.0`包含`VPC 3.0`和`VBC 3.0`，若仅需要`VPC 3.0`的功能，可以不部署`rsserver`管理虚机。

#### VPC 3.0

+ 使用`Installer 4.4.3`及之后版本全新部署的环境，默认已经开启了`VPC 3.0`。
+ 为环境中所有的`hyper`节点安装依赖包:

```bash
/pitrix/upgrade/update_nodes.sh -f hyper pitrix-dep-gobgpd,pitrix-network-agent,pitrix-dep-bgpnetd,pitrix-bot-router3
```

+ 检查服务是否正常以及配置是否跟预期值匹配:

```bash
/pitrix/upgrade/exec_nodes.sh hyper 'service gobgpd status'
/pitrix/upgrade/exec_nodes.sh hyper 'service bgpnetd status'
/pitrix/upgrade/exec_nodes.sh hyper 'supervisorctl status network_agent'
#检查sysctl配置
net.ipv4.neigh.default.gc_thresh1=163840
net.ipv4.neigh.default.gc_thresh2=327680
net.ipv4.neigh.default.gc_thresh3=655360
net.ipv6.neigh.default.gc_thresh1=163840
net.ipv6.neigh.default.gc_thresh2=327680
net.ipv6.neigh.default.gc_thresh3=655360
/pitrix/upgrade/exec_nodes.sh hyper 'sysctl net.ipv4.neigh.default.gc_thresh1'
```

+ 更新`server.yaml`中的配置:

```bash
vim /pitrix/conf/variables/global/server.yaml.ZONE_ID
```

```yaml
common:
  bgp_sync_enabled: 1 # 1: 开启 vpc3，0: 不开启，默认不开启
  default_control_plane: 'bgp'
```

+ 构建`global-conf`包:

```bash
/pitrix/upgrade/build_global_conf.sh
```

+ 更新到所有节点:

```bash
/pitrix/upgrade/update.sh -f all pitrix-global-conf
```

+ 重启`hyper`节点的指定服务:

```bash
/pitrix/upgrade/exec_nodes.sh -f hyper 'supervisorctl restart compute_agent compute_server'
```

+ 在`webservice`节点升级已创建的`VPC`为`VPC 3.0`:

```bash
# 无需全部升级，以后新建的 VPC，默认都是 VPC 3.0
/pitrix/cli//describe-vxnets -v vxnet-XXXX -f /pitrix/conf/client.yaml | grep 'vpc_router_id'
/pitrix/cli/upgrade-vxnet -r rtr-XXXX -f /pitrix/conf/client.yaml --force
/pitrix/cli/describe-jobs -j j-XXXX
```

+ 新建一个`VPC`并加入一个`vxnet`，并查看是否有`route_server`和`control_plane`字段为`1`:

```bash
# 记录一下其中的 rs_ip 和 rt_vni
/pitrix/cli/describe-vxnets -v vxnet-XXXX -f /pitrix/conf/client.yaml
```

+ 在此`vxnet`中创建`instances`，并在此`instances`所在的物理节点，查看`BGP`路由:

```bash
/pitrix/cli/describe-instances -i i-XXXX -f /pitrix/conf/client.yaml | grep 'host_machine' | tail -1
# 查看是否对应 rs_ip 中的记录
ssh HOSTNAME 'gobgp neighbor'
# 使用 rt_vni 替换 RT_VNI，有返回值则正确
ssh HOSTNAME 'gobgp global rib -a evpn rt 1:RT_VNI'
```

### VBC 3.0

+ 注意: 若需要同步`VBC`到交换机，还需要拉起管理虚机`rsserver`，然后进行配置, 步骤见`how_to_deploy_rsserver_4.X.md`。
