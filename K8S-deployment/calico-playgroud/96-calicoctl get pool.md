# Calicoctl get pool-dual-stack

### $calicoctl get ippool default-ipv4-ippool -o yaml
```yaml
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  creationTimestamp: "2020-07-14T01:33:13Z"
  name: default-ipv4-ippool
  resourceVersion: "3469"
  uid: 937b3885-4442-4899-8c85-69af3ac42674
spec:
  blockSize: 26
  cidr: 192.168.250.0/24
  ipipMode: Always
  natOutgoing: true
  nodeSelector: all()
  vxlanMode: Never
```


### $calicoctl get ippool default-ipv6-ippool -o yaml
```YAML
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  creationTimestamp: "2020-07-18T01:39:19Z"
  name: default-ipv6-ippool
  resourceVersion: "3495"
  uid: 6c45f8e7-9005-4610-9f37-6a8900c8d254
spec:
  blockSize: 122
  cidr: fd20::/80
  ipipMode: Never
  nodeSelector: all()
  vxlanMode: Never
```