# Spring Boot on Oracle Cloud Infrastructure (OCI)
This repository contains a Spring Boot "Hello, World" REST application and scripts that deploy the application on Oracle Cloud Infrastructure. The deployed service uses 
only OCI free-tier resources.

The goal of this project is to show how to provision and configure resources in OCI to host a Spring Boot application.

## Prerequisites
You'll need:
 * An [OCI account](https://www.oracle.com/cloud/free/) in a region that supports Oracle Free tier (like eu-frankfurt-1, uk-london-1 or us-ashburn-1.)
 * The [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
 * [Terraform](https://www.terraform.io/downloads.htm)
 
You'll also need Python 3 (it's included by default in many recent Linux distros.)

The code *should* work in any free tier region but has been tested only in `eu-frankfurt-1`.

## What this code does
The REST service is a toy example that exposes a `/hello/{name}` endpoint that returns how often a `GET` request has been performed against each `name` endpoint; e.g. how often the `/hello/alice` or `hello/bob` API endpoints have been invoked. The request counts are stored in a database; for local testing an H2 in-memory database is used while in OCI, an Oracle Autonomous database is used.

In the OCI environment, the code:
 * Provisions a virtual cloud network (VCN) with routing rules and security lists.
 * Instantiates two Oracle Linux VMs and installs Java on them.
 * Creates an Oracle Database and a "wallet" with credentials for accessing the database. The wallet is installed on the the VMs to allow requests to the database.
 * Deploys the Spring Boot application to both VMs.
 * Spins up a load balancer with a self-signed SSL certificate to round-robin requests to both VMs.

## Getting up and running quickly
The subfolders in this repo have READMEs describing what the code in the folder does and how to execute it. If, however, you're impatient there's a script that provisions 
infrastructure and then builds and deploys the service. Before running the script though, you need to have satisfied the prerequisites. Assuming that you've signed up with OCI 
and downloaded the CLI, the first step is to configure your OCI redentials.

### Configure the OCI CLI
For this step, you'll need to supply
 * Your user identifier (user OCID which is a value like `ocid1.user.oc1..aaaaaaaa...mna`)
 * Your tenancy identifier (tenancy OCID which is a value like `ocid1.tenancy.oc1..aaaaaa...tvq`)
 * Your OCI home region (e.g. `eu-frankfurt-1`) 
 
 Then run

```
$ oci setup config
```

Accept the defaults and supply the user and tenancy OCIDs and region when requested. At the end of the setup, you will have generated a private/public key pair. Upload the
API Signing public key to your OCI account by following the instructions emitted by the `oci setup config` command:

```
    If you haven't already uploaded your API Signing public key through the
    console, follow the instructions on the page linked below in the section
    'How to upload the public key':
oci_api_key_public.pem
        https://docs.cloud.oracle.com/Content/API/Concepts/apisigningkey.htm#How2
```

With default configuration, the key that you need to apply exists at the path `~/.oci/oci_api_key_public.pem`.


### Deploying the "Hello, World" Application to OCI
If you've installed Terraform, you can now deploy the application by checking out this repo and running the `provison_configure_deploy` script

```
$ git clone git@github.com:hammingweight/spring_on_oci.git
$ cd spring_on_oci/
$ ./provision_configure_deploy.sh
```

If the script fails almost immediately with the error below, you probably didn't upload your API signing key

```
Error: Service error:NotAuthenticated. The required information to complete authentication was not provided or was incorrect..
```

If you successfully installed your signing key, the script will take about an hour to complete. At the end of the run, you should see some output similar to

```
PLAY RECAP *************************************************************************************************************************************************************
130.61.159.216             : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
130.61.246.238             : ok=6    changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=8    changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

load_balancer_ip = "158.101.189.28"
```

The IP address of the load balancer is needed to access the REST service. If you try accessing the service immediately, you'll probably see HTTP status code `502`

```
$ curl -w '\n' -k https://158.101.189.28/hello
<html>
<head><title>502 Bad Gateway</title></head>
<body bgcolor="white">
<center><h1>502 Bad Gateway</h1></center>
<hr><center></center>
</body>
</html>
```

After a few minutes though, the load balancer should determine that the Spring Boot applications are healthy and API requests should succeed

```
$ curl -w '\n' -k https://158.101.189.28/hello
{"visits":1,"message":"Hello, world"}
$ curl -w '\n' -k https://158.101.189.28/hello
{"visits":2,"message":"Hello again, world"}
$ curl -w '\n' -k https://158.101.189.28/hello
{"visits":3,"message":"Hello again, world"}
$ curl -w '\n' -k https://158.101.189.28/hello/Alice
{"visits":1,"message":"Hello, Alice"}
$ curl -w '\n' -k https://158.101.189.28/hello/Alice
{"visits":2,"message":"Hello again, Alice"}
$ curl -w '\n' -k https://158.101.189.28/hello
{"visits":4,"message":"Hello again, world"}
```

Note that the `curl` commands were invoked with a `-k` switch; the SSL certificate loaded into the load balancer is a self-signed certificate so `curl` will fail if we don't
allow insecure SSL connections.
