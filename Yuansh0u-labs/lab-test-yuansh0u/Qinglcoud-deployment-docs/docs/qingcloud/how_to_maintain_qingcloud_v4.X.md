### 部署平台相关

#### 获取节点的详细信息

+ 获取所有节点的详细信息: `/pitrix/cli/describe-nodes.py`
+ 获取指定节点的详细信息：`/pitrix/cli/describe-nodes.py -i '172.16.80.3'`
+ 更多其他用法，请使用`-h`参数获取：`/pitrix/cli/describe-nodes.py -h`

#### 修改节点的详细信息

+ 修改节点的磁盘类型：`/pitrix/cli/modify-node-attributes.py -i 172.16.80.3 -d sdb -t ssd`。
+ 修改节点的磁盘容量：`/pitrix/cli/modify-node-attributes.py -i 172.16.80.3 -d sdc -S 3200.00`。
+ 修改节点的磁盘状态：`/pitrix/cli/modify-node-attributes.py -i 172.16.80.3 -d sdd -s 0`。
+ 更多其他用法，请使用`-h`参数获取：`/pitrix/cli/modify-node-attributes.py -h`

#### 融合部署模式下，怎么处理`pitrix`目录空间不足的问题？

+ 1 `hyper-local/hyper-pair`节点，采用软链接形式处理:

+ 1.1 `seed/vbr`角色:

```text
rm -rf /pitrix/images-repo
mkdir -p /pitrix/data/container/images-repo
ln -sf /pitrix/data/container/images-repo /pitrix/images-repo

mkdir -p /pitrix/data/container/image
ln -sf /pitrix/data/container/image /pitrix/data/image

mkdir -p /pitrix/data/container/image_nbd
ln -sf /pitrix/data/container/image_nbd /pitrix/data/image_nbd

mkdir -p /pitrix/data/container/vbr
ln -sf /pitrix/data/container/vbr /pitrix/vbr
```

+ 1.2 `snapshot`角色:

```text
rm -rf /pitrix/snapshot
mkdir -p /pitrix/data/container/snapshot
ln -sf /pitrix/data/container/snapshot /pitrix/snapshot
```

+ 2 `hyper-repl`节点，采用软链接配合`zfs dataset`的形式处理(默认`Installer`已经处理):

+ 2.1 `seed/vbr`角色:

```text
rm -rf /pitrix/images-repo
mkdir -p /pitrix/data/container/images-repo
ln -sf /pitrix/data/container/images-repo /pitrix/images-repo
zfs create -o mountpoint=/pitrix/data/container/images-repo -o atime=off -o xattr=sa vpool/images-repo

mkdir -p /pitrix/data/container/image
ln -sf /pitrix/data/container/image /pitrix/data/image
zfs create -o mountpoint=/pitrix/data/container/image -o atime=off -o xattr=sa vpool/image

mkdir -p /pitrix/data/container/image_nbd
ln -sf /pitrix/data/container/image_nbd /pitrix/data/image_nbd
zfs create -o mountpoint=/pitrix/data/container/image_nbd -o atime=off -o xattr=sa vpool/image_nbd

mkdir -p /pitrix/data/container/vbr
ln -sf /pitrix/data/container/vbr /pitrix/vbr
zfs create -o mountpoint=/pitrix/data/container/vbr -o atime=off -o xattr=sa vpool/vbr
```

+ 2.2 `snapshot`角色:

```text
rm -rf /pitrix/snapshot
mkdir -p /pitrix/data/container/snapshot
ln -sf /pitrix/data/container/snapshot /pitrix/snapshot
zfs create -o mountpoint=/pitrix/data/container/snapshot -o atime=off -o xattr=sa vpool/snapshot
```

### 维护平台相关

#### 怎么样删除废弃资源

+ 如何删除废弃资源，包含"等待中"，"找不到租赁信息"等资源?
+ 此处拿虚拟机(`Instance`)举例，其他资源，也可以使用对应的`CLI`并配合上`--skip-unlease`参数使用。

+ 删除虚拟机，配合`-u`参数：

```text
./terminate-instances -i i-XXX -u 0
```

+ 对返回的`job_id`进行过滤，直到看到状态为成功：

```text
./describe-jobs -j j-XXX | grep "status"
```

