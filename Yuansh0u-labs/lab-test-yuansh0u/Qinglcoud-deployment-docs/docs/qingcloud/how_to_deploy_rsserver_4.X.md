# 介绍
在青云平台中， rsserver与proxy， webservice一样，属于云平台的管理节点，用于同步用户的vm路由给交换机， 如果要开启SND3.0或使用novg， 则需要部署rsserver

#### 新环境部署

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 在配置青云平台阶段, 编辑`variables.ZONE_ID.yaml`:
    + 将`deploy_rsserver`设置为`1`;
    + 按照示例填写`switch`相关的配置（如果是spine leaf网络架构，则不需要填写该部分）。

#### 老环境追加

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 进入`/pitrix/config`目录，从`templates`目录的`vm_variables.template.yaml`拷贝一个`vm_variables.ZONE_ID.yaml`出来:
    + `cp -f /pitrix/config/templates/vm_variables.template.yaml /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 此处拷贝的配置文件，必须让`ZONE_ID`在中间，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板里的说明，按需为需要追加部署组件的`ZONE`填入必要的信息。
    + 一次仅允许追加部署一种组件。

+ 更改配置文件:
    + 将`deploy_rsserver`设置为`1`。
    + 可以不填写`rsserver_mgmt_network_address`, 则自动为rsserver分配ip地址；
    + 如果手动填写`rsserver_mgmt_network_address`, 如果有2个rsserver则填写两个（这两个ip需要在同一个31位子网中）， 如果有4个rsserver则填写4个（这4个ip需要分别在两个31位子网中）
    + 如果是spine leaf环境， 不需要填写switch相关配置；
    + 否则，按照示例填写`switch`相关的配置。
        + 交换机名name, 自定义一个容易理解的名称即可；
        + loopback ip填写交换机上用于跟rsserver建立bgp连接的ip地址；
        + 交换机的BGP AS number：
            + 如果交换机上已有BGP配置，则填写已有的BGP AS number即可；
            + 如果交换机上没有BGP配置，添加bgp配置， AS number原则上自行分配，使用私有as号范围（4200000000-4294967294 或 64512-65534）

+ 部署rsserver节点: `/pitrix/cli/deploy-qingcloud-component.py -v /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 查看部署管理节点的当前状态：`/pitrix/cli/get-deploy-qingcloud-component-status.py`。
    + 查看部署管理节点的简略日志：`/pitrix/cli/get-deploy-qingcloud-component-log.py`。
    + 详细日志请看目录下对应`job`的日志：`/pitrix/log/deploy`。
    + 此步骤耗时较长, 耐心等待完成。

#### rsserver的gobgp配置

+ 配置文件： /etc/gobgpd.conf
+ 配置文件说明：

```buildoutcfg
[global.config]
  as = 4300000000               # rsserver的bgp as num
  router-id = "10.0.2.1"        # 填写rsserver的ip地址

# BGP邻居配置（交换机）
[[neighbors]]
  [neighbors.config]
    neighbor-address = "10.0.0.1"   # 填写交换机的ip地址
    peer-as = 4200000000                 # 修改为上联交换机bgp as num
  [[neighbors.afi-safis]]
    [neighbors.afi-safis.config]
      afi-safi-name = "ipv4-unicast"
    [neighbors.afi-safis.mp-graceful-restart.config]
      enabled = true
  [neighbors.graceful-restart.config]
    enabled = true
    restart-time = 600
  [neighbors.ebgp-multihop.config]
    enabled = true
    multihop-ttl = 255
  [neighbors.route-server.config]
    route-server-client = true
  [neighbors.apply-policy.config]
    export-policy-list = ["policy-4200000000"]     # 修改为policy-(bgp_as_num)
    default-import-policy = "reject-route"
    default-export-policy = "reject-route"

[[defined-sets.bgp-defined-sets.community-sets]]
  community-set-name = "pc-4200000000"             # 修改为pc-(bgp_as_num)
  community-list = ["4200000000"]                  # 修改为上联交换机bgp as num

[[policy-definitions]]
  name = "policy-4200000000"                       # 修改为policy-(bgp_as_num)
  [[policy-definitions.statements]]
    name = "ps-4200000000"                         # 修改为ps-(bgp_as_num)
    [policy-definitions.statements.conditions.bgp-conditions.match-community-set]
      community-set = "pc-4200000000"              # 修改为pc-(bgp_as_num)
    [policy-definitions.statements.actions]
      route-disposition = "accept-route"
    [policy-definitions.statements.actions.bgp-actions.set-as-path-prepend]
      as = 4300000000                         # 修改为rsserver的bgp as num
      repeat-n = 1

# 仿照上面的BGP邻居配置，为每个需与rsserver同步路由的的交换机（一般为传统三层网络中的核心交换机和spine leaf网络中的所有leaf交换机）都写一组相应的配置
```
+ 重启gobgpd服务： `service gobgpd restart`;


#### 配置交换机

+ 配置交换机，示例如下（cisco）：

```buildoutcfg
feature bgp
ip prefix-list rs-networks seq 5 permit 10.200.0.0/16 ge 24 le 32    #  如果是配置sdn3.0, 此处网段填写基础网络的16位网段
ip prefix-list rs-networks seq 10 permit 10.1.0.0/16 ge 24 le 32     #  如果是配置novg， 此处填写eip网络的16位网段
route-map allow permit 10
route-map reject deny 10
route-map rs-networks permit 10
 match ip address prefix-list vbc-networks
route-map rs-networks deny 100
router bgp 4200000000                                                   # 交换机的AS number
  router-id 10.0.0.1                                             # 交换机的loopback ip(用于建立bgp连接的)
  bestpath as-path multipath-relax
  address-family ipv4 unicast
    redistribute direct route-map allow
    redistribute static route-map allow
    maximum-paths 9

! 与第一个rsserver的bgp连接配置
  neighbor 10.0.2.1                                            # rsserver的ip
    remote-as 4300000000                                             # rsserver的AS number
    ebgp-multihop 255
    address-family ipv4 unicast
      route-map vbc_networks in                                     # 允许接收rsserver发布的基础网络路由
      route-map reject out                                          # 禁止向rsserver发布基础网络路由
      soft-reconfiguration inbound always

! 仿照第一个rsserver bgp邻居配置，编写其他的rsserver bgp邻居配置
```

#### 检查BGP配置
+ 在rsserver上运行`gobgp n`, 查看是否已与交换机建立BGP连接
+ 在交换机上查看是否已与rsserver建立bgp连接， 如cisco：`sh ip bgp sum`

#### 在server.yaml文件中增加rsserver相关配置
+ 编辑fb上的`/pitrix/conf/global/server.yaml.<zone_id>`(注意替换<zone_id>)

```buildoutcfg
route_server:
  vbc_route_servers:
    <zone_id>:
      host_rs:                       # 该字段下的rsserver，将会同步主机路由和网段路由
        prefix: '10.16.150.116/31'   # 下面的servers字段下的rsserver， 都要在prefix指定的这个网段内
        servers:
          - '<zone_id>-rsserver0'
          - '<zone_id>-rsserver1'
      network_rs:                   # 该字段下的rsserver， 只会同步网段路由
        prefix: '10.16.150.118/31'  # 下面的servers字段下的rsserver， 都要在prefix指定的这个网段内
        servers:
          - '<zone_id>-rsserver2'
          - '<zone_id>-rsserver3'
```

#### 更新包
+ 需重新build的包： pitrix-hosts, pitrix-global-conf
+ 重新build上述包后，更新到所有节点。
