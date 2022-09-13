### API Design Reference

### 公共(Public)

+ `API`的公共参数，包含请求参数和返回参数。

#### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| request_type | string | API 类型 | Yes |
| USER_ID | string | 用户 ID | Yes |
| PASSWORD | string | 用户密码(密文) | Yes |

+ `USER_ID`同`user_id`，`PASSWORD`为`password`的加密值，二者一起传入，用于校验用户身份。
+ 为了避免与`User`里的`user_id`和`password`这两个参数产生歧义与混淆，故全部大写表示。

#### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| ret_code | integer | 执行成功与否 |

+ 若`ret_code`返回为`0`，则属于正常返回。
+ 若`ret_code`返回为非`0`，则属于异常返回。


#### 1 节点 Node

##### 1.1 DescribeNodes

+ 获取该环境节点信息。

#### 请求参数

| 参数名       | 类型   | 描述          | 必需性 |
| :----:      | :----:  | :----:    | :----:  |
| action       | string | API 动作      | Yes    |
| node_ids     | list   | node id 列表  | No     |
| product_type | string | node 产品类型 | No     |
| product_name | string | node 产品名字 | No     |
| role         | string | node 角色     | No     |
| sub_roles    | list | node 子角色   | No     |
| status       | string | node 现在状态 | No     |
| pre_status   | string | node 前一状态 | No     |

#### 返回参数

    - 总览参数

    | 参数名      | 类型    | 描述               |
    | :----       | :----   | :----              |
    | action      | string  | API 动作响应       |
    | node_set    | list    | 所查询到的节点列表 |
    | total_count | integer | 所查询到的节点数量 |
    | ret_code    | integer | 执行成功与否       |

    - 细节参数

    node_set 见示例。

* **示例**

    - 请求

    ```javascript
    send: {
      "action": "DescribeNodes",
      "request_type": "Node",
      "node_ids": [
        "n-8AQZMLrm"
      ]
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"DescribeNodesResponse",
      "node_set":[
        {
          "cpu": {
            "cpu_arch": "x86_64",
            "cpu_cores": 12,
            "cpu_model": "Westmere E56xx/L56xx/X56xx (Nehalem-C)",
            "cpu_processors": 12,
            "cpu_sockets": 12
          },
          "create_time": "2019-12-18 13:12:03",
          "data_disks": [
            {
              "disk_id": "d-96oJeQZ4",
              "id": "virtio-vol-z7lv8fbw",
              "name": "vdc",
              "node_id": "n-bf4swd6P",
              "rest_part": "",
              "rest_size": 0.0,
              "root_part": "",
              "root_size": 0.0,
              "size": 215.0,
              "status": 1,
              "swap_part": "",
              "swap_size": 0.0,
              "type": "sata"
            },
            {
              "disk_id": "d-45bNy6mQ",
              "id": "virtio-vol-znk2mhbu",
              "name": "vdd",
              "node_id": "n-bf4swd6P",
              "rest_part": "",
              "rest_size": 0.0,
              "root_part": "",
              "root_size": 0.0,
              "size": 215.0,
              "status": 1,
              "swap_part": "",
              "swap_size": 0.0,
              "type": "ssd"
            },
          ],
          "description":"",
          "hostname": "express1ar01n01",
          "memory":{
            "memory_size":63.0
          },
          "mgmt_network": {
            "address": "172.16.80.3",
            "bond_mode": "",
            "bond_name": "",
            "bond_slaves": "",
            "gateway": "172.16.80.1",
            "name": "br0",
            "netmask": "255.255.255.0",
            "vlan_id": "",
            "vlan_raw_device": ""
          },
          "networks": [
            {
              "address": "172.16.80.3",
              "bond_mode": 0,
              "gateway": "172.16.80.1",
              "mac_address": "52:54:65:0a:6f:6f",
              "name": "br0",
              "netmask": "255.255.255.0",
              "network": "172.16.80.0/24",
              "network_id": "e-eyVisrNX",
              "node_id": "n-bf4swd6P",
              "raw_device": "eth0",
              "raw_device_id": "e-hMQabGcA",
              "raw_device_info": {
                "address": "",
                "bond_mode": 0,
                "gateway": "",
                "mac_address": "52:54:65:0a:6f:6f",
                "name": "eth0",
                "netmask": "",
                "network": "",
                "network_id": "e-hMQabGcA",
                "node_id": "n-bf4swd6P",
                "raw_device": "",
                "raw_device_id": "",
                "raw_device_type": "",
                "slave_devices": "",
                "type": "common"
              },
              "raw_device_type": "common",
              "slave_devices": "",
              "type": "bridge"
            }
          ],
          "node_id":"n-8AQZMLrm",
          "os":{
            "kernel_version":"4.4.0-131-generic",
            "os_name":"trusty",
            "os_version":"16.04.5"
          },
          "os_disk": {
            "disk_id": "d-X1dM0UKA",
            "id": "virtio-i-1j2kjemk",
            "name": "vda",
            "node_id": "n-bf4swd6P",
            "rest_part": "vda2",
            "rest_size": 0.0,
            "root_part": "vda1",
            "root_size": 53.7,
            "size": 53.7,
            "status": 0,
            "swap_part": "vdb",
            "swap_size": 0.0,
            "type": "sata"
          },
          "pre_status": "",
          "product_name": "",
          "product_type": "",
          "role": "",
          "status": "available",
          "sub_roles": [],
          "update_time": "2019-12-18 13:12:01",
          "zone_id": ""
        }
      ],
      "ret_code": 0,
      "total_count": 1
    }
    ```