+ 再对被删除虚拟机，进行销毁(`ceased`)操作：

```text
./cease-instances -i i-XXX
```

#### `Express`平台中，如何使用命令删除`VxNets`？

1. 连接到`webservice`节点上。
2. 切换目录到`/pitrix/cli/`。
3. 执行以下命令:

```text
./leave-router -r ROUTER_ID -v VxNet_ID --force
./describe_jobs -j JOB_ID
./delete-routers -r ROUTER_ID
./delete-vxnets -v VxNet_ID --force
```

#### 服务器无法连接外网`NTP`服务器, 如何同步时间？

1. 连接到`firstbox`服务器上。
2. 执行以下命令:

```text
/pitrix/upgrade/exec_nodes.sh all "date -s '2018-09-01 12:00:00'"
/pitrix/upgrade/exec_nodes.sh all 'hwclock -w'
/pitrix/upgrade/exec_nodes.sh all 'supervisorctl restart all'
```

#### 怎么修改`VLAN`模式的网关地址？

+ 在建立私有网络之前，修改`server.yaml`里的相关配置，如果没有，请手动添加：

```text
common:
    vbc_gateway_addr: '.1'
    vbc_vlan_dhcp_addr: '.254'
```

+ 默认使用`XXX.XXX.XXX.1`为私有网络网关，`XXX.XXX.XXX.254`为私有网络`dhcp server`地址。
+ 按需修改成自己需要的地址，注意两个地址不要冲突。
+ 修改后刷新`global-conf`到各个节点，并且重启所有服务：

```text
/pitrix/bin/sync.sh
/pitrix/upgrade/update.sh all pitrix-global-conf
/pitrix/upgrade/exec_nodes.sh all 'supervisorctl restart all'
```

+ 在建立私有网络之后，修改`Iass`的数据库，修改`zone`库`router_vxnet`表的信息：

```text
manager_ip: 网关地址
dhcp_server_ip: dhcp server 地址
dyn_ip_start: dhcp 地址池起始地址
dyn_ip_end: dhcp 地址池结束地址
```

+ 修改后，需要使用`cli`重建下私有网络: `./migrate_vxnets -v VxNet_ID`。

#### 如何修复`VLAN`模式下`VPC`内网`IP`显示为`192.168.255.254`？

+ 在`firstbox`上直接修改`server.yaml`。
+ 找到字段 `vm_network: '0.0.0.0/0'`, 将其改成基础网络的大段, 比如 `'10.0.0.0/8'`。
    + `/pitrix/bin/sync.sh`
    + `/pitrix/upgrade/update.sh all pitrix-global-conf`
    + `/pitrix/upgrade/exec_nodes.sh webservice 'supervisorctl restart fg_server'`
+ 修改后刷新`console`到`vpc`页面检查。

#### 如何修复`hyper-pair`部署完成后`drbd-overview`显示状态不正常？

+ 方式`1`: 使用`Installer`提供的脚本修复(**推荐使用**):
  + 首先，将需要修复的`2`个节点上的资源全部迁移走。
  + 然后，将`rc.local`中有关`supervisord`自启动的命令注释掉。
  + 最后，重启节点，观察`drbd`的状态，若状态一致则按下方步骤继续进行。

