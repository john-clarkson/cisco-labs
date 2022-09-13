## IAM 服务

+ Iaas 版本必须是`4.7-20210104`及以上。
+ 随着越来越多独立 global 部署， 一个 zone 可以是单独的 global， 也可以是单独的 sub， 也可以是 global + sub。
+ iam server 相关服务只在 global 部署； sub 需要部署 etcd/metad。

### 新环境部署

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 在配置青云平台阶段, 编辑`variables.ZONE_ID.yaml`时, 将`deploy_iam`设置为`1`即可。

### 老环境追加

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 进入`/pitrix/config`目录，从`templates`目录的`vm_variables.template.yaml`拷贝一个`vm_variables.ZONE_ID.yaml`出来:
    + `cp -f /pitrix/config/templates/vm_variables.template.yaml /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 此处拷贝的配置文件，必须让`ZONE_ID`在中间，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板里的说明，按需为需要追加部署组件的`ZONE`填入必要的信息。
    + 一次仅允许追加部署一种组件。

+ 更改配置文件:
    + 将`deploy_iam`设置为`1`。

+ 部署管理节点: `/pitrix/cli/deploy-qingcloud-component.py -v /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 查看部署管理节点的当前状态：`/pitrix/cli/get-deploy-qingcloud-component-status.py`。
    + 查看部署管理节点的简略日志：`/pitrix/cli/get-deploy-qingcloud-component-log.py`。
    + 详细日志请看目录下对应`job`的日志：`/pitrix/log/deploy`。
    + 此步骤耗时较长, 耐心等待完成。

### 部署完成

#### 修改后端配置

##### 配置 global 的 `server.yaml ` 和 `postgresql.yaml` 的 `IAM` 配置部分

###### 1.1 配置`postgresql.yaml`
```bash
# postgresql.yaml新增部分:

'iam':
  host: '{{ pgpool_host }}'
  user: 'yunify'
  password: '{{ password }}'
  pgnodes: '{{ pg_nodes }}'
```
+ `pgpool_host`  `password` `pg_nodes` 参考`postgresql.yaml`其他部分即可

###### 1.2 配置`server.yaml`

```bash
# server.yaml新增部分
common:
  token_public_key: '/pitrix/conf/cert/iam_sts_rsa.pem'
  token_audience: 'iam'

iam_server:
  iam_sts_server_port: '8388'
  iam_sts_server_addr: '{{ global_zone_id }}-proxy'
  iam_aes_key: 'qingcloudiam2020'
  iam_access_control_enabled: 0
  token_private_key: '/pitrix/conf/cert/iam_sts_rsa'

  # toggle for granting permissions to evaluation when iam eva throws exceptions
  iam_eva_exception_permission: true
  iam_qrn_partition: 'qingcloud'
  region_zones: # 这里要配置所有部署了 iam 的 sub 信息，非region的环境 region_id 用 zone_id 代替
    '{{region_id}}':
      - {{zone_id}}
  metadata_server: # 这里配置所有部署了 iam 的 sub 的信息
    '{{zone_id}}': 
      server_host: '{{dnsmaster_vip}}'
      server_port: '{{port}}'
      data_path: '/v1/data'
  dkron_server_hosts:
    - '{{global-zoocassa0}}:6080' # 此处与安装dkron服务的zoocassa节点一致
    - '{{global-zoocassa1}}:6080'
    - '{{global-zoocassa2}}:6080'

## metadata_server一段，如果有多个zone 一般 zone无法跟global直接通信， 默认在global-proxy上做转发，server_host配置proxyvip，配置参考如下
listen pekt3d-metad
    bind 0.0.0.0:9611
    mode tcp
    balance source
    server pekt3d_metad_0 36.110.217.193:9611 check
    server pekt3d_metad_1 36.110.217.194:9611 check
```
##### 配置各个 sub zone 的 metadata_server 部分

####### 2.1 配置`server.yaml`

```
common:
  intranet_networks:
    - '169.254.169.254/32' # 该配置作用是使绑定eip的主机访问169.254.169.254时，流量不经过vg，不会SNAT，使metadata server能准备识别主机的基础网络ip
  enable_metadata_server: 1   # 使能主机同步身份信息到metad
  metadata_server:
    server_host: {dnsmaster_vip} # 各zone的dnsmaster节点vip
    server_port: '9611'
    server_domain: 'metadata.ks.qingcloud.com'
    user_port: '80'
    data_path: '/v1/data'
    mapping_path: '/v1/mapping'
    instance_prefix: '/instances'
    credential_prefix: '/iam/credential'
```
###### 2.2 更新 global-conf

```bash
/pitrix/build/build_pkgs.py -p pitrix-global-conf
/pitrix/upgrade/update.sh all pitrix-global-conf
```

###### 2.3 交换机配置
交换机上配置169.254.169.254的路由指向metad服务所在的dnsmaster节点的vip

###### 2.4 已有主机的环境数据初始化（针对追加部署的老环境）

+ 对于已存在的主机，需要在WS节点执行脚本才能注册身份信息到metad（脚本在上述配置都完成之后执行）

```bash
# 初始化主机身份metadata
python /pitrix/lib/pitrix-scripts/update_instance_metadata.py -s {dnsmaster_node_vip} -I

# 初始化集群身份metadata
python /pitrix/lib/pitrix-scripts/update_instance_metadata.py -s {dnsmaster_node_vip} -C

# region环境，如果etcd是跨可用区部署的集群，只需要选任一个可用区的dnsmaster节点vip执行一次脚本即可。
# region环境，如果每个可用区都独立部署etcd集群，需要在每个可用区都执行一次该脚本
```

##### 检查服务

###### 3.1 检查`iam`相关服务状态

```bash
/pitrix/upgrade/exec_nodes.sh webservice ' supervisorctl status  |grep -E "iam*|etcd*|meta"'
/pitrix/upgrade/exec_nodes.sh zoocassa ' supervisorctl status  |grep -E "iam*|etcd*|meta"'
/pitrix/upgrade/exec_nodes.sh dnsmater ' supervisorctl status  |grep -E "iam*|etcd*|meta"'
```

#### 前端配置

##### 修改`global fb`节点的前端配置文件`/pitrix/conf/variables/webs/webconsole/local_config.yaml`

```yaml
GLOBAL_CONFIG:
  # ------ iam settings ------ #
  iam_available_zone: [{{region_ids}}]
  iam_settings:
    support_iam_product_role: true
    support_iam: true
    support_iam_user: false
    support_iam_role: true
    support_iam_policy: true
    support_iam_group: false
    valid_role_timeout: [300, 1800, 3600, 7200, 21600, 43200 ,86400]

```

##### 刷新global zone的前端包，然后去`console`测试

```bash
/pitrix/build/build_pkgs.py -p pitrix-ks-webservice-webconsole
/pitrix/upgrade/update.sh webservice pitrix-ks-webservice-webconsole
```