##### 1.2 AddNodes

    向环境添加节点，并自动收集节点的硬件信息，被添加节点需要已经安装操作系统。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述           | 必需性 |
    | :----    | :----  | :----          | :----  |
    | action   | string | API 动作       | Yes    |
    | ip_start | string | ip 段的起始 IP | Yes    |
    | ip_end   | string | ip 段的结尾 IP | Yes    |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名      | 类型    | 描述             |
    | :----       | :----   | :----            |
    | action      | string  | API 动作响应     |
    | node_ids    | list    | 所添加的节点 ID  |
    | total_count | integer | 所添加的节点数量 |
    | ret_code    | integer | 执行成功与否     |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"AddNodes",
      "request_type": "Node",
      "ip_start":"10.10.10.10",
      "ip_end":"10.10.10.20"
    }
    ```
    - 返回

    ```javascript
    recv: {
      "action":"AddNodesResponse",
      "node_ids":[
        "n-test1234"
      ],
      "total_count":1,
      "ret_code":0
    }
    ```

##### 1.3 DeleteNodes

    删除环境里的节点。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述                | 必需性 |
    | :----    | :----  | :----               | :----  |
    | action   | string | API 动作            | Yes    |
    | node_ids | list   | 待删除 node id 列表 | Yes    |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名      | 类型    | 描述                |
    | :----       | :----   | :----               |
    | action      | string  | API 动作响应        |
    | node_ids    | list    | 已删除 node id 列表 |
    | total_count | integer | 所删除的节点数量    |
    | ret_code    | integer | 执行成功与否        |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"DeleteNodes",
      "request_type": "Node",
      "node_ids":[
        "n-test1234"
      ]
    }
    ```
    - 返回

    ```javascript
    recv: {
      "action":"DeleteNodesResponse",
      "node_ids":[
        "n-test1234"
      ],
      "total_count":1,
      "ret_code":0
    }
    ```

