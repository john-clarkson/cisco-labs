## 背景介绍

+ 请提前找`Installer`组的同事，根据以下示例和实际环境，商讨合适的方案。
+ 由于`Installer 4.X`之前部署的环境都是非`region`环境，若需要`region`的功能，需要将环境改造为`region`环境。

## 操作过程

### 预置信息

+ `global`区为非`region`环境:
  + `zone_id`: `devops1a`。
  + `firstbox_address`: `172.16.80.2`
+ `sub`区为`region`环境:
  + `region_id`: `devops2`。
  + `zone_id`: `devops2a`。
  + `firstbox_address`: `172.16.90.2`

### 部署新环境

+ 使用最新的`Installer`部署包，部署一套`sub region`:
  + 将`is_global_zone`设置为`0`。
  + 将`zone_code`设置成与旧环境不一致的数字。
  + `console_id`和`domain`使用旧环境的。
  + 将`deploy_boss`，`deploy_cronus`等都设置为`0`。
  + 部署完成后，该环境无法使用。

### 禁止旧环境处理请求

+ 修改`server.yaml.devops1a`:

```bash
vim /pitrix/conf/variables/global/server.yaml.devops1a
```

```yaml
fg_server:
  # 禁止 fg 接收新 job , 注意查找是否有同名配置
  disable_new_job: true
```

+ 将配置刷新到所有节点:

```bash
/pitrix/build/build_pkgs.py -p pitrix-global-conf
/pitrix/upgrade/update.sh all pitrix-global-conf
```

### 合并firstbox

+ 将`2`套环境升级到同一个版本，就停止掉旧`fistbox`上扩容节点，更新`Patch`等一切操作。
+ 此处将废弃掉新的`firstbox`，将所有配置合并到旧的`fistbox`。

+ 将新环境的`variables.yaml`与旧环境的`variables.yaml`进行融合。

```bash
vim /pitrix/conf/variables/variables.yaml
```

```yaml
common:
  ssh_port: 22
  firstbox_address: '172.16.80.2'
  cloud_type: 'private'
  domain: 'devopscloud.com'
  # 设置 is_region 为 1
  is_region: 1
  # 设置 region_id 为新环境的 region_id
  region_id: 'devops2'
  console_id: 'devopscloud'
  console_name: 'devopscloud'
  site_protocol: 'http'
  zone_ids:
    - 'devops1a'
    # 添加上新环境的 zone_id
    - 'devops2a'

devops1a: [...]

# 添加上新环境的 zone_id 的详细配置
devops2a: [...]
```

+ 改造旧环境的`settings`文件:

```bash
cd /pitrix/conf/settings

# 将所有虚机的 settings 文件名改成带 zone_id-
mv -f bm0 devops1a-bm0
mv -f bm1 devops1a-bm1
mv -f boss0 devops1a-boss0
mv -f boss1 devops1a-boss1
mv -f proxy0 devops1a-proxy0
mv -f proxy1 devops1a-proxy1
mv -f zoocassa0 devops1a-zoocassa0
mv -f zoocassa1 devops1a-zoocassa1
mv -f zoocassa2 devops1a-zoocassa2
mv -f dnsmaster0 devops1a-dnsmaster0
mv -f dnsmaster1 devops1a-dnsmaster1
mv -f webservice0 devops1a-webservice0
mv -f webservice1 devops1a-webservice1

sed -i 's/bm0/devops1a-bm0/g' devops1a-bm0
sed -i 's/bm1/devops1a-bm1/g' devops1a-bm1
sed -i 's/boss0/devops1a-boss0/g' devops1a-boss0
sed -i 's/boss1/devops1a-boss1/g' devops1a-boss1
sed -i 's/proxy0/devops1a-proxy0/g' devops1a-proxy0
sed -i 's/proxy1/devops1a-proxy1/g' devops1a-proxy1
sed -i 's/zoocassa0/devops1a-zoocassa0/g' devops1a-zoocassa0
sed -i 's/zoocassa1/devops1a-zoocassa1/g' devops1a-zoocassa1
sed -i 's/zoocassa2/devops1a-zoocassa2/g' devops1a-zoocassa2
sed -i 's/dnsmaster0/devops1a-dnsmaster0/g' devops1a-dnsmaster0
sed -i 's/dnsmaster1/devops1a-dnsmaster1/g' devops1a-dnsmaster1
sed -i 's/webservice0/devops1a-webservice0/g' devops1a-webservice0
sed -i 's/webservice1/devops1a-webservice1/g' devops1a-webservice1

sed -i 's/is_region.*/is_region="1"/g' /pitrix/conf/settings/*
```

