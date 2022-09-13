## API Design Reference

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

### 1 云平台 QingCloud

#### 1.1 DescribeQingCloud

+ 获取云平台(`QingCloud`)的信息。

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
| qingcloud | dict | 所查询到的环境信息 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action": "DescribeQingCloud",
    "request_type": "QingCloud",
}
```

+ 返回示例：

```text
recv: {
    "action": "DescribeQingCloudResponse",
    "qingcloud": {
        "platform_name": "qingcloud",
        "installer_version": "4.0",
        "qingcloud_version": "20181001",
        "domain": "qingcloud.com",
        "console_id": "qingcloud",
        "is_region": "1",
        "region_id": "pek3",
        "is_deployed": 1,
        "is_activated": 1,
        "hosts": [
            "172.18.10.10 console.qingcloud.com supervisor.qingcloud.com appcenter.qingcloud.com api.qingcloud.com",
            "172.18.10.10 boss.qingcloud.com"
        ],
        "create_time": "2018-10-1 12:12:12",
        "update_time": "2018-10-2 1:12:12",
        "status": "successful",
        "pre_status": "deploying",
        "site_protocol": "http",
        "zone_ids": [
            "pek3a",
            "pek3b"
        ],
        "zone_info": {
            "pek3a": {
                "zone_id": "pek3a",
                "cloud_type": "private",
                "deploy_mode": "standard",
                "network_mode": "nfv",
                "sdn_version": "2",
                "is_zone_deployed": 1,
                "is_zone_activated": 1,
                "platform_id": "5eab9b05410f44ce5d57bafe4d57bb79",
                "ks_node_num": 2,
                "vg_node_num": 2,
                "hyper_node_num": 4,
                "role_node_num": 8,
                "free_node_num": 0,
                "installer_allocate_vbc": 0,
                "create_time": "2018-06-01 12:12:12",
                "update_time": "2018-06-01 12:12:12"
            },
            "pek3b": {
                "zone_id": "pek3b",
                "cloud_type": "private",
                "deploy_mode": "fusion",
                "network_mode": "nfv",
                "sdn_version": "2",
                "is_zone_deployed": 1,
                "is_zone_activated": 1,
                "platform_id": "5eab9b05410f44ce5d57bafc4d57bb79",
                "ks_node_num": 0,
                "vg_node_num": 2,
                "hyper_node_num": 3,
                "role_node_num": 5,
                "free_node_num": 0,
                "installer_allocate_vbc": 1,
                "create_time": "2018-06-01 12:12:12",
                "update_time": "2018-06-01 12:12:12"
            }
        }
    },
    "ret_code": 0
}
```

#### 1.2 ConfigQingCloud

+ 异步任务: 配置云平台，主要是为了生成`variables`和`settings`。

##### 请求参数

+ 总览参数：

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| config | dict | 环境配置 | Yes |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| job_id | string | 配置云平台的 job id |
| ret_code | integer | 执行成功与否 |



+ 请求示例：

```text
send: {
    "action": "ConfigQingCloud",
    "request_type": "QingCloud",
    "config": {
        "pek3a": {
            "variables": {
                "common" {
                    "region_id": "pek3",
                },
                "base": {
                    "deploy_mode": "fusion",
                },
                "advanced": {
                    "deploy_mode": "standard",
                    "cloud_type": "private",
                    "domain": "qingcloud.com",
                    "zone_id": "pek3a",
                    mgmt_network_pools: [
                        '172.16.80.20-172.16.80.40',
                    ],
                }
            },
            "settings": {
                "roles": {
                    "n-pek3a01r01": {
                        "role": "ks-vm",
                        "sub_roles": "seed,vbr,snapshot",
                        "vms": ""
                    },
                    "n-pek3a01r02": {
                        "role": "ks-vm",
                        "sub_roles": "seed,vbr,snapshot",
                        "vms": ""
                    },
                    "n-pek3a01r03": {
                        "role": "vg",
                        "sub_roles": "vgateway",
                        "vms": ""
                    },
                    "n-pek3a01r04": {
                        "role": "vg",
                        "sub_roles": "vgateway",
                        "vms": ""
                    },
                    "n-pek3a01r05": {
                        "role": "hyper-repl",
                        "sub_roles": "hyper",
                        "vms": ""
                    },
                    "n-pek3a01r06": {
                        "role": "hyper-repl",
                        "sub_roles": "hyper",
                        "vms": ""
                    },
                    "n-pek3a01r07": {
                        "role": "hyper-repl",
                        "sub_roles": "hyper",
                        "vms": ""
                    },
                    "n-pek3a01r08": {
                        "role": "hyper-repl",
                        "sub_roles": "hyper",
                        "vms": ""
                    }
                },
                "vbc": {
                    "mgmt_ips": [
                        "172.16.80.7",
                        "172.16.80.8",
                        "172.16.80.9",
                        "172.16.80.10",
                    ],
                    "ipv4_vbc": "10.10.50.0/24",
                    "ipv4_vip": "172.16.80.100|172.16.80.8",
                    "ipv6_vbc": "",
                    "ipv6_vip": ""
                },
                "eip": {
                    "172.16.80.5": [
                        "139.198.10.0/24|.1",
                        "139.198.20.0/24|.1|HA0",
                    ],
                    "172.16.80.6": [
                        "139.198.10.0/24|.1|HA0",
                        "139.198.20.0/24|.1",
                    ]
                }
            }
        },
        "pek3b: {
            "variables": {
                "is_region": "1",
                "region_id": "pek3",
                "deploy_mode": "fusion",
                "cloud_type": "private",
                "domain": "qingcloud.com",
                "zone_id": "pek3b"
            },
            "settings": {
                "roles": {
                    "n-pek3b01r01": {
                        "role": "vg",
                        "sub_roles": "vgateway",
                        "vms": ""
                    },
                    "n-pek3b01r02": {
                        "role": "vg",
                        "sub_roles": "vgateway",
                        "vms": ""
                    },
                    "n-pek3b01r03": {
                        "role": "hyper-repl",
                        "sub_roles": "hyper,seed,vbr,snapshot",
                        "vms": ""
                    },
                    "n-pek3b01r04": {
                        "role": "hyper-repl",
                        "sub_roles": "hyper,seed,vbr,snapshot",
                        "vms": ""
                    },
                    "n-pek3b01r05": {
                        "role": "hyper-repl",
                        "sub_roles": "hyper,seed,vbr,snapshot",
                        "vms": ""
                    },
                },
                "vbc": {
                    "mgmt_ips": [
                        "172.18.80.5",
                        "172.18.80.6",
                        "172.18.80.7",
                    ],
                    "ipv4_vbc": "10.20.50.0/24",
                    "ipv4_vip": "172.18.80.100|172.18.80.6",
                    "ipv6_vbc": "",
                    "ipv6_vip": ""
                },
                "eip": {
                    "172.16.80.3": [
                        "139.198.10.0/24|.1",
                        "139.198.20.0/24|.1|HA0",
                    ],
                    "172.16.80.4": [
                        "139.198.10.0/24|.1|HA0",
                        "139.198.20.0/24|.1",
                    ]
                }
            }
        }
    }
}
```

+ 返回示例：

```text
recv: {
    "action": "ConfigQingCloudResponse",
    "job_id": "j-68mbPHJU",
    "ret_code": 0
}
```

#### 1.3 DeployQingCloud

+ 异步任务: 部署云平台。

##### 请求参数

+ 总览参数：

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| node_ids | list | node id 列表 | Yes |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| job_id | string | 部署云平台的 job id |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action": "DeployQingCloud",
    "request_type": "QingCloud",
    "node_ids":[
        "n-xER6zjlP",
        "n-B1QNEi6K",
        "n-45OipPK7",
        "n-VGEXtdIc",
        "n-K6QGly84",
        "n-uMhpTXdl"
    ]
}
```

