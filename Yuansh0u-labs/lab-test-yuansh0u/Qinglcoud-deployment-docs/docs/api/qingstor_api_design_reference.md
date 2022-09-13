### QingStor API Design Reference

### 0 公共 Public

    API 公共参数，包含请求参数和返回参数

* **请求参数**

    | 参数名   | 类型   | 描述           | 必需性 |
    | :----    | :----  | :----          | :----  |
    | action   | string | API 动作       | Yes    |
    | USER_ID  | string | 用户 ID        | Yes    |
    | PASSWORD | string | 用户密码(密文) | Yes    |

    USER_ID 同 user_id，PASSWORD 为 password 的加密值，二者一起传入，校验用户身份。
    为了避免与 User 里的 user_id 和 password 这两个参数产生歧义与混淆，故全部大写表示。

* **返回参数**

    | 参数名   | 类型    | 描述         |
    | :----    | :----   | :----        |
    | action   | string  | API 动作响应 |
    | ret_code | integer | 执行成功与否 |

    ret_code 为 0 ，正常返回；ret_code 为 非0，异常返回。

### 1 QingStor

#### 1.1 DescribeQingStor

    获取云平台信息。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述         | 必需性 |
    | :----    | :----  | :----        | :----  |
    | action   | string | API 动作     | Yes    |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名    | 类型    | 描述               |
    | :----     | :----   | :----              |
    | action    | string  | API 动作响应       |
    | qingstor | dict    | 所查询到的环境信息 |
    | ret_code  | integer | 执行成功与否       |

    - 细节参数

    qingstor 见示例。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"DescribeQingStor",
    }
    ```

    - 返回

    ```javascript
    recv: {
    "action":"DescribeQingStorResponse",
    "qingstor":{
        "console_id":"test",
        "create_time":"2018-08-28 14:27:32",
        "domain":"qingstor.me",
        "hosts":[],
        "installer_version":"4.0",
        "is_activated":0,
        "is_deployed":1,
        "platform_info":{},
        "platform_name":"qingstor",
        "pre_status":"deploying",
        "qingstor_version":"20181001",
        "status":"running",
        "update_time":"2018-09-10 16:36:23"
    },
    "ret_code":0
    }
    ```


#### 1.2 ConfigQingStor

    配置 QingStor 平台参数，主要是配置 qs_installer_env_config.yml。

* **请求参数**

    - 总览参数

    | 参数名     | 类型    | 描述                      | 必需性 |
    | :----     | :----  | :----                     | :---- |
    | action    | string | API 动作                   | Yes   |
    | qs_conf   | dict   | 环境的变量信息及节点角色      | Yes   |

    - 细节参数

    qs_conf 见示例。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                |
    | :----    | :----   | :----             |
    | action   | string  | API 动作响应       |
    | job_id   | string  | 配置QingStor的 job id |
    | ret_code | integer | 执行成功与否        |

    - 细节参数

    无。

    * **示例**

    - 请求

    ```javascript
    send: {
      "action":"ConfigQingStor",
      "qs_conf":{
            "firstbox": "127.0.0.1",
            "ansible_ssh_pass": "Zhu88jie",
            "with_iaas": False,
            "zone_id": "test",
            "iaas_domain": "test.com",
            "global_domain": "stor.test.com",
            "qs_network": [
                "192.168.10.1/24"
            ],
            "use_cassandra": True
        },
        "access_nodes": {
            "intranet": {
                "interface": "eth0",
                "nodes": [ "node_test1", "node_test2", "node_test3" ],
                "vips": [ "172.17.0.13", "172.17.0.14", "172.17.0.15" ],
                "bridge_vip": "172.17.0.100",
            }
        },
        "storage_nodes": [
            {
                "cluster_id": 0,
                "volume": "vol0",
                "vol_type": "replicate",
                "ec_type": 2,
                "replica": 3,
                "raid": False,
                "storage_class": "standard",
                "readonly": False,
                "brick_count": 2,
                "block": "sdc",
                "nodes": [ "node_test4", "node_test5", "node_test6" ],
            }
        ]
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"ConfigQingStorResponse",
      "job_id":"j-68mbPHJU",
      "ret_code":0
    }
    ```

#### 1.3 GetConfigQingStorStatus

    获取配置 QingStor 平台的状态。stepX / failed / successful

* **请求参数**

    - 总览参数

    | 参数名  | 类型    | 描述                 | 必需性 |
    | :----  | :----  | :----               | :----  |
    | action | string | API 动作             | Yes    |
    | job_id | string | 配置QingStor的 job id | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名     | 类型    | 描述                         |
    | :----      | :----   | :----                      |
    | action     | string  | API 动作响应                |
    | status     | string  | 所查询到的配置QingStor当前状态 |
    | pre_status | string  | 所查询到的配置QingStor前一状态 |
    | ret_code   | integer | 执行成功与否                |

    - 细节参数

    无。

    * **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetConfigQingStorStatus",
      "job_id":"j-68mbPHJU"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"GetConfigQingStorStatusResponse",
      "ret_code":0,
      "status":"successful",
      "pre_status":"step1"
    }
    ```

