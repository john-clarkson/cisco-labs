### BOSS服务

+ 要求: `Installer`的版本必须是`4.3`及以上版本，仅支持部署`BOSS V2`版本。
+ 要求: `zoocassa`节点的系统版本必须大于等于`Ubuntu 14.04.5`(Installer4.4.3之后无此要求)。
+ 要求: 需要环境中部署`cronus`服务，请查看`how_to_deploy_cronus_4.X.md`。
+ 要求: `Sub Region`或`Sub Zone`无需部署`BOSS`服务，仅需部署`cronus`服务即可。

#### 新环境部署

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 在配置青云平台阶段, 编辑`variables.ZONE_ID.yaml`时, 将`deploy_boss`设置为`1`即可;

#### 老环境追加

##### 卸载BOSS V1

+ 查看`zoocassa`节点的系统版本:

```bash
/pitrix/upgrade/exec_nodes.sh -f zoocassa 'lsb_release -ds'
```

+ 卸载`BOSS V1`的服务:

```bash
/pitrix/upgrade/exec_nodes.sh -f webservice 'supervisorctl stop boss_collector'
/pitrix/upgrade/exec_nodes.sh -f webservice 'supervisorctl stop boss_aggregator'
/pitrix/upgrade/exec_nodes.sh -f webservice 'supervisorctl stop boss_aggregator_proxy'
/pitrix/upgrade/exec_nodes.sh -f webservice 'rm -f /etc/supervisor/conf.d/boss_collector.conf'
/pitrix/upgrade/exec_nodes.sh -f webservice 'rm -f /etc/supervisor/conf.d/boss_aggregator.conf'
/pitrix/upgrade/exec_nodes.sh -f webservice 'rm -f /etc/supervisor/conf.d/boss_aggregator_proxy.conf'
/pitrix/upgrade/exec_nodes.sh -f webservice 'supervisorctl reread'
/pitrix/upgrade/exec_nodes.sh -f webservice 'supervisorctl update'

/pitrix/upgrade/exec_nodes.sh -f boss 'supervisorctl stop boss_hypervisor'
/pitrix/upgrade/exec_nodes.sh -f boss 'supervisorctl stop boss_hypervisor_proxy'
/pitrix/upgrade/exec_nodes.sh -f boss 'supervisorctl stop pitrix-boss-console'
/pitrix/upgrade/exec_nodes.sh -f boss 'rm -f /etc/supervisor/conf.d/boss_hypervisor.conf'
/pitrix/upgrade/exec_nodes.sh -f boss 'rm -f /etc/supervisor/conf.d/boss_hypervisor_proxy.conf'
/pitrix/upgrade/exec_nodes.sh -f boss 'rm -f /etc/supervisor/conf.d/pitrix-boss-console.conf'
/pitrix/upgrade/exec_nodes.sh -f boss 'supervisorctl reread'
/pitrix/upgrade/exec_nodes.sh -f boss 'supervisorctl update'

/pitrix/upgrade/exec_nodes.sh -f hyper 'supervisorctl stop boss_daemon'
/pitrix/upgrade/exec_nodes.sh -f hyper 'rm -f /etc/supervisor/conf.d/boss_daemon.conf'
/pitrix/upgrade/exec_nodes.sh -f hyper 'supervisorctl reread'
/pitrix/upgrade/exec_nodes.sh -f hyper 'supervisorctl update'

/pitrix/upgrade/exec_nodes.sh -f proxy "rm -f /etc/nginx/sites-enabled/boss.conf"
/pitrix/upgrade/exec_nodes.sh -f proxy "rm -f /etc/nginx/sites-available/boss.conf"
/pitrix/upgrade/exec_nodes.sh -f proxy "service nginx reload"

rm -f /pitrix/conf/variables/global/boss.yaml*
```

+ 修改`server.yaml.*`:

```bash
vim /pitrix/conf/variables/global/server.yaml.*
```

```yaml
# 注意修改 PROXY_VIP
nf_server:
  notify_settings:
    system:
      enable_save_notifylog: false
      notifylog_third_parties:
        webhook:
          type: 'webhook'
          url: 'http://PROXY_VIP:6777/alert_receiver/nf/'
```