```bash
# 确保 devops1ar01n03 节点的 drbd 的状态如下
root@devops1ar01n03:~# drbd-overview
  0:devops1ar01n03/0  Unconfigured . .
  1:devops1ar01n04/0  Unconfigured . .

# 确保 devops1ar01n04 节点的 drbd 的状态如下
root@devops1ar01n04:~# drbd-overview
  0:devops1ar01n04/0  Unconfigured . .
  1:devops1ar01n03/0  Unconfigured . .

# 查看脚本的帮助信息
root@qingcloud-firstbox:~# /pitrix/bin/repair_drbd.sh -h

# 恢复一组 drbd 资源
root@qingcloud-firstbox:~# /pitrix/bin/repair_drbd.sh -p devops1ar01n03 -s devops1ar01n04

# 正确的返回的结果
root@devops1ar01n03:~# drbd-overview
  0:devops1ar01n03/0  Connected Primary/Secondary UpToDate/UpToDate /pitrix/data/container ext4 99G 61M 99G 1%
  1:devops1ar01n04/0  Unconfigured . .

root@devops1ar01n04:~# drbd-overview
  0:devops1ar01n04/0  Unconfigured . .
  1:devops1ar01n03/0  Connected Secondary/Primary UpToDate/UpToDate

# 恢复一组 drbd 资源
root@qingcloud-firstbox:~# /pitrix/bin/repair_drbd.sh -p devops1ar01n04 -s devops1ar01n03

# 正确的返回的结果
root@devops1ar01n03:~# drbd-overview
  0:devops1ar01n03/0  Connected Primary/Secondary UpToDate/UpToDate /pitrix/data/container ext4 99G 61M 99G 1%
  1:devops1ar01n04/0  Connected Secondary/Primary UpToDate/UpToDate

root@devops1ar01n04:~# drbd-overview
  0:devops1ar01n04/0  Connected Primary/Secondary UpToDate/UpToDate /pitrix/data/container ext4 99G 61M 99G 1%
  1:devops1ar01n03/0  Connected Secondary/Primary UpToDate/UpToDate

# 将 rc.local 中 supervisord 的自启动打开， 然后重启服务器，观察drbd的状态是否正常
```

+ 方式`2`: 手动修复的方法：

```text
# 假设A节点 -> B节点同步，A节点为primary，B节点为secondary

# A节点的当前状态
0:A/0  Connected Unconfigured/Unconfigured UpToDate/UpToDate

# B节点的当前状态
0:A/0  Connected Unconfigured/Unconfigured UpToDate/UpToDate

# 将2个节点的`compute_agent`服务停止
supervisorctl stop compute_agent

# 将2个节点的垃圾信息删除掉
rm -f /etc/drbd.d/{*.init*,*.rebuild}

# 清除磁盘的脏数据，按照实际情况修改 of 后的磁盘
dd if=/dev/zero of=/dev/intelcas1-1p1 bs=1M count=128

# A节点，执行如下操作
umount /pitrix/data/container
drbdadm down A

# B节点，执行如下操作
drbdadm down A
drbdadm -- --force create-md A
drbdadm up A

# A节点，执行如下操作
drbdadm down A
drbdadm -- --force create-md A
drbdadm up A
drbdadm -- --clear-bitmap new-current-uuid A
drbdadm primary --force A/0

## 通过如下命令，确认磁盘格式，若存在该文件，则为ext4格式
ll /etc/qingcloud/drbd_with_ext4

## 若为ext4，请使用如下命令
mkfs.ext4 -q -E nodiscard,lazy_itable_init=0,lazy_journal_init=0 -O sparse_super,large_file -m 0 -i 67108864 /dev/drbd0
mount -t ext4 -o defaults,noatime /dev/drbd0 /pitrix/data/container

## 若非ext4，请使用如下命令(老环境)
mkfs.xfs -f -K /dev/drbd0
mount -t xfs -o defaults,allocsize=16m,noatime,nobarrier /dev/drbd0 /pitrix/data/container

# A节点的正确状态
0:A/0  Connected Primary/Secondary UpToDate/UpToDate /pitrix/data/container xfs 1.5T 33G 1.5T 3%

# B节点的正确状态
0:A/0  Connected Secondary/Primary UpToDate/UpToDate

# 将2个节点的`compute_agent`服务启动
supervisorctl start compute_agent
```

+ 方式`3`: `rebuild`方法:
    1. 将两边的`compute_agent`停掉，`supervisorctl stop compute_agent`。
    2. 在两边确保`/pitrix/data/container`没有`mount`，如果已经加载，运行 `umount /pitrix/data/container`。
    3. 运行 `drbdadm down xxx` 将`xxx`节点`drbd`停掉。
    4. 再去 `touch /etc/drbd.d/xxx.rebuild`，然后重启`compute_agent`就会正常做`rebuild`。

#### 如何升级一个`Hyper`节点的`kernel`?