##### 1.4 CollectNodes

    收集节点硬件信息，被收集的节点角色应该为空。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述         | 必需性 |
    | :----    | :----  | :----        | :----  |
    | action   | string | API 动作     | Yes    |
    | node_ids | list   | node id 列表 | Yes    |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                |
    | :----    | :----   | :----               |
    | action   | string  | API 动作响应        |
    | job_id   | string  | 收集节点信息 job id |
    | ret_code | integer | 执行成功与否        |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"CollectNodes",
      "request_type": "Node",
      "node_ids":[
        "n-test1234"
      ]
    }
    ```
    - 返回

    ```javascript
    recv: {
      "action":"CollectNodesResponse",
      "job_id":"j-test1234",
      "ret_code":0
    }
    ```


##### 1.5 GetStatus

+ 获取异步任务的状态，返回的状态包括`stepX/failed/successful`。

#### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| request_type | string | 请求类型 | Yes |
| job_action | string | job 动作 | Yes |
| job_id | string | job id | No |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| job_action | string | JOB 动作 |
| status     | string  | 所查询到的收集节点当前状态 |
| pre_status | string  | 所查询到的收集节点前一状态 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例:

```javascript
send: {
    "action": "GetStatus",
    "request_type": "Node",
    "job_action": "CollectNodes",
    "job_id":"j-68mbPHJU"
}
```

+ 返回示例:

```javascript
recv: {
    "action": "GetStatusResponse",
    "status": "failed",
    "pre_status": "step0",
    "job_action": "CollectNodes",
    "ret_code": 0
}
```

##### 1.6 GetLog

+ 获取异步任务的日志。

#### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| request_type | string | 请求类型 | Yes |
| job_action | string | JOB 动作 | Yes |
| job_id     | string | job id     | No     |
| job_status | string | job status | No     |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| log      | dict | 所查询到的日志 |
| job_action | string | JOB 动作 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例:

```javascript
send: {
    "action": "GetLog",
    "request_type": "Node",
    "job_action": "CollectNodes",
    "job_id":"j-68mbPHJU"
}
```

+ 返回示例:

```javascript
recv: {
    "action": "GetLogResponse",
    "log":{
        "001": "Error: Can not get the firstbox address, please check it in /pitrix/conf/variables!"
    },
    "job_action": "CollectNodes",
    "ret_code": 0
}
```

##### 1.7 ModifyNodeAttributes

+ 修改指定节点的硬件信息。

#### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| request_type | string | 请求类型 | Yes |
| node_id         | string | Node ID | Yes |
| data_disks  | str | 数据盘列表     | Yes   |
| type  | str | 类型     | No     |
| status  | int   | 状态 | No     |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例:

```javascript
send: {
    "action": "ModifyNodeAttributes",
    "request_type": "Node",
    "node_id": "n-test1234",
    "data_disks": "vdb, vdc"
    "status": 0,
    "type": "ssd"
}
```

+ 返回示例:

```javascript
recv: {
    "action": "ModifyNodeAttributesResponse",
    "ret_code": 0
}
```

#### 2 裸机节点 BMNode

##### 2.1 DescribeBMNodes

    获取环境已注册的裸机节点信息。

* **请求参数**

    - 总览参数

    | 参数名      | 类型    | 描述        | 必需性 |
    | :----      | :----  | :----       | :----  |
    | action     | string | API 动作     | Yes    |
    | node_ids   | list   | node id 列表 | No     |
    | status     | string | node 现在状态 | No     |
    | pre_status | string | node 前一状态 | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名      | 类型    | 描述               |
    | :----       | :----   | :----              |
    | action      | string  | API 动作响应       |
    | node_set    | list    | 所查询到的节点列表 |
    | total_count | integer | 所查询到的节点数量 |
    | ret_code    | integer | 执行成功与否       |

    - 细节参数

    node_set 见示例。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"DescribeBMNodes",
      "node_ids":[
        "n-Jr8KE6cf"
      ]
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"DescribeBMNodesResponse",
      "node_set":[
        {
          "create_time":"2018-07-02 20:55:21",
          "description":"",
          "general":{
            "brand":"dell",
            "cpu_arch":"x86_64",
            "hostname":"test01n01",
            "os_version":"14.04.5",
            "serial_number":"123434433"
          },
          "ipmi":{
            "ipmi_network_address":"172.30.10.47",
            "ipmi_password":"ADMIN",
            "ipmi_username":"ADMIN"
          },
          "mgmt_network":{
            "is_mgmt_config_bond":0,
            "is_mgmt_config_vlan":0,
            "mgmt_network_address":"172.31.11.47",
            "mgmt_network_gateway":"172.31.11.254",
            "mgmt_network_netmask":"255.255.255.0",
            "mgmt_network_vlan_id":0
          },
          "node_id":"n-Jr8KE6cf",
          "os_disk":{
            "os_disk_name":"sda"
          },
          "pre_status":"",
          "public_network":{
            "is_public_config_bond":0,
            "is_public_config_vlan":0,
            "public_network_address":"",
            "public_network_gateway":"",
            "public_network_netmask":"",
            "public_network_vlan_id":0
          },
          "pxe":{
            "pxe_network_address":"",
            "pxe_network_interface":"",
            "pxe_network_mac_addr":"0c:c4:7a:88:63:1b"
          },
          "status":"new",
          "update_time":"2018-07-02 20:55:21"
        }
      ],
      "ret_code":0,
      "total_count":2
    }
    ```


