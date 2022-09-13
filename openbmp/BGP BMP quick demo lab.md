# BGP BMP quick demo lab
## BMP introduction
- BMP(BGP monitoring protocol) is an sub-protocol inside BGP, you can think it looks like BGP AFI(address-family identifier), the reason that you want to use this, we want to visualize BGP database on WEBGUI, then we can check the BGP neighbor or routing-info.
## Workflow

*BGP speaker-<IBGP/EBGP>-BGP speaker->BMP(generate MRT update)->BMP server->WEBGUI*

```sh 
 #bmp server
 https://github.com/SNAS/docker/blob/master/aio/README.md
 https://www.snas.io/docs/#usecases
 https://github.com/SNAS
 https://www.snas.io/docs/kafka_apis/

  
##access server 
http://localhost:8000
username:openbmp
password:CiscoRA

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
```
## CISCO CSR1000V configurations
```cisco
interface g1
 ip address 100.64.1.100 255.255.255.0
 no shutdown
interface loopback0
 description create-BGP-update
 ip address 1.1.1.1 255.255.255.255
 
router bgp 1
 bmp server 1
  address 100.64.1.20 port-number 5000
  description "BMP Server - I'm in docker"
  initial-delay 10
  failure-retry-delay 120
  flapping-delay 120
  stats-reporting-period 300
  update-source GigabitEthernet1
  activate
 exit-bmp-server-mode
 !       
 !
 address-family ipv4
  redistribute connected
 !100.64.1.66 <frrouting in docker> 
  neighbor 100.64.1.66 activate
 exit-address-family
 !
```
## Feed BGP MRT update to BMP server
- #BMP client
 https://github.com/SNAS/openbmp-mrt2bmp
- BGP MRT update download link
 http://routeviews.org/ 

```sh 
##enable bmp client, double click will kill client
cd ~/openbmp/openbmp-mrt2bmp/src/etc
nohup openbmp-mrt2bmp -c openbmp-mrt2bmp.yml -r router-v4 > /dev/null 2>&1 &
##

cd ~/openbmp/openbmp-mrt2bmp/src/etc
openbmp-mrt2bmp -c openbmp-mrt2bmp.yml -r router-v4
```
## Online BGP public router
```sh 
#access routeview-server
$telnet route-server.ip-plus.net
```