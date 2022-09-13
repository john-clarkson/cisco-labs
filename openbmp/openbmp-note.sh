#!bin/bash
RED='\033[0;31m'
Yellow="\033[0;33m****"
Green="\033[0;32m****"
NC="\033[0m****"
Cyan="\033[0;36m\]"  

echo -e ${Yellow}"
Openbmp server Mysql info
ip address:localhost:3306
username:openbmp
password:openbmp"

sleep 3

echo -e ${Green}"
 link:
 mysql-workbench-download-link
 https://dev.mysql.com/downloads/workbench/
 sudo apt install ./home/hitler/Downloads/mysql-workbench-community_8.0.21-1ubuntu20.04_amd64.deb
 
 #bmp server
 https://github.com/SNAS/docker/blob/master/aio/README.md
 
 https://www.snas.io/docs/#usecases
 https://github.com/SNAS
 https://www.snas.io/docs/kafka_apis/
#bmp client
 https://github.com/SNAS/openbmp-mrt2bmp
#bgp mrt data download link
 http://routeviews.org/ 
  
##access server 
http://localhost:8000
username:openbmp
password:CiscoRA


##enable bmp client,sencond click will kill client
cd ~/openbmp/openbmp-mrt2bmp/src/etc
nohup openbmp-mrt2bmp -c openbmp-mrt2bmp.yml -r router-v4 > /dev/null 2>&1 &
##

cd ~/openbmp/openbmp-mrt2bmp/src/etc
openbmp-mrt2bmp -c openbmp-mrt2bmp.yml -r router-v4

##access routeview-server
telnet route-server.ip-plus.net

"