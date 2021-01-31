# Configuring the Servers
The servers spun up in the [provisioning](../0_provision) stage need to be configured to be usable:
 * Java needs to be installed
 * The firewall running on the VMs needs to be opened to allow traffic to the VMs.
 * SQLcl (a CLI for Oracle databases) should be installed so that the database can be interrogated by an administrator who has
   logged into a VM
   
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
also installs an *Ansible Galaxy* collection, `oracle.oci`, that provides modules useful for configuring servers
running in OCI.
