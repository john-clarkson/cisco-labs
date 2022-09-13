# kubernetes check PKI cert
```sh
MASTER/etc/kubernetes/pki
$kubeadm alpha certs check-expiration 
[check-expiration] Reading configuration from the cluster...
[check-expiration] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'

CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Jul 20, 2021 02:13 UTC   364d                                    no      
apiserver                  Jul 20, 2021 02:13 UTC   364d            ca                      no      
apiserver-etcd-client      Jul 20, 2021 02:13 UTC   364d            etcd-ca                 no      
apiserver-kubelet-client   Jul 20, 2021 02:13 UTC   364d            ca                      no      
controller-manager.conf    Jul 20, 2021 02:13 UTC   364d                                    no      
etcd-healthcheck-client    Jul 20, 2021 02:13 UTC   364d            etcd-ca                 no      
etcd-peer                  Jul 20, 2021 02:13 UTC   364d            etcd-ca                 no      
etcd-server                Jul 20, 2021 02:13 UTC   364d            etcd-ca                 no      
front-proxy-client         Jul 20, 2021 02:13 UTC   364d            front-proxy-ca          no      
scheduler.conf             Jul 20, 2021 02:13 UTC   364d                                    no      

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Jul 17, 2030 23:58 UTC   9y              no      
etcd-ca                 Jul 17, 2030 23:58 UTC   9y              no      
front-proxy-ca          Jul 17, 2030 23:58 UTC   9y              no      
MASTER/etc/kubernetes/pki
```
## Renew cert
```sh
$kubeadm alpha certs renew all
[renew] Reading configuration from the cluster...
[renew] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'

certificate embedded in the kubeconfig file for the admin to use and for kubeadm itself renewed
certificate for serving the Kubernetes API renewed
certificate the apiserver uses to access etcd renewed
certificate for the API server to connect to kubelet renewed
certificate embedded in the kubeconfig file for the controller manager to use renewed
certificate for liveness probes to healthcheck etcd renewed
certificate for etcd nodes to communicate with each other renewed
certificate for serving etcd renewed
certificate for the front proxy client renewed
certificate embedded in the kubeconfig file for the scheduler manager to use renewed
MASTER/etc/kubernetes/pki

