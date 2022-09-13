## KS PKI configuration
```py
crypto key generate rsa label GETVPN-REKEY-RSA modulus 2048 exportable

US_KS_1#show crypto key mypubkey rsa 
% Key pair was generated at: 08:09:41 UTC Sep 11 2016
Key name: GETVPN-REKEY-RSA
 Storage Device: not specified
 Usage: General Purpose Key
 Key is exportable.
 Key Data:
  30820122 300D0609 2A864886 F70D0101 01050003 82010F00 3082010A 02820101 
  009F9351 7517A7E8 7A1DD603 23E6A3BD B59A389C 8F80873B 6D245BE8 20AD7903 
  D277D8B4 7049B8ED 324E3EA5 69F95D20 91228CB7 75C49BCE 2FCAFC86 8D4F682A 
  53E0507C 81727306 A1A0420C 78448056 A256B275 2C959B43 2CA70C31 38AAB4EB 
  0736BF46 9B86B697 E4E58308 1124E500 564F6D05 F1EF4CC2 D8A4A587 0791C87A 
  8FA331CF B0859C4F FA232A16 8E77182D 5C82F4E3 04C80398 63389002 710D1454 
  2F1E48CE 43EC0246 CBCC1E13 6954879A 8927E200 B1A4A57F 5116B51A 4B2B1113 
  1CA6BEC4 B7FC85FB C8661D6D C12B809A 62D00D4D 7241C38A 2C5A4498 3B10B8A9 
  5B3252AF B4B0AB60 768E4AD7 DDC32204 828EC130 9CBE02CF 8DD7DB0C 89D43CCA 
  FB020301 0001
% Key pair was generated at: 08:09:42 UTC Sep 11 2016
Key name: GETVPN-REKEY-RSA.server
Temporary key
 Usage: Encryption Key
 Key is not exportable.
 Key Data:
  307C300D 06092A86 4886F70D 01010105 00036B00 30680261 00A4973B E0B12D16 
  6AF423D3 5570EB34 7E69A17D 4865AE38 B2F0D473 75AEC9FB 7A052FBF 848CE87D 
  D9125418 9878896C CDE73230 0D2D26F5 6E1B408C E5D1CE6B 2900DC6A 162F5DE2 
  D91992A3 AFC5E018 498B9B1F 64CC1326 08690235 224C5A6D 41020301 0001
US_KS_1# 

```
## KS1 EXPORT KEY
```py
US_KS_1(config)#crypto key export rsa GETVPN-REKEY-RSA pem terminal 3des SUCK_MY_DICK
  LINE  Passphrase used to protect the private key
```
## KS2 IMPORT KEY
```PY
US_KS_2(config)#crypto key import rsa GETVPN-REKEY-RSA pem terminal SUCK_MY_DICK

% Enter PEM-formatted public General Purpose key or certificate.
% End with a blank line or "quit" on a line by itself.
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1qNvJX2n+Z7TWX7sjkyT
dFsQmiCTDAEgLJJenHANA+iLVJdXuHJh8o5xntJmSSPiWdaOuEGp98ujps+QOuV2
DVXUkIDtlqFIyN8d4jIy08tSmeHumuRl9owM0qAn/7+DCzWu0mxnTidwvk4wM2RH
wYiOVJANd12r1hgMdQ30a2nQlkM1nimSJA2qfSTK5ybFD5M3FfwHKqN/k7D1UMTa
zpJmN0COI3YBWkVoppnNTGARQ/mYFUjCTvktlE13S2shXsLovS4HT88YUCtG/Iuu
e2wm/h8Dh8bxeB5NnmQsCQNSjHF1JjBbeV/uICeqOLeboiM4jgoidEeFXQmV5dja
ZwIDAQAB
-----END PUBLIC KEY-----
quit
% Enter PEM-formatted encrypted private General Purpose key.
% End with "quit" on a line by itself.

-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,36CDD51270869322

zHEVmruO/vZ/7OOEelj0CQSQvCUPmJIuYSERtQ1QrG0hJcL8FO97NqnU8lJrn4Rc
r594tkTFDfmvdJ/cBPA0YaTrEn+wvPElD9D/0h6oTBfqNwaKP5+FBSRKziHs4ckE
OdkmA44DMA6uX8JRvtk3yDnD4Xlc5InziRTBGUCbFUnSVUFXZQVqPSFNIgg3eMnA
XSAgAtlYGpuxGND7a2mAR0ZAmfgUHkD1hzJZQEC5jlWp0U3xeKNVWOMoMAGjI8zO
u0W1hSN6Nxv35xWxhbi6Xwi4ATF3vh9c5gW1HmFK7nfVDGWe2QKTnDv3a+Ife88r
EnS/35a4OMiyE08ZbkYQbCa8PlBvXWN0jzB0RIS0KZE2rCxEvwCkJ4fJ09fvT5tO
RIKmZCCl/22gXh9/HrAjl6EEPYugXgeKM+uEDeScpFSMg61Awu/3zRk9YyIMWx6K
sx+i46LxnSB+8tjcWBdCpsJs+MXFKbhZs25Ufrwvp42g4WInC2s4R7bJYLRvSQr6
g4br/NP7V3XxTeWx8HpuGdfrWzQT7v/3/Yis4F85qbV8bmNnDSZ5nHqU8BFTLpWU
KVlOhF9/PvohN/SKfbOpdhZRWjIG126YXlTa4JLZhejt/x+8mZklZ7I/IXHREGCH
RPMHULJgik/MDPQrGZMaWehOhKjqV60maQOqUVT9xuSs6Ih4dz+VOLyczUUFyZD+
lNAY5wEjf/zr6Xq75R7Bg8vJhCF1W8jMrtfdp+ySbY58raT3fKBysdheTs78P9WK
KjYtCCQtISsOlRpFwccDofjRwaFu1klIBTAU67EEAB4kVM97y3S8j1qkVaZsRIdT
QLkSAGyH/6aA5kVx0bT35k7PivfYMWysaDvQn7Oa3UNd55S0eE50sl2xse806E3e
OleLSOw8tyy8MPZUcLUye3/DgXZ+G/mM5m001P3B9pQY5BSxi+QYHgaWlpCeh5Kr
HAV09dliDcueO+fqBZoVn889/aq1fvK6vVUjxWWkTGXQBv8LfBjeyVZ3tL5wHdEu
LdIPnNCdtXMkn4//D170KKiz/A+Lh2aUKrQ/T95Mtes8oH7mJIpvvmLtHhRXHG6t
fYI2/FLN1BsV4Z7F9y7jZvNZiZpDLH/PGHSyf56udq+fqZR2ASeWOhSmfEBVGIja
mNp1ZSJoFadudqfSAZLS8E1Ss4NSYWcF0ZdH90jZtr14XD80JUrNszTqWPmPjWJn
cc3p51MdVJcDFsEovafQAqxYzTkmFxnoui7Pc/VtYHAv/Qg1M75t5rit4qpCVVwu
i4g++zC9fh5Ucjl3VyeyiWdg5EtghW2vsQrUXkWfbF+0+ZNogKjRB86ORQEvgw6e
M9dGzpefCivANuMiDpH0b4pAHlwINt7D4pDCy3XAn86iSzjLg7wTD2sk6O6ncXna
LJrMzKP+ZKbWofppJBVx2k2oZK9J6et/wvT6D+vFQp24Fhe6hyyA88uSzPokBNe6
rbfPqABKLrD2UXzhgGVPaAySRmZg8mdeyd4wYnfe7wyZa+vNegyHYEVc/orzKU/D
C3p4/v0vAjvu3+NaQgM2A7QD9yoRT7dOyZq/YFGZFyudJRV3S27e+Q==
-----END RSA PRIVATE KEY-----

quit
% Key pair import succeeded.

```
## GM
```py
crypto keyring USA_KS 
  pre-shared-key address 155.155.155.1 key I_LOVE_USA
  pre-shared-key address 155.155.155.2 key I_LOVE_USA
!
crypto isakmp policy 15
 encr aes 256
 authentication pre-share
 group 2
!
!
crypto gdoi group GETVPN-GROUP-UNICAST
 identity number 18090212
 server address ipv4 155.155.155.1
 server address ipv4 155.155.155.2
!
crypto gdoi group GETVPN-GROUP-MULTICAST
 identity number 17320222
 server address ipv4 155.155.155.2
 server address ipv4 155.155.155.1
!
!
crypto map GETVPN-MAP local-address Loopback0
crypto map GETVPN-MAP 10 gdoi 
 set group GETVPN-GROUP-UNICAST
crypto map GETVPN-MAP 20 gdoi 
 set group GETVPN-GROUP-MULTICAST
```

```py
 you can't config 
 crypto isakmp profile DMVPN-PHASE1
   keyring DMVPN-KEYRING
   match identity address 0.0.0.0 
   0.0.0.0 will be cause IKEv1 Main mode failed.
```