### 0 部署平台相关
#### 获取节点的详细信息

+ 获取所有节点的详细信息: `/pitrix/cli/describe-nodes.py`
+ 获取指定节点的详细信息：`/pitrix/cli/describe-nodes.py -n 'NODE_IDS'`
+ 更多其他用法，请使用`-h`参数获取：`/pitrix/cli/describe-nodes.py -h`

#### 修改节点的详细信息

+ 修改节点的数据磁盘列表：`/pitrix/cli/modify-node-attributes.py -n 'n-1DmMkv6L' -a '["sdc", "sdd"]'`。
+ 更多其他用法，请使用`-h`参数获取：`/pitrix/cli/modify-node-attributes.py -h`

#### 修改 NeonSAN 集群参数
`neonsan create_pool --pool vol`  
`neonsan set_parameter --parameter auto_recovery --value 1`  
`neonsan set_parameter --parameter auto_balance --value 1`  
`neonsan create_rg -rg default`  
`neonsan add_rg_node -rg default -store_id xx` (store_id 可以用 neonsan list_store 获取)  
+ 注意: 混插节点和全闪节点不能加入同一个 rg , 需要创建不通的 rg 来添加  

### 1 日常维护
#### 关机与开机
关机然后再开机，保证NeonSAN状态不变，不引起降级的步骤如下:  
* 关闭neonsan集群的步骤
    1. 关闭client，保证没有IO，如Oracle应用
    2. 卸载volume，如qbd/qemu等
    3. 保留一份MySQL plus的元数据
    4. 关闭center
    5. 关闭store
    6. 关机
* 启动neonsan集群的步骤
    1.开机
    2.检查MySQL plus集群状态；检测费zookeeper集群状态
    3.启动store
    4.启动center
    5. 检查NeonSAN集群状态：neonsan list_store/neonsan list_volume/ neonsan list_ssd
    6.挂载volume
    7.启动client， 先启动部分client，验证OK，启动剩余client