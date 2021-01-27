# The "Hello, world" REST API
This Spring Boot application exposes two REST endpoints that can be queried and that return JSON documents.

Querying (i.e. doing a `GET`) against the path `/hello/{name}` returns a document with a message and a count that records how many times that API endpoint has been queried. Issuing
a `GET` against the path `/hello` is the same as querying the `/hello/world` endpoint.

## Building the Application
From this directory, run
```
./mvnw clean package
```

You can then start the application by running
```
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

And then query the API from a browser or using `curl`
```
$ curl http://localhost:8000/hello
{"visits":1,"message":"Hello, world"}
$ curl http://localhost:8000/hello
{"visits":2,"message":"Hello again, world"}
$ curl http://localhost:8000/hello/Carl
{"visits":1,"message":"Hello, Carl"}
$ curl http://localhost:8000/hello/world
{"visits":3,"message":"Hello again, world"}
```
