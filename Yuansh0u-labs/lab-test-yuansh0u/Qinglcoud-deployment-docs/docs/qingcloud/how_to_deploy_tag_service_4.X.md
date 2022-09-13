### tag服务
#### 前提
installer 4.6+

#### 新环境部署

+ 新环境默认将部署tag服务，无需手动操作；

#### 老环境追加
+ 注意修改`ZONE_ID`/`REGION_ID`为平台环境的实际值。

+ 构建相关包

```buildoutcfg
/pitrix/build/build_pkgs.py -p pitrix-ks-proxy-tag
/pitrix/build/build_pkgs.py -p pitrix-ks-tag-server
```

+ 在相关节点安装/更新包

```buildoutcfg
/pitrix/upgrade/update.sh ZONE_ID-proxy pitrix-ks-proxy-tag
/pitrix/upgrade/update.sh ZONE_ID-webservice pitrix-ks-tag-server
```

+ 修改global zone的server.yaml, fb的/pitrix/conf/variables/global/server.yaml.GLOBAL_ZONE_ID

```buildoutcfg
common:
  enable_global_tag_server: true
  zones_enable_tag_server: 'REGION_ID'  # 启用标签服务的区域，填写region_id，非region部署填写zone_id，多个区域用逗号分隔
 
tag_server:
  register_to_zk: true
```

+ 修改sub zone的server.yaml, fb的/pitrix/conf/variables/global/server.yaml.ZONE_ID

```buildoutcfg
common:
  enable_global_tag_server: true
 
fg_server:
  tag_proxy_host: 'ZONE_ID-proxy'  # proxy节点vip对应的hostname
```

+ 更新pitrix-global-conf到所有节点

```buildoutcfg
/pitrix/upgrade/update.sh all pitrix-global-conf
```

+ 迁移db, 登录到webservice节点执行

```buildoutcfg
cd /pitrix/lib/pitrix-scripts/src/tag/
./migrate_for_tag_server.py -z ZONE_ID -f /pitrix/conf/admin_beta.yaml -a insert

输出形如下：
Here is a probe response:
{'action': 'DescribeTagsResponse', 'total_count': 40, 'tag_set': [{'resource_type_count': [{'count': 5, 'resource_type': 'volume'}], 'tag_name': 'SameName', 'description': None, 'resource_count': 5, 'color': 'default', 'controller': 'self', 'tag_id': 'tag-ssssssss', 'console_id': 'admin', 'root_user_id': 'admin', 'create_time': '2020-02-18T03:32:21Z', 'owner': 'admin', 'tag_key': 'default'}], 'ret_code': 0}
There are 40 tag items to migrate.
 
+(inserted)  ^(update)  X(error)  W(warning)
tag: 39 +  0 ^  0 X  1 W  resource_tag: 29 +  0 ^  0 X
All done.

+ 表示插入的条目数
^ 表示更新的条目数
X 表示发生错误的条目数
W 表示警告的条目数 ，如果有同一用户在不同的 zone 持有了同名标签，计入警告数目。
对比 total_count 和( inserted + warning )的数量相同，表明此次迁移成功。
```

+ 迁移完成后，使用 update 指令再次确认迁移结果。

```buildoutcfg
./migrate_for_tag_server.py -z ZONE——ID -f /pitrix/conf/admin_beta.yaml -a update
```

#### 部署完成

##### 升级包

+ 将适用的最新的后端包('pitrix-tag-server' 'pitrix-tag-proxy')放置到`/pitrix/repo/indep/`目录。

```bash
/pitrix/bin/scan_all.sh
/pitrix/upgrade/update.sh webservice tag
```

***