+ 返回示例：

```text
recv: {
    "action": "DeployQingCloudResponse",
    "job_id": "j-QJMYu7nS",
    "ret_code": 0
}
```

#### 1.4 ScaleQingCloud

+ 异步任务: 扩容单个`Zone`的节点。

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| zone_id | string | 待扩容的ZONE_ID | Yes |
| node_ids | list | node id 列表 | Yes |

##### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| job_id | string | 扩容云平台的 job id |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action": "ScaleQingCloud",
    "request_type": "QingCloud",
    "zone_id": "pek3a",
    "node_ids": [
        "n-test1234",
        "n-test2345"
    ]
}
```

+ 返回示例：

```text
recv: {
    "action": "ScaleQingCloudResponse",
    "job_id": "j-QJMYu7dS",
    "ret_code": 0
}
```

#### 1.5 GetQingCloudVBCRoute

+ 获取部署或者扩容`hyper`节点后的`vbc route`信息。

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| job_id | string | 部署或扩容云平台的 job id | Yes |

##### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| vbc_route | list | 所查询到的部署或者扩容后的 vbc route 信息 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action": "GetQingCloudVBCRoute",
    "request_type": "QingCloud",
    "job_id": "j-QJMYu7aS"
}
```

+ 返回示例：

```text

```

