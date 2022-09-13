#!/bin/bash
#ubuntu server kernel update

toor|sudo -i
mkdir kernel
cd kernel


wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-headers-5.6.0-050600_5.6.0-050600.202003292333_all.deb

wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-headers-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb

wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-image-unsigned-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb

wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6/linux-modules-5.6.0-050600-generic_5.6.0-050600.202003292333_amd64.deb

dpkg -i *.deb