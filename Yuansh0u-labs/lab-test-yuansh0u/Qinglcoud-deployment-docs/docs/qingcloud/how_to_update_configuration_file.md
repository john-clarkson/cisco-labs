## 如何更新配置文件

+ 以下都是如何从`firstbox`节点批量更新配置文件到节点的方法。

### global-conf

+ 配置目录: `/pitrix/conf/variables/global`

```bash
vim /pitrix/conf/variables/global/server.yaml.ZONE_ID
```

```bash
/pitrix/upgrade/build_global_conf.sh
/pitrix/upgrade/update.sh all pitrix-global-conf
```

### 前端配置

+ 配置目录: `/pitrix/conf/variables/webs/`

```bash
vim /pitrix/conf/variables/webs/webconsole/local_config.yaml
```

```bash
# webconsole
/pitrix/build/build_pkgs.py -p pitrix-ks-webservice-webconsole
/pitrix/upgrade/update.sh webservice pitrix-ks-webservice-webconsole

# webappacenter
/pitrix/build/build_pkgs.py -p pitrix-ks-webservice-webappacenter
/pitrix/upgrade/update.sh webservice pitrix-ks-webservice-webappacenter
```

***
