
# This container is rootless, without privileged keywords. you can not restart frr process by using </etc/init.d/frr restart>

## Error output=Operation not permitted
### $docker run -dit --name=frr frrouting/frr
### $docker exec ti frr sh

```sh
 /etc # /etc/init.d/frr start
privs_init: initial cap_set_proc failed: Operation not permitted
Wanted caps: cap_net_bind_service,cap_net_admin,cap_net_raw,cap_sys_admin=p
Have   caps: cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap=ip
privs_init: initial cap_set_proc failed: Operation not permitted
Wanted caps: cap_net_bind_service,cap_net_admin,cap_net_raw,cap_sys_admin=p
Have   caps: cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap=ip
privs_init: initial cap_set_proc failed: Operation not permitted
Wanted caps: cap_net_bind_service,cap_net_raw,cap_sys_admin=p
Have   caps: cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap=ip
```


## Correct output
### $docker run -dit --privileged --name=frr frrouting/frr
### $docker exec ti frr sh
```sh
bash-5.0# /etc/init.d/frr restart
Stopping Frr monitor daemon:.
Stopping Frr daemons (prio:0):Stopping staticd since zebra is running (bgpd) (ripd) (ripngd) (ospfd) (ospf6d) (isisd) (babeld) (pimd) (ldpd) (nhrpd) (eigrpd) (sharpd) (pbrd) (staticd) (bfdd) (fabricd) (vrrpd).
Stopping other frr daemons..
Removing remaining .vty files.
Exiting from the script
Exiting from the script
Exiting from the script
```

## Useful command

```sh
$docker image ls
$docker run -dit --privileged --name=frr frrouting/frr
$docker exec -ti frr /bin/bash

cp /etc/frr/vtysh.conf.sample /etc/frr/vtysh.conf
vi vtysh.conf
#delete ! mark, enter esc, :wq enter.
cp /etc/frr/zebra.conf.sample /etc/frr/zebra.conf
vi daemons
bgpd=yes
ospfd=yes
#enter esc, :wq enter.
/etc/init.d/frr restart
```
## FRR process up and running verification

```sh
bash-5.0# ps
PID   USER     TIME  COMMAND
    1 root      0:00 /sbin/tini -- /usr/lib/frr/docker-start
    6 root      0:00 tail -f /dev/null
   13 root      0:00 /usr/lib/frr/watchfrr -d -F traditional zebra bgpd ospfd ospf6d isisd staticd
   41 frr       0:00 /usr/lib/frr/zebra -d -F traditional -A 127.0.0.1 -s 90000000
   46 frr       0:00 /usr/lib/frr/bgpd -d -F traditional -A 127.0.0.1
   53 frr       0:00 /usr/lib/frr/ospfd -d -F traditional -A 127.0.0.1
   56 frr       0:00 /usr/lib/frr/ospf6d -d -F traditional -A ::1
   59 frr       0:00 /usr/lib/frr/isisd -d -F traditional -A 127.0.0.1
   62 frr       0:00 /usr/lib/frr/staticd -d -F traditional -A 127.0.0.1
   64 root      0:00 /bin/bash
   69 root      0:00 ps
bash-5.0# 
```
