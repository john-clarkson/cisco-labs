### NeonSAN API Design Reference

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

### 1 NeonSAN

#### 1.0 DescribeNeonSAN

    获取NeonSAN的信息。

* **请求参数**

    - 总览参数

    | 参数名     | 类型    | 描述              | 必需性 |
    | :----     | :----  | :----             | :---- |
    | action    | string | API 动作          | Yes   |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                |
    | :----    | :----   | :----             |
    | action   | string  | API 动作响应       |
    | neonsan | dict | 所查询到的环境信息 |
    | ret_code | integer | 执行成功与否        |

    - 细节参数

    无。

    * **示例**

    - 请求

    ```javascript
    send: {
      "action":"DescribeNeonSAN",
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"DescribeNeonSANResponse",
      "neonsan":{
        "create_time":"2018-09-12 17:43:27",
        "hosts":[],
        "installer_version":"",
        "is_activated":0,
        "is_deployed":0,
        "neonsan_version":"",
        "platform_info":{},
        "platform_name":"neonsan",
        "pre_status":"deploying",
        "status":"failed",
        "update_time":"2018-09-14 17:56:41"
      },
      "ret_code":0
    }
    ```

#### 1.1 ConfigNeonSAN

    配置NeonSAN平台参数，主要是生成 variables 和 settings。

* **请求参数**

    - 总览参数

    | 参数名     | 类型    | 描述              | 必需性 |
    | :----     | :----  | :----             | :---- |
    | action    | string | API 动作          | Yes   |
    | variables | dict   | 环境的变量信息      | Yes   |
    | roles     | dict   | 各个节点的角色信息   | Yes   |

    - 细节参数

    variables, roles 见示例。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                |
    | :----    | :----   | :----             |
    | action   | string  | API 动作响应       |
    | job_id   | string  | 配置NeonSAN的 job id |
    | ret_code | integer | 执行成功与否        |

    - 细节参数

    无。

    * **示例**

    - 请求

    ```javascript
    send: {
      "action":"ConfigNeonSAN",
      "variables":{
        "avail_mgmt_network_pool":"172.16.56.20-172.16.56.40",
        "repl_networks":"192.168.102.0/24",
        "smtp_smarthost":"mail.yunify.com:25",
        "smtp_auth_username":"xxxxxxxx@yunify.com",
        "smtp_auth_password":"xxxxxxxx",
        "receive_alert_email":"xxxx@yunify.com",
        "neonsan_cluster_name": "cluster1"
        "ntp_server_address": "10.10.10.1",
      },
      "roles":{
        "n-ycMgzxoh":"neonsan-alone|neonsan-center,neonsan-store, neonsan-zk, neonsan-db",
        "n-uOw17Q3Z":"neonsan-alone|neonsan-center,neonsan-store, neonsan-zk, neonsan-db",
        "n-VZ9xvyQC":"neonsan-alone|neonsan-center,neonsan-store, neonsan-zk, neonsan-db",
        "n-x28ZDCDx":"neonsan-fused|neonsan-center,neonsan-store",
      }
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"ConfigNeonSANResponse",
      "job_id":"j-68mbPHJU",
      "ret_code":0
    }
    ```

#### 1.2 GetConfigNeonSANStatus

    获取配置 NeonSAN 平台的状态。stepX / failed / successful

