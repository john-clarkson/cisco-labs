### 1 部署warehouse服务

#### 1.1 服务简介

+ `warehouse`服务是主要按时间，项目，资源类型，区域，账户等维度统计用户消费情况，在右上角消费统计页面查看。
+ 请在`GLOBAL ZONE`中部署`warehouse`服务。
+ 若为`SUB ZONE`或`SUB REGION`仅需部署`warehouse-proxy`服务即可。

#### 1.2 新环境部署

+ 注意修改`ZONE_ID`。
+ 在配置青云平台阶段, 编辑`variables.ZONE_ID.yaml`时:
  + 将`deploy_warehouse`设置为`1`即可;
  + 若一个`Region`中有多个`ZONE`，仅需将任意一个`ZONE`的`deploy_warehouse`设置为`1`，其他`ZONE`设置为`0`。
  + 此环境为`Sub ZONE`或者`Sub REGION`:
    + 需要将`remote_warehouse_proxy_host`设置为`Global ZONE`的`proxy`的`IP`地址。
    + 需要将`remote_warehouse_proxy_port`设置为`Global ZONE`的`proxy`的`SSH`端口。
    + 需要配置`Global ZONE`的`proxy`节点与`Sub ZONE`的`proxy`节点之前的免密登录。

#### 1.3 老环境追加

##### Sub环境

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 进入`/pitrix/config`目录，从`templates`目录的`vm_variables.template.yaml`拷贝一个`vm_variables.ZONE_ID.yaml`出来:
    + `cp -f /pitrix/config/templates/vm_variables.template.yaml /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 此处拷贝的配置文件，必须让`ZONE_ID`在中间，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板里的说明，按需为需要追加部署组件的`ZONE`填入必要的信息。
    + 一次仅允许追加部署一种组件。

+ 更改配置文件:
    + 将`deploy_warehouse`设置为`1`，若为`Sub REGION`仅需其中一个`ZONE`设置为`1`即可。
    + 需要将`remote_warehouse_proxy_port`设置为`Global ZONE`的`proxy`的`IP`地址。
    + 需要将`remote_warehouse_proxy_port`设置为`Global ZONE`的`proxy`的`SSH`端口。
    + 需要配置`Global ZONE`的`proxy`节点与`Sub ZONE`的`proxy`节点之间的免密登录。
    + `fusion`模式不支持指定管理虚机的`floating_ip`和`mgmt_network_address`。

+ 更新到`variables.yaml`文件:

```bash
/pitrix/config/vm_variables.py /pitrix/config/vm_variables.ZONE_ID.yaml -f
```

+ 构建相关的包:

```bash
/pitrix/build/build_pkgs_allinone.py -r warehouse
```

+ 为`proxy`节点安装指定的包:

```bash
/pitrix/upgrade/update.sh proxy pitrix-ks-proxy-warehouse
```

##### Global环境

+ 在`firstbox`上修改`postgresql.yaml.*`, 注意修改`GLOBAL_ZONE_ID`。:
  + 复制其他项(`5`行), 仅修改名称即可, `host`, `user`, `password`都不变:

```bash
# firstbox
# /pitrix/conf/variables/global/postgresql.yaml.*

'boss_statistics':
  host: 'xxx'
  user: 'yunify'
  password: 'yyy'

'wh_data':
  host: 'xxx'
  user: 'yunify'
  password: 'yyy'
```

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 进入`/pitrix/config`目录，从`templates`目录的`vm_variables.template.yaml`拷贝一个`vm_variables.ZONE_ID.yaml`出来:
    + `cp -f /pitrix/config/templates/vm_variables.template.yaml /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 此处拷贝的配置文件，必须让`ZONE_ID`在中间，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板里的说明，按需为需要追加部署组件的`ZONE`填入必要的信息。
    + 一次仅允许追加部署一种组件。

+ 更改配置文件:
    + 将`deploy_warehouse`设置为`1`，若为`Sub REGION`仅需其中一个`ZONE`设置为`1`即可。
    + `fusion`模式不支持指定管理虚机的`floating_ip`和`mgmt_network_address`。

