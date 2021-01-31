# Deploying the "Hello, world" application
By default, Maven will build the "Hello, world" application for a local environment with an H2 database (see the [0_spring_application README](../0_spring_application).)

Deploying the "Hello, world" service to OCI involves two main tasks:
  * Using Maven to package the application with the `oci` profile
  * Copying the packaged JAR to the OCI instances and running the JAR
 
 Both of the tasks are performed using Ansible in the [deploy.yml](./deploy.yml) playbook.
 
 ## Building the application for OCI
 
