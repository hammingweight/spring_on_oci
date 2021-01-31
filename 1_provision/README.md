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

### The Terraform Files
#### `provider.tf`
The [provider.tf](./provider.tf) file declares that we want to provision our infrastructure on OCI.

#### `compartment.tf`
OCI has an idea of compartments which allows tenancies to be divided into compartments of grouped resources. The [`compartment.tf`](./compartment.tf) file creates
a compartment that all resources (VM, networks, load balancers, etc) will be created in. Many of the other files will reference the compartment created with
assignments like

```
compartment_id = oci_identity_compartment.compartment.id
```

#### `compute.tf`
The [compute.tf](./compute.tf) file provisions our VMs. For horizontal scalability we don't simply declare the compute instances (aka VMs) directly; instead
we define an "instance configuration" which is a blueprint that allows us to spin up muliple instances of identical VMs. The instance configuration includes:
 * The SSH key that should be used to access the VMs
 * The shape of the VM
 * The image from which the instance should be launched
 
 We then define an "instance pool" that specifies the size of the pool (i.e. how many instances we want to launch) and that the instances should be based on
 the previously defined instance configuration. We also specify that we want a load balancer to distribute traffic to the instances.
 
 #### `load_balancer.tf`
 The [load_balancer.tf](./load_balancer.tf) file instantiates a load balancer with an SSL certificate and key that we supply. The declaration of the load balancer
 also specifies how to check that instances are healthy. Since we're deploying a Spring Boot application that means instructing the load balancer to poll the
 `/actuator/health` endpoint of our services.
 
 #### `network.tf`
 Our VMs need to exist on a Virtual Cloud Network (VCN) and need access to the internet. The VCN is split into two subnets: one subnet for our VMs and the other subnet
 for the load balancer. There are also security rules that restrict traffic to the load balancer and the VMs (e.g. only the load balancer can access the REST endpoint
 of our service but we can SSH into the VMs from anywhere). The [network.tf](./network.tf) defines the VCN and subnets, internet gateway and security lists.
 
 #### `database.tf`
 The [database.tf](./database.tf) file provisions an OLTP (aka ATP) database in OCI. Naturally, a database should have access restrictions limiting who can query
 the database. The Terraform scripts create a "wallet" for the database with credentials. The wallet is downloaded to the host machine and can be installed on the
 VMs during [configuration](../2_configure/README.md) so that our deployed service can read from and write to the database.
