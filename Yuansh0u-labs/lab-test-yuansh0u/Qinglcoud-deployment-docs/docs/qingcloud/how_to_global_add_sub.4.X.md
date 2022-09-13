### 背景

+ 随着平台规模的扩大，需要添加一个`Sub reigon/zone`到已有的`Global region/zone`中。
+ 若需要在同一个`Region`中扩容`ZONE`，请参考`how_to_scale_qingcloud_4.X.md`文档。
+ 使用`Installer 4.X`部署的环境，默认都是`Region`环境，支持扩容节点，支持在`Region`中扩容`ZONE`，支持对接其他的`Region/Zone`。
+ 使用`Installer 3.X`部署的环境，默认都是`Zone`环境，支持扩容节点，支持对接其他的`Region/Zone`。

### 操作过程

#### 预置信息

+ `2`个环境的`console_id`一定要一致。
+ 若`global`为`Region`环境，则需要获取`region_id`和`zone_id`。
+ 若`global`为`Zone`环境，则需要获取`zone_id`。
+ 若`sub`为`Region`环境，则需要获取`region_id`和`zone_id`。
+ 若`sub`为`Zone`环境，则需要获取`zone_id`。
+ 根据以上规则，总共有`4`种配对，分别为`region-region`、`region-zone`、`zone-region`、`zone-zone`。
+ 分别获取`Global`环境和`Sub`环境的`proxy`节点的公网地址。
+ 在`Global`环境的`proxy`找一个未被占用的端口，用于转发请求到`Sub`环境。

+ 以下为本文档，预置的环境信息:

```yaml
console_id: qingcloud

global_region_id: pek1
global_zone_id: pek1a

sub_region_id: cd1
sub_zone_id: cd1a

global_proxy0: 139.198.15.9
global_proxy1: 139.198.20.20
global_proxy_port: 6515

sub_zone_proxy0: 36.110.217.193
sub_zone_proxy1: 36.110.217.194
```

#### Sub环境

+ 修改`proxy`节点的`haproxy`的配置:

```bash
listen api-front
    bind 0.0.0.0:7777
    mode tcp
    balance source
    # 若 Global 为 https，则端口为 443
    server  apiserver_0 139.198.15.9:443 check
    server  apiserver_1 139.198.20.20:443 check
    # 若 Global 为 http，则端口为 7777
    server  apiserver_0 139.198.15.9:7777 check
    server  apiserver_1 139.198.20.20:7777 check

listen ws-front
    bind 0.0.0.0:8565
    mode tcp
    balance roundrobin
    server  ws_server_0 139.198.15.9:8565 check
    server  ws_server_1 139.198.20.20:8565 check

# 标准模式: 注意端口
listen io-front
    bind 0.0.0.0:8000
    mode tcp
    balance source
    server  io_server_0 139.198.15.9:8000 check
    server  io_server_1 139.198.20.20:8000 check

# 融合模式: 注意端口
listen io-front
    bind 0.0.0.0:8011
    mode tcp
    balance source
    server  io_server_0 139.198.15.9:8011 check
    server  io_server_1 139.198.20.20:8011 check
```

+ 依次重启`proxy`节点的`haproxy`服务:

```bash
service haproxy restart
```

+ 修改`webservice`节点上的配置文件:

```yaml
# /pitrix/conf/client.yaml

# access key info，将 XXXX 修改为 global 的 key
qy_access_key_id: 'XXXX'
qy_secret_access_key: 'XXXX'

# message expired time in seconds
msg_time_out: 3600

# http socket timeout in seconds
http_socket_timeout: 30

# retry time after message send failed
retry_time: 3

# local proxy floating hostname
host: "cd1a-proxy"

# remote host port, 443 for https
port: 7777

# protocol, "http" or "https"
protocol: "http"

# zone
zone: "cd1a"
```

