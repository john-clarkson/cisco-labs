# k8s macvlan CNI driver 
## Topology

```text
|pod eth0|----|macvlan-bridge|-----hostOS eth0|------|outside gateway|
< ------in this case: subnet=172.17.0.0/16---------gateway 172.17.0.1>
```

## Delete your original CNI plugin, in this case=flannel
```sh
$kubectl delete -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
$rm -rf /etc/cni/net.d/*
$ifconfig cni0 down
$ip link delete cni0
$ifconfig flannel.1 down
$ip link delete flannel.1
$rm -rf /var/lib/cni/
$rm -f /etc/cni/net.d/*
```
## Restart kubelet service
```sh
$systemctl restart kubelet
$systemctl status kubelet
$systemctl daemon-reload && systemctl restart kubelet
```

## kubelet status check and log info
```sh
$journalctl -flu kubelet
```
## Make sure your OS has Macvlan binary inside /opt/cni/bin folder, if not. please go to https://github.com/containernetworking/plugins/releases then download binary tar pack then unzip them put in /opt/cni/bin folder
### Example output
```sh
$ls /opt/cni/bin/
$bandwidth firewall host-device  ipvlan  loopback  portmap  sbr tuning bridge dhcp flannel   host-local macvlan   ptp static  vlan
```
### $nano /etc/cni/net.d/10-maclannet.conf

```yaml
{
	"cniVersion":"0.3.1",
	"name": "macvlannet",
	"type": "macvlan",
	"master": "eth0",
	"mode": "bridge",
	"isGateway": true,
	"ipMasq": false,
	"ipam": {
		"type": "host-local",
		"subnet": "172.17.0.0/16",
		"rangeStart": "172.17.0.100",
		"rangeEnd": "172.17.1.200",
		"gateway": "172.17.0.1",
		"routes": [
			{ "dst": "0.0.0.0/0" }
			]
	}
}
```
### Create samplepod to make sure the IP address is we allocate from our configuration above
```sh
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: samplepod
spec:
  containers:
  - name: samplepod
    command: ["/bin/ash", "-c", "trap : TERM INT; sleep infinity & wait"]
    image: alpine
EOF
```
### Verification
```sh
$kubectl get pods -n <your namespaces> -o wide 
```