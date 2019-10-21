# Container Demo
## Summary
This repo provides a series of demos that start with a simple "Hello World"
Java app and creates a Docker image that can be run either standalone or as
part of a Kubernetes cluster. Each training module builds on the previous ones
to create more complex examples and explore topics such as deployment and networking.

This is an ongoing series.

## Prerequisites
This demo assumes you are running on a Linux box. However, this demo should
work just fine on Mac or Windows once the software is installed. Please
install the following software prior to beginning this demo:

* [Docker CE](https://docs.docker.com/install/) or [Docker Desktop](https://www.docker.com/products/docker-desktop) (v19.0)
* [packer](https://packer.io/downloads.html) (v1.4.4)
* [maven](https://maven.apache.org/download.cgi) (v3.3+)
* Java SDK 11 (choose your own adventure)
* [curl](https://github.com/curl/curl)
* [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) (v1.4.0)
* [helm](https://github.com/helm/helm) (v2.14.3)
* [vagrant](https://www.vagrantup.com/downloads.html) (v2.2.5)
* [VirtualBox](https://www.virtualbox.org/) (v6.0.12)

## Training Modules
* [Intro to Containers and Docker](doc/intro_to_containers.md)
* [Intro to Kubernetes](doc/intro_to_kubernetes.md)
* [Intro to Helm](doc/intro_to_helm.md)
* [Intro to Networking in Docker](doc/intro_to_networking_in_docker.md)
* [Intro to Networking in Kubernetes](doc/intro_to_networking_in_k8s.md)

## Building the Sandbox image
Some of the training modules use a sandbox VM to simulate a second machine on
the network. I've uploaded the sandbox image to Vagrant Cloud so you don't
have to build the image yourself. However, if you'd like to build the image
yourself, I've included a packer build that utilizes vagrant and ansbile to
provide a Virtualbox image which can be used by vagrant.

NOTE: Just to be clear this is not necessary to run the trainging modules.

To build the image:

```
$ packer build packer/sandbox-minikube.json
```

To add your local copy of the vagrant box do the following:

```
$ vagrant box add --name sandbox-minikube output-vagrant/package.box
```

Once you've added the box to vagrant the `output-vagrant` directory can be
deleted.
