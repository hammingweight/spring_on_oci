# The "Hello, world" REST API
This Spring Boot application has a single REST Controller, [HelloController](./src/main/java/com/example/demo/controllers/HelloController.java) that exposes two API
endpoints: `/hello` and `/hello/{name}` where the `/hello` endpoint is a shortcut for `/hello/world`. The controller interacts with a SQL database to store a count of
the number of times that `/hello/{name}` is invoked for `{name}`.

## Building the application for a local versus an OCI deployment
This project is built using Maven. It's common to have different profiles in a POM file to handle different requirements in local versus production deployments. In particular,
it's common to use an in-memory database for local development while using an Oracle database in production. That's true in this case as well where an examination of the [POM file](./pom.xml) shows that there are two profiles: `local` and `oci`

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
