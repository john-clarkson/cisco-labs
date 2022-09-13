#### 对接

- 查询 qingstor 得到相关信息, 将 qingcloud 的 firstbox 中的 `/pitrix/conf/variables/variables.yaml` 配置文件中的 support_qingstor 改为 1, 将 dns_trusted_segment, qs_network, qs_bridge_vip, qs_public_key, qs_dns_master, qs_dns_slave 填入该文件中对应的字段，将qs节点的公钥写入配置中的公钥文件路径  
    ```yaml
    support_qingstor: 1
    qingstor:
      # the qingstor network segment that can iaas dns transfer
      dns_trusted_segments:
        - '172.16.80.0/24'
      # all network belonging to the qingstor
      qs_networks:
        - '172.16.80.200/24-172.16.80.250/24'
      # qingstor bridge vip
      qs_bridge_vip: '172.16.80.240'
      # the public key of qingstor proxy
      qs_public_key: '/pitrix/conf/variables/qs_public_key.pub'
      # qingstor dns server address
      qs_dns_master: '172.16.80.201'
      qs_dns_slave: '172.16.80.202'
    ```

- 生成新的安装包  
    `/pitrix/build/build_pkgs_allinone.sh` 重新打包安装包.  

- 在 iaas 部署 qingstor 相关包  
    `/pitrix/upgrade/update_nodes.sh <zone_id>-dnsmaster pitrix-ks-dnsmaster-qingstor`  
    `/pitrix/upgrade/update_nodes.sh <zone_id>-proxy pitrix-ks-proxy-qingstor`  
    `/pitrix/upgrade/update_nodes.sh <zone_id>-webservice pitrix-ks-webservice-website-qingstor`  

- 更新global-conf  
    `/pitrix/upgrade/update_nodes.sh all pitrix-global-conf`
