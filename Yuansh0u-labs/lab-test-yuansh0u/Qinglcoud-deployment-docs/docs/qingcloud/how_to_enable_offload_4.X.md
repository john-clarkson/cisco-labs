### 介绍
offload将网络中断留给网卡进行处理，减轻网络IO对CPU的负载

### 前提
+ 节点必须是hyper节点；
+ 必须装配了CX4/5的网卡；
+ 不能是vlan mode；
+ BIOS选项设置： SR-IOV Support=Enabled

### 开启方式
+ 如果hyper在spine leaf网络中且内核版本为`4.15-44`,则执行下面的步骤， 否则跳过该步：

```bash
apt-get --yes --allow-unauthenticated install pitrix-dep-mst
cat >> /etc/rc.local.head << "EOF"
python /pitrix/bin/mlnx_vf_map.py --start -n 32
cores=$(cat /proc/cpuinfo| grep 'cpu cores'| uniq | awk '{print $NF}')
net_ifs=$(ls /etc/network/interfaces.d/)
vf_ifs=$(ifconfig | grep ^vf | awk '{print $1}')
for interface in ${net_ifs[*]};do
    ethtool -i ${interface} | grep mlx
    if [ $? == 0 ]; then
        ethtool -X ${interface} hfunc toeplitz
        ethtool -G ${interface} tx 8192 rx 8192
        ethtool -L ${interface} combined ${cores}
        set_irq_affinity -x local ${interface}
    fi
done
for vf_interface in ${vf_ifs[*]};do
    set_irq_affinity -x local ${vf_interface}
    ethtool -G ${vf_interface} tx 8192 rx 8192
done
EOF

# 把"/etc/rc.local.spine_leaf" 放在/etc/rc.local.head的最后执行
sed -i "/rc.local.spine_leaf/d" /etc/rc.local.head
echo "/etc/rc.local.spine_leaf" >> /etc/rc.local.head
```

+ 如果hyper在spine leaf网络中且内核版本为`4.15-58`,则执行下面的步骤，否则跳过该步：

```bash
apt-get --yes --allow-unauthenticated --reinstall -o Dpkg::Options::="--force-overwrite" install pitrix-dep-mlx-utils
apt-get --yes --allow-unauthenticated install mlnx-fw-updater

cat > /etc/rc.local.offload << "EOF"
#!/bin/bash
VFS=32
net_ifs=($(ls /etc/network/interfaces.d/))
if [[ ${#net_ifs[@]} != '2' ]]; then
    echo "Error: The count of CX4/5 NICs is not 2!"
    exit 0
fi

PF1_nic=$(echo ${net_ifs[@]} | awk '{print $1}')
PF2_nic=$(echo ${net_ifs[@]} | awk '{print $2}')

echo 0 > /sys/class/net/$PF1_nic/device/sriov_numvfs
echo 0 > /sys/class/net/$PF2_nic/device/sriov_numvfs
echo $VFS > /sys/class/net/$PF1_nic/device/sriov_numvfs
echo $VFS > /sys/class/net/$PF2_nic/device/sriov_numvfs

#Get the virtual functions
pci_vfs=$(lspci -D | grep nox | grep -iE "ConnectX-5 |ConnectX-4" |grep "Virtual Function" | awk '{print $1}')

#Unbing VF's
for vf_interface in ${pci_vfs[*]}; do
    echo ${vf_interface} > /sys/bus/pci/drivers/mlx5_core/unbind
done

for interface in ${net_ifs[*]}; do
    echo switchdev >  /sys/class/net/${interface}/compat/devlink/mode
done

for i in {1..60}; do
	ret_c=$(ip link show | grep $PF1_nic | wc -l)
	ret_d=$(ip link show | grep $PF2_nic | wc -l)

	if  [[ $ret_c -gt $VFS ]] && [[ $ret_d -gt $VFS ]] ;then
		break
	fi

	echo "wait vf ready $i..."
	sleep 1
done

/etc/rc.local.spine_leaf

#bing VF's
for vf_interface in ${pci_vfs[*]}; do
    echo ${vf_interface} > /sys/bus/pci/drivers/mlx5_core/bind
    sleep 0.5
done

ethtool -K $PF1_nic hw-tc-offload on
ethtool -K $PF2_nic hw-tc-offload on

python /pitrix/bin/mlnx_vf_map.py -p  $PF1_nic,$PF2_nic --rvfn=1 --init_rvfn

cores=$(cat /proc/cpuinfo| grep 'cpu cores'| uniq | awk '{print $NF}')
vf_ifs=$(ifconfig | grep ^vf | awk '{print $1}')
for interface in ${net_ifs[*]};do
  ethtool -i ${interface} | grep mlx
  if [ $? == 0 ]; then
    ethtool -X ${interface} hfunc toeplitz
    ethtool -G ${interface} tx 8192 rx 8192
    ethtool -L ${interface} combined ${cores}
    set_irq_affinity -x local ${interface}
  fi
done
for vf_interface in ${vf_ifs[*]};do
  set_irq_affinity -x local ${vf_interface}
  ethtool -G ${vf_interface} tx 8192 rx 8192
done
EOF

echo "/etc/rc.local.offload" >> /etc/rc.local.head
sed -i "/rc.local.spine_leaf/d" /etc/rc.local.head
chmod +x /etc/rc.local.offload
```

+ 如果hyper是bond网络且有cx5的网卡，且内核为`4.15-58`, 则执行下面的步骤

