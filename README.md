# Spring Boot on Oracle Cloud Infrastructure (OCI)
This repository contains a Spring Boot "Hello, World" REST Service and scripts that deploy the application on Oracle Cloud Infrastructure. The deployed service uses 
only free-tier resources.

The goal of this project is to show how to provision and configure services in OCI to host a Spring Boot application. Hopefully you'll be able to replace the toy web service
with your real one.

## Prerequisites
You'll need:
 * An [OCI account](https://www.oracle.com/cloud/free/)
 * The [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
 * [Terraform](https://www.terraform.io/downloads.htm)
 
 You'll also need Python 3 (it's included by default in many recent Linux distros.)
 
## Running this stuff immediately
The subfolders in this repo have READMEs describing what the code in the folder does. If, however, you're impatient there's a script that runs it all in the root folder of
the project. Before you do that though, you need to have satisfied the prerequisites. Assuming that you've signed up with OCI and downloaded the CLI, you need to set up
credentials.

### Configure the OCI CLI
For this step, you'll need to retrieve
 * Your user identifier (user OCID)
 * Your tenancy identifier (tenancy OCID)
 
 Then run

```
$ oci setup config
```

Accept the defaults and supply the user and tenancy OCIDs when requested. At the end of the setup, you will have generated a private/public key pair. Upload the *public* key
to your OCI account by following the instructions from running the `oci setup config command).

### Deploying the "Hello, World" Application to OCI
Assuming that you've installed Terraform, you can now deploy the application by checking out this repo and running a helpful script

```
$ git clone git@github.com:hammingweight/spring_on_oci.git
$ cd spring_on_oci/
$ ./provision_configure_deploy.sh
```


