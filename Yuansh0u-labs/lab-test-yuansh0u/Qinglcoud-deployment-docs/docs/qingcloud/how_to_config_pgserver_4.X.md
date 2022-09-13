### 简介

+ 由于`Installer4.X`默认以`Region`的方式部署青云平台，如何保证多`ZONE`之间的数据库的数据一致性呢?
+ 从`Installer4.X`开始，默认使用`PostgreSQL 10`作为数据库，通过新特性，主从同步写，都完成写入工作，才算完成，保证了数据的强一致性。
+ 从`Installer4.X`开始，使用`pgserver`标识数据库的角色，不再使用角色`pgmaster`和`pgslave`标识主从。
+ 从`Installer4.X`开始，默认不开启数据库的`HA`，如需开启，请参照本文档中的教程。

### 常用操作

#### 确认PGPOOL节点

+ 如何快速方便的确认一个环境中，哪些节点是`pgpool`节点呢，通过如下命令即可获取:

```bash
# qingcloud-firstbox
cat /pitrix/conf/nodes/pgpool
```

#### 确认PG节点

+ 如何快速方便的确认一个环境中，哪些节点是`pgserver`节点呢，通过如下命令即可获取:

```bash
# qingcloud-firstbox
cat /pitrix/conf/nodes/pgserver
```

#### 确认PG主节点

+ 当我们了解了哪些节点是`pgserver`节点后，我们该如何快速方便的确认一个环境中，哪一个节点是数据库的主节点呢?
+ 任选一个数据库节点，通过`SSH`连接上去。

+ 方式一:

```bash
# pgserver
cat /pitrix/run/pg_master
```

+ 方式二(详细):

```bash
# pgserver
/opt/postgresql/work/pg_overview
```

#### 服务状态

+ 如何确认`PostgreSQL`和`PGPool`的服务状态呢?

```bash
# Ubuntu 14.04
service pgpool2 status
service postgresql status

# Ubuntu 16.04
systemctl status pgpool2.service
systemctl status postgresql.service
```

+ 如何确认`PG`集群的服务状态:

```bash
/opt/postgresql/work/pg_overview
```

### 开启PG的HA(PG 10.X)

#### 服务架构

+ `PG`的宕机修复主要依靠`pg_watcher`服务，配置文件在`server.yaml.*`中。
+ `pg_watcher`服务会被安装到每一个`PG`节点。
+ 当`ZONE`的个数少于`3`个时，需要有`global`节点充当决策者。
    + 标准模式: 部署在`global zone`的`webservice`节点。
    + 融合模式: 部署在`ks0/1`所在的`Hyper`节点。
+ 当`ZONE`的个数等于或大于`3`个时，无需`global`节点充当决策者。
+ `pg_watcher`只负责宕机恢复，不负责将灾难节点恢复到集群中，需要人为介入。

#### PGPOOL

+ 从`Installer4.X`开始，不再使用`pgpool`的切换`PG`的主从，仅仅起到`PostgreSQL`连接池的作用，故配置文件仅存在主节点的连接信息。

```bash
vim /etc/pgpool2/pgpool.conf
```

```text
backend_hostname0 = 'devopsar01n01'
backend_port0 = 5433
backend_weight0 = 1
backend_flag0 = 'DISALLOW_TO_FAILOVER'
backend_data_directory0 = '/opt/postgresql/data'
```

#### 开启主从自动切换

+ 在`firstbox`上，修改所有的`ZONE`的`server.yaml.*`，将`inactive_failover`的值设置为`0`:

```bash
vim /pitrix/conf/variables/global/server.yaml.ZONE_ID
```

```text
pg_watcher:
  # global节点的信息, 若ZONE的个数多于2，无此配置
  globals: 'devopsar01n03,devopsar01n04'
  # 1: 禁用自动切换, 0: 启用自动切换
  inactive_failover: 0
  # 1: 启用灾难恢复(存在两个master时，将使用时间版本较新的作为master，旧master成为其slave节点) 0: 禁用灾难恢复
  using_master_by_ts: 0
  pg_node_info:
    devopsar01n01:
      zone_id: 'devops1a'
      pgpools: 'devopsar01n01,devopsar01n02'
    devopsar01n02:
      zone_id: 'devops1a'
      pgpools: 'devopsar01n01,devopsar01n02'
```

+ 重新构建包: `/pitrix/upgrade/build_global_conf.sh`
+ 下发配置: `/pitrix/upgrade/update.sh -f all pitrix-global-conf`

#### 服务状态

+ 如何确认`pg_watcher`的服务状态呢?

```bash
supervisorctl status pg_watcher
```

+ 查看`PGMonitor`:

```bash
cat /var/run/pg_watcher.PGMonitor
```

+ 查看`PGNode`:

