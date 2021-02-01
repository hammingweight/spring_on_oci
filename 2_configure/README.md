# Configuring the Servers
The servers spun up in the [provisioning](../1_provision) stage need to be configured to be usable:
 * Java needs to be installed.
 * The firewall running on the VMs needs to be opened to allow traffic to the VMs.
 * SQLcl (a CLI for Oracle databases) should be installed so that the database can be administered from the VM.
 * The database wallet created during the provisioning stage should be copied onto the VMs.
   
## Ansible
There are several configuration management tools like Puppet, Chef, Ansible and SaltStack. The preferred
tool for configuring VMs in OCI is Ansible.

Ansible scripts for configuring one or more hosts are written
in YAML and are known as *playbooks*. In addition to the playbooks, a user also needs to create an *inventory*
specifying the hosts and credentials for accessing the hosts and a configuration file, `ansible.cfg`.

To execute a playbook, the user runs the `ansible-playbbok` command which takes the name of a playbbok as well
as optional arguments specifying variables that are needed by the playbook. A typical value that is passed
via a variable is the port number for the "Hello, world" service so that a playbook can configure the firewall
to accept packets destined for the port.

### Installing Ansible
Running the [ap.sh](../ansible_common/ap.sh) script will install Ansible in a Python virtual environment. The script
also installs an *Ansible Galaxy* collection, `oracle.oci`, that provides modules and plugins useful for configuring servers
running in OCI.

### The Ansible inventory
Ansible has the notions of *static* and *dynamic* inventories. Static inventories are, effectivley, lists of server names
with corresponding IP addresses. Static inventories do not work well in cloud environments where IP addresses are
dynamcially assigned and the number of servers can change as the infrastructure dynamically creates or deletes servers in
response to demand. The [inventory](../ansible_common/inventory.oci.yml) file used for configuration is trivial since it
uses the OCI inventory plugin to list all servers created.

### The `configure.yml` playbook
The [configure.yml](./configure.yml) playbook installs Java and SQLcl, copies the database wallet and opens a firewall port on all
instances that are tagged to run the "Hello, world" web service.

If you look at the playbook, you will see that two variables are used, `webservice_port` and `project_name` (variables in playbooks are
enclosed between "`{{`" and "`}}`".) To pass these vriables to the playbook, you would invoke `ansible-playbook` as

```
ansible-playbook -e webservice_port=8000 -e project_name=demo configure.yml
```

Both of those variables are needed during the provisioning stage and are defined in the [tf_vars.sh](../configuration_parameters_common.sh.tmpl)
file. To keep things simple, the [ap.sh](../ansible_common/ap.sh) script will read environment variables from the `tf_vars.sh` file and
pass them to `ansible-playbook`; i.e. `ap.sh` is a thin wrapper around `ansible-playbook` that takes care of populating the variables needed
by playbooks. So, instead of invoking `ansible-playbook` directly to configure the servers you can simply run

```
../ansible_common/ap.sh configure.yml
```
