# Coredns testing note, K8s VERSION:1.18.2(KIND)

### DNS per pod basis, ref link
### https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#:~:text=DNS%20policies%20can%20be%20set,that%20the%20pods%20run%20on

#
## busybox is not working for some reason~

```sh
$kubectl exec -it busybox-deployment1-65ff9b6c7b-k48rv sh
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl kubectl exec [POD] -- [COMMAND] instead.
/ # nslookup kubernetes.default
Server:         10.96.0.10
Address:        10.96.0.10:53

** server can't find kubernetes.default: NXDOMAIN

*** Can't find kubernetes.default: No answer

/ # 

```

## DNSbox is working perfectly well.
```sh
$kubectl exec -ti dnsbox-deployment-8485677597-hqpcl sh

/ # nslookup kubernetes.default
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1

/ # nslookup nginx.kube-system
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   nginx.kube-system.svc.cluster.local
Address: 10.102.94.80
/ #apk update
/ #apk add curl
/ # curl nginx.kube-system
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
/ # 

/ # ping www.google.com
PING www.google.com (172.217.25.4): 56 data bytes
64 bytes from 172.217.25.4: seq=0 ttl=126 time=58.381 ms

##under kube-system namespace.
$kubectl create deployment nginx --image=nginx
deployment.apps/nginx created
$kubectl expose deployment nginx --port 80
service/nginx exposed
$kubectl get svc
NAME       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10     <none>        53/UDP,53/TCP,9153/TCP   65m
nginx      ClusterIP   10.102.94.80   <none>        80/TCP                   8s
```