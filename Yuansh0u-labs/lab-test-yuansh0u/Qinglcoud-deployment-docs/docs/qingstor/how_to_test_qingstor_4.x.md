### 1 部署测试组件
- 部署 Jenkins 和 Cosbench  
    `/pitrix/cli/deploy-qingstor-test.py`

### 2 jenkins 测试

- 浏览器访问 Jenkins x.x.x.x:8888, 点左边菜单 "Manage Jenkins" -> "Configure System", 把 "# of executors" （默认是 2） 改成100
- 开启测试  
    ```
    ssh jenkins0
    docker exec -it jenkins /bin/bash
    /qingstor/bin/enable_all_jobs.sh
    ```

### cosbench 测试(压力测试)
- 通过 `ping cosbench0` 来确定 cosbench0 的 IP 地址.  
    通过 http://<cosbench0 的 IP>:19088/controller  访问 controller 的页面, 后续的测试结果需要通过页面查看和下载.

- 提高 qingstor 账户的 buckets 配额  
    在 portal 页面提高 qingstor 账户的 buckets 配额; 方法:  
    用户 --> 点击 qingstor 账户的 user id --> 配额 --> bucket 数量.

- 配置 cosbench
    * 进入 cosbench0
        ```
        ssh cosbench0
        docker exec -it cosbench /bin/bash
        ```
    * 预先给定的测试案例脚本在 /tmp/workloads 下, 每个 xml 文件包含其指定大小的 read/write 操作
        ```
        [root@cosbench0 ~]# ll /tmp/workloads/
        total 56
        -rw-r--r-- 1 root root 1201 Aug  2 01:01 128k.xml
        -rw-r--r-- 1 root root 1201 Aug  2 01:01 128m.xml
        -rw-r--r-- 1 root root 1193 Aug  2 01:01 16k.xml
        -rw-r--r-- 1 root root 1196 Aug  2 01:01 16m.xml
        -rw-r--r-- 1 root root 1182 Aug  1 18:41 1g.xml
        -rw-r--r-- 1 root root 1190 Aug  2 01:01 1m.xml
        -rw-r--r-- 1 root root 1185 Aug  2 00:27 4k.xml
        -rw-r--r-- 1 root root 1190 Aug  2 01:01 4m.xml
        -rw-r--r-- 1 root root 1201 Aug  2 01:01 512k.xml
        -rw-r--r-- 1 root root 1197 Aug  1 18:41 512m.xml
        -rw-r--r-- 1 root root 1193 Aug  2 01:01 64k.xml
        -rw-r--r-- 1 root root 1194 Aug  1 18:41 64m.xml
        -rw-r--r-- 1 root root 1185 Aug  2 01:01 8k.xml
        -rw-r--r-- 1 root root 1188 Aug  1 18:41 8m.xml
        ```
    * 每个测试用例的配置文件格式相同, 下面以 4k.xml 为例:
        ``` xml
        [root@cosbench0 ~]# cat /tmp/workloads/4k.xml
        <?xml version="1.0" encoding="UTF-8" ?>
        <workload name="qs-benchmark-RW-4K" description="benchmark for qingstor with s3 api">

        <storage type="s3" config="accesskey=HJEBVKMZPXKLFQHLFQJH;secretkey=kUHD5orRJfZaVMqYtSHptLtaSOc1FebjV958TQeJ;endpoint=http://s3.gd2b.stor.yunify.com;path_style_access=true;timeout=60000;" />

        <workflow>

            <workstage name="init">
            <work type="init" workers="1" config="cprefix=benchmark;containers=r(1,3)" />
            </workstage>
        <!-- 4KB RW Begin -->
            <workstage name="4K-prepare">
            <work type="prepare" workers="1000" config="cprefix=benchmark;containers=r(1,3);objects=r(1,10000);sizes=c(4096)B" />
            </workstage>

            <workstage name="4K-read">
            <work name="main" workers="3000" runtime="60">
                <operation type="read" ratio="100" config="cprefix=benchmark;containers=u(1,3);objects=u(1,10000)" />
            </work>
            </workstage>

            <workstage name="4K-write">
            <work name="main" workers="3000" runtime="60">
                <operation type="write" ratio="100" config="cprefix=benchmark;containers=u(1,3);objects=u(10001,20000);sizes=c(4096)B" />
            </work>
            </workstage>
        <!-- 4KB RW End -->
        </workflow>

        </workload>
        ```

        *参数*:  
        workers: 指定并发数量  
        runtime: 运行时间  
        config: cprefix: 指定 bucket name 的前缀; containers: 指定 bucket 的数量  
        objects: 指定 object name 的命名范围, 默认以 myobjects 为前缀  
        sizes: 指定 object 的大小, 单位可以是 B KB  MB GB 等, 因为 cosbench 的单位换算是以 1000 为进制, 为避免歧义, 默认用字节为单位

        *工作流*:  
        每个 workstage 是一个测试阶段;  
        4K-prepare: 测试前的准备工作, 将会向每个 bucket (benchmark1--3) 中上传 100000 个 sizes 为 4096B(4KB) 的 object (myobjects1-10000)  
        4K-read: 读测试, 在指定时间内以指定的并发数反复读取之前上传的 object  
        4K-write: 写测试, 在指定时间内以指定的并发数反复写入 object

        *注意*: 实际中可以根据当前环境的配置来调整 workers 的数量. 并发数并非越高越高, 需要通过 增/减 worker 的数量来观察当前环境的吞吐能力

        测试过程中可以观察访问和存储的负载情况:  
        访问节点: cpu 使用、网卡流量、数据盘的 IO、端口占用数量等  
        存储节点: cpu 使用、存储的 IO

        *命令*:  
        top: 查看 CPU 的使用情况  
        nload: 查看网卡流量  
        iostat -xmd 1 : 查看磁盘 IO  
        netstat -an |wc -l  : 查看端口占用数量(一般在 30 w 左右都是安全的)

    * 运行测试  
        `./cosbench/cli.sh submit /tmp/workloads/4k.xml`  
        然后可以通过页面查看测试进度和结果.

- 清理测试
    在做用完单元测试和压测后, 删除jenkins  
    `docker stop jenkins; docker rm jenkins; docker rmi jenkins`