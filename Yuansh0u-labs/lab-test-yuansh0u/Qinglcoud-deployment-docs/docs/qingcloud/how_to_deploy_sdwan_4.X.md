### SDWAN 服务

+ 要求: 版本必须是`4.2-20190318`及以上。

#### 追加部署
+ 确认并登陆 global zone 的 fb

1. 如果没有 sdwan packages 文件则需要添加:
```bash
root@qingcloud-firstbox:~# cat /pitrix/upgrade/packages/sdwan
packages=('pitrix-wanctl-proxy' 'pitrix-wanctl-server' 'pitrix-wan-gate-server');
```

2. 安装 sdwan 相关包, 并暂时先关闭相关服务:
```bash
/pitrix/upgrade/update.sh proxy sdwan
/pitrix/upgrade/exec_nodes.sh proxy 'supervisorctl status'
wan_gate_server                  RUNNING    pid 24333, uptime 0:04:59
wanctl_proxy                     RUNNING    pid 24334, uptime 0:04:59
wanctl_server                    RUNNING    pid 909, uptime 0:00:02
/pitrix/upgrade/update.sh proxy 'supervisorctl stop wanctl_server wan_gate_server wanctl_proxy'
```

+ 在 global proxy 添加配置 (有备注的变量都需要控制器提供方提供)

1. 在 /pitrix/conf 目录下添加文件:
```bash
# ** 注 ** url 为 SDWAN控制器的公网地址; 需要SD-WAN控制器提供信息：usename 为 yop 需要具备 admin 权限; password 为 yop 用户的密码
cat /pitrix/conf/wanctl_driver.ini
[driver]
url = http://139.198.255.2:9082  #9082需要SD-WAN控制器提供信息，一般情况为9080
username = yop
password = yop@88
```

2. 在 /etc/haproxy/haproxy.cfg 追加如下配置:
```bash
# 首先确认 9033/19033 是否被占用 ss -tunlp |grep 9033，如果没有被占用 
# ** 注 ** 假设 proxy hostname 分别是 xxx-proxy0/xxx-proxy
listen wan-gate-front
    bind 0.0.0.0:19033
    mode tcp
    balance roundrobin
    server  wan-gate-server1 xxx-proxy0:9033 check
    server  wan-gate-server2 xxx-proxy1:9033 check
# 一个节点一个节点的依次执行
service haproxy reload
```

3. 配置 proxy 节点上的 iptables:
```bash
# ** 注 ** 10.100.1.20/24 为 SD-WAN控制器的 source ip（VBC），需要根据具体情况填写
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j RETURN
iptables -A INPUT -p tcp -s 10.100.1.20/24 --dport 19033 -j ACCEPT
iptables -A INPUT -p tcp -s 0.0.0.0/0 --dport 19033 -j DROP
```

+ 配置 global zone 的 server.${zone_id}.yaml, 并刷到全局:
```bash
# 添加如下内容到 server.yaml.${zone_id}
wanctl_server:
  wan_gate_clients:
    - '10.16.120.236' # xxx-proxy0 的 ip 地址，默认配置文件是域名，可以改成proxy的自身IP
    - '10.16.130.236' # xxx-proxy1 的 ip 地址，默认配置文件是域名，可以改成proxy的自身IP
# 刷到所有节点
/pitrix/upgrade/build_global_conf.sh
/pitrix/upgrade/update.sh all pitrix-global-conf
```

+ 确认所有配置后,启动所有服务
```bash
#建议在每个 proxy 上依次执行，避免报错
supervisorctl start wanctl_server
supervisorctl start wan_gate_server
supervisorctl start wanctl_proxy
```

+ 开放前端

