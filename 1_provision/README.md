# Provisioning
In this section, "provisioning" means creating resources in OCI. Resources that are typically provisioned include resources for:
 * Identity and access management (IAM)
 * Compute (such as virtual machines or containers)
 * Networking (such as virtual networks, load balancers, routing tables and security lists)
 * Storage (which includes virtual block volumes but also distributed storage mechanisms such as object storage or databases)

## Terraform
There are many ways to create resources in OCI including through the web console, OCI's REST API, the OCI CLI, the OCI SDKs and Ansible.
However, the most reliable way to reproducibly create resources in an automated way is to use the OCI provider for Terraform.

### The HCL language
Terraform describes "things" in the Hashicorp Configuration Language (HCL) where "things" can be:
  * providers of infrastructure (e.g. OCI)
  * variables (e.g. a password, the number of VMs that should be created or a port number that a firewall should allow access to)
  * resources (e.g. a compute VM or a virtual network)
  * data (some value retrieved from the infrastructure such as list of images for spinning up VMs)
  * output (a value that should be reported to the user once provisioning is finished such as the IP address of a load balancer)
 
 ### `.tf` files
 Terraform expects that infrastructure and other "things" will be declared in files that end in a `.tf` extension. Terraform will determine
 the relationships between objects even if they are in different files and it doesn't impose restrictions on what resources can be defined
 where. If you want to create a database resource in a file called `network.tf` that's fine syntactically.
 
 ### Large Terraform projects and modules
 If you need to provision many sites or have many grouped resources (e.g. you're deploying several microservices or you have different needs for
 development, test and production sites or different requirements across regions), it's a good idea to modularize your Terraform files which means
 creating directories for distinct scenarios. In HCL, these directories are known as "modules". If you simply put all your `.tf` files into a
 single directory, that directory is known as the "root" module.
 
 This is a simple project so all of the Terraform files live in a root module. Putting everything in the root module is not be best practice for a
 complex topology but keeping this example simple avoids the complexities of referencing values across modules.
 
 ## Provisioning OCI for the "Hello, world" REST API
 ### The variables needed
 The [vars.tf](./vars.tf) file declares all of the variables needed for this project. If you open the file though you'll see the variables are simply
 declared but no values are assigned. Terraform can retrieve the values of variables needed in two ways:
  * By prompting the user to enter a value
  * By retrieving it from an environment variable. Any environment variable that starts with `TF_VAR_` is mapped to a corresponding Terraform variable.
 
The [tf_vars.sh.tmpl](../configuration_parameters_common/tf_vars.sh.tmpl) file is a template that can be used to populate the variables needed, which you
edit with your chosen values. I.e.

```
$ cp ../configuration_parameters_common/tf_vars.sh.tmpl ../configuration_parameters_common/tf_vars.sh
$ vi ../configuration_parameters_common/tf_vars.sh
$ source ../configuration_parameters_common/tf_vars.sh
```

There is also some "intelligence" built into the script that will generate SSH and SSL public key pairs if the declared keys can't be found. If you
want to use particular keys for SSL (e.g. not a self-signed SSL certificate) and SSH, you should edit the `tf_vars.sh` file to reference your preferred
keys.

### Running Terraform
Now, that the role of the `tf_vars.sh` file is clear, you can provision the infrastructure with default values by running

```
$ source ../configuration_parameters_common/tf_vars.sh
$ terraform init
$ terraform apply
```

Similarly to tear down your infrastructure

```
$ source ../configuration_parameters_common/tf_vars.sh
$ terraform destroy
```