+ 通过`global`的`webservice`节点的`/pitrix/conf/client.yaml`文件，更新`sub`的`firstbox`上的配置:
  + 根据`qy_access_key_id`，更新`firstbox`节点的`/pitrix/conf/variables/keys/.access_key_id`。
  + 根据`qy_secret_access_key`，更新`firstbox`节点的`/pitrix/conf/variables/keys/.access_secret_key`。
  + 通过查询`global`的`account`数据库中`access_key`表中与`access_key_id`对应的`secret_access_key`字段，更新`firstbox`节点的`/pitrix/conf/variables/keys/.secret_access_key`。

##### 卸载 Global 服务

+ 若部署`sub`环境时，填写的`is_global_zone`为`1`，则需要将此值设置为`0`并卸载相关的服务。

```bash
vim /pitrix/conf/variables/variables.yaml
```

+ 在`webservice`节点，卸载相关服务:

```bash
apt-get purge pitrix-ws-* pitrix-account-* pitrix-billing-daemon* pitrix-billing-resource* pitrix-billing-user* pitrix-boss-aggregator* pitrix-billing-broker* pitrix-global-bot-*
```

```bash
rm -f /etc/nginx/sites-enabled/docs.conf
rm -f /etc/nginx/sites-enabled/apiserver.conf
rm -f /etc/nginx/sites-enabled/webconsole.conf
rm -f /etc/nginx/sites-enabled/webappcenter.conf
rm -f /etc/nginx/sites-enabled/websupervisor.conf
service nginx restart

rm -f /etc/apache2/sites-enabled/apiserver.conf
rm -f /etc/apache2/sites-enabled/webconsole.conf
rm -f /etc/apache2/sites-enabled/webappcenter.conf
rm -f /etc/apache2/sites-enabled/websupervisor.conf
service apache2 restart
```

+ 在`firstbox`节点，删除`server.yaml`中`account_server`相关的配置:

```bash
# 注意修改 ZONE_ID，account_server 的配置，一般在文件开头
vim /pitrix/conf/variables/global/server.yaml.ZONE_ID
```

+ 在`firstbox`节点，删除`billing.yaml`文件:

```bash
rm -f /pitrix/conf/variables/global/billing.yaml.*
```

+ 重新构建包并下发配置:

```bash
/pitrix/upgrade/build_global_conf.sh
/pitrix/upgrade/update.sh all pitrix-global-conf
```

#### Global 环境

+ 修改`proxy`节点的`haproxy`的配置:

```bash
vim /etc/haproxy/haproxy.cfg
```

```bash
listen cd1a-fg-front
    bind 0.0.0.0:6515
    mode tcp
    balance roundrobin
    server cd1a_fg_server_1 36.110.217.193:8665 check
    server cd1a_fg_server_2 36.110.217.194:8665 check
```

+ 依次重启`proxy`节点的`haproxy`服务:

```bash
service haproxy restart
```

+ 在`firstbox`节点生成需要的`SQL`文件，用于更新数据库:

```bash
vim /root/global_add_sub.yaml
```

```text
global:
    console_id: "qingcloud"

sub:
    is_region: 1
    region_id: 'cd1'
    zone_ids:
      - 'cd1a'
    cd1a:
      zone_code: 22
      global_proxy_port: 6515
```

```bash
/pitrix/bin/global_add_sub.py -c /root/global_add_sub.yaml
```

+ 生成的`SQL`语句在`/pitrix/backup/global_add_sub/`目录:

```bash
# 更新 account 数据库
/pitrix/bin/exec_sql.py -d account -F /pitrix/backup/global_add_sub/cd1/account.sql

# 更新 global 数据库
/pitrix/bin/exec_sql.py -d global -F /pitrix/backup/global_add_sub/cd1/global.sql

# 更新 billing_resource 数据库
/pitrix/bin/exec_sql.py -d billing_resource -F /pitrix/backup/global_add_sub/cd1/billing_resource.sql
```

+ 更新`firstbox`上的`server.yaml`:

```bash
vim /pitrix/conf/variables/global/server.yaml.pek1a
```