+ 将原`hostname`对应的`hosts`放到`variables`中:

```bash
vim /pitrix/conf/variables/hosts
```

```text
172.16.80.3 proxy.mgmt.pitrix.yunify.com proxy
# 172.16.80.4 dnsmaster.mgmt.pitrix.yunify.com dnsmaster
172.16.80.5 pgpool.mgmt.pitrix.yunify.com pgpool
172.16.80.6 webservice.mgmt.pitrix.yunify.com webservice
172.16.80.7 zoocassa.mgmt.pitrix.yunify.com zoocassa
172.16.80.8 boss.mgmt.pitrix.yunify.com boss

10.16.100.110 bm0.mgmt.pitrix.yunify.com bm0
10.16.100.111 bm1.mgmt.pitrix.yunify.com bm1
10.16.100.112 boss0.mgmt.pitrix.yunify.com boss0
10.16.100.113 boss1.mgmt.pitrix.yunify.com boss1
172.16.80.101 proxy0.mgmt.pitrix.yunify.com proxy0
172.16.80.102 proxy1.mgmt.pitrix.yunify.com proxy1
172.16.80.103 dnsmaster0.mgmt.pitrix.yunify.com dnsmaster0
172.16.80.104 dnsmaster1.mgmt.pitrix.yunify.com dnsmaster1
172.16.80.105 webservice0.mgmt.pitrix.yunify.com webservice0
172.16.80.106 webservice1.mgmt.pitrix.yunify.com webservice1
172.16.80.107 zoocassa0.mgmt.pitrix.yunify.com zoocassa0
172.16.80.108 zoocassa1.mgmt.pitrix.yunify.com zoocassa1
172.16.80.109 zoocassa2.mgmt.pitrix.yunify.com zoocassa2
```

+ 将新环境的`settings`目录中文件拷贝到旧环境的`settings`目录:

```bash
# 备份
cp -r /pitrix/conf/settings /pitrix/conf/settings.$(date +%Y%m%d)

# 同步
rsync -azPS new-firstbox:/pitrix/conf/settings/ /pitrix/conf/settings/

# 将firstbox的地址替换为旧节点的地址
sed -i 's/\<172.16.90.2\>/172.16.80.2/g' /pitrix/conf/settings/*
```

+ 重新构建包并更新`hosts`:

```bash
/pitrix/bin/gen_node_list.py

/pitrix/build/build_pkgs_allinone.py

/pitrix/upgrade/exec_nodes.sh devops2a-all "sed -i 's@\<172.16.90.2\>@172.16.80.2@g' /etc/hosts"

/pitrix/upgrade/update.sh all pitrix-hosts
```

+ 修改旧环境中`vm`的`hostname`:

```bash
ssh devops1a-boss0

hostname -b devops1a-boss0
echo "devops1a-boss0" > /etc/hostname
```

+ 将`/pitrix/conf/variables/global`中的配置文件中旧的`hostname`改为新的`hostname`。

