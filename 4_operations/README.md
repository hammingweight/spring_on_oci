# Operations
Once software has been deployed the software has to be operated and maintained. This section provides an incomplete list of tools
that are useful for debugging and otherwise maintaining deployed applicatbions in OCI. The tools are classified into two broad
categories: command line tools and tools provided by OCI.

The coverage of these tools is very limited.

## Command line tools
### terraform
[Terraform](https://terraform.io) was used to [provision](../1_provision) this project by running `terraform apply` but there are other useful commands:
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

It's a good idea to include `output` directives in your `.tf` files to emit facts that are useful. See the [compartment.tf](../1_provision/compartment.tf) and
[load_balancer.tf](../1_provision/load_balancer.tf) files for examples.

### The `oci` CLI

### `sqlcl`

## Platform tools
### The notification service
