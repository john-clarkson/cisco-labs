#!/bin/bash
#Shell color ref https://gist.github.com/vratiu/9780109
RED='\033[0;31m'
Yellow="\033[0;33m****"
Green="\033[0;32m****"
NC="\033[0m****"
Cyan="\033[0;36m\]"  

echo -e {Yellow}"LIST ALL DOCKER IMAGE ON THIS HOST LOCALLY"
docker image ls;

echo -e {Green}"ing docker image CNI+busybox+kuard+ubuntu+dnsutils locally"
 docker pull cilium/cilium:latest;
 docker pull calico/cni:v3.14.1;
 docker pull calico/kube-controllers:v3.14.1;
 docker pull calico/node:v3.11.2;
 docker pull calico/kube-controllers:v3.11.2;
 docker pull busybox:latest;
 docker pull dlneintr/kuard:latest;
 docker pull gcr.io/kubernetes-e2e-test-images/dnsutils:1.3;
echo done;