```bash
# 备份
cp -r /pitrix/conf/variables /pitrix/conf/variables.$(date +%Y%m%d)

sed -i 's/\<pgpool\>/devops1a-pgpool/g' /pitrix/conf/variables/global/*.yaml.devops1a
sed -i 's/\<proxy0\>/devops1a-proxy0/g' /pitrix/conf/variables/global/*.yaml.devops1a
sed -i 's/\<proxy1\>/devops1a-proxy1/g' /pitrix/conf/variables/global/*.yaml.devops1a
sed -i 's/\<zoocassa0\>/devops1a-zoocassa0/g' /pitrix/conf/variables/global/*.yaml.devops1a
sed -i 's/\<zoocassa1\>/devops1a-zoocassa1/g' /pitrix/conf/variables/global/*.yaml.devops1a
sed -i 's/\<zoocassa2\>/devops1a-zoocassa2/g' /pitrix/conf/variables/global/*.yaml.devops1a
sed -i 's/\<dnsmaster0\>/devops1a-dnsmaster0/g' /pitrix/conf/variables/global/*.yaml.devops1a
sed -i 's/\<dnsmaster1\>/devops1a-dnsmaster1/g' /pitrix/conf/variables/global/*.yaml.devops1a
sed -i 's/\<webservice0\>/devops1a-webservice0/g' /pitrix/conf/variables/global/*.yaml.devops1a
sed -i 's/\<webservice1\>/devops1a-webservice1/g' /pitrix/conf/variables/global/*.yaml.devops1a

sed -i 's/\<boss\>/devops1a-boss/g' /pitrix/conf/variables/boss2/*.yaml.devops1a
sed -i 's/\<pgpool\>/devops1a-pgpool/g' /pitrix/conf/variables/boss2/*.yaml.devops1a
sed -i 's/\<zoocassa\>/devops1a-zoocassa/g' /pitrix/conf/variables/boss2/*.yaml.devops1a
sed -i 's/\<webservice\>/devops1a-webservice/g' /pitrix/conf/variables/boss2/*.yaml.devops1a
```

+ 将新环境的`global`目录中文件拷贝到旧环境的`global`目录:

```bash
# 同步
rsync -azPS new-firstbox:/pitrix/conf/variables/global/ /pitrix/conf/variables/global/
```

+ 修改`server.yaml.*`(`2`个`zone`都需要修改):

```bash
vim /pitrix/conf/variables/global/server.yaml.*
```

```yaml
common:
  public_user_services:
    # 此处需要包含 region 中所有 dnsmaster 的 IP 地址及 VIP 地址
    - '172.16.80.4/32'
    - '172.16.80.103/32'
    - '172.16.80.104/32'
    - '172.16.90.4/32'
    - '172.16.90.103/32'
    - '172.16.90.104/32'
  # 此处 ... 代表省略号，表示之前的配置不变，只是追加新的配置
  appcenter2_available_areas: "...,devops2,devops1a,devops2a"
  region_id: 'devops2'
  resource_limits:
    # 此处 ... 代表省略号，表示之前的配置不变
    ...
    devops2:
      bm_zones:
        - 'devops1a'
        - 'devops2a'
      neonsan_zones:
        - 'devops1a'
        - 'devops2a'
      public_zones:
        - 'devops1a'
        - 'devops2a'
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
      zones:
        - 'devops1a'
        - 'devops2a'
    # 此处 ... 代表省略号，表示之前的配置不变，只是追加新的配置
    zones: '...,devops2'
  zone_settings:
    # 仿造 devops2a 写出 zone_settings
    devops1a:
      backstore_replicas: 2
      # 当前 zone 的所有 snapshot 节点的 hostname
      backstore_servers:
        - 'devops1ar01n01'
        - 'devops1ar01n02'
      backstore_type: 'disk'
      fg_proxy: 'devops1a-proxy'
      # 当前 zone 的所有 seed 节点的 hostname
      image_sources:
        - 'devops1ar01n01'
        - 'devops1ar01n02'
      repl_zone: 'devops2a'
      # 当前 zone 的所有 vg 节点的 hostname
      virtual_gateways:
        - 'devops1ar01n03'
        - 'devops1ar01n04'
    devops2a:
      backstore_replicas: 2
      # 当前 zone 的所有 snapshot 节点的 hostname
      backstore_servers:
        - 'devops2ar01n01'
        - 'devops2ar01n02'
      backstore_type: 'disk'
      fg_proxy: 'devops2a-proxy'
      # 当前 zone 的所有 seed 节点的 hostname
      image_sources:
        - 'devops2ar01n01'
        - 'devops2ar01n02'
      repl_zone: 'devops1a'
      # 当前 zone 的所有 vg 节点的 hostname
      virtual_gateways:
        - 'devops2ar01n03'
        - 'devops2ar01n04'
  # 以下配置为预留合约，无预留合约无需添加，私有云一般都不需要添加
  reserved_resource:
    zones:
      bm_instance: '...,devops2'
      cluster: '...,devops2'
      dedicated_host_group: '...,devops2'
      instance: '...,devops2'
      volume: '...,devops2'

pg_watcher:
  pass

compute_server:
    # 防止误触发灾难迁移
    disable_hyperpair_rescue: 1
    enable_auto_healing: 0

# virtual_gateway 中包含当前 region 中所有的 vg 节点的配置
virtual_gateway:
  global:
    has_eip_rule: 0
    has_tc_rx: 1
    has_tc_tx: 1
    min_tc_rx: 10
    pps_rx_alert: 100000
    pps_rx_alert_action: 'warn'
    rx_bandwidth_percent: 100
  devops1ar01n03:
    eips:
      172.18.80.0/24: '172.18.80.2(172.18.80.1)'
    mgmt_ip: '172.16.80.13'
    user_ip:
      10.10.0.0/16: '172.16.80.13'
  devops1ar01n04:
    eips:
      172.18.80.0/24|HA0: '172.18.80.3(172.18.80.1)'
    mgmt_ip: '172.16.80.14'
    user_ip:
      10.10.0.0/16: '172.16.80.14'
  devops2ar01n03:
    eips:
      172.18.90.0/24: '172.18.90.2(.1)'
    mgmt_ip: '172.16.90.13'
    user_ip:
      10.10.0.0/16: '172.16.90.13'
  devops2ar01n04:
    eips:
      172.18.90.0/24|HA0: '172.18.90.4(.1)'
    mgmt_ip: '172.16.90.14'
    user_ip:
      10.10.0.0/16: '172.16.90.14'
```