+ 部署管理节点: `/pitrix/cli/deploy-qingcloud-component.py -v /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 查看部署管理节点的当前状态：`/pitrix/cli/get-deploy-qingcloud-component-status.py`。
    + 查看部署管理节点的简略日志：`/pitrix/cli/get-deploy-qingcloud-component-log.py`。
    + 详细日志请看目录下对应`job`的日志：`/pitrix/log/deploy`。
    + 此步骤耗时较长, 耐心等待完成。

#### 1.4 特殊环境

+ 若此环境部署过`warehouse`服务，需要手动修改`proxy`节点的`haproxy`的配置文件:

```bash
# /etc/haproxy/haproxy.cfg
# 移除多余的 warehouse-front 配置

listen warehouse-front
    bind 0.0.0.0:8856
    mode tcp
    balance source
    server  warehou_seserver_0 {{ warehouse0_hostname }}:7756 check
    server  warehou_seserver_1 {{ warehouse1_hostname }}:7756 check
```

#### 1.5 部署完成

##### 1.5.1 启用服务

+ 修改`fb`节点`/pitrix/conf/variables/global/server.yaml.*`启用`warehouse`:

```yaml
warehouse_server:
  func_enabled: []
  is_enabled: true
  proxy_host: 'GLOBAL_ZONE_ID-proxy'
  proxy_port: 8856
```

+ 更新配置

```bash
/pitrix/build/build_pkgs.py -p pitrix-global-conf
/pitrix/upgrade/update.sh all pitrix-global-conf
```

+ 修改`global fb`节点的前端配置文件`/pitrix/conf/variables/webs/webconsole/local_config.yaml`:

```yaml
GLOBAL_CONFIG:
  support_consumptions: true
```

+ 刷新global zone的前端包，然后去`console`测试

```bash
/pitrix/build/build_pkgs.py -p pitrix-ks-webservice-webconsole
/pitrix/upgrade/update.sh webservice pitrix-ks-webservice-webconsole
```

#### 1.5.2 在BOSS2上配置warehouse

+ 登录firstbox，修改BOSS2的配置文件`/pitrix/conf/variables/boss2/boss2.yaml.ZONE_ID`(如BOSS2在多个zone部署，请修改所有zone的配置文件)：

```yaml
# 在modules--enable部分添加 warehouse
modules:
  enable:
    - warehouse

# 在配置文件最下方添加warehouse的连接配置，请复制以下配置示例并进行修改(该配置中需修改的仅有host部分)
warehouse:
  host: 'GLOBAL_ZONE_ID-proxy'
  port: 8857
  protocol: 'http'
  access_key_id: 'LBSHHHIQRPROLHFYAJMV'
  secret_access_key: 'U/hdCoWMiyTfyTZajFSSUc7f8nG662t0c3Lne5h9Djaah+0Vb3nVJtBApSJLJlAn'
```

+ 更新配置到`boss`节点

```bash
/pitrix/build/build_pkgs.py -p pitrix-ks-boss2-conf
/pitrix/upgrade/update.sh boss pitrix-ks-boss2-conf
```

##### 1.5.3 Boss V1 启用warehouse(针对没有使用boss2的环境)

+ `BOSS V1`: 修改`boss.yaml.*`启用`warehouse`:

```bash
# firstbox
# /pitrix/conf/variables/global/boss.yaml.*

wh_server:
  proxy_host: 'GLOBAL_ZONE_ID-proxy'
  proxy_port: 8856
```

+ 然后重新 `build` 包: `/pitrix/upgrade/build_global_conf.sh`;
+ 重新安装 `pitrix-global-conf` 包: `/pitrix/upgrade/update.sh -f all pitrix-global-conf`;

+ `BOSS V1`: 需要在`boss`节点修改前端配置文件:

```bash
# boss0/boss1
# /pitrix/conf/boss/console.yaml

public:
  has_warehouse: true
```

+ 重启`boss0/1`上的`pitrix-boss-console`服务：`/pitrix/upgrade/exec_nodes.sh -f boss 'supervisorctl restart pitrix-boss-console'`;