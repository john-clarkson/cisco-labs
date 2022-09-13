# kubernetes v1.20 docker to containerd migration
## after reboot, kubelet is not start. type: systemctl daemon-reload

- https://kubernetes.io/docs/setup/production-environment/container-runtimes/
- https://github.com/kata-containers/documentation/blob/master/how-to/how-to-use-k8s-with-cri-containerd-and-kata.md#configure-kubelet-to-use-containerd
```sh
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```
## Setup required sysctl params, these persist across reboots.
```sh
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# (Install containerd)
sudo apt-get update && sudo apt-get install -y containerd
# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
# Restart containerd
sudo systemctl restart containerd
```

## Systemd: To use the systemd cgroup driver in /etc/containerd/config.toml with runc, set (final config /)
```sh
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```
## Example config.toml
```yaml
version = 2
root = "/var/lib/containerd"
state = "/run/containerd"
plugin_dir = ""
disabled_plugins = []
required_plugins = []
oom_score = 0

[grpc]
  address = "/run/containerd/containerd.sock"
  tcp_address = ""
  tcp_tls_cert = ""
  tcp_tls_key = ""
  uid = 0
  gid = 0
  max_recv_message_size = 16777216
  max_send_message_size = 16777216

[ttrpc]
  address = ""
  uid = 0
  gid = 0

[debug]
  address = ""
  uid = 0
  gid = 0
  level = ""

[metrics]
  address = ""
  grpc_histogram = false

[cgroup]
  path = ""

[timeouts]
  "io.containerd.timeout.shim.cleanup" = "5s"
  "io.containerd.timeout.shim.load" = "5s"
  "io.containerd.timeout.shim.shutdown" = "3s"
  "io.containerd.timeout.task.state" = "2s"

[plugins]
  [plugins."io.containerd.gc.v1.scheduler"]
    pause_threshold = 0.02
    deletion_threshold = 0
    mutation_threshold = 100
    schedule_delay = "0s"
    startup_delay = "100ms"
  [plugins."io.containerd.grpc.v1.cri"]
    disable_tcp_service = true
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    stream_idle_timeout = "4h0m0s"
    enable_selinux = false
    sandbox_image = "k8s.gcr.io/pause:3.1"
    stats_collect_period = 10
    systemd_cgroup = false
    enable_tls_streaming = false
    max_container_log_line_size = 16384
    disable_cgroup = false
    disable_apparmor = false
    restrict_oom_score_adj = false
    max_concurrent_downloads = 3
    disable_proc_mount = false
    [plugins."io.containerd.grpc.v1.cri".containerd]
      snapshotter = "overlayfs"
      default_runtime_name = "runc"
      no_pivot = false
      [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
        runtime_type = ""
        runtime_engine = ""
        runtime_root = ""
        privileged_without_host_devices = false
      [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime]
        runtime_type = ""
        runtime_engine = ""
        runtime_root = ""
        privileged_without_host_devices = false
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v1"
          runtime_engine = ""
          runtime_root = ""
          privileged_without_host_devices = false
           [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
             SystemdCgroup = true
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/opt/cni/bin"
      conf_dir = "/etc/cni/net.d"
      max_conf_num = 1
      conf_template = ""
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://registry-1.docker.io"]
    [plugins."io.containerd.grpc.v1.cri".x509_key_pair_streaming]
      tls_cert_file = ""
      tls_key_file = ""
  [plugins."io.containerd.internal.v1.opt"]
    path = "/opt/containerd"
  [plugins."io.containerd.internal.v1.restart"]
    interval = "10s"
  [plugins."io.containerd.metadata.v1.bolt"]
    content_sharing_policy = "shared"
  [plugins."io.containerd.monitor.v1.cgroups"]
    no_prometheus = false
  [plugins."io.containerd.runtime.v1.linux"]
    shim = "containerd-shim"
    runtime = "runc"
    runtime_root = ""
    no_shim = false
    shim_debug = false
  [plugins."io.containerd.runtime.v2.task"]
    platforms = ["linux/amd64"]
  [plugins."io.containerd.service.v1.diff-service"]
    default = ["walking"]
  [plugins."io.containerd.snapshotter.v1.devmapper"]
    root_path = ""
    pool_name = ""
    base_image_size = ""%
```
```
sudo mkdir -p  /etc/systemd/system/kubelet.service.d/

cat << EOF | sudo tee  /etc/systemd/system/kubelet.service.d/0-containerd.conf
[Service]                                                 
Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock"
EOF
```
```sh
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl restart containerd
sudo systemctl status containerd
sudo iptables -P FORWARD ACCEPT
```
# Final check
```sh
# Before
root@k8s-master1:~# kubectl get nodes -o wide
NAME          STATUS   ROLES                  AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
k8s-master1   Ready    control-plane,master   123m   v1.20.2   10.211.55.5   <none>        Ubuntu 20.04.1 LTS   5.4.0-65-generic   containerd://1.3.3-0ubuntu2.2
k8s-slave1    Ready    <none>                 122m   v1.20.2   10.211.55.6   <none>        Ubuntu 20.04.1 LTS   5.4.0-65-generic   docker://19.3.8
k8s-slave2    Ready    <none>                 122m   v1.20.2   10.211.55.7   <none>        Ubuntu 20.04.1 LTS   5.4.0-65-generic   docker://19.3.8

# After
root@k8s-master1:~# kubectl get nodes -o wide
NAME          STATUS   ROLES                  AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
k8s-master1   Ready    control-plane,master   124m   v1.20.2   10.211.55.5   <none>        Ubuntu 20.04.1 LTS   5.4.0-65-generic   containerd://1.3.3-0ubuntu2.2
k8s-slave1    Ready    <none>                 123m   v1.20.2   10.211.55.6   <none>        Ubuntu 20.04.1 LTS   5.4.0-65-generic   docker://19.3.8
k8s-slave2    Ready    <none>                 123m   v1.20.2   10.211.55.7   <none>        Ubuntu 20.04.1 LTS   5.4.0-65-generic   containerd://1.3.3-0ubuntu2.2
root@k8s-master1:~#
```
## crictl cli setup

