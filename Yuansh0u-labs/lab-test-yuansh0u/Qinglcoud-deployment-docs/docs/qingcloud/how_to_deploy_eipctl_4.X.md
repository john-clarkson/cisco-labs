### 部署eipctl服务

#### 服务简介

+ 部署时，请微信联系`Ben`, 邮箱: `benwang@yunify.com`;
+ `eipctl`是用来管理硬件`vg`(`H3C-VG`)的服务, 只有在使用硬件交换机做`vg`的情况下才需要该服务;

#### 新环境部署

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 在配置青云平台阶段, 编辑`variables.ZONE_ID.yaml`时, 将`deploy_eipctl`设置为`1`即可;

#### 老环境追加

+ 注意修改`ZONE_ID`为平台环境的实际值。
+ 进入`/pitrix/config`目录，从`templates`目录的`vm_variables.template.yaml`拷贝一个`vm_variables.ZONE_ID.yaml`出来:
    + `cp -f /pitrix/config/templates/vm_variables.template.yaml /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 此处拷贝的配置文件，必须让`ZONE_ID`在中间，以方便区分`region`模式下，不同`ZONE`的配置文件。
    + 按照模板里的说明，按需为需要追加部署组件的`ZONE`填入必要的信息。
    + 一次仅允许追加部署一种组件。

+ 更改配置文件:
    + 将`deploy_eipctl`设置为`1`。
    + 将`eipctl_switch_loopback_ip`设置为`H3C-VG`的`Loopback IP`。

+ 部署管理节点: `/pitrix/cli/deploy-qingcloud-component.py -v /pitrix/config/vm_variables.ZONE_ID.yaml`。
    + 查看部署管理节点的当前状态：`/pitrix/cli/get-deploy-qingcloud-component-status.py`。
    + 查看部署管理节点的简略日志：`/pitrix/cli/get-deploy-qingcloud-component-log.py`。
    + 详细日志请看目录下对应`job`的日志：`/pitrix/log/deploy`。
    + 此步骤耗时较长, 耐心等待完成。

#### 部署完成

+ 先停掉`eipctl`节点的`supervisor`服务, 等真正调试对接硬件 `vg` 再启动;
+ 修改`eipctl`节点的`/etc/gobgpd.conf`:
    + 修改 `MGMT_ADDRESS` 为具体的 `eipctl` 节点的管理网 `ip`;
    + 修改 `SWITCH_LOOPBACK_IP` 为具体的硬件交换机的 `loopback_ip`;

```text
[global.config]
 as = 65533
 # eipctl0/1 的 IP
 router-id = "{{MGMT_ADDRESS}}"

[[neighbors]]
 [neighbors.config]
 # H3C 的 loopback IP 地址
 neighbor-address = "{{SWITCH_LOOPBACK_IP}}"
 peer-as = 65533
 [neighbors.timers.config]
   connect-retry = 5
   keepalive-interval = 21845
   hold-time = 65535
 [[neighbors.afi-safis]]
   [neighbors.afi-safis.config]
     afi-safi-name = "l2vpn-evpn"
   [neighbors.afi-safis.mp-graceful-restart.config]
       enabled = true
 [neighbors.graceful-restart.config]
     enabled = true
     restart-time = 600
```

***
