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


#### 1 用户 User

##### 1.1 CreateUser

    创建新用户, 需要 admin 权限。

* **请求参数**

    - 总览参数

    | 参数名    | 类型   | 描述           | 必需性 |
    | :----     | :----  | :----          | :----  |
    | action    | string | API 动作       | Yes    |
    | user_name | string | 用户名         | Yes    |
    | password  | string | 用户密码(明文) | Yes    |
    | email     | string | 用户邮箱       | Yes    |
    | role      | string | 用户角色       | No     |
    | status    | string | 用户状态       | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述           |
    | :----    | :----   | :----          |
    | action   | string  | API 动作响应   |
    | user_id  | string  | 用户 ID        |
    | password | string  | 用户密码(密文) |
    | ret_code | integer | 执行成功与否   |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"CreateUser",
      "user_name":"test",
      "password":"zhu88jie",
      "email":"test@installer.com",
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"CreateUserResponse",
      "user_id":"usr-hsyt872s",
      "password":"9hSFs72OL",
      "ret_code":0
    }
    ```

##### 1.2 VerifyUser

    校验用户信息，用户名和邮箱至少提供一个, 此 API 无需用户鉴权。

* **请求参数**

    - 总览参数

    | 参数名    | 类型   | 描述           | 必需性 |
    | :----     | :----  | :----          | :----  |
    | action    | string | API 动作       | Yes    |
    | user_name | string | 用户名         | Yes/No |
    | password  | string | 用户密码(明文) | Yes    |
    | email     | string | 用户邮箱       | Yes/No |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述           |
    | :----    | :----   | :----          |
    | action   | string  | API 动作响应   |
    | user_id  | string  | 用户 ID        |
    | password | string  | 用户密码(密文) |
    | ret_code | integer | 执行成功与否   |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"VerifyUser",
      "user_name":"test",
      "password":"zhu88jie"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"VerifyUserResponse",
      "user_id":"usr-hsyt872s",
      "password":"9hSFs72OL",
      "ret_code":0
    }
    ```

##### 1.3 DescribeUsers

    获取该环境用户信息。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述         | 必需性 |
    | :----    | :----  | :----        | :----  |
    | action   | string | API 动作     | Yes    |
    | user_ids | list   | 用户 ID 列表 | No     |
    | role     | string | 用户角色     | No     |
    | status   | string | 用户状态     | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名      | 类型    | 描述               |
    | :----       | :----   | :----              |
    | action      | string  | API 动作响应       |
    | user_set    | list    | 所查询到的用户列表 |
    | total_count | integer | 所查询到的用户数量 |
    | ret_code    | integer | 执行成功与否       |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"DescribeUsers",
      "user_ids":[
        "usr-test1234"
      ]
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"DescribeUsersResponse",
      "user_set":[],
      "total_count":0,
      "ret_code":0
    }
    ```

##### 1.4 DeleteUsers

    删除环境里的用户。

* **请求参数**

    - 总览参数

    | 参数名   | 类型   | 描述               | 必需性 |
    | :----    | :----  | :----              | :----  |
    | action   | string | API 动作           | Yes    |
    | user_ids | list   | 待删除用户 ID 列表 | Yes    |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名   | 类型    | 描述               |
    | :----    | :----   | :----              |
    | action   | string  | API 动作响应       |
    | user_ids | list    | 所删除用户 ID 列表 |
    | ret_code | integer | 执行成功与否       |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"DeleteUsers",
      "user_ids":[
        "usr-test1234"
      ]
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"DeleteUsersResponse",
      "user_ids":[
        "usr-test1234"
      ],
      "ret_code":0
    }
    ```

##### 1.5 ModifyUserAttributes

    修改用户信息。

* **请求参数**

    - 总览参数

    | 参数名    | 类型   | 描述           | 必需性 |
    | :----     | :----  | :----          | :----  |
    | action    | string | API 动作       | Yes    |
    | user_id   | string | 用户 ID        | Yes    |
    | user_name | string | 用户名         | No     |
    | password  | string | 用户密码(明文) | No     |
    | email     | string | 用户邮箱       | No     |
    | role      | string | 用户角色       | No     |
    | status    | string | 用户状态       | No     |

    - 细节参数

    无。

* **返回参数**

    - 总览参数

    | 参数名      | 类型    | 描述               |
    | :----       | :----   | :----              |
    | action      | string  | API 动作响应       |
    | ret_code    | integer | 执行成功与否       |

    - 细节参数

    无。

* **示例**

    - 请求

    ```javascript
    send: {
      "action":"ModifyUserAttributes",
      "user_id":"usr-test1234",
      "password":"zhu1241jie"
    }
    ```

    - 返回

    ```javascript
    recv: {
      "action":"ModifyUserAttributesResponse",
      "ret_code":0
    }
    ```
