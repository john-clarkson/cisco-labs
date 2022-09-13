### V2V服务

+ `V2V`迁移工具，可将用户现有`VMware`环境虚拟机进行转换，迁移到`QingCloud`云平台上运行。
+ 要求: `Installer`的版本必须是`4.3`及以上版本，需要与`BOSS V2`版本配合使用。

#### 新环境部署

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 在配置青云平台阶段, 编辑`variables.ZONE_ID.yaml`时, 将`deploy_v2v`设置为`1`即可;

#### 老环境追加

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 进入`/pitrix/config`目录，从`templates`目录的`vm_variables.template.yaml`拷贝一个`vm_variables.ZONE_ID.yaml`出来:
    + `cp -f /pitrix/config/templates/vm_variables.template.yaml /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 此处拷贝的配置文件，必须让`ZONE_ID`在中间，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板里的说明，按需为需要追加部署组件的`ZONE`填入必要的信息。
    + 一次仅允许追加部署一种组件。

+ 更改配置文件:
    + 将`deploy_v2v`设置为`1`。
    + `fusion`模式不支持指定管理虚机的`mgmt_network_address`。

+ 部署管理节点: `/pitrix/cli/deploy-qingcloud-component.py -v /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 查看部署管理节点的当前状态：`/pitrix/cli/get-deploy-qingcloud-component-status.py`。
    + 查看部署管理节点的简略日志：`/pitrix/cli/get-deploy-qingcloud-component-log.py`。
    + 详细日志请看目录下对应`job`的日志：`/pitrix/log/deploy`。
    + 此步骤耗时较长, 耐心等待完成。

+ 修改`boss`的配置文件:

```bash
vim /pitrix/conf/variables/boss2/boss2.yaml.ZONE_ID
```

```yaml
modules:
  enable:
    - v2v

v2v:
  ZONE_ID:
    url: 'http://V2V_HOSTNAME/'
    upload: 'V2V_HOSTNAME:80'
```

+ 更新`boss`的配置文件:

```bash
/pitrix/build/build_pkgs.py -p pitrix-ks-boss2-conf
/pitrix/upgrade/update.sh boss pitrix-ks-boss2-conf
```

***
