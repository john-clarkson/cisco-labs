### API Design Reference

#### 0 公共 Public

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


#### 1 作业 Job

##### 1.1 DescribeJobs

    获取该环境作业信息。

* **请求参数**

    - 总览参数

    | 参数名     | 类型   | 描述         | 必需性 |
    | :----      | :----  | :----        | :----  |
    | action     | string | API 动作     | Yes    |
    | job_ids    | list   | job id 列表  | No     |
    | job_action | string | job 动作     | No     |
    | job_type   | string | job 类型     | No     |
    | owner      | string | job 所有者   | No     |
    | status     | string | job 现在状态 | No     |
    | pre_status | string | job 前一状态 | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名      | 类型    | 描述               |
    | :----       | :----   | :----              |
    | action      | string  | API 动作响应       |
    | job_set     | list    | 所查询到的作业列表 |
    | total_count | integer | 所查询到的作业数量 |
    | ret_code    | integer | 执行成功与否       |

    - 细节参数

    job_set 见示例。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"DescribeJobs",
      "job_ids":[
        "j-68mbPHJU",
        "j-QJMYu7nS"
      ]
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"DescribeJobsResponse",
      "job_set":[
        {
          "create_time":"2017-10-10 15:23:56",
          "job_action":"ConfigQingCloud",
          "job_id":"j-68mbPHJU",
          "job_type":"QingCloud",
          "resources":{
            "node_ids":[
              "n-xER6zjlP",
              "n-uMhpTXdl",
              "n-K6QGly84",
              "n-B1QNEi6K",
              "n-45OipPK7",
              "n-VGEXtdIc"
            ]
          },
          "owner":"usr-00000000",
          "status":"successful",
          "pre_status":"step1",
          "update_time":"2017-10-10 15:24:47"
        },
        {
          "create_time":"2017-10-10 15:49:35",
          "job_action":"DeployQingCloud",
          "job_id":"j-QJMYu7nS",
          "job_type":"QingCloud",
          "resources":{
            "node_ids":[
              "n-xER6zjlP",
              "n-B1QNEi6K",
              "n-45OipPK7",
              "n-VGEXtdIc",
              "n-K6QGly84",
              "n-uMhpTXdl"
            ],
            "vbc_route":[
              "ip route add 10.10.50.0/24 via 172.16.50.129",
              "ip route add 10.10.51.0/24 via 172.16.50.130"
            ],
            "hosts":[
              "172.18.50.2 console.devopscloud.com supervisor.devopscloud.com appcenter.devopscloud.com api.devopscloud.com",
              "172.18.50.2 cb0test.devopscloud.com"
            ]
          },
          "owner":"usr-00000000",
          "status":"successful",
          "pre_status":"step4",
          "update_time":"2017-10-10 16:56:58"
        }
      ],
      "ret_code":0,
      "total_count":2
    }
    ```

##### 1.2 DescribeLatestJob

    获取该环境最新的作业信息。

* **请求参数**

    - 总览参数

    | 参数名     | 类型   | 描述         | 必需性 |
    | :----      | :----  | :----        | :----  |
    | action     | string | API 动作     | Yes    |
    | job_type   | string | job 类型     | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名      | 类型    | 描述               |
    | :----       | :----   | :----              |
    | action      | string  | API 动作响应       |
    | job         | dict    | 所查询到的作业信息 |
    | ret_code    | integer | 执行成功与否      |

    - 细节参数

    job 见示例。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"DescribeLatestJob",
      "job_type": "neonsan"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"DescribeLatestJobResponse",
      "job":{
        "create_time":"2018-09-18 16:59:50",
        "directive":{
          "PASSWORD":"emh1ODhqaWU=",
          "USER_ID":"usr-00000000",
          "access_key_id":"",
          "action":"ScaleNeonSAN",
          "expires":"2018-09-18T09:04:22Z",
          "lang":"zh-CN",
          "node_ids.1":"n-zt6A9RD7",
          "node_ids.2":"n-Th9VOkx5",
          "signature":"fSgJS1KrM9XAwlmo29hRFQ5K/OwRpVC5B3vRxLVsPG4=",
          "signature_method":"HmacSHA256",
          "signature_version":"1",
          "time_stamp":"2018-09-18T09:04:02Z"
        },
        "job_action":"ScaleNeonSAN",
        "job_id":"j-3K2CQ4h6",
        "job_type":"neonsan",
        "owner":"usr-00000000",
        "pre_status":"step4",
        "resources":{
          "node_ids":[
            "n-zt6A9RD7",
            "n-Th9VOkx5"
          ]
        },
        "status":"successful",
        "update_time":"2018-09-18 17:22:52"
      },
      "ret_code":0
    }
    ```