##### 2.2 RegisterBMNodes

    向环境注册裸机节点。

* **请求参数**

    - 总览参数

    | 参数名                  | 类型    | 描述                 | 必需性 |
    | :----                  | :----  | :----               | :---- |
    | action                 | string | API 动作             | Yes   |
    | os_version             | string | 期望的 OS 版本        | Yes   |
    | cpu_arch               | string | 期望的 CPU 架构       | Yes   |
    | hostname               | string | 期望的主机名          | Yes   |
    | ipmi_network_address   | string | 真实的 IPMI 地址      | Yes   |
    | ipmi_username          | string | 真实的 IPMI 用户      | Yes   |
    | ipmi_password          | string | 真实的 IPMI 用户密码   | Yes   |
    | pxe_network_mac_addr   | string | 真实的 PXE MAC       | Yes   |
    | os_disk_name           | string | 期望的系统盘名称       | No    |
    | mgmt_network_address   | string | 期望的管理网络地址     | No    |
    | mgmt_network_netmask   | string | 期望的管理网络子网掩码  | No    |
    | mgmt_network_gateway   | string | 期望的管理网络网关     | No    |
    | is_mgmt_config_bond    | integer    | 管理网络是否配置 Bond | 0/1    |
    | is_mgmt_config_vlan    | integer    | 管理网络是否配置 VLAN | 0/1    |
    | mgmt_network_vlan_id   | integer    | 管理网络 VLAN ID    | No    |
    | public_network_address | string | 期望的外网地址        | No    |
    | public_network_netmask | string | 期望的外网子网掩码     | No    |
    | public_network_gateway | string | 期望的外网网关        | No    |
    | is_public_config_bond  | integer    | 外网是否配置 Bond    | 0/1    |
    | is_public_config_vlan  | integer    | 外网是否配置 VLAN    | 0/1    |
    | public_network_vlan_id | integer    | 外网 VLAN ID       | No    |
    | serial_number          | string | 机器序列号          | No    |
    | brand                  | string | 机器品牌            | No    |

    - 细节参数

    is_mgmt_config_vlan 值为 0 或 1,为 0 则 mgmt_network_vlan_id 可以隐藏起来,其他的类似。

* **返回参数**

    - 总览参数

    | 参数名      | 类型    | 描述             |
    | :----       | :----   | :----            |
    | action      | string  | API 动作响应     |
    | node_ids    | list    | 所添加的节点 ID  |
    | total_count | integer | 所添加的节点数量 |
    | ret_code    | integer | 执行成功与否     |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    sent: {
      "bm_nodes":[
        {
          "brand":"dell",
          "cpu_arch":"x86_64",
          "hostname":"test01n01",
          "ipmi_network_address":"172.30.10.47",
          "ipmi_password":"ADMIN",
          "ipmi_username":"ADMIN",
          "is_mgmt_config_bond":0,
          "is_mgmt_config_vlan":0,
          "is_public_config_bond":0,
          "is_public_config_vlan":0,
          "mgmt_network_address":"172.31.11.47",
          "mgmt_network_gateway":"172.31.11.254",
          "mgmt_network_netmask":"255.255.255.0",
          "mgmt_network_vlan_id":0,
          "os_disk_name":"sda",
          "os_version":"14.04.5",
          "public_network_address":"",
          "public_network_gateway":"",
          "public_network_netmask":"",
          "public_network_vlan_id":0,
          "pxe_network_mac_addr":"0c:c4:7a:88:63:1b",
          "serial_number":"123434433"
        }
      ]
    }

    ```
    - 返回

    ```javascript
    recv: {
      "action":"RegisterBMNodesResponse",
      "node_ids":[
        "n-LgYn6GVa"
      ],
      "ret_code":0,
      "total_count":1
    }

    ```

##### 2.3 DeleteBMNodes

    删除环境里的裸机节点。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述                | 必需性 |
    | :----    | :----  | :----               | :----  |
    | action   | string | API 动作            | Yes    |
    | node_ids | list   | 待删除 node id 列表 | Yes    |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名      | 类型    | 描述                |
    | :----       | :----   | :----               |
    | action      | string  | API 动作响应        |
    | node_ids    | list    | 已删除 node id 列表 |
    | total_count | integer | 所删除的节点数量    |
    | ret_code    | integer | 执行成功与否        |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"DeleteBMNodes",
      "node_ids":[
        "n-ACHI1x2T"
      ]
    }
    ```
    - 返回

    ```javascript
    recv: {
      "action":"DeleteBMNodesResponse",
      "node_ids":[
        "n-ACHI1x2T"
      ],
      "ret_code":0
    }
    ```