```yaml
# 从 sub 环境中将 server.yaml 中对应的配置复制到 global 环境的对应位置
# 此处的示例为 sub 环境是一个 region 环境

common:
  # 此处 ... 代表省略号，表示之前的配置不变，只是追加新的配置
  appcenter2_available_areas: "...,cd1"
  resource_limits:
    # 此处 ... 代表省略号，表示之前的配置不变，只是追加新的配置
    zones: '...,cd1'
    cd1:
      zones:
        - 'cd1a'
      bm_zones:
        - 'cd1a'
      neonsan_zones:
        - 'cd1a'
      public_zones:
        - 'cd1a'
      max_abuse_eip_cnt: 50
      max_eip_bandwidth: 300
      max_hc_volume_size: 5000
      max_volume_size: 2000
      min_abuse_eip_sec: 86400
      valid_cpu_cores: '1, 2, 4, 8, 12, 16, 24, 32'
      valid_cpu_memory_pairs:
        !!int 1: '1024, 2048, 4096, 6144, 8192, 12288, 16384, 24576, 32768, 40960,
          49152, 65536'
        !!int 2: '1024, 2048, 4096, 6144, 8192, 12288, 16384, 24576, 32768, 40960,
          49152, 65536'
        !!int 4: '2048, 4096, 6144, 8192, 12288, 16384, 24576, 32768, 40960, 49152,
          65536'
        !!int 8: '4096, 6144, 8192, 12288, 16384, 24576, 32768, 40960, 49152, 65536'
        !!int 12: '8192, 12288, 16384, 24576, 32768, 40960, 49152, 65536'
        !!int 16: '12288, 16384, 24576, 32768, 40960, 49152, 65536, 98304, 114688,
          131072'
        !!int 32: '65536, 98304, 114688, 131072'
  # 以下配置为预留合约，无预留合约无需添加，私有云一般都不需要添加
  reserved_resource:
    zones:
      bm_instance: '...,cd1'
      cluster: '...,cd1'
      dedicated_host_group: '...,cd1'
      instance: '...,cd1'
      volume: '...,cd1'
```

+ 更新配置到所有节点:

```bash
/pitrix/upgrade/build_global_conf.sh
/pitrix/upgrade/update.sh -f all pitrix-global-conf
```

+ 在`webservice`节点上清理`memcache`的缓存:

```bash
# 若为源码包，则该脚本需要带 *.py 执行
# 注意将 zoocassa 节点的 hostname 修改为实际的
/pitrix/lib/pitrix-scripts/cache/operate_cache_by_re -S 'zoocassa0:11211;zoocassa1:11211;zoocassa2:11211' -A delete -P "Pitrix.Zone.Zone.UserZone.yunify" -F
```

+ 在`webservice`节点上重启相关服务:

```bash
supervisorctl restart ws_server billing_resource
```

+ 将新区开发给用户:

```bash
# 开放给所有用户
/pitrix/lib/pitrix-scripts/region/merge_zone/grant_region_to_user --region cd1 --dry 0
# 开放给指定用户
/pitrix/lib/pitrix-scripts/region/merge_zone/grant_region_to_user --region cd1 --users usr-Gjl0Xlsu --dry 0
```

+ 生成预留合约所需的`SQL`文件(无预留合约无需执行，私有云一般都不需要执行):

```bash
# 将生成的 SQL 文件再导入数据库即可
/pitrix/lib/pitrix-scripts/pricing/init_reserved_resource_price -z cd1 -c qingcloud
```

+ 前端开放:

```bash
vim /pitrix/lib/pitrix-webconsole/mysite/local_config.yaml
```

```text
GLOBAL_CONFIG:
  zones: [..., cd1]
  zones_info:
    cd1: {en: cd1, zh-cn: CD1}
```

```bash
vim /pitrix/lib/pitrix-webappcenter/mysite/local_config.yaml
```

```text
GLOBAL_CONFIG:
  zones: [...,cd1]
```

```bash
vim /pitrix/conf/web_console_settings.py
```

```text
PITRIX_SETTINGS = {
    ...
    # public zones that can be access by newly registered user
    'public_zones': [..., 'cd1'],
    ...
}
```

```bash
service apache2 reload
```

+ cronus对接:

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