##### 1.4 GetConfigQingStorLog

    获取配置QingStor的日志。

* **请求参数**

    - 总览参数

    | 参数名     | 类型   | 描述                       | 必需性 |
    | :----      | :----  | :----                   | :----  |
    | action     | string | API 动作                 | Yes    |
    | job_id     | string | 配置QingStor的 job id     | No     |
    | job_status | string | 配置QingStor的 job status | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                      |
    | :----    | :----   | :----                   |
    | action   | string  | API 动作响应             |
    | log      | dict    | 所查询到的配置QingStor日志  |
    | ret_code | integer | 执行成功与否              |

    - 细节参数

    log 见示例。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetConfigQingStorLog",
      "job_id":"j-68mbPHJU",
      "job_status":"step0"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"GetConfigQingStorLogResponse",
      "log":{
      },
      "ret_code":0
    }
    ```

##### 1.5 DeployQingStor

    开始部署QingStor。

- 总览参数

    | 参数名   | 类型   | 描述                  | 必需性 |
    | :----    | :----  | :----              | :----  |
    | action   | string | API 动作            | Yes    |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名    | 类型     | 描述                   |
    | :----    | :----   | :----                  |
    | action   | string  | API 动作响应            |
    | job_id   | string  | 部署QingStor的 job id   |
    | ret_code | integer | 执行成功与否             |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"DeployQingStor",
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"DeployQingStorResponse",
      "job_id":"j-QJMYu7nS",
      "ret_code":0
    }
    ```

##### 1.6 GetDeployQingStorStatus

    获取部署QingStor的状态。stepX / failed / successful

* **请求参数**

    - 总览参数

    | 参数名 | 类型   | 描述                   | 必需性 |
    | :----  | :----  | :----               | :----  |
    | action | string | API 动作             | Yes    |
    | job_id | string | 部署QingStor的 job id | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名     | 类型    | 描述                         |
    | :----      | :----   | :----                      |
    | action     | string  | API 动作响应                |
    | status     | string  | 所查询到的部署QingStor当前状态  |
    | pre_status | string  | 所查询到的部署QingStor前一状态  |
    | ret_code   | integer | 执行成功与否                 |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetDeployQingStorStatus",
      "job_id":"j-QJMYu7nS"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"GetDeployQingStorStatusResponse",
      "ret_code":0,
      "status":"failed",
      "pre_status":"step2"
    }
    ```

##### 1.7 GetDeployQingStorLog

    获取部署QingStor的日志。

* **请求参数**

    - 总览参数

    | 参数名     | 类型   | 描述                    | 必需性 |
    | :----      | :----  | :----                   | :----  |
    | action     | string | API 动作                | Yes    |
    | job_id     | string | 部署QingStor的 job id     | No     |
    | job_status | string | 部署QingStor的 job status | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                      |
    | :----    | :----   | :----                   |
    | action   | string  | API 动作响应             |
    | log      | dict    | 所查询到的部署QingStor日志  |
    | ret_code | integer | 执行成功与否              |

    - 细节参数

    log 见示例。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetDeployQingStorLog",
      "job_id":"j-QJMYu7nS",
      "job_status":"step0"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"GetDeployQingStorLogResponse",
      "log":{
      },
      "ret_code":0
    }
    ```

##### 1.8 ScaleQingStorAccess

扩容对象存储控制节点。

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
    | job_id   | string  | 扩容云平台的 job id |
    | ret_code | integer | 执行成功与否        |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"ScaleQingStorAccess",
      "node_ids":[
        {"node_id": "n-test7", "vip": "172.16.0.201"},
        {"node_id": "n-test8", "vip": "172.16.0.202"},
        {"node_id": "n-test9", "vip": "172.16.0.203"}
      ]
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"ScaleQingStorAccessResponse",
      "job_id":"j-QJMYu7nS",
      "ret_code":0
    }
    ```

##### 1.9 ScaleQingStorStorage

扩容对象存储存储节点

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
    | job_id   | string  | 扩容云平台的 job id |
    | ret_code | integer | 执行成功与否        |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
        "action":"ScaleQingStorStorage",
        "storage_nodes": [
            {
                "cluster_id": 0,
                "volume": "vol0",
                "vol_type": "replicate",
                "ec_type": 2,
                "replica": 3,
                "raid": False,
                "storage_class": "standard",
                "readonly": False,
                "brick_count": 2,
                "block": "sdc",
                "nodes": [
                    "node_id": "n-test11",
                    "node_id": "n-test12",
                    "node_id": "n-test13",
                ],
            }
        ]
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"ScaleQingStorStorageResponse",
      "job_id":"j-QJMYu7nS",
      "ret_code":0
    }
    ```