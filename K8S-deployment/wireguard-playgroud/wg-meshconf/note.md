# configuration step
- https://github.com/k4yt3x/wg-meshconf
```sh
wg-meshconf addpeer location1 --address <allow-ip> --endpoint <public-ip>
wg-meshconf addpeer location1 --address 10.0.0.1/24 --endpoint 1.1.1.1

wg-meshconf showpeers
wg-meshconf genconf
mv /usr/local/lib/python3.9/site-packages/wg_meshconf/output .
ls output
