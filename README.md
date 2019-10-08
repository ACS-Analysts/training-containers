# Container Demo
## Summary
This repo provides a demo of a simple "Hello World" Java app and creates a
Docker image that can be run either standalone or as part of a Kubernetes
cluster. The Docker image can be built either using a Dockerfile or Packer.

## Prerequisites
This demo assumes you are running on a Linux box. However, this demo should
work just fine on Mac or Windows once the software is installed. Please
install the following software prior to beginning this demo:

* [Docker CE v19.0](https://docs.docker.com/install/)
* [packer v1.4.4](https://packer.io/downloads.html) (optional)
* [maven v3.3+](https://maven.apache.org/download.cgi)
* Java SDK 11 (choose your own adventure)

## Doing it manually
### Building the JAR file
```
$ mvn package
```

### Building the Docker image
The Docker image can be built two ways. Both should result in an identical
image. The first way is to use docker to build the image directly using a
"Dockerfile". The second is to use packer to build the image which will in
turn run the docker build for you. For reasons why this might be useful, see
the [Dockerfile vs Packer] section.

#### Dockerfile
To see what how things are defined, look at the Dockerfile:
```
$ cat Dockerfile
```

Then build the image using the `docker` command.
```
$ docker build -t hello .
```

#### Packer
Instead of using the Dockerfile directly, packer uses a JSON file to define
the image. Packer supports many different image formats through it's "builder"
plugins. First take a look at the packer file:
```
$ cat packer/hello.json
```

Then build the image using the `packer` command:
```
$ packer build packer/hello.json
```

## Run as standalone Docker image
We should see our image listed in docker:
```
$ docker image ls
```

Go ahead and run an instance of our container
```
$ docker run -d --name hello hello
```

Check that everything started up OK:
```
$ docker ps
```

And then check the logs to see the results:
```
$ docker logs hello
```

You should see the output of the Java app in the logs:
```
Hello world! (1)
Hello world! (2)
```

When you're ready, stop and remove the container:
```
$ docker stop hello
$ docker rm hello
```

## Running the image with additional parameters
The app supports changing the message by passing a command line parameter. This can be passed to the `docker run` command:
```
$ docker run -d --name hello hello Ben
```

And then check the logs to see the results:
```
$ docker logs hello
```

The message should now include your parameter:
```
Hello Ben! (1)
Hello Ben! (2)
```

## Setup a local docker repository
Next let's setup a local docker image repository in preparation for uploading our image into a Kubernetes
cluster. For now we'll use a pre-made container from Docker:

```
$ docker run -d -p 5000:5000 --name registry registry:2
```

This starts up a container that runs a small web server that acts as a basic Docker image repository. Now we
need to tag our image and push it up to our new repo:

```
$ docker tag hello localhost:5000/hello
$ docker push localhost:5000/hello
```

## References

* [What is a container?](https://www.docker.com/resources/what-container)
* [OpenJDK base image](https://hub.docker.com/_/openjdk)

## Dockerfile vs Packer
Using a Dockerfile is the standard way to create a Docker image. Packer is an infrastructure as code (IaC) tool that
makes automating and managing images more repeatable and easier.

Packer has several plugins that can live at different points in the build cycle; docker is just one of the "builders"
it supports. Packer can execute multiple builders if necessary. For instance, if you wanted to build a Docker image
and a vmWare image for the same application you would just wire up the additional builder and packer would make sure both
images are provisioned identically.

In addition to builders, packer supports variables and numerous "provisioners". We used the "shell" provisioner in our
example but we could also have used more advanced automation tools such as Ansible.

For more info see [packer.io](http://packer.io)