##### 2.4 ModifyBMNodeAttributes

    修改指定节点的硬件信息。

* **请求参数**

    - 总览参数

    - 总览参数

    | 参数名                  | 类型    | 描述                 | 必需性 |
    | :----                  | :----  | :----               | :---- |
    | action                 | string | API 动作             | Yes   |
    | node_id                | string | 要修改的节点的 ID      | Yes   |
    | os_version             | string | 期望的 OS 版本        | No   |
    | cpu_arch               | string | 期望的 CPU 架构       | No   |
    | hostname               | string | 期望的主机名          | No   |
    | ipmi_network_address   | string | 真实的 IPMI 地址      | No   |
    | ipmi_username          | string | 真实的 IPMI 用户      | No   |
    | ipmi_password          | string | 真实的 IPMI 用户密码   | No   |
    | pxe_network_mac_addr   | string | 真实的 PXE MAC       | No   |
    | os_disk_name           | string | 期望的系统盘名称       | No    |
    | mgmt_network_address   | string | 期望的管理网络地址     | No    |
    | mgmt_network_netmask   | string | 期望的管理网络子网掩码  | No    |
    | mgmt_network_gateway   | string | 期望的管理网络网关     | No    |
    | is_mgmt_config_bond    | integer    | 管理网络是否配置 Bond | 0/1    |
    | is_mgmt_config_vlan    | integer    | 管理网络是否配置 VLAN | 0/1    |
    | mgmt_network_vlan_id   | integer    | 管理网络 VLAN ID    | No    |
    | public_network_address | string | 期望的外网地址        | No    |
    | public_network_netmask | string | 期望的外网子网掩码     | No    |
    | public_network_gateway | string | 期望的外网网关        | No    |
    | is_public_config_bond  | integer    | 外网是否配置 Bond    | 0/1    |
    | is_public_config_vlan  | integer    | 外网是否配置 VLAN    | 0/1    |
    | public_network_vlan_id | integer    | 外网 VLAN ID       | No    |
    | serial_number          | string | 机器序列号          | No    |
    | brand                  | string | 机器品牌            | No    |

    - 细节参数

    无

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述         |
    | :----    | :----   | :----        |
    | action   | string  | API 动作响应 |
    | ret_code | integer | 执行成功与否 |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"ModifyBMNodeAttributes",
      "node_id":"n-test1234",
      "hostname":"testr01n01",
      "ipmi_username":"admin",
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"ModifyBMNodeAttributesResponse",
      "ret_code":0
    }
    ```

##### 2.5 ProvisionBMNodes

    为裸机节点安装操作系统。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述         | 必需性 |
    | :----    | :----  | :----        | :----  |
    | action   | string | API 动作     | Yes    |
    | node_ids | list   | node id 列表 | Yes    |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                |
    | :----    | :----   | :----               |
    | action   | string  | API 动作响应        |
    | job_id   | string  | 安装 OS 的 job id |
    | ret_code | integer | 执行成功与否        |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"ProvisionBMNodes",
      "node_ids":[
        "n-test1234"
      ]
    }
    ```
    - 返回

    ```javascript
    recv: {
      "action":"ProvisionBMNodesResponse",
      "job_id":"j-test1234",
      "ret_code":0
    }
    ```

