
## Fortigate VDOM settings via GUI has a bug that you add new vdom config give a error message say access deny
 - cli configuration works fine.
  ```bash
 FortiGate-VM64-KVM # get system status
Version: FortiGate-VM64-KVM v5.4.4,build7605,170208 (GA)
Virus-DB: 1.00123(2015-12-11 13:18)
Extended DB: 1.00000(2012-10-17 15:46)
IPS-DB: 6.00741(2015-12-01 02:30)
IPS-ETDB: 0.00000(2001-01-01 00:00)
Serial-Number: FGVMEV0000000000
IPS Malicious URL Database: 1.00001(2015-01-01 01:01)
Botnet DB: 1.00000(2012-05-28 22:51)
License Status: Valid
Evaluation License Expires: Wed Jan 31 08:02:19 2018
VM Resources: 1 CPU/1 allowed, 995 MB RAM/1024 MB allowed
BIOS version: 04000002
Log hard disk: Not available
Hostname: FortiGate-VM64-KVM
Operation Mode: NAT
Current virtual domain: root
Max number of virtual domains: 10
Virtual domains status: 1 in NAT mode, 0 in TP mode
Virtual domain configuration: disable
FIPS-CC mode: disable
Current HA mode: standalone
Branch point: 1117
Release Version Information: GA
FortiOS x86-64: Yes
System time: Tue Jan 16 09:04:46 2018

FortiGate-VM64-KVM # 
```