```sh
# bash completion
root@k8s-master1:/etc# crictl completion bash >~/.bashrc
root@k8s-master1:/etc# source ~/.bashrc
```
```sh
# dockershim config
export CRT_CONFIG_FILE=/etc/crictl.yaml

root@k8s-slave1:/etc# cat crictl.yaml
runtime-endpoint: unix:///var/run/dockershim.sock
image-endpoint: unix:///var/run/dockershim.sock
timeout: 2
debug: true
pull-image-on-create: false
root@k8s-slave1:/etc#

root@k8s-slave1:/etc# crictl pods
...
POD ID              CREATED             STATE               NAME                                    NAMESPACE           ATTEMPT
2f902a37cd232       2 hours ago         Ready               busybox-deploy-slave1-8d7c8756d-z6q5x   default             0
f26c8f81bc8da       3 hours ago         Ready               calico-node-9l45v                       kube-system         0
5ddd1fe165e76       3 hours ago         Ready               kube-proxy-c42l2                        kube-system         0
root@k8s-slave1:/etc#
```
```sh
## crictl containerd
export CRT_CONFIG_FILE=/etc/crictl.yaml

root@k8s-master1:/etc# cat crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///var/run/dockershim.sock
timeout: 10
debug: true

root@k8s-master1:/etc# crictl ps
...
CONTAINER ID        IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID
85686bd2cf1a5       b97242f89c8a2       28 minutes ago      Running             busybox                   0                   c2734cbf4f41a
8174e4f2e1fa8       b97242f89c8a2       28 minutes ago      Running             busybox                   0                   f06deb4a56bc3
48092a7218173       b97242f89c8a2       28 minutes ago      Running             busybox                   0                   b518a04d5846a
22ca734e21d45       b97242f89c8a2       28 minutes ago      Running             busybox                   0                   83ed6abad3d2a
d890bcd82dedf       bfe3a36ebd252       About an hour ago   Running             coredns                   0                   94bbc4085e140
f88942bca6a64       b97242f89c8a2       About an hour ago   Running             busybox                   0                   6edb98c050a6d
57a85047a2702       bfe3a36ebd252       About an hour ago   Running             coredns                   0                   69a46d14b82e5
2711477b0b763       ac08a3af350bd       About an hour ago   Running             calico-kube-controllers   0                   b6d9c3f5a328b
91ea53a70af4b       43154ddb57a83       About an hour ago   Running             kube-proxy                0                   8e5c75c730e8b
```
```sh
root@k8s-master1:/etc# docker ps
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS               NAMES
7204bf8d4ae8        a27166429d98              "kube-controller-man…"   About an hour ago   Up About an hour                        k8s_kube-controller-manager_kube-controller-manager-k8s-master1_kube-system_6fe5f671ea842294501f69ff3d0e7f6b_0
379a73ae2fe0        k8s.gcr.io/pause:3.2      "/pause"                 About an hour ago   Up About an hour                        k8s_POD_kube-controller-manager-k8s-master1_kube-system_6fe5f671ea842294501f69ff3d0e7f6b_0
6e9bfe9cee11        k8s.gcr.io/pause:3.2      "/pause"                 2 hours ago         Up 2 hours                              k8s_POD_busybox-deploy-master1-784757fd7-ks745_default_d6947b68-69fa-4310-b121-c7b9ee44266d_0
535daa21833c        calico/kube-controllers   "/usr/bin/kube-contr…"   3 hours ago         Up 3 hours                              k8s_calico-kube-controllers_calico-kube-controllers-55ffdb7658-9l8wq_kube-system_8bbabf15-afea-4f79-bbc4-c4d4f00b26ff_0
35c8a2c1181e        bfe3a36ebd25              "/coredns -conf /etc…"   3 hours ago         Up 3 hours                              k8s_coredns_coredns-74ff55c5b-h74m7_kube-system_d0bf87c9-92ea-4eaf-8f8b-67b71fd923f7_0
1cc0682b770e        k8s.gcr.io/pause:3.2      "/pause"                 3 hours ago         Up 3 hours                              k8s_POD_coredns-74ff55c5b-h74m7_kube-system_d0bf87c9-92ea-4eaf-8f8b-67b71fd923f7_68
6dc1807471a3        bfe3a36ebd25              "/coredns -conf /etc…"   3 hours ago         Up 3 hours                              k8s_coredns_coredns-74ff55c5b-54h9l_kube-system_1778b3da-bf07-455c-b449-d06685f62e39_0
6c33ecec54c4        k8s.gcr.io/pause:3.2      "/pause"                 3 hours ago         Up 3 hours                              k8s_POD_coredns-74ff55c5b-54h9l_kube-system_1778b3da-bf07-455c-b449-d06685f62e39_74
a06031bcdffa        k8s.gcr.io/pause:3.2      "/pause"                 3 hours ago         Up 3 hours                              k8s_POD_calico-kube-controllers-55ffdb7658-9l8wq_kube-system_8bbabf15-afea-4f79-bbc4-c4d4f00b26ff_62
a6f0151b90d1        calico/node               "start_runit"            3 hours ago         Up 3 hours                              k8s_calico-node_calico-node-bsv9t_kube-system_85218475-61ba-4166-b821-c9c0415f2fdb_0
02f759eda187        k8s.gcr.io/pause:3.2      "/pause"                 3 hours ago         Up 3 hours                              k8s_POD_calico-node-bsv9t_kube-system_85218475-61ba-4166-b821-c9c0415f2fdb_0
53b767869c20        43154ddb57a8              "/usr/local/bin/kube…"   3 hours ago         Up 3 hours                              k8s_kube-proxy_kube-proxy-mk5hx_kube-system_77c851ba-4c3c-49aa-9ed3-112a64e231b7_0
1259c9c033cb        k8s.gcr.io/pause:3.2      "/pause"                 3 hours ago         Up 3 hours                              k8s_POD_kube-proxy-mk5hx_kube-system_77c851ba-4c3c-49aa-9ed3-112a64e231b7_0
3b5d70b5eb21        ed2c44fbdd78              "kube-scheduler --au…"   3 hours ago         Up 3 hours                              k8s_kube-scheduler_kube-scheduler-k8s-master1_kube-system_69cd289b4ed80ced4f95a59ff60fa102_0
62ef1c3c40c2        a8c2fdb8bf76              "kube-apiserver --ad…"   3 hours ago         Up 3 hours                              k8s_kube-apiserver_kube-apiserver-k8s-master1_kube-system_bc360a20cf16b3c53675d55ba277e0b6_0
2683bd74d085        0369cf4303ff              "etcd --advertise-cl…"   3 hours ago         Up 3 hours                              k8s_etcd_etcd-k8s-master1_kube-system_6c77456f644043d8cd4dc715d71e3385_0
81e4464dc9a1        k8s.gcr.io/pause:3.2      "/pause"                 3 hours ago         Up 3 hours                              k8s_POD_kube-scheduler-k8s-master1_kube-system_69cd289b4ed80ced4f95a59ff60fa102_0
2d00593e9e2a        k8s.gcr.io/pause:3.2      "/pause"                 3 hours ago         Up 3 hours                              k8s_POD_etcd-k8s-master1_kube-system_6c77456f644043d8cd4dc715d71e3385_0
a7c856f3ebb4        k8s.gcr.io/pause:3.2      "/pause"                 3 hours ago         Up 3 hours                              k8s_POD_kube-apiserver-k8s-master1_kube-system_bc360a20cf16b3c53675d55ba277e0b6_0
root@k8s-master1:/etc#
```
## After server reboot
```sh
root@k8s-master1:~# systemctl daemon-reload
root@k8s-master1:~# systemctl status kubelet
● kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/lib/systemd/system/kubelet.service; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/kubelet.service.d
             └─0-containerd.conf, 10-kubeadm.conf
     Active: active (running) since Fri 2021-01-29 11:26:15 UTC; 31s ago
       Docs: https://kubernetes.io/docs/home/
   Main PID: 5035 (kubelet)
      Tasks: 20 (limit: 2271)
     Memory: 56.4M
     CGroup: /system.slice/kubelet.service
```
## docker container is gone.
```sh
root@k8s-master1:~# crictl ps

CONTAINER ID        IMAGE               CREATED              STATE               NAME                      ATTEMPT             POD ID
46866ca7de9ca       b97242f89c8a2       About a minute ago   Running             busybox                   2                   5fe8ae47f8727
38ccf32cc0088       b97242f89c8a2       About a minute ago   Running             busybox                   2                   0aeba9abcd183
3e6eff8ada21f       b97242f89c8a2       About a minute ago   Running             busybox                   2                   e1b08ff8d82b3
718326d74e4da       ac08a3af350bd       About a minute ago   Running             calico-kube-controllers   1                   c44550aa5c738
c84d1069135c4       b97242f89c8a2       About a minute ago   Running             busybox                   2                   1b30ab1845830
c7bbe64cef429       b97242f89c8a2       About a minute ago   Running             busybox                   2                   078c62aa92aa5
f6011972acd58       bfe3a36ebd252       About a minute ago   Running             coredns                   1                   240d53dfcbacf
077cb9997ebac       bfe3a36ebd252       About a minute ago   Running             coredns                   1                   c32548a974e2c
7b6ed17c187e2       04a9b816c7535       2 minutes ago        Running             calico-node               29                  31ce465e51cfa
a85a9e6688210       43154ddb57a83       2 minutes ago        Running             kube-proxy                1                   2c854e1fa8243
27d6e6aa42566       0369cf4303ffd       2 minutes ago        Running             etcd                      25                  2bd81c1738478
aa363d8247d07       a8c2fdb8bf76e       2 minutes ago        Running             kube-apiserver            24                  8f7ced19e5bde
64a6706e1f808       ed2c44fbdd78b       2 minutes ago        Running             kube-scheduler            24                  25d29da5626aa
e25d787b67a5f       a27166429d98e       2 minutes ago        Running             kube-controller-manager   24                  a3a9eed7173e6
root@k8s-master1:~#
root@k8s-master1:~#
root@k8s-master1:~# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
root@k8s-master1:~#
```