# Deploying the "Hello, world" application to OCI
Deploying the "Hello, world" service to OCI involves three main tasks:
  * Creating the database schema needed for the application.
  * Using Maven to package the application with the `oci` profile.
  * Copying the packaged JAR to the OCI instances and running the JAR.
 
 All of the tasks are performed using Ansible in the [schema.yml](./schema.yml) and [deploy.yml](./deploy.yml) playbooks. We separate the schema
 creation from the application depolyment since, in practice, the application may undergo many revisions and we may want to deploy many iterative versions of
 the application while the database schema is likely to remain comparatively static. By separating schema creation from application deployment, we can run the
 deployment script regularly without trying to recreate the database schema on every new deployment.
 
 ## `schema.yml`
 ### Creating the database schema
For a production deployment, it's a poor idea to package a `schema.sql` file with an application; instead the database schema should be created before running the
application.  The [schema.sql file](./templates/schema.sql) defines the schema used by our Spring Boot application. The [schema.yml](./schema.yml) playbook creates
the schema by copying the schema SQL file to one of the compute instances and then executing
 
 ```
 /opt/oracle/sqlcl/bin/sql -cloudconfig /home/opc/{{ project_name }}_wallet.zip -L 'admin/"{{ database_admin_password }}"@{{ project_name }}_low' @/home/opc/schema.sql
 ```
 
 Note how this command references the database wallet loaded onto the host during instance [configuration](../2_configure) and needs to authenticate using a secret
 password.
 
 The script should only be run on one host; it does not makes sense to try to create the schema from all of the compute instances. Ansible's `run_once: True` conditional
 is used to limit the schema creation to a single VM.

To run the `schema.yml` playbook, we use the [ap.sh](../ansible_common/ap.sh) script that is a thin wrapper around `ansible-playbook`
 
 ```
 ../ansible_common/ap.sh schema.yml
 ```

 
 ## `deploy.yml`
 ### Building the application for OCI
 The [resources](./src/main/resources) directory, by default, contains an `application.yml` and `schema.sql` file for the `local` Maven profile. Spring allows multiple
 profiles to be defined in `application.yml` file but the data for the OCI profile needs to include a database password so it would be a poor idea to
 include the OCI profile in the `application.yml` file and store it under source control. Instead we use an Ansible template for the OCI
 [application.yml](./templates/application.yml) which will populate the password from an Ansible variable (`database_admin_password`) that is passed to the
 `ansible-playbook` script.
 
As noted in the previous section, in the case of the `oci` profile we do not want a `schema.sql` file in the `resources` directory so we shohuld ensure that we do 
not package the `schema.sql` used by the default (`local`) profile with our application. Our build script should remove `schema.sql` from the resources
directory so that we don't package that script with the Spring application.

The `deploy.yml` playbook runs a task on the local machine that deletes the contents of the `src/main/resources` directory and populates the
`resources` directory with an `application.yml` file created from the application template needed for the OCI environment. The playbook then builds the application
by executing `mvnw package` with the `oci` profile.

```
./mvnw -Poci clean package
```
 
  ### Deploying and starting the service
 The `deploy.yml` script copies the JAR file built on the local machine to all the hosts and populates a `systemd` [service file](./templates/demo.service) file with
 the command needed to start our service
 
 ```
 /usr/bin/java -jar /home/opc/{{ project_name }}-{{ project_version }}.jar
 ```
 
 To build and deploy the application, we can run
 
 ```
 ../ansible_common/ap.sh deploy.yml
 ```
 
 A point to note is that we run the deployment playbook with the `serial: 1` directive. The directive ensures that only one server is updated
 at a time. While a server is being updated, it cannot handle requests but the other server(s) can continue to handle API calls. The serialization ensures that during an
 upgrade the load balancer will forward requests to the healthy server(s) and users should experience (near) zero downtime even during an upgrade of our service.
