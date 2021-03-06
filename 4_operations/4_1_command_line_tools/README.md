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

generates an enormous amount of information even for this small project; the last lines show some useful details as "ouput".

```
Outputs:

compartment_ocid = "ocid1.compartment.oc1..aaaaaaaa ... yq"
load_balancer_ip = "193.122.63.175"
```

It's a good idea to include `output` directives in your `.tf` files to emit facts that are useful. See the [compartment.tf](../../1_provision/compartment.tf) and
[load_balancer.tf](../../1_provision/load_balancer.tf) files for examples.

The `terraform` commands usually require that the variables needed by the terraform plans have been populated by running, e.g.,

```
$ source tf_vars.sh
```

The utility script [tf.sh](../../1_provision/tf.sh) can be used to source the variables before running `terraform`. For example,

```
$ cd 1_provision
$ ./tf.sh show
```


## `ansible`
The `ansible-playbook` script was used to execute playbooks consisting of many tasks to [configure](../../2_configure/configure.yml) the hosts and to
[deploy](../../3_deploy/deploy.yml) our service. There are other tools in the Ansible toolkit that are also worth knowing about:
 * `ansible` is a command line tool that lets the operator run a single task against hosts without packaging the task into a playbook.
 * `ansible-inventory` which can be used to list all hosts in the inventory.
 

## The `oci` CLI
The OCI CLI is particularly useful for querying resources. The general form of a command is

```
oci <COMMAND> <RESOURCE_TYPE> <OPERATION>
```

Most commands require that you specify either the OCID of a resource or a compartment. For example, to list all instances in a compartment

```
$ oci compute instance list --compartment-id ocid1.compartment.oc1..aaaaaaaa ... yq
```

That example would also return results for instances that have been terminated. To get only running instances we can issue the previous command with a filter on the
`lifecycle-state`

```
$ oci compute instance list --compartment-id ocid1.compartment.oc1..aaaaaaaa ... yq --lifecycle-state="RUNNING"
```

You might be surprised that listing instances does not show the public IP addresses of the instances. OCI resources do not exist in isolation but have relationships
with other objects and you sometimes have to perform "joins" to get the information that you're after. An IP address is assigned to a VNIC and a VM is associated
with a VNIC via a "VNIC attachment" resource. In this case, the CLI provides a short cut to list the IP addresses for all all VNICs. This query returns the
IP addresses of our instances

```
$ oci compute instance list-vnics -c ocid1.compartment.oc1..aaaaaaaa ... yq --query 'data[*]."public-ip"'
[
  "130.61.188.32",
  "130.61.189.70"
]
```

Note the `--query 'data[*]."public-ip"'` parameter; the `oci` CLI supports a JSON query language known as [JMESPath](https://mespath.org) for extracting data
from JSON documents.

With the IP addresses and using the private key needed for SSH access, we can get a shell to the VM.

## `SQLcl`
As part of the [configuration](../../2_configure), we installed a SQL CLI,`SQLcl`, and a "wallet" on the servers. It's worth knowing how to use `SQLcl` if you're
going to use an Oracle database in OCI. The snippet below shows how we can connect to the VM and then use the wallet and DB password to connect to the database
to query and update data.

```
$ ssh -i ../configuration_parameters_common/vm_ssh_key opc@130.61.188.32
Last login: Thu Feb 11 04:21:11 2021 from 41.75.111.147
[opc@inst-0zdaf-demoinstancepool ~]$ /opt/oracle/sqlcl/bin/sql -cloudconfig ./demo_wallet.zip -L 'admin/S3cr3t?assword@demo_low'

SQLcl: Release 20.4 Production on Thu Feb 11 04:35:34 2021

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Operation is successfully completed.
Operation is successfully completed.
Using temp directory:/tmp/oracle_cloud_config5891842159087229846
Last Successful login time: Thu Feb 11 2021 04:35:42 +00:00

Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.5.0.0.0


SQL>  -- count the number of unique visitors
SQL> select count(*) from visitors;

   COUNT(*)
___________
          2

SQL> -- count the total number of visits
SQL> select sum(num_visits) from visitors;

   SUM(NUM_VISITS)
__________________
                 6

SQL> -- view all visitors
SQL> select * from visitors;

    NAME    NUM_VISITS
________ _____________
world                4
alice                2

SQL> -- delete all records
SQL> delete visitors;

2 rows deleted.

SQL> commit;

Commit complete.

SQL> Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.5.0.0.0
[opc@inst-0zdaf-demoinstancepool ~]$
```

We passed a reference to the wallet via the `cloudconfig` argument and connected to the database by passing credentials and an endpoint in the for
<username>/password@<tns_entry>. "TNS" stands for "Transparent Network Substrate". If you want to know what TNS endpoints are available to connect to, you can
run `SQLcl` without logging in and running `show tns`.
  
```
[opc@inst-0zdaf-demoinstancepool ~]$ /opt/oracle/sqlcl/bin/sql -cloudconfig demo_wallet.zip /nolog

SQLcl: Release 20.4 Production on Thu Feb 11 04:43:31 2021

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Operation is successfully completed.
Operation is successfully completed.
Using temp directory:/tmp/oracle_cloud_config3067693529660537264

SQL> show tns;
TNS_ADMIN set to: /tmp/oracle_cloud_config3067693529660537264


Available TNS Entries
---------------------
demo_high
demo_low
demo_medium
demo_tp
demo_tpurgent
SQL> 
```

Note that we also needed to supply a TNS entry when we populated the [application.yml](../../3_deploy/templates/application.yml) file so that Spring could connect to the
database.