1. 修改 local_config.yaml 前端配置文件:
```yaml
# ZONE_CONFIG 里面 cate networks_cdn 下面填加
- cate: sdwan
      items:
      - {name: wan_nets, title: Overview}
      - {name: wan_cpes, title: WAN CPEs}
      title: SD-WAN
# 在 GLOBAL_CONFIG 里配置
# --------- sdwan billing config ------- 以下第一个配置是增加sdwan导航入口，第二个配置是设置sdwan计费
- valid_sdwan_billing_time:
  - {text: '1', unit: 'month_unit', value: 1}
  - {text: '3', unit: 'months_unit', value: 3}
  - {text: '6', unit: 'months_unit', value: 6}
  - {text: '1', unit: 'year', value: 12}
  - {text: '3', unit: 'years', value: 36}
  - {text: '5', unit: 'years', value: 60}
  valid_sdwan_auto_renew_time:
  - {text: '1', unit: 'month_unit', value: 1}
  - {text: '3', unit: 'months_unit', value: 3}
  - {text: '6', unit: 'months_unit', value: 6}
  - {text: '1', unit: 'year', value: 12}
  - {text: '3', unit: 'years', value: 36}
  - {text: '5', unit: 'years', value: 60}
  sd_wan_connect_version: true #专线配置，如果没有专线环境，可以不写此项
  global_valid_features: #参照这个字段，以上信息与这个字段对齐
```

2. 如果普通租户看不到地图地址，默认情况下 global 库的 location 表的 console_id 为 QingCloud ，需要修改 global 库的 location 表的 console_id 为私有云 console_id:
```postgres-sql
update location set console_id = console_id;  -- console_id 需要iaas提供
```

3. 插入计费信息:
```postgres-sql
update price_list set price = 1300000, duration = '1' where price_key_id = 'pk-00000001' and resource_info = 'wan_access_cpe_bw' and charge_mode='monthly' and currency = 'cny';
update price_list set price = 216667, duration = '1' where price_key_id = 'pk-00000001' and resource_info = 'wan_access_cpe_bw' and charge_mode='monthly' and currency = 'hkd';
update price_list set price = 1560000, duration = '1' where price_key_id = 'pk-00000001' and resource_info = 'wan_access_cpe_bw' and charge_mode='monthly' and currency = 'usd';
INSERT INTO price_list (price_key_id,resource_info,duration,charge_mode,price,currency) VALUES ('pk-00000001','wan_access_cpe_bw',3600,'elastic',3611,'cny');
INSERT INTO price_list (price_key_id,resource_info,duration,charge_mode,price,currency) VALUES ('pk-00000001','wan_access_cpe_bw',3600,'elastic',602,'usd');
INSERT INTO price_list (price_key_id,resource_info,duration,charge_mode,price,currency) VALUES ('pk-00000001','wan_access_cpe_bw',3600,'elastic',4333,'hkd');
update price_list set price = 200000, duration = '1' where price_key_id = 'pk-00000001' and resource_info = 'wan_access_vpc_bw' and charge_mode='monthly' and currency = 'cny';
update price_list set price = 33333, duration = '1' where price_key_id = 'pk-00000001' and resource_info = 'wan_access_vpc_bw' and charge_mode='monthly' and currency = 'hkd';
update price_list set price = 240000, duration = '1' where price_key_id = 'pk-00000001' and resource_info = 'wan_access_vpc_bw' and charge_mode='monthly' and currency = 'usd';
INSERT INTO price_list (price_key_id,resource_info,duration,charge_mode,price,currency) VALUES ('pk-00000001','wan_access_vpc_bw',3600,'elastic',3600,'cny');
INSERT INTO price_list (price_key_id,resource_info,duration,charge_mode,price,currency) VALUES ('pk-00000001','wan_access_vpc_bw',3600,'elastic',600,'usd');
INSERT INTO price_list (price_key_id,resource_info,duration,charge_mode,price,currency) VALUES ('pk-00000001','wan_access_vpc_bw',3600,'elastic',4320,'hkd');
```

+ 对接调试

1. 由于新版本boss中没有提供cpe sn的注册窗口，需要手动在 iaas 中注册，注册时需要加密，参照以下方案:
```bash
https://tool.oschina.net/encrypt?type=3   #在线转base64码的地址
./import-wan-cpe-sn -s MDAyNTdDMzAyQ0U4   #在webcervice上的/pitrix/cli/wan下执行，MDAyNTdDMzAyQ0U4为转换完成的cpe sn
```

2. cpe光盒接线后，在console端配置，填入SD-WAN控制器的公网地址，应用配置后，盒子即可在console界面看到接入信息