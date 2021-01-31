# Common Configuration Parameters
While [provisioning](../1_provision), [configuration](../2_configure) and [deployment](../3_deployment) can be seen as three separate tasks involved in getting an application
to run in OCI, there needs to be some coupling between the tasks. For example, we provision our compute instances with an SSH public key but the corresponding private key must be
used by Ansible to authenticate itself to configure the hosts.

This directory contains:
 * A script, `tf_vars.sh`, with configuration parameters that are needed by Terraform and Ansible.
 * Private and public keys.

The private and public keys needed for the "Hello, world" application are:
 * `vm_ssh_key` and `vm_ssh_key.pub` for SSH access to the compute instances.
 * `load_balancer_key.pem` and `load_balancer_cert.pem` for encrypting SSL traffic from the internet to the load balancers.
 
## The `tf_vars.sh` script
Environment variables with names that are prefixed with `TF_VAR_` are mapped by Terraform to corresponding Terraform variables. For example, `TF_VAR_foo` is mapped to `foo`.
The [tf_vars.sh.tmpl](./tf_vars.sh.tmpl) should be copied to `tf_vars.sh` and the values edited to reflect changes that you wish to make for your local environment. It's instructive to read through the file to see what can be configured. Not all changes will work in a free-tier account. For example increasing this value will cause provisioning
to fail (since a free tier account supports a maximum of two instances)

```
export TF_VAR_number_of_instances=2
```

## The `vm_ssh_key` key
You need to specify an SSH key pair for provisioning and configuration. The scripts assume that the SSH private key exists in this directory under the name `vm_ssh_key` and the
corresponding public key is `vm_ssh_key.pub`. The key pair will be associated with the `opc` user. If the keys do not exist in the directory, the `tf_vars.sh` script will generate
a new key pair. If you have an existing SSH key pair that you'd prefer to use, copy the public and private keys to this directory and rename them to `vm_ssh_key.pub` and
`vm_ssh_key`.

## The load balancer SSL key and certificate
Traffic to and from a web service is frequently sensitive and should be encrypted for confidentiality. The "Hello, world" service loads an SSL private key and a digital
certificate for the key into the load balancer. If no private key exists in this directory, the `tf_vars.sh` script generates a private key and a self-signed SSL certificate.
Information security frequently requires both confidentiality and authentication; when using self-signed certificates you get only the former. To get authentication, you
will, at a minimum, need to get a Certificate Authority to generate a certificate for your private key. That will partially solve the problem but you would still need to
associate the `common name` in the certificate with the IP address of the load balancer.