```bash
apt-get --yes --allow-unauthenticated --reinstall -o Dpkg::Options::="--force-overwrite" install pitrix-dep-mlx-utils
apt-get --yes --allow-unauthenticated install mlnx-fw-updater

# 创建文件/etc/network/bond.offload.post
cat > /etc/network/bond.offload.post << "EOF"
#!/bin/bash
PF1_nic={{ MGMT_BOND_SLAVE_1 }}
PF2_nic={{ MGMT_BOND_SLAVE_2 }}
VFS=32
for ifs in $PF1_nic $PF2_nic; do
    echo switchdev > /sys/class/net/$ifs/compat/devlink/mode
done
for i in {1..260}; do
    ret_a=`ip link show dev $PF1_nic|grep -w vf|wc -l`
    ret_b=`ip link show dev $PF2_nic|grep -w vf|wc -l`
    ret_c=`ip link show | grep $PF1_nic | wc -l`
    ret_d=`ip link show | grep $PF2_nic | wc -l`
    echo $ret_a
    echo $ret_b
    echo $ret_c
    echo $ret_d
    if [ $ret_a -eq $VFS ] && [ $ret_b -eq $VFS ] && [ $ret_c -gt $VFS ] && [ $ret_d -gt $VFS ]; then
        break
    fi
    echo `date`
    echo "wait vf ready $i..."
    sleep 1
done
## test rdma node guid
echo '00:11:22:33:44:55:00:00' > /sys/class/infiniband/mlx5_bond_0/device/sriov/0/node
echo '00:11:22:33:44:55:11:00' > /sys/class/infiniband/mlx5_bond_0/device/sriov/1/node
#Get the virtual functions
pci_vfs=$(lspci -D | grep nox | grep -iE "ConnectX-5 |ConnectX-4" |grep "Virtual Function" | awk '{print $1}')
# bind VF's
for vf in $pci_vfs; do
    echo $vf > /sys/bus/pci/drivers/mlx5_core/bind
    sleep 0.5
done
ethtool -K $PF1_nic hw-tc-offload on
ethtool -K $PF2_nic hw-tc-offload on
echo > /pitrix/conf/vf_rep_map.yaml
# if need reserved vf used for netconsole,
# must set --rvfn=1 and
# --init_rvfn is used to init tc filter for reserved vf
python /pitrix/bin/mlnx_vf_map.py -p $PF1_nic,$PF2_nic --rvfn=1 --init_rvfn
touch /tmp/vf_done.offload
EOF

# 创建文件/etc/network/bond.offload.pre
cat > /etc/network/bond.offload.pre << "EOF"
#!/bin/bash
PF1_nic={{ MGMT_BOND_SLAVE_1 }}
PF2_nic={{ MGMT_BOND_SLAVE_2 }}
VFS=32
echo 0 > /sys/class/net/$PF1_nic/device/sriov_numvfs
echo 0 > /sys/class/net/$PF2_nic/device/sriov_numvfs
echo $VFS > /sys/class/net/$PF1_nic/device/sriov_numvfs
echo $VFS > /sys/class/net/$PF2_nic/device/sriov_numvfs
#Get the virtual functions
pci_vfs=$(lspci -D | grep nox | grep -iE "ConnectX-5 |ConnectX-4" |grep "Virtual Function" | awk '{print $1}')
#Unbing VF's
for vf in $pci_vfs ; do  echo $vf > /sys/bus/pci/drivers/mlx5_core/unbind; done
EOF

chmod a+x /etc/network/bond.offload.pre
chmod a+x /etc/network/bond.offload.post
echo "pre-up /etc/network/bond.offload.pre" >> /etc/network/interfaces
echo "post-up /etc/network/bond.offload.post" >> /etc/network/interfaces

. /opt/install/os/setting
bond_slaves=(${mgmt_network_bond_slaves/,/ })
bond_slave1=${bond_slaves[0]}
bond_slave2=${bond_slaves[1]}

# 替换掉/etc/network/bond.offload.pre 和 /etc/network/bond.offload.post中的变量
sed -i "s/{{ MGMT_BOND_SLAVE_1 }}/${bond_slave1}/g" /etc/network/bond.offload.pre
sed -i "s/{{ MGMT_BOND_SLAVE_2 }}/${bond_slave2}/g" /etc/network/bond.offload.pre
sed -i "s/{{ MGMT_BOND_SLAVE_1 }}/${bond_slave1}/g" /etc/network/bond.offload.post
sed -i "s/{{ MGMT_BOND_SLAVE_2 }}/${bond_slave2}/g" /etc/network/bond.offload.post

# 创建文件/etc/rc.local.wait_offload
cat > /etc/rc.local.wait_offload << "EOF"
#!/bin/bash
# make sure offload is configured
count=600
while [ ${count} -gt 0 ]
do
    if [[ -f /tmp/vf_done.offload ]]; then
        break
    fi
    sleep 1
    count=$((count-1))
done
EOF

chmod +x /etc/rc.local.wait_offload
sed -i "/\#\!\/bin\/bash/a\\/etc\/rc.local.wait_offload" /etc/rc.local.head
```

+ 运行命令`/pitrix/bin/mlnx_vf_map.py --init -n 32` , 注意把最后一个参数替换成实际的vf数，此处假设为32

### 重启生效
重启后， 运行`ip a`查看是否已有vf开头的网卡。