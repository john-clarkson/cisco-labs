#!bin/bash
##no hostname
#export PS1="\[\033[38;5;50m\]\w\[$(tput sgr0)\]\n\[$(tput sgr0)\]\[\033[38;5;44m\]\\$\[$(tput sgr0)\]"
#show hostname
export PS1="\[\033[38;5;32m\]\h\[$(tput sgr0)\]\[\033[38;5;242m\]\w\[$(tput sgr0)\]\n\\$\[$(tput sgr0)\]"
source <(kind completion bash)
source <(kubectl completion bash)
source <(kubeadm completion bash)
source <(helm completion bash)
export KUBE_EDITOR="code --wait"

export GOPATH=~/go/bin
export PATH=$PATH:~/go/bin
export GOROOT=~/go

echo calicoctl loading kubernetes
export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=~/.kube/config 
calicoctl get workloadendpoints
calicoctl get node
calicoctl version


