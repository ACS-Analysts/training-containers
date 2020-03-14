# Intro to Containers
## Summary
In this opening demo we will create a basic container that runs a "Hello World" app in Java and deploy that container to
Docker. The app only logs output to STDOUT and performs not network functions. We will also learn how to interact with a
running container and perform basic management functions.

## Assumptions
All commands and file locations are assumed to be run from the repository root.

## Building a Container
### Building the JAR file
We need a JAR file to run our application from. The application can be found in [src/main/java](src/main/java). We will
use the [Maven](https://maven.apache.org/) build tool to create a JAR file containing our classes and any dependencies
we may need. The maven build is controlled by the [pom.xml](../../pom.xml) file.

```shell script
sandbox$ mvn package
```

### Building the Docker image
The Docker image can be built two ways. Both should result in a functionally identical image. The first way is to use
docker to build the image directly using a "Dockerfile". The second is to use packer to build the image which will in
turn run the docker build for you. For reasons why this might be useful, see the
[Dockerfile vs Packer](#dockerfile-vs-packer) section.

Please note that you don't need to do both, you can do either Packer or Dockerfile.

#### Dockerfile
To see what how things are defined, look at the Dockerfile:
```shell script
sandbox$ cat Dockerfile
```

Then build the image using the `docker` command.
```shell script
sandbox$ docker build -t hello .
```

#### Packer
Instead of using the Dockerfile directly, packer uses a JSON file to define the image. Packer supports many different
image formats through it's "builder" plugins. First take a look at the packer file:
```shell script
sandbox$ cat packer/hello.json
```

Then build the image using the `packer` command:
```shell script
sandbox$ packer build packer/hello.json
```

## Deploying a Container
### Run as standalone Docker image
We should see our image listed in docker:
```shell script
sandbox$ docker image ls
```

Go ahead and run an instance of our container
```shell script
sandbox$ docker run -d --name hello hello
```

Check that everything started up OK:
```shell script
sandbox$ docker ps
```

And then check the logs to see the results:
```shell script
sandbox$ docker logs hello
```

You should see the output of the Java app in the logs:
```
Hello world! (1)
Hello world! (2)
```

When you're ready, stop and remove the container:
```shell script
sandbox$ docker stop hello
sandbox$ docker rm hello
```

You can also delete a running conatiner using the `--force` option:

```shell script
sandbox$ docker rm --force hello
```

### Running the image with additional parameters
The app supports changing the message by passing a command line parameter. This can be passed to the `docker run` command:
```shell script
sandbox$ docker run -d --name hello hello Superman
```

And then check the logs to see the results:
```shell script
sandbox$ docker logs hello
```

The message should now include your parameter:
```
Hello Superman! (1)
Hello Superman! (2)
```

## Managing Docker
### Executing a Command
Commands can be executed against running containers. For instance, to get a shell on our `hello` container:
```shell script
sandbox$ docker exec -it hello bash
```

In this case the `-it` flags tell docker to attach STDIN to our local TTY. The above command is a very common method to
investigate or debug a running container since most containers do not have SSH installed, only the process they are in
charge of.

### Listing Containers
You get a list of running containers using the `ps` command:
```shell script
sandbox$ docker ps
```

To see all containers, even ones that are currently paused, use the `-a` flag:
```shell script
sandbox$ docker ps -a
```

### Listing Images
```shell script
sandbox$ docker image ls
```

### More Commands
For a complete list of supported docker commands see the [Docker CLI reference](https://docs.docker.com/engine/reference/commandline/docker/).

## Up Next
Next up is an [introduction to Kubernetes](../intro_to_kubernetes/README.md).

## References
* [What is a container?](https://www.docker.com/resources/what-container)
* [OpenJDK base image](https://hub.docker.com/_/openjdk)

## Dockerfile vs Packer
Using a Dockerfile is the standard way to create a Docker image. Packer is an infrastructure as code (IaC) tool that
makes automating and managing images more repeatable and easier.

Packer has several plugins that can live at different points in the build cycle; docker is just one of the "builders"
it supports. Packer can execute multiple builders if necessary. For instance, if you wanted to build a Docker image
and a vmWare image for the same application you would just wire up the additional builder and packer would make sure
both images are provisioned identically.

In addition to builders, packer supports variables and numerous "provisioners". We used the "shell" provisioner in our
example but we could also have used more advanced automation tools such as Ansible.

For more info see [packer.io](http://packer.io)
