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
with other objects and you sometimes have to perform "joins" to get the information that you're after. For example, to find the IP addresses of our instances, we
have to know that IP addresses are assigned to VNICs (Virtual Network Interface Cards) via a `vnic-attachment`.

## `sqlcl`