```bash
cat /var/run/pg_watcher.PGNode
```

+ 若`status`为`active`或`available`均为正确，否则有错。

#### 开启测试

+ `pg_watcher`会持续判断`2`分钟后，才会有一个执行者去执行宕机恢复。
+ 当`slave`节点宕机，等待`2~3`分钟后，自动将该节点从集群中踢出。
+ 当`master`节点宕机，等待`2~3`分钟后，自动将该节点从集群中踢出，并选举一个`slave`节点作为新的`master`节点，并更新`pgpool`的配置文件。

#### 人为修复

+ 当启用灾难恢复时，即`using_master_by_ts`的值为`1`，无需人为修复，只需确认`PG`集群的状态即可。
+ 将旧的`master`节点修复好之后，启动主机后。
+ 登录到新的`master`节点，通过以下命令，将旧的`master`节点以`slave`的角色加入到集群中。

```bash
/opt/postgresql/work/pg_upmaster OLD_MASTER_HOSTNAME
```

+ 若`pgpool`节点与宕机的`pgserver`节点为同一节点，还需要更新`pgpool`的配置文件并重启服务。

+ 修复好之后，可以通过之前的文档，确认各服务的状态。

***

### 开启PG的HA(PG 9.X)
以下内容适用于installer 3.x中使用的PG 9.X版本。

#### 有关 pgserver 背景

* installer 从 3.3.1 开始默认开启数据库的 HA，后台有机器人处理 HA 之后的所有恢复逻辑，请知悉！

* 使用 installer 部署的青云平台, pgserver 架构采用 2 pgpool + 2 postgresql (pgmaster pgslave) 组成, 默认配置下 pgpool 仅仅起了 postgresql 连接池的作用。
* pgpool 还有监控并且切换 pgmaster pgslave 的能力，但是由于切换后，pgpool 中的主从节点会和 postgresql 的主从节点颠倒，造成切换后的主从数据不一致，故默认关闭此自动切换。
* 默认配置下（即关闭 pgool 的主从切换），pgslave 节点断掉不会影响平台任何功能，但是 pgmaster 节点断掉，平台立刻挂掉，需要人工介入恢复 pgmaster 节点。
* 在工程师的现场配合下，我们可以开启 pgool 的监控与切换能力，用以解决 pgmaster 节点挂掉之后整个平台服务停止的问题，具体方法请参考此 guide。

#### 开启 pgpool 主从切换

* 开启 pgpool 的主从切换能力

    登录 pgpool0(ks0) 和 pgpool1(ks1)，修改 /etc/pgpool2/pgpool.conf 文件
    修改如下两项如下：

    ```
    backend_flag0 = 'ALLOW_TO_FAILOVER'
    backend_flag1 = 'ALLOW_TO_FAILOVER'
    ```

    或者，使用下面的命令一键完成修改
    `sed -i "s/DISALLOW_TO_FAILOVER/ALLOW_TO_FAILOVER/g" /etc/pgpool2/pgpool.conf`

    修改成功后，重启服务
    `service pgool2 restart`

* 断掉 pgmaster，开启测试

    可以观察到，通过 pgpool 依然可以连接 pgserver，平台正常工作, pgserver HA 功能生效。

    一段时间后，恢复断掉的 pgmaster 节点，通过 pgpool 登录到数据库 `show pool_nodes;` 命令看到主从已经完成切换。
    登录到 老pgslave (新pgmaster) 节点，`ls /var/lib/postgresql/9.3/main/`，目录中存在 recovery.done 文件。

#### 调整 postgresql 主从配置

##### 方法一： 执行脚本
* 在fb上创建脚本文件`/pitrix/bin/auto_failover.sh`, 赋予其执行权限`chmod +x /pitrix/bin/auto_failover.sh`, 复制下面脚本到文件中：