##### 部署BOSS V2

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 进入`/pitrix/config`目录，从`templates`目录的`vm_variables.template.yaml`拷贝一个`vm_variables.ZONE_ID.yaml`出来:
    + `cp -f /pitrix/config/templates/vm_variables.template.yaml /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 此处拷贝的配置文件，必须让`ZONE_ID`在中间，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板里的说明，按需为需要追加部署组件的`ZONE`填入必要的信息。
    + 一次仅允许追加部署一种组件。

+ 更改配置文件:
    + 将`deploy_boss`设置为`1`。
    + `fusion`模式不支持指定管理虚机的`floating_ip`和`mgmt_network_address`。

+ 部署管理节点: `/pitrix/cli/deploy-qingcloud-component.py -v /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 查看部署管理节点的当前状态：`/pitrix/cli/get-deploy-qingcloud-component-status.py`。
    + 查看部署管理节点的简略日志：`/pitrix/cli/get-deploy-qingcloud-component-log.py`。
    + 详细日志请看目录下对应`job`的日志：`/pitrix/log/deploy`。
    + 此步骤耗时较长, 耐心等待完成。

#### 部署完成

##### 登录平台

+ 执行`/pitrix/bin/dump_hosts.py`导出`hosts`;
+ 访问`URL`为 `boss.DOMAIN`;
+ 内置账号`boss@DOMAIN`, 默认密码: `zhu88jie`;

#### 维护环境

##### WebSupervisor

+ 若需要使用`BOSS V2`暂不支持的功能，但是`websupervisor`界面支持，可通过以下命令部署:

```bash
/pitrix/build/build_pkgs.py -p pitrix-ks-webservice-websupervisor
/pitrix/upgrade/update.sh webservice pitrix-ks-webservice-websupervisor
```

+ 部署完成之后，还需要添加访问`hosts`，形如: `supervisor.DOMAIN`，添加到和`console`并列。

##### 更新配置文件

+ 在`firstbox`上编辑后端配置文件:

```bash
vim /pitrix/conf/variables/boss2/boss2.yaml.ZONE_ID
```

+ `build`包并更新到节点:

```bash
/pitrix/build/build_pkgs.py -p pitrix-ks-boss2-conf
/pitrix/upgrade/update.sh boss pitrix-ks-boss2-conf
```

+ 在`firstbox`上编辑前端配置文件:

```bash
vim /pitrix/conf/variables/boss2/local_config.yaml
```

+ `build`包并更新到节点:

```bash
/pitrix/build/build_pkgs.py -p pitrix-ks-boss2-console
/pitrix/upgrade/update.sh boss pitrix-ks-boss2-console
```

##### 检查环境

+ 在任意一个`boss`节点检查服务是否正常:

```bash
/pitrix/bin/boss2-manager/django_manage.sh areyouok
```

##### 环境版本

+ 在任意一个`boss`节点执行以下命令:

```bash
/pitrix/bin/boss2-manager/django_manage.sh versions
```

##### 升级包

+ 将适用的最新的前端包放置到`/pitrix/repo/web/`目录。
+ 将适用的最新的后端包放置到`/pitrix/repo/indep/boss2/`目录。

```bash
# 升级后端包
/pitrix/bin/scan_all.sh
/pitrix/upgrade/update.sh boss boss
/pitrix/upgrade/update.sh boss pitrix-transit-upload-server

. /pitrix/conf/nodes/boss
ssh ${nodes[0]} "/pitrix/bin/boss2-manager/django_manage.sh migrate"
ssh ${nodes[0]} "/pitrix/bin/boss2-manager/django_manage.sh init_data"

# 升级前端包
/pitrix/build/build_pkgs.py -p pitrix-ks-boss2-console
/pitrix/upgrade/update.sh boss pitrix-ks-boss2-console
```

##### 扩容环境

+ 当平台扩容节点后，请重建`boss`的缓存，防止统计信息不更新:

```bash
/pitrix/bin/boss2-manager/django_manage.sh rebuild_cache
```

***
