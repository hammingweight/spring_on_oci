# Command line tools
## terraform
[Terraform](https://terraform.io) was used to [provision](../../1_provision) this project by running `terraform apply` but there are other useful commands:
 * `terraform plan` which shows what changes would be made if `terraform apply` were run.
 * `terraform destroy` to tear down infrastructure.
 * `terraform show` which shows the the provisioned resources.
The state of the provisioned resources is stored in a local file, `terraform.tfstate`.

Running

```
$ cd 1_provision
$ terraform show
```

generates an enormous amount of output even for this small project. However the last lines emit

```
Outputs:

compartment_ocid = "ocid1.compartment.oc1..aaaaaaaa ... yq"
load_balancer_ip = "193.122.5.88"
```

It's a good idea to include `output` directives in your `.tf` files to emit facts that are useful. See the [compartment.tf](../../1_provision/compartment.tf) and
[load_balancer.tf](../../1_provision/load_balancer.tf) files for examples.

## The `oci` CLI
The OCI CLI is particularly useful for querying resources. The general form of a command is

```
oci <COMMAND> <RESOURCE_TYPE> <OPERATION>
```

Most commands require that you specify either the OCID of a resource or a compartment. For example, to list all instances in a compartment

```
$ oci compute instance list --compartment-id ocid1.compartment.oc1..aaaaaaaa ... yq
```

That example would also return results for instances that have been terminated. The `oci` commands typically allow filtering. For example to get only running instances

```
$ oci compute instance list --compartment-id ocid1.compartment.oc1..aaaaaaaa ... yq --lifecycle-state="RUNNING"
```

You might be surprised that listing instances does not show the public IP addresses of the instances. OCI resources do not exist in isolation but have relationships
with other objects and you sometimes have to perform "joins" to get the information that you're after. An IP address is assigned to a VNIC and a VNIC is associated
with a VNIC via a "VNIC attachment" resource. In this case, the CLI provides a short cut to list the IP addresses for all all VNICs. This query returns the
IP addresses of our instances

```
$ oci compute instance list-vnics -c ocid1.compartment.oc1..aaaaaaaa ... yq --query 'data[*]."public-ip"'
[
  "130.61.54.217",
  "158.101.168.72"
]
```

Note the `--query 'data[*]."public-ip"'` parameter; the `oci` CLI supports a JSON query language known as [JMESPath](https://mespath.org) for extracting data
from JSON documents.

With the IP addresses and if we have the private key needed for SSH access to a VM, we can get a shell to the VM.

## `sqlcl
As part of the [configuration](../../2_configure), we installed a SQL CLI,`sqlcl`, and a "wallet" on the servers. It's worth knowing how to use `sqlcl` if you're
going to use an Oracle database in OCI. The snippet below shows how we can connect to the VM and then use the wallet and DB password to connect to the database
to query and update data.

```

```
