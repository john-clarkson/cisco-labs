# k8s mofify kube-proxy from iptables to IPVS

```yaml
##change kube-proxy to ipvs mode
$kubectl edit configmap kube-proxy -n kube-system
##change mode from "" to ipvs
mode: ipvs
```
## Kill all kube-proxy pods
```sh
$kubectl get po -n kube-system
$kubectl delete po -n kube-system <pod-name>
##Verify kube-proxy is started with ipvs proxier
$kubectl logs [kube-proxy pod] | grep "Using ipvs Proxier"
$kubectl logs kube-proxy-cjhkz | grep "Using ipvs Proxier"
I0705 01:49:52.617137       1 server_others.go:259] Using ipvs Proxier.
```
