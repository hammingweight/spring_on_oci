# The "Hello, world" REST API
This Spring Boot application has a single REST Controller, [HelloController](./src/main/java/com/example/demo/controllers/HelloController.java), that exposes two API
endpoints: `/hello` and `/hello/{name}` where the `/hello` endpoint is a shortcut for `/hello/world`. The controller interacts with a SQL database to store a count of
the number of times that `/hello/{name}` is invoked.

## Building the application for a local versus an OCI deployment
This project is built using Maven. It's common to have different profiles in a Maven POM file to handle different requirements in local versus production deployments. In
particular, an in-memory database is used for local development while, e.g., an Oracle database is used in production. That's the case in this example where an examination
of the [POM file](./pom.xml) shows that there are two profiles: `local` and `oci`

```
<profile>
    <!-- For local development we use the embedded H2 database -->
    <id>local</id>
    <activation>
        <activeByDefault>true</activeByDefault>
    </activation>
    <dependencies>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
    </dependencies>
</profile>
<profile>
    <!-- For the OCI profile, we'll use an Oracle 19c DB -->
    <id>oci</id>
    <dependencies>
        <dependency>
            <groupId>com.oracle.database.jdbc</groupId>
            <artifactId>ojdbc8-production</artifactId>
            <version>19.7.0.0</version>
            <type>pom</type>
        </dependency>
    </dependencies>
</profile>
```

If we build the `local` profile (which is activated by default) we'll include the H2 database while JDBC drivers for Oracle 19c are used when we build the `oci` profile.

The rest of this README describes building and running the application locally; building the application for OCI is described in the [3_deploy/README.md file](../3_deploy/README.md).

## The `application.yml` file for local development
The [application.yml](./src/main/resources/application.yml) file does not contain anything unusual; the application properties specify that the REST service will listen for
requests on port 8000 and that the application should expose an API endpoint, `/h2`, to allow users to query the H2 database.

## The `schema.sql` file
If a Spring Boot application is packaged with a `schema.sql` file, Spring will try to create the schema when the service is restarted. Including such a file makes sense for
local development since an in-memory database will be destroyed when an application shuts down and will need to be recreated when the service starts up again. It makes less
sense to include such a file in a production environment where you typically run multiple instances of a service and the database schema only needs to be created once and
not for every instance of the service.

The [schema.sql](./src/main/resources/schema.sql) creates a database that map names to a count:

```
CREATE TABLE IF NOT EXISTS visitors (
    name VARCHAR(50) NOT NULL,
    num_visits NUMBER,
    PRIMARY KEY(name)
);
```

## Building and running the service locally
To build the service for local testing, we need to use the `local` profile

```
$ ./mvnw -Plocal clean package
```

but, since `local` is activated by default, we can omit the profile

```
$ ./mvnw clean package
```

We can then run the service locally
```
$ java -jar target/demo-0.1.jar
```

and issue `GET` requests against our API

```
$ curl -w '\n' http://localhost:8000/hello
{"visits":1,"message":"Hello, world"}
```

Visting http://localhost:8000/h2 from a browser opens a console to manage and query the H2 database.