* **请求参数**

    - 总览参数

    | 参数名  | 类型    | 描述                 | 必需性 |
    | :----  | :----  | :----               | :----  |
    | action | string | API 动作             | Yes    |
    | job_id | string | 配置NeonSAN的 job id | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名     | 类型    | 描述                         |
    | :----      | :----   | :----                      |
    | action     | string  | API 动作响应                |
    | status     | string  | 所查询到的配置NeonSAN当前状态 |
    | pre_status | string  | 所查询到的配置NeonSAN前一状态 |
    | ret_code   | integer | 执行成功与否                |

    - 细节参数

    无。

    * **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetConfigNeonSANStatus",
      "job_id":"j-68mbPHJU"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"GetConfigNeonSANStatusResponse",
      "ret_code":0,
      "status":"successful",
      "pre_status":"step1"
    }
    ```

#### 1.3 GetConfigNeonSANLog

    获取配置NeonSAN的日志。

* **请求参数**

    - 总览参数

    | 参数名     | 类型   | 描述                       | 必需性 |
    | :----      | :----  | :----                   | :----  |
    | action     | string | API 动作                 | Yes    |
    | job_id     | string | 配置NeonSAN的 job id     | No     |
    | job_status | string | 配置NeonSAN的 job status | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                      |
    | :----    | :----   | :----                   |
    | action   | string  | API 动作响应             |
    | log      | dict    | 所查询到的配置NeonSAN日志  |
    | ret_code | integer | 执行成功与否              |

    - 细节参数

    log 见示例。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetConfigNeonSANLog",
      "job_id":"j-68mbPHJU",
      "job_status":"step0"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"GetConfigNeonSANLogResponse",
      "log":{
        "001":"Parsing the variables conf file [/tmp/variables.conf_2018-06-28-15-19-47] ...",
        "002":"Checking the new variables dict whether is valid ...",
        "003":"Writing the valid variables dict to variables files ...",
        "004":"The variable files has been generated successfully."
      },
      "ret_code":0
    }
    ```

#### 1.4 DeployNeonSAN

    开始部署NeonSAN。

- 总览参数

    | 参数名   | 类型   | 描述                  | 必需性 |
    | :----    | :----  | :----              | :----  |
    | action   | string | API 动作            | Yes    |
    | node_ids | list   | node id 列表        | Yes    |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                |
    | :----    | :----   | :----               |
    | action   | string  | API 动作响应        |
    | job_id   | string  | 部署NeonSAN的 job id |
    | ret_code | integer | 执行成功与否        |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"DeployNeonSAN",
      "node_ids":[
        "n-ycMgzxoh",
        "n-uOw17Q3Z",
        "n-VZ9xvyQC",
      ]
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"DeployNeonSANResponse",
      "job_id":"j-QJMYu7nS",
      "ret_code":0
    }
    ```

#### 1.5 GetDeployNeonSANStatus

    获取部署NeonSAN的状态。stepX / failed / successful

* **请求参数**

    - 总览参数

    | 参数名 | 类型   | 描述                   | 必需性 |
    | :----  | :----  | :----               | :----  |
    | action | string | API 动作             | Yes    |
    | job_id | string | 部署NeonSAN的 job id | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名     | 类型    | 描述                         |
    | :----      | :----   | :----                      |
    | action     | string  | API 动作响应                |
    | status     | string  | 所查询到的部署NeonSAN当前状态  |
    | pre_status | string  | 所查询到的部署NeonSAN前一状态  |
    | ret_code   | integer | 执行成功与否                 |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetDeployNeonSANStatus",
      "job_id":"j-QJMYu7nS"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"GetDeployNeonSANStatusResponse",
      "ret_code":0,
      "status":"failed",
      "pre_status":"step2"
    }
    ```

#### 1.6 GetDeployNeonSANLog

    获取部署NeonSAN的日志。

