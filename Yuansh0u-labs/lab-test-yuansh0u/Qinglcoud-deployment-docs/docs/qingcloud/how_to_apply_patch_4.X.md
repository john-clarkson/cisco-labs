### 1 应用PATCH包

#### 1.1 Installer的PATCH包

##### 1.1.1 使用要求

+ 使用`Installer`的`Patch`包的前提是`IaaS`的版本一致。
+ 查看当前环境`IaaS`的版本: `current`中的`qingcloud`对应的值:

```bash
cat /pitrix/version.json
```

```text
{
    "current": {
        "installer": "4.2.1",
        "patch": "20190410",
        "qingcloud": "20190318",
        "upgrade": "20190318"
    },
    "old": []
}
```

+ `Patch`包的名称为: `installer-INSTALLER的版本-IAAS的版本-patch.tar.gz`
  + 示例`1`: `installer-4.2.5-20190318-patch.tar.gz`, `IaaS`版本相同, `Installer`主版本相同, 可以直接使用`PATCH`包。
  + 示例`2`: `installer-4.3.5-20190318-patch.tar.gz`, `IaaS`版本相同, `Installer`主版本不同, 可以直接使用`PATCH`包。
  + 示例`3`: `installer-4.4.5-20190710-patch.tar.gz`, `IaaS`版本不同, `Installer`主版本不同, 不可以使用`PATCH`包升级，请参考`how_to_upgrade_qingcloud_4.X.md`文档升级`IaaS`版本。

##### 1.1.2 使用方法

+ 到发布服务器上下载对应的`Installer`的`Patch`包。
+ 在`qingcloud-firstbox`上解压:

```bash
tar -zxf installer-4.2.5-20190318-patch.tar.gz -C /root/
```

+ 执行脚本:

```bash
/root/installer-4.2.5-20190318-patch/apply-patch.sh
```

+ 检查`firstbox`上的服务状态:

```bash
supervisorctl status
```

#### 1.2 IaaS的Patch包

##### 1.2.1 使用要求

+ 使用`IaaS`的`Patch`包的前提是`IaaS`的版本一致。
+ 查看当前环境`IaaS`的版本: `current`中的`qingcloud`对应的值:

```bash
cat /pitrix/version.json
```

```text
{
    "current": {
        "installer": "4.2.1",
        "patch": "20190410",
        "qingcloud": "20190318",
        "upgrade": "20190318"
    },
    "old": []
}
```

+ `Patch`包的名称为: `repo-IAAS的版本-patch-PATCH的版本.tar.gz`
  + 示例`1`: `repo-20190318-patch-20190410.tar.gz`, `IaaS`版本相同, 可以直接使用`PATCH`包。
  + 示例`2`: `repo-20190318-patch-20190520.tar.gz`, `IaaS`版本相同, 可以直接使用`PATCH`包。
  + 示例`3`: `repo-20190710-patch-20190830.tar.gz`, `IaaS`版本不同, 不可以使用`PATCH`包升级，请参考`how_to_upgrade_qingcloud_4.X.md`文档升级`IaaS`版本。

+ `Patch`包由`Reno`编译发布，由`Installer`推送邮件至`Service`团队。
+ `Patch`包分为`可选更新`, `建议更新`，`必须更新`。
    + `可选更新`: 针对某一类环境更新的包，比如针对`hyper-sanc`模式，未部署此模式的可不更新。
    + `建议更新`: 更新优化了代码，修复某些`Bug`，建议所有环境更新。
    + `必须更新`: 修复了重大`Bug`，需要所有环境必须马上更新的包。

##### 1.2.2 使用方法

+ 到发布服务器上下载对应的`IaaS`的`Patch`包。
+ 在`qingcloud-firstbox`上解压:

```bash
tar -zxf repo-20190318-patch-20190410.tar.gz -C /root/
```

+ 执行脚本:

```bash
/root/repo-20190318-patch-20190410/apply-patch.sh
```

+ 上述脚本仅更新了`repo`仓库，未更新包到对应节点，需要手动更新。
+ 请根据邮件内容执行更新操作。

***