```text
apt-get update

# update kernel
apt-get -y --force-yes install --reinstall linux-headers-4.4.0-116 linux-headers-4.4.0-116-generic linux-image-4.4.0-116-generic linux-image-extra-4.4.0-116-generic

# update nic driver
apt-get -y --force-yes install --reinstall pitrix-dep-ixgbe-driver pitrix-dep-mlx-driver pitrix-dep-intel-i40e-driver

# reboot
reboot --force-reboot

# update kernel module
apt-get -y --force-yes install --reinstall pitrix-dep-spl pitrix-dep-zfs shannon-module-4.4.0-116-generic pitrix-dep-drbd pitrix-dep-cfs-rq-cleanup pitrix-dep-zfs-dnode-dest lxcfs pitrix-dep-iscsi-trgt

# 若无该文件，请重启iscsitarget服务
ls /proc/net/iet/volume
service iscsitarget restart

# reboot
reboot --force-reboot

# enable new zpool features
zpool upgrade vpool
```

#### 如何替换 QingCloud Logo

+ 如果只是清除 QingCloud Logo, 在 firstbox 上执行 `/pitrix/bin/replace_logo.sh -r all`

+ 如果需要替换成客户自己的 logo
  - 将客户自己的 logo 文件放在 firstbox 节点 /pitrix/custom/logo/ 目录下, 分别重命名为 home_logo.svg, logo_en.svg, favicon.ico
    * home_logo.svg 对应的是登录页的 logo
    * logo_en.svg 对应的是控制台左上角的 logo
    * favicon.ico 对应的是浏览器选项卡上的图标
  - 在 firstbox 节点执行 `/pitrix/bin/replace_logo.sh -r all -c` 将 logo 替换为客户自定义的
  - 另外, 可以通过指定 -w 参数来修改某个logo的大小, 例如执行 `/pitrix/bin/replace_logo.sh -r home_logo -c -w 200` 可以将 home_logo 的大小修改为 200px
  - logo 的跳转链接可以执行 `/pitrix/bin/replace_logo.sh -l <link>` 来修改


#### 跨区迁移服务相关

+ 如果私有云部署了跨区迁移服务并且涉及到了`region`, 需要调整`transit`的配置

```
## 假设 Region pek3 包含 pek3b / pek3c / pek3d 三个 zone , 所以还需要针对这三个 zone 做一个软链，指向 region 的目录
root@pek3a_migration_transit:/pitrix/resource_migration/resources# ls -lht | grep pek3
drwxr-xr-x 23 root root 4.0K Mar 31 03:00 pek3
drwxr-xr-x 14 root root 4.0K Mar 31 03:00 pek3a
lrwxrwxrwx  1 root root    4 Jun  8  2018 pek3d -> pek3
lrwxrwxrwx  1 root root    4 Jun  8  2018 pek3c -> pek3
lrwxrwxrwx  1 root root    4 Jun  8  2018 pek3b -> pek3
```

#### 如何对hyper下线

+ hyper下线大致分为永久下线和临时维护下线
  + 通用操作
    + 下线前，需要将节点上的资源都迁移到其他节点，包括`vm`、`vpc`和`volumes`等(在`webservice`节点执行):
      + 迁移操作: 可以通过`boss`或者后台`cli`执行`migrate-instances`来做
      + 迁移`netns`以及其他资源: `cd /pitrix/cli; ./migrate-hyper-node -H HOSTNAME`
      + 观察任务状态: `cd /pitrix/cli; ./describe-jobs -j j-XXXX`

  + 临时维护下线
    + 将`hyper`状态置为`down`(在`firstbox`节点执行):
    + `/pitrix/bin/modify_hyper_status.sh HOSTNAME down`
    + 关机维护(如果不想要告警可以 mv alert-agent)
    + 维护好之后将状态改为`active`

  + 永久下线:
    + 将`hyper`状态置为`deprecated`(在`firstbox`节点执行):
      + `/pitrix/bin/modify_hyper_status.sh HOSTNAME deprecated`
      + 如果`cli`没有这个状态可以`update`数据库
    + 在`firstbox`上将对应的`setting`文件移动到备份目录中。
    + 更新`/pitrix/conf/node`目录, 执行`/pitrix/bin/gen_node_list.sh`。
    + 删除`firstbox`中数据库的数据: `/pitrix/cli/delete-nodes.py -i IP -f`
    + 更新所有节点的`hosts`:
      + 构建包: `/pitrix/build/build_pkgs.py -p pitrix-host`。
      + 更新包: `/pitrix/upgrade/update.sh all pitrix-host`。

