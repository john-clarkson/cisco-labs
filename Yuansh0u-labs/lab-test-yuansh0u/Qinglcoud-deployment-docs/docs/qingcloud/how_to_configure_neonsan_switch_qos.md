### Cisco配置方法

+ 定义流量类型, dscp值为48的标记为CNP流量， dscp值为26的标记为RoCE流量
```
class-map type qos match-all CNP
  match dscp 48
class-map type qos match-all RoCE
  match dscp 26
```

+ 将CNP流量绑定qos队列7, RoCE流量绑定qos队列3
```
policy-map type qos QOS_MARKING
  class RoCE
    set qos-group 3
  class CNP
    set qos-group 7
  class class-default
```  

+ 配置出口队列策略
```
policy-map type queuing QOS_QUEUEING8q-out
  # 队列7（CNP）的流量绝对优先传输
  class type queuing c-out-8q-q7
    priority level 1
  
  # 队列3（RoCE）的流量分配剩余带宽的50%， 并配置丢包阈值和概率，以及开启ecn
  # 如果RoCE流量有专用的交换机，可配置为90%
  class type queuing c-out-8q-q3
    bandwidth remaining percent 50
    random-detect threshold burst-optimized ecn
  
  # 默认队列的流量分配剩余带宽的40%（业务流量）
  class type queuing c-out-8q-q-default
    bandwidth remaining percent 40
    
  # 其余队列不配置
  class type queuing c-out-8q-q6
    bandwidth remaining percent 0
  class type queuing c-out-8q-q5
    bandwidth remaining percent 0
  class type queuing c-out-8q-q4
    bandwidth remaining percent 0
  class type queuing c-out-8q-q2
    bandwidth remaining percent 0
  class type queuing c-out-8q-q1
    bandwidth remaining percent 0
```

+ 在neonsan节点对应的接口下绑定流控策略
```
interface Ethernet1/*
  service-policy type qos input QOS_MARKING
  service-policy type queuing output QOS_QUEUEING8q-out
```

### Ruijie配置方法
+ 定义流量类型, dscp值为48的标记为CNP流量， dscp值为26的标记为RoCE流量
```
class-map CNP
 match ip dscp 48
class-map RoCE
 match ip dscp 26
```
+ 将CNP流量绑定qos队列7, RoCE流量绑定qos队列3
```
policy-map QOS
 class RoCE
  set cos 3 priority
 class CNP
  set cos 7 priority
```

+ 配置队列负载权重
```
# 队列7绝对优先，队列3占剩余带宽的50%，如果RoCE流量有专用交换机，可配置为90%
qos-queue compatible enable
mls qos scheduler drr
drr-queue bandwidth 1 1 1 50 1 1 1 0
queueing wred
```

+ neonsan节点对应的接口下绑定流控策略
```
int TFGigabitEthernet 0/*
 qos queue 3 ecn
 qos queue 7 ecn
```