#!bin/bash
echo Create a root certificate and private key to sign the certificates for your services
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout example.com.key -out example.com.crt;
sleep 3

echo Create a certificate and a private key for foobar.example.com
openssl req -out foobar.example.com.csr -newkey rsa:2048 -nodes -keyout foobar.example.com.key -subj "/CN=foobar.example.com/O=foobar organization";
sleep 3


openssl x509 -req -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 0 -in foobar.example.com.csr -out foobar.example.com.crt;
sleep 3

echo Create a secret for the ingress gateway
kubectl create -n istio-system secret tls foobar-credential --key=foobar.example.com.key --cert=foobar.example.com.crt;
