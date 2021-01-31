# Deploying the "Hello, world" application to OCI
By default, Maven will build the "Hello, world" application for a local environment with an H2 database (see the [0_spring_application README](../0_spring_application).)

Deploying the "Hello, world" service to OCI involves three main tasks:
  * Using Maven to package the application with the `oci` profile.
  * Creating the database schema needed for the application.
  * Copying the packaged JAR to the OCI instances and running the JAR.
 
 All of the tasks are performed using Ansible in the [deploy.yml](./deploy.yml) playbook.
 
 ## `deploy.yml`
 ### Building the application for OCI
 The [resources](./src/main/resources) directory, by default, contains an `application.yml` and `schema.sql` file for the `local` profile. Spring allows multiple
 profiles to be defined in `application.yml` file but the data for the OCI profile needs to include a database password so it would be a poor idea to
 include the OCI profile in the `application.yml` file and store it under source control. Instead we use an Ansible template for the OCI
 [application.yml](./templates/application.yml) which will populate the password from an Ansible variable (`database_admin_password`) that is passed to the
 `ansible-playbook` script.
 
For a production deployment, it's a poor idea to package a `schema.sql` file with an application; instead the database schema should be created before deploying the
application. So, in the case of the `oci` profile we do not want a `schema.sql` file in the `resources` directory.
 
The `deploy.yml` playbook runs a task on the local machine that deletes the contents of the `src/main/resources` directory and then repopulates the
`resources` directory with an `application.yml` file created from the application template. The playbook then builds the application by executing `mvnw package` with
the `oci` profile.

```
./mvnw -Poci clean package
```
 
 ### Creating the database schema
 The [schema.sql file](./templates/schema.sql) contains a SQLcl script that should be run against the database to create the schema in the Autonomous Database. The
 `deploy.yml` file runs the script by copying the schema file to one of the instances and then executing
 
 ```
 /opt/oracle/sqlcl/bin/sql -cloudconfig /home/opc/{{ project_name }}_wallet.zip -L 'admin/"{{ database_admin_password }}"@{{ project_name }}_low' @/home/opc/schema.sql
 ```
 
 Note how this command references the database wallet loaded onto the host during instance [configuration](../2_configure) and needs to authenticate using a secret
 password.
 
 The script should only be run on one host; it does not makes sense to try to create the schema from all of the compute instances. Ansible's `run_once: True` conditional
 is used to limit schema creation to running from only one VM.
 
 ### Deploying and starting the service
 The `deploy.yml` script copies the JAR file built on the local machine to all the hosts and then populates a `systemd` [service file](./templates/demo.service) file with
 the command needed to start our service
 
 ```
 /usr/bin/java -jar /home/opc/{{ project_name }}-{{ project_version }}.jar
 ```
 
 ## Running the deployment
 To deploy the application, we use the [ap.sh](../ansible_common/ap.sh) script that is a thin wrapper around `ansible-playbook`
 
 ```
 ../ansible_common/ap.sh deploy.yml
 ```
