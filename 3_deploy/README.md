# Deploying the "Hello, world" application to OCIhree
By default, Maven will build the "Hello, world" application for a local environment with an H2 database (see the [0_spring_application README](../0_spring_application).)

Deploying the "Hello, world" service to OCI involves t main tasks:
  * Using Maven to package the application with the `oci` profile
  * Creating the database schema needed for the application 
  * Copying the packaged JAR to the OCI instances and running the JAR
 
 All of the tasks are performed using Ansible in the [deploy.yml](./deploy.yml) playbook.
 
 ## Building the application for OCI
 
