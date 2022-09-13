### Cronus监控

+ 要求: `Installer`的版本必须是`4.2`及以上版本。

#### 新环境部署

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 在配置青云平台阶段, 编辑`variables.ZONE_ID.yaml`时:
    + 将`deploy_cronus`设置为`1`即可;
    + 若一个`Region`中有多个`ZONE`，仅需将任意一个`ZONE`的`is_cronus_master_zone`设置为`1`，其他`ZONE`设置为`0`。

#### 老环境追加

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 进入`/pitrix/config`目录，从`templates`目录的`vm_variables.template.yaml`拷贝一个`vm_variables.ZONE_ID.yaml`出来:
    + `cp -f /pitrix/config/templates/vm_variables.template.yaml /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 此处拷贝的配置文件，必须让`ZONE_ID`在中间，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板里的说明，按需为需要追加部署组件的`ZONE`填入必要的信息。
    + 一次仅允许追加部署一种组件。

+ 更改配置文件:
    + 将`deploy_cronus`设置为`1`。
    + 若为从`3.7`升级上来的旧环境，则为非`Region`环境:
        + 无论是`Global ZONE`，还是`Sub ZONE`。
        + 都需要设置`is_cronus_master_zone`为`1`。
    + 若为从`4.X`全新部署的环境，则为`Region`环境:
        + 无论是`Global Region`，还是`Sub Region`。
        + 每个`Region`仅需要设置一个`ZONE`的`is_cronus_master_zone`为`1`，其他`ZONE`设置为`0`。
    + `fusion`模式不支持指定管理虚机的`floating_ip`和`mgmt_network_address`。

+ 部署管理节点: `/pitrix/cli/deploy-qingcloud-component.py -v /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 查看部署管理节点的当前状态：`/pitrix/cli/get-deploy-qingcloud-component-status.py`。
    + 查看部署管理节点的简略日志：`/pitrix/cli/get-deploy-qingcloud-component-log.py`。
    + 详细日志请看目录下对应`job`的日志：`/pitrix/log/deploy`。
    + 此步骤耗时较长, 耐心等待完成。

#### 验证功能

+ 在`firstbox`上执行下面命令找出`influxdb`所在机器信息：

```bash
cat /etc/hosts | grep -w $(awk '{print $2}' /pitrix/conf/nodes/influxdb)
```

+ 登陆`http://X.X.X.X:8888/sources/1/manage-sources`(可省略):
    + `X.X.X.X`为`influxdb`所在机器的`IP`地址。
    + 点击有加号(`+`)标识的`Add Kapacitor Connection`, 不用任何操作，点击`Continue`, 然后点击`Finish`, 操作完成。

+ 在浏览器输入如下`URL`，若返回数据则表示安装正确:

```bash
# 请修改对应的API Server
# Region环境
curl http://api.$(/pitrix/bin/get_yaml_info.py variables.yaml common domain)/monitor/$(/pitrix/bin/get_yaml_info.py variables.yaml common region_id)/api/topology

# 非Region环境
curl http://api.$(/pitrix/bin/get_yaml_info.py variables.yaml common domain)/monitor/$(/pitrix/bin/get_yaml_info.py variables.yaml common zone_ids)/api/topology
```

+ 登录到influxdb节点，检查监控数据保存时间为720h:

```bash
influx -execute 'SHOW RETENTION POLICIES ON telegraf'
#输出：
name    duration shardGroupDuration replicaN default
----    -------- ------------------ -------- -------
autogen 720h0m0s 168h0m0s           1        true

influx -execute 'SHOW RETENTION POLICIES ON chronograf'
#输出：
name    duration shardGroupDuration replicaN default
----    -------- ------------------ -------- -------
autogen 720h0m0s       168h0m0s           1        true
```

#### 特殊环境

+ 若环境存在`sub zone`或者`sub region`的情况，单独部署完`cronus`后，需要手动修改配置。
+ 在`Global ZONE`的每个`proxy`节点上，修改`cronus-api`配置文件:

```text
vim /etc/cronus-api/config.yaml

# 在zone_server字段下增加sub zone的配置:

zone_server:
  {{global_zone}}: "http://{{global_zone_proxy_vip}}:8081"
  # sub server，若sub为region环境，则将 {{sub_zone}}改为 region_id，否则，改为 zone_id
  {{sub_zone}}: "http://{{sub_zone_proxy_vip}}:9091"
```

+ 重启`proxy`节点的`cronus-api`服务：`supervisorctl restart cronus-api`。

***