```bash
#!/bin/bash
# This script is used for auto executing the pg post failover actions
# Installer version should be 3.X
# Usage: ./auto_failover.sh

cat << EOF > /tmp/set_pg_post_failover.sh
if [[ ! -f /var/lib/postgresql/bin/utils.sh ]]; then
    echo "Error: File /var/lib/postgresql/bin/utils.sh does not exist!"
    exit 1
fi
if [[ ! -f /pitrix/ks/pgserver/conf/pgserver_hosts ]]; then
    echo "Error: File /pitrix/ks/pgserver/conf/pgserver_hosts does not exist!"
    exit 1
fi
. /var/lib/postgresql/bin/utils.sh
pgservers=(\$(cat /pitrix/ks/pgserver/conf/pgserver_hosts))
pgserver0=\${pgservers[0]}
pgserver1=\${pgservers[1]}
install_failover_cron \$pgserver0 \$pgserver1

# backup scripts
if [[ ! -f /var/lib/postgresql/bin/auto_post_failover.done ]]; then
    cp /var/lib/postgresql/bin/configure_master.sh /var/lib/postgresql/bin/configure_master.sh.bak
    cp /var/lib/postgresql/bin/configure_slave.sh /var/lib/postgresql/bin/configure_slave.sh.bak
    cp /var/lib/postgresql/bin/post_failover.sh /var/lib/postgresql/bin/post_failover.sh.bak

    # edit scripts
    sed -i '/install_failover_cron/d' /var/lib/postgresql/bin/configure_master.sh
    sed -i '/install_failover_cron/d' /var/lib/postgresql/bin/configure_slave.sh
    sed -i '/service pgpool2 restart/i\ssh root@\${pgpool_server} "pgpool -m fast stop"' /var/lib/postgresql/bin/post_failover.sh
    sed -i '/service pgpool2 restart/i\ssh root@\${pgpool_server} "rm /var/lib/pgpool/.s.PGSQL.*"' /var/lib/postgresql/bin/post_failover.sh
    sed -i 's/service pgpool2 restart/service pgpool2 start/g' /var/lib/postgresql/bin/post_failover.sh
    touch /var/lib/postgresql/bin/auto_post_failover.done
fi
EOF

chmod +x /tmp/set_pg_post_failover.sh
. /pitrix/conf/nodes/pgmaster
pgmaster=$nodes
. /pitrix/conf/nodes/pgslave
pgslave=$nodes

ssh $pgmaster "scp firstbox:/tmp/set_pg_post_failover.sh /tmp/; /tmp/set_pg_post_failover.sh"
ssh $pgslave "scp firstbox:/tmp/set_pg_post_failover.sh /tmp/; /tmp/set_pg_post_failover.sh"
```

* 运行命令`/pitrix/bin/auto_failover.sh`即可，第一次执行完后，以后再进行`开启 pgpool 主从切换`的操作后，即可自动完成`调整 postgresql 主从配置`，无需手动操作步骤;

* 如不记得是否已运行过该脚本，可以查看是否存在文件`/var/lib/postgresql/bin/auto_post_failover.done`， 如已存在，则无需运行脚本;

* 该脚本可重复运行，不会造成影响;

##### 方法二： 手动操作
* 如不选用方法一，也可以在每次完成`开启 pgpool 主从切换`的操作后，按以下步骤操作

* 删除主从切换触发文件

    登录到 新pgmaster (老pgslave) 节点，`rm /tmp/postgres-failover.trigger`。

* 调整 新pgmaster 配置

    登录到 新pgmaster (老pgslave) 节点，停掉数据库 `service postgresql stop`。
    切换用户 `su postgres`，然后执行 `cd /var/lib/postgresql/bin; ./configure_master.sh <新pgmaster ip> <新pgslave ip>`。
    重启数据库 `service postgresql restart`。

    同步数据到 新pgslave (老pgmaster) 节点，执行 `cd /var/lib/postgresql/bin; ./base_backup.sh <新pgslave ip>`。

* 调整 新pgslave 配置

    登录到 新pgslave (老pgmaster) 节点，停掉数据库 `service postgresql stop`。
    切换用户 `su postgres`，然后执行 `cd /var/lib/postgresql/bin; ./configure_slave.sh <新pgslave ip> <新pgmaster ip>`。
    重启数据库 `service postgresql restart`。

* 校验配置是否正确

    在 postgresql 节点上执行 `ps -ef | grep -v grep | grep wal` 查看进程

    新pgmaster 节点可以看到如下，同时有 writer 和 sender

    ```
    root@ks0:~# ps -ef | grep -v grep | grep wal
    postgres 19435 19422  0 13:30 ?        00:00:00 postgres: wal writer process
    postgres 21826 19422  0 13:31 ?        00:00:00 postgres: wal sender process postgres 172.31.30.3(49298) streaming 0/A0569F8
    ```

    新pgslave 节点可以看到如下，只有一个 receiver

    ```
    root@ks1:~# ps -ef | grep -v grep | grep wal
    postgres  3298  3285  0 13:31 ?        00:00:01 postgres: wal receiver process   streaming 0/A0569F8
    ```

    并且在 新pgslave (老pgmaster) 节点，执行 `ls /var/lib/postgresql/9.3/main/`，目录中 有recovery.conf

* 调整 pgpool 的主从配置

    登录 pgpool0(ks0) pgpool1(ks1)，修改 /etc/pgpool2/pgpool.conf 文件
    修改如下两项如下：

    ```
    backend_hostname0 = '<新pgmaster hostname>'
    backend_hostname1 = '<新pgslave hostname>'
    ```

    修改成功后，重启服务
    `service pgool2 restart`
