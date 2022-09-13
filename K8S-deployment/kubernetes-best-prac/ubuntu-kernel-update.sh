#!/bin/bash
#ubuntu server kernel update

toor|sudo -i
mkdir kernel
cd kernel


wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-headers-5.6.0-050600_5.6.0-050600.202003292333_all.deb;

wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-headers-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb;

wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-image-unsigned-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb;

wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-modules-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb;

dpkg -i *.deb
rm -rfv /lib/modules/5.4*

```sh
root@k8s-slave3:~# cd kernel5.6/
root@k8s-slave3:~/kernel5.6# wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-headers-5.6.0-050600_5.6.0-050600.202003292333_all.deb;
--2021-01-31 05:21:26--  https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-headers-5.6.0-050600_5.6.0-050600.202003292333_all.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 91.189.94.216
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|91.189.94.216|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 11127504 (11M) [application/x-debian-package]
Saving to: ‘linux-headers-5.6.0-050600_5.6.0-050600.202003292333_all.deb’

linux-headers-5.6.0-050600_5.6.0-050600.2 100%[===================================================================================>]  10.61M   778KB/s    in 14s

2021-01-31 05:21:42 (770 KB/s) - ‘linux-headers-5.6.0-050600_5.6.0-050600.202003292333_all.deb’ saved [11127504/11127504]

root@k8s-slave3:~/kernel5.6#
root@k8s-slave3:~/kernel5.6# wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-headers-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb;
--2021-01-31 05:21:42--  https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-headers-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 91.189.94.216
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|91.189.94.216|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1180920 (1.1M) [application/x-debian-package]
Saving to: ‘linux-headers-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb’

linux-headers-5.6.0-050600-generic_5.6.0- 100%[===================================================================================>]   1.13M   499KB/s    in 2.3s

2021-01-31 05:21:45 (499 KB/s) - ‘linux-headers-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb’ saved [1180920/1180920]

root@k8s-slave3:~/kernel5.6#
root@k8s-slave3:~/kernel5.6# wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-image-unsigned-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb;
--2021-01-31 05:21:45--  https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-image-unsigned-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 91.189.94.216
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|91.189.94.216|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 9053444 (8.6M) [application/x-debian-package]
Saving to: ‘linux-image-unsigned-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb’

linux-image-unsigned-5.6.0-050600-generic 100%[===================================================================================>]   8.63M   796KB/s    in 12s

2021-01-31 05:21:58 (745 KB/s) - ‘linux-image-unsigned-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb’ saved [9053444/9053444]

root@k8s-slave3:~/kernel5.6#
root@k8s-slave3:~/kernel5.6# wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-modules-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb;
--2021-01-31 05:21:58--  https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-modules-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 91.189.94.216
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|91.189.94.216|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 52319388 (50M) [application/x-debian-package]
Saving to: ‘linux-modules-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb’

linux-modules-5.6.0-050600-generic_5.6.0- 100%[===================================================================================>]  49.90M   861KB/s    in 62s

2021-01-31 05:23:02 (820 KB/s) - ‘linux-modules-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb’ saved [52319388/52319388]

root@k8s-slave3:~/kernel5.6#
root@k8s-slave3:~/kernel5.6# dpkg -i *.deb
Selecting previously unselected package linux-headers-5.6.0-050600-generic.
(Reading database ... 71553 files and directories currently installed.)
Preparing to unpack linux-headers-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb ...
Unpacking linux-headers-5.6.0-050600-generic (5.6.0-050600.202003292333) ...
Selecting previously unselected package linux-headers-5.6.0-050600.
Preparing to unpack linux-headers-5.6.0-050600_5.6.0-050600.202003292333_all.deb ...
Unpacking linux-headers-5.6.0-050600 (5.6.0-050600.202003292333) ...
Selecting previously unselected package linux-image-unsigned-5.6.0-050600-generic.
Preparing to unpack linux-image-unsigned-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb ...
Unpacking linux-image-unsigned-5.6.0-050600-generic (5.6.0-050600.202003292333) ...
Selecting previously unselected package linux-modules-5.6.0-050600-generic.
Preparing to unpack linux-modules-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb ...
Unpacking linux-modules-5.6.0-050600-generic (5.6.0-050600.202003292333) ...
Setting up linux-headers-5.6.0-050600 (5.6.0-050600.202003292333) ...
Setting up linux-modules-5.6.0-050600-generic (5.6.0-050600.202003292333) ...
Setting up linux-headers-5.6.0-050600-generic (5.6.0-050600.202003292333) ...
Setting up linux-image-unsigned-5.6.0-050600-generic (5.6.0-050600.202003292333) ...
I: /boot/vmlinuz is now a symlink to vmlinuz-5.6.0-050600-generic
I: /boot/initrd.img is now a symlink to initrd.img-5.6.0-050600-generic
Processing triggers for linux-image-unsigned-5.6.0-050600-generic (5.6.0-050600.202003292333) ...
/etc/kernel/postinst.d/initramfs-tools:
update-initramfs: Generating /boot/initrd.img-5.6.0-050600-generic
modinfo: ERROR: could not get modinfo from 'da903x': No such file or directory
/etc/kernel/postinst.d/zz-update-grub:
Sourcing file `/etc/default/grub'
Sourcing file `/etc/default/grub.d/init-select.cfg'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-5.6.0-050600-generic
Found initrd image: /boot/initrd.img-5.6.0-050600-generic
Found linux image: /boot/vmlinuz-5.4.0-65-generic
Found initrd image: /boot/initrd.img-5.4.0-65-generic
done
root@k8s-slave3:~/kernel5.6# cd /lib/modules
root@k8s-slave3:/lib/modules# ls
5.4.0-65-generic  5.6.0-050600-generic
root@k8s-slave3:/lib/modules# uname -a
Linux k8s-slave3 5.4.0-65-generic #73-Ubuntu SMP Mon Jan 18 17:25:17 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
root@k8s-slave3:/lib/modules# reboot


```