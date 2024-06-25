somesaydjohn## Nginx-ingress controller installation
## cert-manager ref link
https://cert-manager.io/docs/tutorials/
```sh
##install helm nginx-ingress controller
$ helm install stable/nginx-ingress --name helm-nginx-in --set rbac.create=true
NAME:   helm-nginx-in
LAST DEPLOYED: Mon Jul  6 13:25:38 2020
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ClusterRole
NAME                         CREATED AT
helm-nginx-in-nginx-ingress  2020-07-06T05:25:39Z

==> v1/ClusterRoleBinding
NAME                         ROLE                                     AGE
helm-nginx-in-nginx-ingress  ClusterRole/helm-nginx-in-nginx-ingress  0s

==> v1/Deployment
NAME                                         READY  UP-TO-DATE  AVAILABLE  AGE
helm-nginx-in-nginx-ingress-controller       0/1    1           0          0s
helm-nginx-in-nginx-ingress-default-backend  0/1    1           0          0s

==> v1/Pod(related)
NAME                                                          READY  STATUS             RESTARTS  AGE
helm-nginx-in-nginx-ingress-controller-66b5459646-7w8t4       0/1    ContainerCreating  0         0s
helm-nginx-in-nginx-ingress-default-backend-65546798d5-s6k67  0/1    ContainerCreating  0         0s
helm-nginx-in-nginx-ingress-controller-66b5459646-7w8t4       0/1    ContainerCreating  0         0s
helm-nginx-in-nginx-ingress-default-backend-65546798d5-s6k67  0/1    ContainerCreating  0         0s

==> v1/Role
NAME                         CREATED AT
helm-nginx-in-nginx-ingress  2020-07-06T05:25:39Z

==> v1/RoleBinding
NAME                         ROLE                              AGE
helm-nginx-in-nginx-ingress  Role/helm-nginx-in-nginx-ingress  0s

==> v1/Service
NAME                                         TYPE          CLUSTER-IP      EXTERNAL-IP  PORT(S)                     AGE
helm-nginx-in-nginx-ingress-controller       LoadBalancer  10.99.124.238   <pending>    80:31617/TCP,443:32135/TCP  0s
helm-nginx-in-nginx-ingress-default-backend  ClusterIP     10.105.184.152  <none>       80/TCP                      0s

==> v1/ServiceAccount
NAME                                 SECRETS  AGE
helm-nginx-in-nginx-ingress          1        0s
helm-nginx-in-nginx-ingress-backend  1        0s


NOTES:
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace default get services -o wide -w helm-nginx-in-nginx-ingress-controller'

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
##fake externalip bind to nginx-controller. 4.3.2.1

$ kubectl patch service helm-nginx-in-nginx-ingress-controller -p '{"spec": {"type": "LoadBalancer", "externalIPs":["4.3.2.1"]}}'
```

## Add testing pods foobar with service
```yaml
kind: Pod
apiVersion: v1
metadata:
  name: foo-app
  labels:
    app: foo
spec:
  containers:
  - name: foo-app
    image: hashicorp/http-echo:0.2.3
    args:
    - "-text=foo"
---
kind: Service
apiVersion: v1
metadata:
  name: foo-service
spec:
  selector:
    app: foo
  ports:
  # Default port used by the image
  - port: 5678
---
kind: Pod
apiVersion: v1
metadata:
  name: bar-app
  labels:
    app: bar
spec:
  containers:
  - name: bar-app
    image: hashicorp/http-echo:0.2.3
    args:
    - "-text=bar"
---
kind: Service
apiVersion: v1
metadata:
  name: bar-service
spec:
  selector:
    app: bar
  ports:
  # Default port used by the image
  - port: 5678
```
## backend PATH means URL=somesayingtls-prod.com

```yaml
apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
  spec:
    rules:
      - host: somesayingtls-prod.com
        http:
          paths:
            - backend:
                serviceName: bar-service
                servicePort: 5678
              path: /
            - backend:
                serviceName: foo-service
                servicePort: 5678
              path: /  
              
```
## backend PATH  means URL=somesayingtls-prod.com/foo
## backend PATH  means URL=somesayingtls-prod.com/bar



```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
  - host: somesayingtls-prod.com
    http:
      paths:
      - path: /foo
        backend:
          serviceName: foo-service
          servicePort: 5678
      - path: /bar
        backend:
          serviceName: bar-service
          servicePort: 5678
```

## Deploy letencrypt with cert-manager
```sh
## nginx-ingress with letsencrypt
```sh
$kubectl -n kube-system create serviceaccount tiller
$kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
$helm init --service-account tiller
$helm install \
  --name cert-manager \
  --namespace cert-manager \
  --version v0.15.0 \
  --set installCRDs=true \
  jetstack/cert-manager 


$kubectl apply -f kuard-nginx-ingress-with-staging-issuer.yaml
clusterissuer.cert-manager.io/letsencrypt-staging created

$kubectl get clusterissuers.cert-manager.io 
$kubectl describe clusterissuers.cert-manager.io letsencrypt-staging 


echo ##install nginx-ingress conntroller, namespace=default
helm install stable/nginx-ingress --name helm-nginx-in --set rbac.create=true
echo ##create fake externalIPs(4.3.2.1) patch to svc nginx-controller.

##
#NOTES:
#cert-manager has been deployed successfully!
#In order to begin issuing certificates, you will need to set up a ClusterIssuer
#or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).

echo watch 'kubectl describe certificate |grep 'Events:' -A 20'
echo kubectl get certificate kubectl get challange  
```

## Deploy acme certificate
```sh
## deploy issuer
$kubectl apply -f /home/hitler/kuber-deployment/hitler-testing-yaml/nginx-ingress-with-letsencrypt-tls-offloading/issuer-working.yaml

$kubectl apply -f kuard-nginx-ingress-with-production-issuer.yaml
## expose ingress-controller EIP
$kubectl patch service nginx-ingress-controller -p {"spec": {"type": "LoadBalancer", "externalIPs":["4.3.2.1"]}}
```
## Modify your client hosts file for domain testing working, in this case, we assume somesayingtls.prod.com is our domain name, 4.3.2.1 is my public IP address
```sh
$cat /etc/hosts
127.0.0.1	localhost
127.0.1.1	hitler-k8s

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
4.3.2.1 somesayingtls-prod.com
/
```
open browser https://somesayingtls-prod.com

```sh
$curl somesayingtls-prod.com
<html>
<head><title>308 Permanent Redirect</title></head>
<body>
<center><h1>308 Permanent Redirect</h1></center>
<hr><center>nginx/1.17.10</center>
</body>
</html>
$
```










```sh