+ 仿造`postgresql.yaml.devops1a`配置文件修改`postgresql.yaml.devops2a`中的`password`

```bash
vim /pitrix/conf/variables/global/postgresql.yaml.devops2a
```

+ 将配置刷新到所有节点:

```bash
/pitrix/build/build_pkgs.py -p pitrix-global-conf
/pitrix/upgrade/update.sh all pitrix-global-conf
```

### 更新数据库

+ 更新`account`数据库:

```sql
update console set zones = zones ||',devops2a,devops2' where console_id = 'devopscloud';
```

+ 更新`global`数据库:

```sql
\c global
INSERT INTO user_zone (user_id, zone_id, privilege, role) VALUES ('admin', 'devops2', 10, 'global_admin');
INSERT INTO user_zone (user_id, zone_id, privilege, role) VALUES ('admin', 'devops2a', 10, 'global_admin');
UPDATE user_zone SET default_in_region='devops2' WHERE zone_id='devops1a';

INSERT INTO region (region_id, region_name) VALUES ('devops2', 'DEVOPS2');
UPDATE zone SET region_id='devops2' WHERE zone_id='devops1a';
INSERT INTO zone (zone_id, zone_code, status, front_gates, region_id) VALUES ('devops2a', '2', 'active', 'devops2a-proxy:8665', 'devops2');
```

+ 更新`zone`数据库:

```sql
UPDATE scheduler SET handle_server = 'devops1a-webservice0' WHERE handle_server = 'webservice0';
UPDATE scheduler SET handle_server = 'devops1a-webservice1' WHERE handle_server = 'webservice1';
UPDATE alarm_policy SET group_id= 'devops1a-webservice0' WHERE group_id= 'webservice0';
UPDATE alarm_policy SET group_id= 'devops1a-webservice1' WHERE group_id= 'webservice1';
```

### 配置DNS

+ 连接到`devops1a`的`dnsmaster`节点:

```bash
# 备份
cp -ar /etc/bind /etc/bind.$(date +%Y%m%d)

cp -a /etc/bind/db.devops1a.devopscloud.com /etc/bind/db.devops2.devopscloud.com
sed -i s/"devops1a"/"devops2"/g /etc/bind/db.devops2.devopscloud.com
```

+ 增加配置到`named.conf`:

```bash
vim /etc/bind/named.conf
```

```text
# internal zone
zone "devops2.devopscloud.com" {
    type master;
    file "db.devops2.devopscloud.com";

    # only allow local update
    allow-update { 127.0.0.1; };

};
```

