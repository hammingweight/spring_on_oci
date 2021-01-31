# Common Ansible Functionality

We use Ansible both for [configuration](../2_configure) and [deployment](../3_deploy). This directory contains Ansible scripts and configuration that is needed for
both configuration and deployment. Ansible is installed in a Python virtual environment in this directory running the [ap.sh](./ap.sh) script without any arguments.

## `ansible.cfg`
The [ansible.cfg](./ansible.cfg) defines the configuration settings used by Ansible. The most important setting is the declaration of the inventory to use

```
inventory = inventory.oci.yml
```

## `inventory.oci.yml`
The [inventory.oci.yml](./inventory.oci.yml) file specifies that the `oracle.oci.oci` plugin should be used to generate an inventory of hosts in OCI. In any cloud infrastructure
environment (e.g. OCI) is does not make sense to have a static inventory of hosts since cloud hosts are frequently assigned dynamic IP addresses and even the number of hosts
can change when using elastic scaling.

## The `ap.sh` script
The [ap.sh](./ap.sh) script is a thin wrapper around `ansible-playbook` that:
 * Installs Ansible if it's not already installed
 * Invokes `ansible-playbook` with arguments derived from the [tf_vars.sh](../configuration_parameters_common/tf_vars.sh.tmpl). Those aarguments include the SSH key needed to
   authenticate the `opc` user for logging into host VMs.
