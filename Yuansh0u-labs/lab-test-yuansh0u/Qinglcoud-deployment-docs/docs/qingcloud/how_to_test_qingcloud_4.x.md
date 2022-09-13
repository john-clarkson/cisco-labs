### 1 功能测试

+ 目前功能测试建议只在全新部署的环境运行, 仅支持`firstbox`操作系统版本为`Ubuntu 16.04.3`和`Ubuntu 16.04.5`的环境。
+ `VLAN`模式下需要先添加上基础网络，才可以开始测试。
+ 测试会创建邮箱为`test@test.com`的测试账户, 若有`VG`节点, 还会创建邮箱为`vbc@test.com`的测试用户，测试结束后，会自动禁用。

#### 1.1 准备测试

+ 若测试环境没有`VG`节点, 需要上传`tr`、`xe`、`s2`的镜像。
+ 若测试环境中有`VG`节点, 需要上传`tr`、`xe`、`ro`、`ks`、`s2`的镜像，并且`tr`目录中需要包含`trustyx64test1.lz4`和`trustyx64test2.lz4`镜像。
+ 若测试环境中有`VG`节点, 测试之前还需要分配`eip`组为`eipg-00000000`的`eip`池, 数量至少在`10`个以上。
+ 记录现有`hyper`的安置组(`plg`), 在`firstbox`上执行`/pitrix/bin/modify_hyper_plgs.sh hyper add sas,sata,ssd`。

#### 1.2 开始测试

+ 开始执行测试: `/pitrix/cli/test-qingcloud.py`。
+ 查看测试状态: `/pitrix/cli/get-test-qingcloud-status.py`。
+ 当`get-test-qingcloud-status.py`的状态为`successful`，表明测试环境已搭建完成，正在运行测试用例。
+ 查看测试用例的状态: `/pitrix/cli/get-qingcloud-testcases-status.py`。
+ 查看指定测试用例的日志: `/pitrix/cli/get-qingcloud-testcases-log.py -t <testcase-name>`。
+ 重新执行失败的测试用例: `/pitrix/cli/run-qingcloud-testcases.py -t <testcase-name1,testcase-name2>`。
+ 当所有的测试用例都运行完成后, 可以执行`/pitrix/cli/clean-qingcloud-test.py`清理测试环境。

***
