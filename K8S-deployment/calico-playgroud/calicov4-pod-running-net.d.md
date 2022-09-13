# Calico CNI net.d default configuration

## $kubectl taint nodes kind-master node-role.kubernetes.io/master-
## $kubectl taint nodes kind-worker node.kubernetes.io/not-ready:NoSchedule-
```YAML
root@kind-control-plane:/etc/cni/net.d# cat 10-calico.conflist 
{
  "name": "k8s-pod-network",
  "cniVersion": "0.3.1",
  "plugins": [
    {
      "type": "calico",
      "log_level": "info",
      "datastore_type": "kubernetes",
      "nodename": "kind-control-plane",
      "mtu": 1440,
      "ipam": {
          "type": "calico-ipam"
      },
      "policy": {
          "type": "k8s"
      },
      "kubernetes": {
          "kubeconfig": "/etc/cni/net.d/calico-kubeconfig"
      }
    },
    {
      "type": "portmap",
      "snat": true,
      "capabilities": {"portMappings": true}
    },
    {
      "type": "bandwidth",
      "capabilities": {"bandwidth": true}
    }
  ]
}
```
```SH
root@kind-control-plane:/etc/cni/net.d# cat calico-kubeconfig 
# Kubeconfig file for Calico CNI plugin.
apiVersion: v1
kind: Config
clusters:
- name: local
  cluster:
    server: https://[10.96.0.1]:443
```