#### 1.6 UpgradeQingCloud

+ 异步任务: 升级云平台。

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| package_name | string |升级包的名称 | Yes |

##### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| job_id | string | 升级云平台的 job id |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action": "UpgradeQingCloud",
    "request_type": "QingCloud",
    "package_name": "qingcloud-installer-express_4.3.1-20190318_16.04.3_amd64.tar.gz"
}
```

+ 返回示例：

```text
recv:{
    "action": "UpgradeQingCloudResponse",
    "job_id": "j-ksjcIyox",
    "ret_code": 0
}
```

#### 1.7 DescribeQingCloudLicenses

+ 获取云平台的`licenses`。

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| license_ids | list | license id 列表 | No |

##### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string  | API 动作响应 |
| license_set | string  | 平台的 license 集合 |
| total_count | integer | 平台的 license 数量 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action": "DescribeQingCloudLicenses",
    "request_type": "QingCloud",
    "license_ids": [
        "lc-gGHu4Uu0",
        "lc-KoOicfCz"
    ]
}
```

- 返回

```text
recv: {
    "action": DescribeQingCloudLicensesResponse",
    "license_set": [
        {
            "status":"enabled",
            "start_time":"2017-10-01T00:00:00Z",
            "create_time":"2017-10-24T04:22:30Z",
            "end_time":"2100-01-01T00:00:00Z",
            "status_time":"2017-10-24T04:22:30Z",
            "hypernode_count":100000,
            "license_id":"lc-gGHu4Uu0"
        },
        {
            "status":"expired",
            "start_time":"2017-05-06T14:22:23Z",
            "create_time":"2017-10-15T06:48:16Z",
            "end_time":"2037-10-13T13:33:00Z",
            "status_time":"2017-10-15T06:48:16Z",
            "hypernode_count":1000000,
            "license_id":"lc-KoOicfCz"
        },
    ],
    "total_count": 2,
    "ret_code": 0
}
```

#### 1.8 ActivateQingCloudLicense

+ 利用`license`激活云平台：

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| license_code | string | 激活用的License内容 | Yes |

##### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action": "ActivateQingCloudLicense",
    "request_type": "QingCloud",
    "license_code": "dakdkj/dajk89adakNg/adal==="
}
```

+ 返回示例：

```text
recv: {
    "action": "ActivateQingCloudLicenseResponse",
    "ret_code": 0
}
```

#### 1.9 GenerateQingCloudCode

+ 生成云平台`license`的申请码：

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| description | string | 云平台的描述信息    | Yes |
| start_time | string | license有效起始时间 | Yes |
| end_time | string | liense有效终止时间 | Yes |
| applicant | string | 申请人邮箱 | Yes |
| hypernode_count | int | hyper节点数量 | Yes |

+ `start_time`、`end_time`的格式必须是`'%Y-%m-%d %H:%M:%S'`;
+ `applicant`的邮箱后缀必须是`@yunify.com`;

##### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| application_code | string | 生成的平台申请码 |
| ret_code | integer | 执行成功与否 |


##### 示例

+ 请求示例：

```text
send: {
    "action": "GenerateQingCloudCode",
    "request_type": "QingCloud",
    "applicant": "admin@yunify.com",
    "description": "just for test!",
    "end_time": "2018-08-31 15:20:21",
    "start_time": "2017-08-31 15:20:21",
    "hypernode_count": 8
}
```

+ 返回示例：

```text
recv: {
    "action": "GenerateQingCloudCodeResponse",
    "application_code": "rqjmzsPIN7HMkjVdYHaK+o3+O0glmqvMArbNZmuGHXi5q7JMdFAPNFzMf6D3YZauVBEDZJuU06ityKZROBpsjvj7uLAixyI26MMAiKpQhXPzPvib8MxUQ4kM6SKfjDWTv4HML5++5w9sBVQDd8oBjZD0oOQOO1rfXWMfram9nlO0MixpE3qYS7ZgpuYS6ojGqGE4rCpVREMLkCJlEvtjEI6vN1ARcN/B2PUltU6SoZnlVrnqybl08aK6xD0lYNatiyfrW3ZgY5C0t+9SbielZmoKw/SIT7KIcV82zrvkOSD3qfXB4lmbjX+eWGoV6tjP",
    "ret_code": 0
}
```

#### 1.10 ScaleQingCloudZone

+ 异步任务: 扩容`Region`下的单个`Zone`

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| zone_id | string | 待扩容的ZONE_ID | Yes |
| node_ids | list | node id 列表 | Yes |

##### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| job_id | string | 扩容云平台的 job id |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send: {
    "action":"ScaleQingCloudZone",
    "request_type": "QingCloud",
    "zone_id": "pek3c",
    "node_ids":[
        "n-pek3cr01n1",
        "n-pek3cr01n2",
        "n-pek3cr01n3",
        "n-pek3cr01n4",
        "n-pek3cr01n5",
        "n-pek3cr01n6"
    ]
}
```

+ 返回示例：

```text
recv: {
    "action": "ScaleQingCloudZoneResponse",
    "job_id": "j-QJMYu7dS",
    "ret_code": 0
}
```

#### 1.11 TestQingCloud

+ 异步任务: 测试`QingCloud`平台

##### 请求参数

| 参数名 | 类型   | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| mode | string | 测试模式, 可选值为 all/user/res/skip/clean, all: 准备测试环境和运行所选测试; user: 准备测试用户和运行所选测试; res: 准备测试资源和运行所选测试; skip: 跳过准备部分, 直接运行所选测试; clean: 清理测试资源 | yes |
| tasks | string | 测试任务列表 | No |

##### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| job_id | string | 测试云平台的 job id |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send:{
    "action": "TestQingCloud",
    "request_type": "QingCloud",
    "mode": "res",
    "tasks": "vm-instance-capture,lb-vxnet"
}
```

+ 返回示例：

```text
recv:{
    "action": "TestQingCloudResponse",
    "job_id": "j-ksjcIyou",
    "ret_code": 0
}
```

#### 1.12 RerunQingCloudTestCase

+ 对于运行失败的测试, 重新运行

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| tasks | string | 测试任务列表 | Yes |

##### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send:{
    "action": "RerunQingCloudTestCase",
    "request_type": "QingCloud",
    "tasks": "vm-instance-capture,lb-vxnet"
}
```

+ 返回示例：

```text
recv:{
    "action": "RerunQingCloudTestCaseResponse",
    "ret_code": 0
}

```

#### 1.13 CleanQingCloudTest

+ 清理测试之后遗留的资源

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |

##### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例：

```text
send:{
    "action": "CleanQingCloudTest",
    "request_type": "QingCloud",
}
```

+ 返回示例：

```text
recv:{
    "action": "CleanQingCloudTestResponse",
    "ret_code": 0
}
```

#### 1.14 GetQingCloudTestCasesLog

