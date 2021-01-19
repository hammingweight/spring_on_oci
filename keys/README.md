Put your API and VM SSH keys in this directory.

Generate a private key and cert for the load balancer
by running

```
openssl req  -nodes -new -x509  -keyout lb_key.pem -out lb_cert.pem
```