+ `named.conf.options`配置中的`trusty`需要包含`region`中所有的`IP`段:

```bash
vim /etc/bind/named.conf.options
```

```text
acl "trusted" {
    172.16.0.0/16;
    10.0.0.0/8;
    localhost;
    localhost;
};
```

+ 重启服务:

```
service bind9 restart
```

### 配置HaProxy

+ 连接到`devops2a`的`proxy`节点:

```bash
vim /etc/haproxy/haproxy.cfg
```

```conf
listen api-front
    bind 0.0.0.0:7777
    mode tcp
    balance source
    # 指向 global 的 ws_server
    server  apiserver_0 172.16.80.105:7777 check
    server  apiserver_1 172.16.80.106:7777 check

listen ws-front
    bind 0.0.0.0:8565
    mode tcp
    balance roundrobin
    server  ws_server_0 172.16.80.105:8565 check
    server  ws_server_1 172.16.80.106:8565 check

listen io-front
    bind 0.0.0.0:8000
    mode tcp
    balance source
    server  io_server_0 172.16.80.105:8000 check
    server  io_server_1 172.16.80.106:8000 check
```

+ 重启服务:

```bash
service haproxy restart
```

### 合并数据库

+ 将所有`hyper`节点的状态设置为`standby`:

```bash
/pitrix/bin/modify_hyper_status.sh hyper standby
```

+ 关闭所有节点的服务:

```bash
/pitrix/upgrade/exec_nodes.sh all "supervisorctl stop all"
```

+ 连接到`devops1a`的`master`节点，导出数据库的所有数据:

```bash
su - postgres -c 'pg_dumpall -c > /tmp/devops1a.sql`
```

+ 连接到`devops2a`的`master`节点，导出`zone`数据库:

```bash
# 清空 service_ip_pool表, 避免ip冲突问题
psql zone
delete from service_ip_pool;
exit

pg_dump -a --column-insert -d zone -f /tmp/devops2a.sql
```

+ 在`devops1a`的`slave`节点停止掉旧的数据库:

```bash
# 14.04
service postgresql stop
sysv-rc-conf postgresql off
service postgresql status

# 16.04
systemctl stop postgresql.service
systemctl disable postgresql.service
systemctl status postgresql.service

# all
mkdir -p /backup/etc/{init.d,logrotate.d}
mkdir -p /backup/lib/systemd/system/
mv -f /etc/init.d/postgresql /backup/etc/init.d/
mv -f /lib/systemd/system/postgresql* /backup/lib/systemd/system/
mv -f /etc/postgresql /backup/etc/
mv -f /etc/postgresql-common /backup/etc/
mv -f /etc/logrotate.d/postgresql-common /backup/etc/logrotate.d
mv -f /pitrix/postgresql /pitrix/postgresql-bak

apt-get remove postgresql-9.3
apt-get remove postgresql-9.5
```

+ 在`devops1a`的`slave`节点清理旧的`crontab`:

```bash
# 查看
crontab -l
crontab -l -u postgres

# 清理有关数据库
crontab -e
crontab -e -u postgres
```

+ 在`devops1a`的`slave`节点安装新的数据库:

```bash
apt-get update
apt-get install pitrix-postgresql

# 14.04
service postgresql stop
# 16.04
systemctl stop postgresql.service

source /etc/profile.d/postgresql.sh
mv -f /opt/postgresql-${PG_VER} /pitrix/postgresql-${PG_VER}
chown -R postgres:postgres /pitrix/postgresql-${PG_VER}
ln -sf /pitrix/postgresql-${PG_VER} /opt/

# 172.16.0.0/16 改成 管理网的大段
echo "host    all    all    172.16.0.0/16    md5" >> /pitrix/postgresql-${PG_VER}/data/pg_hba.conf

# 14.04
service postgresql start

# 16.04
systemctl start postgresql.service


apt-get install pitrix-postgresql-tools pitrix-pg-watcher
```

+ 将之前`devops1a`导出的数据导入到新的数据库中:

```bash
rsync -azPS old-master:/tmp/devops1a.sql /tmp/

