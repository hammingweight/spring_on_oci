This directory contains public and private keys and
digital certificates.

1. OCI API Key
Download your OCI API key and save it as `oci_api_key.pem`.
You will also need the key's fingerprint.

2. VM SSH Key
Generate an SSH key for logging into your VMs by running
```
ssh-keygen -f vm_ssh_key -N ""
```

3. Load Balancer Key and Certificate
Generate an SSL private key and certificate for the load balancer
by running

```
openssl req  -nodes -new -x509  -keyout lb_key.pem -out lb_cert.pem -days 365
```