+ 获取运行失败的测试用例的错误日志

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| task | string | 测试用例名称 | Yes |

##### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| result | list | 测试云平台的状态 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例
```text
send:{
    "action": "GetQingCloudTestCasesLog",
    "request_type": "QingCloud",
    "task": "vm-instance-capture"
}

```

+ 返回示例
```text
recv:{
  "action": "GetQingCloudTestCasesLogResponse",
  "log": {
    "000": "",
    "001": "cmd [safe-guest-sh i-l7fjkkgq \\\"date +%Y-%m-%d_%H:%M:%S -u\\\" 10] on [fourr01n03] time out. exec_time is [10.002]s",
    "002": "cmd [safe-guest-sh i-l7fjkkgq \\\"date +%Y-%m-%d_%H:%M:%S -u\\\" 10] on [fourr01n03] time out. exec_time is [10.003]s",
    "003": "file [/tmp/tmpIdZ1IO] is removed on remote_host [fourr01n03]",
    "004": "file [/tmp/kp-nwpm1n97] is removed on remote_host [fourr01n03]",
    "005": "file [/tmp/tmpb1Gd43] is removed on remote_host [fourr01n03]",
    "006": "Ran 1 test in 2472.441s",
    "007": "",
    "008": "FAILED (failures=1)"
  },
  "ret_code": 0
}
```

#### 1.15 GetQingCloudTestCasesStatus

+ 获取测试用例的运行状态

##### 请求参数

| 参数名 | 类型   | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |

##### 返回参数

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| result | list | 测试云平台的状态 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例
```text
send:{
    "action": "GetQingCloudTestCasesStatus",
    "request_type": "QingCloud"
}
```

+ 返回示例
```text
recv:{
    "action": "GetQingCloudTestCasesStatusResponse",
    "result": [
        {
        "end_time": "2019-04-06 13:15:06",
        "start_time": "2019-04-06 13:14:56",
        "status": "failed",
        "test": "lb-vxnet",
        "description": "测试vxnet负载均衡功能"
        },
        {
        "end_time": "2019-04-06 13:15:12",
        "start_time": "2019-04-06 13:14:56",
        "status": "failed",
        "test": "vm-instance-volume",
        "description": "测试虚拟型主机磁盘的挂载,迁移,备份等功能"
        }
    ],
    "ret_code": 0
}
```

#### 1.16 GetStatus

+ 获取异步任务的状态，返回的状态包括`stepX/failed/successful`。

##### 请求参数

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
    "request_type": "QingCloud",
    "job_action": "TestQingCloud",
}
```

+ 返回示例:

```javascript
recv: {
    "action": "GetStatusResponse",
    "status": "failed",
    "pre_status": "step0",
    "job_action": "TestQingCloud",
    "ret_code": 0
}
```

#### 1.17 GetLog

+ 获取异步任务的日志。

##### 请求参数

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
    "request_type": "QingCloud",
    "job_action": "TestQingCloud",
    "job_id": "j-68mbPHJU"
}
```

+ 返回示例:

```javascript
recv: {
    "action": "GetLogResponse",
    "log":{
        "001": "Error: Can not get the firstbox address, please check it in /pitrix/conf/variables!"
    },
    "job_action": "TestQingCloud",
    "ret_code": 0
}
```

#### 1.18 DeployQingCloudComponent

+ 异步任务: 追加部署各种插件式服务，暂时仅支持`VDI`(桌面云)和`V2V`。

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| config | dict | 环境配置 | Yes |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| job_id | string | 测试云平台的 job id |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例:

```javascript
send: {
    "action": "DeployQingCloudComponent",
    "request_type": "QingCloud",
    "config": {
        "pek3a": {
            "variables": {
                "vdi": {
                    "deploy_vdi": "1",
                }
                "v2v": {
                    "deploy_v2v": "1",
                }
            },
        }
    }
}
```

+ 返回示例:

```javascript
recv: {
    "action": "DeployQingCloudComponentResponse",
    "job_id": "j-68mbPHJX",
    "ret_code": 0
}
```

