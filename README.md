# Spring Boot on Oracle Cloud Infrastructure (OCI)
This repository contains a [Spring Boot](https://spring.io/projects/spring-boot) "Hello, World" REST application and scripts that deploy the application on [Oracle Cloud Infrastructure](https://cloud.oracle.com). The deployed service uses 
only OCI Free Tier resources (the deployed Virtual Machines run on Ampere Altra processors.)

The goal of this project is to show how to provision and configure resources in OCI to host a Spring Boot application.

## Prerequisites
You'll need:
 * An [OCI account](https://www.oracle.com/cloud/free/) in a region that supports the free tier (like eu-frankfurt-1, uk-london-1 or us-ashburn-1.)
 * The [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
 * [Terraform](https://www.terraform.io/downloads.html)
 
You'll also need Python 3 (it's included by default in many recent Linux distros.)

The code *should* work in any free tier region but has been tested only in `eu-frankfurt-1`.

## What this code does
The REST service is a toy example that exposes a `/hello/{name}` endpoint that returns how often a `GET` request has been performed against each `name` endpoint; e.g. how often the `/hello/alice` or `hello/bob` API endpoints have been invoked. The request counts are stored in a database; for local testing an H2 in-memory database is used while in OCI an Oracle Autonomous database is used.

In the OCI environment, the code:
 * Provisions a virtual cloud network (VCN) with routing rules and security lists.
 * Instantiates two Oracle Linux VMs and installs Java on them.
 * Creates an Oracle Database and a "wallet" with credentials for accessing the database. The wallet is installed on both VMs to authenticate client requests to the database.
 * Deploys the Spring Boot application to both VMs.
 * Spins up a load balancer with a self-signed SSL certificate to round-robin requests to the VMs.

## Getting up and running quickly
The subfolders in this repo have READMEs describing what the code in the folder does and how to execute it. If, however, you're impatient there's a script that provisions 
infrastructure and then builds and deploys the service. Before running the script though, you need to have satisfied the prerequisites. Assuming that you've signed up with OCI 
and downloaded the CLI, the first step is to configure your OCI credentials.

### Configure the OCI CLI
For this step, you'll need to have your OCI credentials; specifically you should know
 * Your user identifier (user OCID which is a value like `ocid1.user.oc1..aaaaaaaa...mna`)
 * Your tenancy identifier (tenancy OCID which is a value like `ocid1.tenancy.oc1..aaaaaa...tvq`)
 * Your OCI home region (e.g. `eu-frankfurt-1`) 
 
 Then run

```
$ oci setup config
```

Accept the defaults and supply the user and tenancy OCIDs and region when requested. At the end of the setup, you will have generated a private/public key pair. Upload the
API signing public key to your OCI account by following the instructions emitted by the `oci setup config` command:

```
    If you haven't already uploaded your API Signing public key through the
    console, follow the instructions on the page linked below in the section
    'How to upload the public key':

        https://docs.cloud.oracle.com/Content/API/Concepts/apisigningkey.htm#How2
```

With default configuration, the key that you need to upload exists at the path `~/.oci/oci_api_key_public.pem`.


### Deploying the "Hello, World" application to OCI
If you've installed Terraform, you can now deploy the application by running

```
$ git clone https://github.com/hammingweight/spring_on_oci.git
$ cd spring_on_oci/
$ ./provision_configure_deploy.sh
```

If the script fails almost immediately with the error below, you probably didn't upload your API signing key

```
Error: Service error:NotAuthenticated. The required information to complete authentication was not provided or was incorrect..
```

If you successfully installed your signing key, the script will take about to hour to run to completion on the first run. Subsequent runs will be much faster since the time for
the first run is dominated by installing dependencies into your local environment.

At the end of the run, you should see output similar to

```
PLAY RECAP **********************************************************************************************************
130.61.188.32              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
130.61.189.70              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=8    changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

load_balancer_ip = "193.122.63.175"
```

The IP address of the load balancer is needed to access the REST service. If you try accessing the service immediately, you'll probably get back HTTP status code `502`

```
$ curl -w '\n' -ks https://193.122.63.175/hello
<html>
<head><title>502 Bad Gateway</title></head>
<body bgcolor="white">
<center><h1>502 Bad Gateway</h1></center>
<hr><center></center>
</body>
</html>
```

After a few minutes, the load balancer should determine that the Spring Boot applications are healthy and API requests should succeed

```
$ curl -w '\n' -ks https://193.122.63.175/hello
{"visits":1,"message":"Hello, world"}
$ curl -w '\n' -ks https://193.122.63.175/hello
{"visits":2,"message":"Hello again, world"}
$ curl -w '\n' -ks https://193.122.63.175/hello
{"visits":3,"message":"Hello again, world"}
$ curl -w '\n' -ks https://193.122.63.175/hello/alice
{"visits":1,"message":"Hello, alice"}
$ curl -w '\n' -ks https://193.122.63.175/hello/alice
{"visits":2,"message":"Hello again, alice"}
$ curl -w '\n' -ks https://193.122.63.175/hello
{"visits":4,"message":"Hello again, world"}
```

Note that the `curl` commands were invoked with a `-k` switch; the SSL certificate loaded into the load balancer is a self-signed certificate so `curl` will fail if we don't
allow insecure SSL connections.

### Destroying the Infrastructure
If you want to destroy the infrastructure to free up resources, the easiest way is to run

```
./destroy.sh
```

## Looking at the code in more detail
Deploying an application to any cloud Infrastructure-as-a-Service (IaaS) involves four steps:
 * Writing the application.
 * Provisioning resources (VMs, load balancers, databases, etc.) in the IaaS.
 * Configuring the VM servers (e.g. installing Java or opening firewall ports.)
 * Deploying your application to the servers.
 
 The READMEs in the following folders provide more details:
 
 0. [The Spring Boot application.](./0_spring_application#readme)
 1. [Provisioning.](./1_provision#readme) Resources are provisioned using the OCI provider for Terraform.
 2. [Configuring.](./2_configure#readme) The servers are configured using Ansible.
 3. [Deploying.](./3_deploy#readme) The application is built using Maven and deployed using Ansible.
  
  The code is also commented which might provide insights that the READMEs don't supply.

Software is not finished when it's deployed; the [operations README](./4_operations#readme) provides some pointers
to tools that can be useful in operating, maintaining and debugging an application running on OCI.
