#!/bin/bash
sudo apt update
echo install net-tools for ifconfig cli.
sudo apt install -y net-tools
echo 
ip a
sleep 2
ifconfig
sleep 2
echo Find your nic card name.
echo Shutdown interface
sudo ifconfig ens33 down;
echo Renaming your NIC to eth0.
sudo ip link set ens33 name eth0;
sleep 2
echo enable eth0.
sudo ifconfig eth0 up;
sleep 2
echo sending DHCP client request from eth0.
sudo dhclient eth0;
echo done
echo For ubuntu desktop OS, the whole configuration is handle by netplan.
echo netplan config is under /etc/netplan
echo For more infomation, go to https://ubuntu.com/server/docs/network-configuration