##### 2.6 GetProvisionBMNodesStatus

    获取裸机节点安装 OS 的状态。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述                      | 必需性 |
    | :----    | :----  | :----                  | :----  |
    | action   | string | API 动作               | Yes    |
    | job_id   | string | 裸机节点安装 OS 的 job id | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名     | 类型    | 描述                         |
    | :----      | :----   | :----                        |
    | action     | string  | API 动作响应                 |
    | status     | string  | 所查询到的安装 OS 当前状态 |
    | pre_status | string  | 所查询到的安装 OS 前一状态 |
    | ret_code   | integer | 执行成功与否                 |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetProvisionBMNodesStatus",
      "job_id":"j-test1234"
    }
    ```
    - 返回

    ```javascript
    recv: {
      "action":"GetProvisionBMNodesStatusResponse",
      "pre_status":"step0",
      "ret_code":0,
      "status":"failed"
    }
    ```

##### 2.7 GetProvisionBMNodesLog

    获取裸机节点安装 OS 的日志。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述         | 必需性 |
    | :----    | :----  | :----        | :----  |
    | action   | string | API 动作     | Yes    |
    | job_id   | string  | 安装 OS 的 job id       | No    |
    | job_status | string | 安装 OS 的 job status | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                |
    | :----    | :----   | :----               |
    | action   | string  | API 动作响应        |
    | log      | dict    | 所查询到的安装 OS 日志 |
    | ret_code | integer | 执行成功与否        |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetProvisionBMNodesLog",
      "job_id":"n-test1234",
      "job_status":"failed"
    }
    ```
    - 返回

    ```javascript
    recv: {
      "action":"GetProvisionBMNodesLogResponse",
      "log":{
        "1":"Error: The node [nihao] is not found in database, please check it!"
      },
      "ret_code":0
    }
    ```

##### 2.8 ScanBMNodes

    扫描裸机节点并自动注册到数据库。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述         | 必需性 |
    | :----    | :----  | :----        | :----  |
    | action   | string | API 动作     | Yes    |
    | node_ids | list   | node id 列表 | Yes    |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                |
    | :----    | :----   | :----               |
    | action   | string  | API 动作响应        |
    | job_id   | string  | 收集节点信息 job id |
    | ret_code | integer | 执行成功与否        |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"CollectNodes",
      "node_ids":[
        "n-test1234"
      ]
    }
    ```
    - 返回

    ```javascript
    recv: {
      "action":"CollectNodesResponse",
      "job_id":"j-test1234",
      "ret_code":0
    }
    ```

##### 2.6 GetScanBMNodesStatus

    获取扫描裸机节点的状态。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述                      | 必需性 |
    | :----    | :----  | :----                  | :----  |
    | action   | string | API 动作               | Yes    |
    | job_id   | string | 扫描裸机节点的 job id | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名     | 类型    | 描述                         |
    | :----      | :----   | :----                        |
    | action     | string  | API 动作响应                 |
    | status     | string  | 所查询到的扫描裸机节点当前状态 |
    | pre_status | string  | 所查询到的扫描裸机节点前一状态 |
    | ret_code   | integer | 执行成功与否                 |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetScanBMNodesStatus",
      "job_id":"j-test1234"
    }
    ```
    - 返回

    ```javascript
    recv: {
      "action":"GetScanBMNodesStatusResponse",
      "pre_status":"step0",
      "ret_code":0,
      "status":"failed"
    }
    ```

##### 2.7 GetScanBMNodesLog

    获取扫描裸机节点的日志。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述         | 必需性 |
    | :----    | :----  | :----        | :----  |
    | action   | string | API 动作     | Yes    |
    | job_id   | string  | 扫描裸机节点的 job id       | No    |
    | job_status | string | 扫描裸机节点的 job status | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                |
    | :----    | :----   | :----               |
    | action   | string  | API 动作响应        |
    | log      | dict    | 所查询到的扫描裸机节点日志 |
    | ret_code | integer | 执行成功与否        |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetScanBMNodesLog",
      "job_id":"n-test1234",
      "job_status":"failed"
    }
    ```
    - 返回

    ```javascript
    recv: {
      "action":"GetScanBMNodesLogResponse",
      "log":{
        "1":"Error: The node [nihao] is not found in database, please check it!"
      },
      "ret_code":0
    }
    ```