#### hyper故障重装(其他角色类似)

+ 如果重装了系统需要重新做免秘钥
  + `/pitrix/bin/establish_ssh.sh ip`
  + 由于是故障下线,所以原来的节点信息在环境中都有, 只需要检查`settings`以及到节点上确认基本信息, 比如`os_version/disk_id/interface_name`等
  + 安装基础依赖包
    + `tmux`
    + `/pitrix/install/install_nodes.sh xxx`
  + 检查是否正常
    + /pitrix/upgrade/exec_nodes.sh xxx "supervisorctl status"
    + hyper还需要检查 zpool/drbd 的信息
  + 刷hyper包(其他角色类似) `/pitrix/upgrade/update.sh xxx pitrix-hyper,hyper`
  + 如果环境支持 NeonSAN，则需要额外部署 NeonSAN 对应的包`/pitrix/upgrade/update.sh xxx pitrix-neonsan-conf`
  + 如果部署了cronus, 则需要安装cronus相关服务 `/pitrix/upgrade/update_nodes.sh xxx pitrix-cronus-telegraf,pitrix-cronus-telegraf-resource`
  + 执行巡检脚本
    `python /pitrix/check/check.py -n xxx -v`
  + 测试通过后将`hyper`状态改成`active`


#### appcenter的镜像

##### 导入APP

```bash
## 1. 将镜像放在物理节点节点
## 2. 在任意一个 webservice 节点导入镜像
## 3. 若为 SDS 1.0，请指定 -C kvm。
## 方式一: migrate_appcenter2_apps: 按照需求拆分出常用的 APP，导入时，仅支持子目录
## 方式二: migrate_appcenter2_qingcloud: 包含 QingCloud 所有的 APP
/pitrix/lib/pitrix-scripts/appcenter2/import_apps -s root@NODE_HOSTNAME:/root/migrate_appcenter2_qingcloud/ -y -c CONSOLE_ID -C kvm --isolate-billing 1
/pitrix/lib/pitrix-scripts/appcenter2/import_apps -s root@NODE_HOSTNAME:/root/migrate_appcenter2_apps/migrate_appcenter2_mongodb/ -y -c CONSOLE_ID -C kvm --isolate-billing 1
```

```bash
## 1. 在 firstbox 节点批量重启 billing_resource 服务
/pitrix/upgrade/exec_nodes.sh -f webservice 'supervisorctl restart billing_resource'
```

##### 清理APP

```bash
## 1. 连接到 pgserver 节点
su - postgres
su - postgres -c "psql -c \"delete from app;\" -d global -U postgres"
su - postgres -c "psql -c \"delete from app_version;\" -d global -U postgres"
su - postgres -c "psql -c \"delete from app_approved;\" -d global -U postgres"
su - postgres -c "psql -c \"delete from app_version_image;\" -d global -U postgres"
su - postgres -c "psql -c \"delete from app_approved_version;\" -d global -U postgres"
```

***

#### 如何修复ICAS SUPERBLOCK
假如cas无法启动，在kernel log里面打印下面的错误，可以试试使用crc-fix这个工具修复。
```
Oct 30 15:25:48 devops1ar01n02 kernel: [Intel(R) CAS] Loading runtime super block ERROR, invalid checksum
 
Oct 30 15:25:48 devops1ar01n02 kernel: [Intel(R) CAS] Metadata read FAILURE
 
Oct 30 15:25:48 devops1ar01n02 kernel: [Intel(R) CAS] Metadata Error
 
Oct 30 15:25:48 devops1ar01n02 kernel: [Intel(R) CAS] ERROR: Cannot load cache state
```
1. 备份superblock, 以防无法修复时恢复到初始状态。示例里面nvme0n1是ssd缓存盘（cache device）:
```dd if=/dev/nvme0n1 of=~/superblock.bin bs=4k count=1 iflag=direct```
2. 运行修复工具:
```./crc-fix fix /dev/nvme0n1```
3. 启动cas:
```intelcas start```

工作原理:
superblock是cas保存文件信息的区域，大小4k，每次往盘里写文件时，会修改这块的数据。假如这部分数据出现错误，cas无法启动。
这个工具能够重新计算checksum值，让cas能启动，但是不能保证数据一定能恢复。