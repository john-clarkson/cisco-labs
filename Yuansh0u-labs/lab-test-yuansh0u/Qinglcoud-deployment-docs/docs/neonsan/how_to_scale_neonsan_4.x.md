### 1 准备硬件环境

#### 1.1 服务器和系统

1. 服务器和系统的要求参见 docs/how_to_deploy_neonsan_4.x.md。

#### 1.2 扩容注意事项

1. 目前扩容只适用于扩容 neonsan-center/neonsan-store 节点。
2. 扩容和升级/维护是互斥操作，扩容时候建议终止其它操作。
3. 扩容目前只支持 installer 20180731 之后的版本。

### 2 扩容 Neonsan

#### 2.1 收集硬件信息

* 建立 ip_list 文件，放入待扩容节点的 ip，一行一个  
    `vim /root/ip_list`  

* 进入 /pitrix/cli 目录，添加节点  
    `/pitrix/cli/add-nodes.py -I /root/ip_list`  
    可以利用 `/pitrix/cli/describe_nodes.py -s new` 来查看添加的节点  

* 如果节点不是默认的用户名和密码(yop/zhu1241jie), 需要执行脚本建立节点直接的 ssh 无密码访问  
    `/pitrix/bin/establish_ssh.sh /root/ip_list ssh_port username passwd`  
    日志文件为 /pitrix/log/node/establish_ssh.log  

* 收集硬件信息  
    `/pitrix/cli/collect-nodes.py -I /root/ip_list`  
    可以利用`/pitrix/cli/get-collect-nodes-status.py` 来查看收集节点的状态  
    可以利用`/pitrix/cli/get-collect-nodes-log.py` 来查看收集节点的简略日志  
    详细日志文件为 /pitrix/log/node/collect.log  
    在正式部署之前，该收集程序可以重复执行以修正硬件信息的错误；正式部署之后，建议不要再次执行，如有硬件信息错误需要去数据库修改  

    **注意**  
    1) 如果待收集节点数据磁盘有脏数据，可能会导致收集硬件信息失败，建议收集前格式化一下待部署节点数据磁盘  
    也可以使用 installer 提供的工具，/pitrix/bin/erase_data_disks.sh，-h 可以查看帮助  
    `/pitrix/bin/erase_data_disks.sh -i /root/ip_list -d nvme0n1`  
    日志文件为 /pitrix/log/node/erase_data_disks.log  

* 校验硬件信息  
    可以登录到 firstbox 节点的 postgresql 数据库的 installer 库 node 表，查看各个节点的硬件信息，也可以按需修改硬件信息，以匹配部署要求  
    也可以到每个待部署节点的 /root/collect 目录，查看目录里的 xxx.json 文件，来校验硬件信息是否有问题，如有想修改，依旧需要登录数据库来修改

#### 2.3 配置 Neonsan

* 进入 /pitrix/config 目录，从 templates 目录的 roles.conf.template 拷贝一个 roles.conf 出来  
    `cp /pitrix/config/templates/roles.conf.template /root/roles.conf`  
    按照模板里的说明，按需为每个待部署节点分配角色  

* 生成配置文件  
    `/pitrix/cli/config-neonsan.py -r /root/roles.conf`  
    可以利用`/pitrix/cli/get-config-neonsan-status.py` 来查看执行状态  
    可以利用`/pitrix/cli/get-config-neonsan-log.py` 来查看收集执行简略日志  
    详细日志文件为 /pitrix/log/config/settings.log  
    
    **注意：**  
    1) 如果反复执行 settings 生成程序，请务必将旧的垃圾 settings 移除掉(注意只能删除扩容节点的settings,别删多了)，并执行 `rm -f /pitrix/config/neonsan_ip_reserved.json`  
    2) 生成 settings 后需要手动修改 server_chassis 参数以符合实际情况(在同一机箱内的机器配置相同的 server_chassis )  

* 校验 settings 文件  
    /pitrix/conf/settings 里的文件要符合配置预期，可以按需修改部分项目，使之更加匹配安装要求  

#### 2.4 扩容 Neonsan

* 扩容 neonsan  
    `/pitrix/cli/scale-neonsan.py -I /root/ip_list`  
    可以利用`/pitrix/cli/get-scale-neonsan-status.py` 来查看执行状态  
    可以利用`/pitrix/cli/get-scale-neonsan-log.py` 来查看收集执行简略日志  


#### 2.5 检查测试环境

* 如果服务都起不来就在其中一个 neonsan 节点, 执行  
    `qfcip`  
    得到输出, 然后登录到输出 ip 的节点,重启下 neoncenter  
    `supervisorctl restart neoncenter`  

* 检查扩容节点的服务  
    `/pitrix/upgrade/exec_nodes.sh xxx "supervisorctl status"`  
    如果所有的服务都是保持 RUNNING 即部署正常，如果出现 STARTING BACKOFF 等其它状态，说明部署出现问题，需要修复后才能测试  
    如果 neonstore 一直起不来,可能是 ssd 盘不干净需要清理, /pitrix/bin/erase_data_disks.sh 脚本可以用但是只清理开头的1G  

* 检查 neonsan  
    在任一扩容节点上 `neonsan list_store && neonsan list_ssd && neonsan list_port && neonsan list_pool && neonsan list_parameter`  
    检查输出是否符合实际情况,另外 list_pool 包含 vol ; list_parameter 包含 auto_recovery 为 1 , auto_balance 为 0  