#### 1.19 CheckQingCloud

+ 检查青云平台

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| request_type | string | 请求类型 | Yes |
| verbose     | string | 是否详细显示结果     | No (default: 1)    |
| nodes | string | 需要检查的节点 | No (default: 'all')    |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| job_id | string | JOB ID |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例:

```javascript
send: {
    "action": "CheckQingCloud",
    "request_type": "QingCloud",
}
```

+ 返回示例:

```javascript
recv: {
    "action": "CheckQingCloudResponse",
    "job_id": "j-OTj6NQJs",
    "ret_code": 0
}
```


#### 1.20 GetQingCloudCheckResult

+ 获取平台检查结果

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| request_type | string | 请求类型 | Yes |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| result | 列表 | 详细的节点的不正常服务列表 |
| qingcloud_status | string | 平台各项服务是否正常 | Normal: 正常, Abnormal: 不正常 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例:

```javascript
send: {
    "action": "GetQingCloudCheckResult",
    "request_type": "QingCloud",
}
```

+ 返回示例:

```javascript
recv: "action": "GetQingCloudCheckResultResponse",
  "qingcloud_status": "Abnormal",
  "result": [
    {
      "hostname": "niner01n01",
      "services": [
        {
          "service": "apache2",
          "status": "Normal"
        },
        {
          "service": "cassandra",
          "status": "Normal"
        },
        {
          "service": "dns",
          "status": "Normal"
        },
      ]
    },
    {
      "hostname": "niner01n02",
      "services": [
        {
          "service": "kdump",
          "status": "Normal"
        },
        {
          "service": "lxcfs",
          "status": "Normal"
        },
        {
          "service": "netconsole",
          "status": "Normal"
        },
      ]
    }
  ],
  "ret_code": 0
}
```


#### 1.21 DescribeConfiguration

+ 获取配置

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| request_type | string | 请求类型 | Yes |
| zone_id | string | ZONE_ID | Yes |
| file_name | string | 指定需要查看的文件 | Yes |
| segment | string | 需要查询的文件具体字段 | Yes |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例:

```javascript
sent:
{
  "PASSWORD": null,
  "USER_ID": null,
  "file_name": "server.yaml",
  "request_type": "QingCloud",
  "segment": "common.hypervisor_policies",
  "zone_id": "express1a"
}
```

+ 返回示例:

```javascript
recv:
{
  "action": "DescribeConfigurationResponse",
  "common.hypervisor_policies": {
    "cache": "lxc,kvm",
    "hadoop": "lxc,kvm",
    "loadbalancer": "lxc,kvm",
    "mongo": "kvm",
    "nfv": "lxc,kvm",
    "rdb": "lxc,kvm",
    "rdb_mysql5.5": "kvm",
    "router": "lxc,kvm"
  },
  "ret_code": 0
}
```


#### 1.22 ModifyConfiguration

+ 修改配置

##### 请求参数

| 参数名 | 类型 | 描述 | 必需性 |
| :----: | :----: | :----: | :----: |
| action | string | API 动作 | Yes |
| request_type | string | 请求类型 | Yes |
| zone_id | string | ZONE_ID | Yes |
| file_name | string | 指定需要修改的文件 | Yes |
| segment | string | 需要修改的文件具体字段 | Yes |

##### 返回参数

+ 总览参数：

| 参数名 | 类型 | 描述 |
| :----: | :----: | :----: |
| action | string | API 动作响应 |
| job_id | string | JOB ID |
| ret_code | integer | 执行成功与否 |

##### 示例

+ 请求示例:

```javascript
sent:
{
  "PASSWORD": null,
  "USER_ID": null,
  "file_name": "server.yaml",
  "request_type": "QingCloud",
  "segment": {
    "account_server": {
      "qingstor_enable": 1
    }
  },
  "zone_id": "express1a"
}
```

+ 返回示例:

```javascript
recv:
{
  "action": "ModifyConfigurationResponse",
  "job_id": "j-EtDxehRL",
  "ret_code": 0
}
```

***
