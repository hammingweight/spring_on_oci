This directory contains public and private keys and
digital certificates.

1. VM SSH Key
Generate an SSH key for logging into your VMs by running
```
ssh-keygen -f vm_ssh_key -N ""
```

2. Load Balancer Key and Certificate
Generate an SSL private key and certificate for the load balancer
by running

```
openssl req  -nodes -new -x509  -keyout lb_key.pem -out lb_cert.pem -days 365
```