su - postgres -c 'psql -p 5433 -f /tmp/devops1a.sql'
```

+ 修改`devops1a`的`pgpool`的配置文件:

```bash
vim /etc/pgpool2/pgpool.conf
```

```conf
# 此处仅保留 backend_hostname0，值改为 devops1a 的新 PG 节点的主机名
backend_hostname0 = 'DEVOPS1A-PGSERVER'
backend_port0 = 5433
backend_weight0 = 1
backend_flag0 = 'DISALLOW_TO_FAILOVER'
backend_data_directory0 = '/opt/postgresql/data'
```

```bash
echo "host    all    all    172.16.0.0/16    md5" >> /etc/pgpool2/pool_hba.conf

rm -f /var/run/pgpool/.s.PGSQL.*
service pgpool2 restart
service pgpool2 status
```

+ 连接到`devops1a`的`webservice`节点，合并`devops2a`的数据:

```bash
rsync -azPS PGSERVER:/tmp/devops2a.sql /tmp/

# 此脚本需要使用源码，请联系Installer
# 脚本未报错的话，则执行成功，会有文件 devops2a.sql.untouched 产生，此文件记录了未执行的 sql，一般是记录已存在引起的，如未报错可忽略
/pitrix/lib/pitrix-scripts/region/merge_zone/import_db.py /tmp/devops2a.sql
```

+ 参照`devops1a`的`pgpool`节点的配置修改所有的`pgpool`节点:

```bash
# backend_hostname0
vim /etc/pgpool2/pgpool.conf
# 密码
vim /etc/pgpool2/pool_passwd

rm -f /var/run/pgpool/.s.PGSQL.*
service pgpool2 restart
service pgpool2 status
```

+ 在`devops1a`的`slave`节点创建`PG`集群:

```bash
/opt/postgresql/work/pg_upmaster DEVOPS2A-PGSERVER
```

+ 停止掉`devops1a`的`master`节点的`PG`服务。

```bash
# 14.04
service postgresql stop
sysv-rc-conf postgresql off
service postgresql status

# 16.04
systemctl stop postgresql.service
systemctl disable postgresql.service
systemctl status postgresql.service

# all
mkdir -p /backup/etc/{init.d,logrotate.d}
mkdir -p /backup/lib/systemd/system/
mv -f /etc/init.d/postgresql /backup/etc/init.d/
mv -f /lib/systemd/system/postgresql* /backup/lib/systemd/system/
mv -f /etc/postgresql /backup/etc/
mv -f /etc/postgresql-common /backup/etc/
mv -f /etc/logrotate.d/postgresql-common /backup/etc/logrotate.d
mv -f /pitrix/postgresql /pitrix/postgresql-bak
```

+ 停止掉`devops2a`的`1`台`pgserver`:

```bash
systemctl stop postgresql.service
systemctl disable postgresql.service
systemctl status postgresql.service
```

+ 连接到`devops1a`的`webservice`节点，更新`billing`记录:

```bash
/pitrix/lib/pitrix-scripts/region/merge_zone/billing_change_zone -z devops1a -r devops2 -U
```

+ 在`firstbox`上, 修改`settings`文件中的角色，将`devops1a`中的`pgmaster`去掉，然后将`pgslave`改为`pgserver`，将`devops2a`中的一个`pgserver`去掉。

```bash
/pitrix/bin/gen_node_list.py
```

+ 在`firstbox`上启动非`hyper`节点的所有服务:

```bash
/pitrix/upgrade/exec_nodes.sh ks "supervisorctl start all"
/pitrix/upgrade/exec_nodes.sh vg "supervisorctl start all"
```

+ 检查服务运行状态，没有问题后，逐步启动`hyper`节点的服务:

```bash
/pitrix/upgrade/exec_nodes.sh hyper "supervisorctl start all"
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

### 还原配置

+ 检查所有的服务都运行正常后，允许接收新的任务:

```bash
vim /pitrix/conf/variables/global/server.yaml.devops1a
vim /pitrix/conf/variables/global/server.yaml.devops2a
```

```yaml
fg_server:
  # 允许 fg 接收新 job , 注意查找是否有同名配置
  disable_new_job: false

compute_server:
    disable_hyperpair_rescue: 0
    enable_auto_healing: 1
```

***
