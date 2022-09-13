## API Design Reference

### 1 公共(Public)

+ `API`的公共参数，包含请求参数和返回参数。

#### 1.1 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |

#### 1.2 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| ret_code | integer | 执行成功与否 |

+ 若`ret_code`返回为`0`，则属于正常返回。
+ 若`ret_code`返回为非`0`，则属于异常返回。

### 2 物理服务器

#### 2.1 SetNetwork

+ 设置服务器的网络配置，设置并重启网络:
    + 成功: 用户通过新设置的管理`IP`查看任务进度。
    + 失败: 回滚网络配置，允许用户通过`100.100.100.100`重新设置网络。

##### 请求参数

+ 总览参数：

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| hostname | string | 服务器主机名 | Yes |
| mgmt_address | string | 服务器IP地址 | Yes |
| mgmt_netmask | string | 服务器IP掩码 | Yes |
| mgmt_gateway | string | 服务器网关 | Yes |
| mgmt_interfaces | string | 服务器管理接口 | Yes |
| mgmt_is_bond | string | 是否配置BOND | No |
| mgmt_is_vlan | string | 是否配置VLAN | No |
| mgmt_vlan_id | string | VLAN_ID | No |
| firstbox_address | string | FB的IP地址 | No |

##### 返回参数

+ 由于重启网络，导致无法返回响应。

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action": "SetNetwork",
    "hostname": "pek3ar01n01",
    "mgmt_address": "172.16.80.10",
    "mgmt_netmask": "255.255.255.0",
    "mgmt_gateway": "172.16.80.254",
    "mgmt_interfaces": "eth0,eth1",
    "mgmt_is_bond": "1",
    "mgmt_is_vlan": "1",
    "mgmt_vlan_id": "100",
    "firstbox_address": "172.16.80.100"
}
```

+ 返回示例：

```text
recv: {
    "action": "SetNetworkResponse",
    "ret_code": 0
}
```

#### 2.2 DescribeStatus

+ 获取配置服务器的状态: `new/failed/loading/running`。
    + `new`: 还未配置服务器的网络。
    + `failed`: 配置失败。
    + `loading`: 正在拉起`fb`。
    + `running`: 配置成功。

##### 请求参数

+ 总览参数：

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| status | string | 配置状态 |
| firstbox_address | string | FB的IP地址 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action": "DescribeStatus",
}
```

+ 返回示例：

```text
recv: {
    "action": "DescribeStatusResponse",
    "status": "running",
    "firstbox_address": "",
    "ret_code": 0
}
```

#### 2.3 GetMgmtInterfaces

+ 获取配置服务器的所有网卡信息。

##### 请求参数

+ 总览参数：

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| network_interfaces | dict | 网卡列表 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action": "GetMgmtInterfaces",
}
```

+ 返回示例：

```text
recv: {
    "action": "GetMgmtInterfacesResponse",
    "network_interfaces": {
        {
            "name": "eth0",
            "speed": "20000Mb/s",
            "mac": "54:e1:ad:ee:af:b7"
        },
        {
            "name": "eth1",
            "speed": "10000Mb/s",
            "mac": "54:e1:ad:ee:af:b6"
        }
    },
    "ret_code": 0
}
```

#### 2.4 EnablePortIdentification

+ 启用网卡检查，对应的网络接口会闪灯，持续时间为`60s`。

##### 请求参数

+ 总览参数：

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| mgmt_interface | string | 网络接口名 | Yes |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action": "EnablePortIdentification",
}
```

+ 返回示例：

```text
recv: {
    "action": "EnablePortIdentificationResponse",
    "ret_code": 0
}
```

#### 2.5 DisablePortIdentification

+ 禁用网卡检查，对应的网络接口会停止闪灯。

##### 请求参数

+ 总览参数：

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| mgmt_interface | string | 网络接口名 | Yes |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action": "DisablePortIdentification",
}
```

+ 返回示例：

```text
recv: {
    "action": "DisablePortIdentificationResponse",
    "ret_code": 0
}
```

***