* **请求参数**

    - 总览参数

    | 参数名     | 类型   | 描述                    | 必需性 |
    | :----      | :----  | :----                   | :----  |
    | action     | string | API 动作                | Yes    |
    | job_id     | string | 部署NeonSAN的 job id     | No     |
    | job_status | string | 部署NeonSAN的 job status | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                      |
    | :----    | :----   | :----                   |
    | action   | string  | API 动作响应             |
    | log      | dict    | 所查询到的部署NeonSAN日志  |
    | ret_code | integer | 执行成功与否              |

    - 细节参数

    log 见示例。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetDeployNeonSANLog",
      "job_id":"j-QJMYu7nS",
      "job_status":"step0"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"GetDeployNeonSANLogResponse",
      "log":{
        "1":"Building the packages allinone ...",
        "2":"Building [pitrix-hosts] ... OK.",
        "3":"Building [pitrix-ks-zookeeper] ... OK.",
        "4":"Building [pitrix-ks-mysql] ... OK.",
        "5":"Building [pitrix-neonsan-monitors] ... OK.",
        "6":"Building [pitrix-neonsan-center] ... OK.",
        "7":"Building [pitrix-neonsan-store] ... OK.",
        "8":"Build the packages allinone Done.",
        "9":"Scanning [/pitrix/repo/indep] ... OK."
      },
      "ret_code":0
    }
    ```

#### 1.7 ScaleNeonSAN

    开始扩容NeonSAN。

- 总览参数

    | 参数名   | 类型   | 描述                  | 必需性 |
    | :----    | :----  | :----              | :----  |
    | action   | string | API 动作            | Yes    |
    | node_ids | list   | node id 列表        | Yes    |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                |
    | :----    | :----   | :----               |
    | action   | string  | API 动作响应        |
    | job_id   | string  | 扩容NeonSAN的 job id |
    | ret_code | integer | 执行成功与否        |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"ScaleNeonSAN",
      "node_ids":[
        "n-ycMgzxoh",
        "n-uOw17Q3Z",
        "n-VZ9xvyQC",
      ]
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"ScaleNeonSANResponse",
      "job_id":"j-QJMYu7nS",
      "ret_code":0
    }
    ```

#### 1.8 GetScaleNeonSANStatus

    获取扩容NeonSAN的状态。stepX / failed / successful

* **请求参数**

    - 总览参数

    | 参数名 | 类型   | 描述                   | 必需性 |
    | :----  | :----  | :----               | :----  |
    | action | string | API 动作             | Yes    |
    | job_id | string | 扩容NeonSAN的 job id | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名     | 类型    | 描述                         |
    | :----      | :----   | :----                      |
    | action     | string  | API 动作响应                |
    | status     | string  | 所查询到的扩容NeonSAN当前状态  |
    | pre_status | string  | 所查询到的扩容NeonSAN前一状态  |
    | ret_code   | integer | 执行成功与否                 |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetScaleNeonSANStatus",
      "job_id":"j-QJMYu7nS"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"GetScaleNeonSANStatusResponse",
      "ret_code":0,
      "status":"failed",
      "pre_status":"step2"
    }
    ```

#### 1.9 GetScaleNeonSANLog

    获取扩容NeonSAN的日志。

* **请求参数**

    - 总览参数

    | 参数名     | 类型   | 描述                    | 必需性 |
    | :----      | :----  | :----                   | :----  |
    | action     | string | API 动作                | Yes    |
    | job_id     | string | 扩容NeonSAN的 job id     | No     |
    | job_status | string | 扩容NeonSAN的 job status | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述                      |
    | :----    | :----   | :----                   |
    | action   | string  | API 动作响应             |
    | log      | dict    | 所查询到的扩容NeonSAN日志  |
    | ret_code | integer | 执行成功与否              |

    - 细节参数

    log 见示例。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"GetScaleNeonSANLog",
      "job_id":"j-QJMYu7nS",
      "job_status":"step0"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"GetScaleNeonSANLogResponse",
      "log":{
        "001":"------------------------------------------------",
        "002":"TARGET NODES:",
        "003":"i-ohtr8hmr,i-1gb7xuwx",
        "004":"------------------------------------------------",
        "005":"TARGET PACKAGES:",
        "006":"pitrix-ins-neonsan-center,pitrix-ins-neonsan-store",
        "007":"------------------------------------------------",
        "008":"Updating [i-1gb7xuwx] with [pitrix-ins-neonsan-center ~ ] ... OK.",
        "009":"Updating [i-ohtr8hmr] with [pitrix-ins-neonsan-center ~ ] ... OK.",
      },
      "ret_code":0
    }
    ```