#!/bin/bash

RED='\033[0;31m'
Yellow="\[\033[0;33m\]"
Green="[\033[0;32m\]****"
NC='\033[0m'
Cyan="\[\033[0;36m\]"  

echo -e ${Green}'
helm generate config
helm install cilium ./cilium \
    --namespace kube-system \
    --set global.kubeProxyReplacement=strict \
    --set global.k8sServiceHost=172.18.0.3 \
    --set global.k8sServicePort=6443 \
    --dry-run'
echo -e ${Cyan}' 
helm install cilium ./cilium \
    --namespace kube-system \
    --set global.kubeProxyReplacement=strict \
    --set global.k8sServiceHost=172.18.0.3 \
    --set global.k8sServicePort=6443 '
echo -e ${RED}'
##uninstall cilium with helm
helm uninstall cilium --namespace kube-system 
    
helm list -A
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
cilium  kube-system     1               2020-07-14 01:14:57.671146576 +0800 CST deployed        cilium-1.8.90   1.8.90   
'   
        