# Container Demo
## Summary
This repo provides a series of demos that start with a simple "Hello World"
Java app and creates a Docker image that can be run either standalone or as
part of a Kubernetes cluster. Each training module builds on the previous ones
to create more complex examples and explore topics such as deployment and
networking.

The demos do not necessarily go into details but more show steps to achieve
goals. The reader is encouraged to use the examples as a starting point for
their own research.

This is an ongoing series.

## Using the sandbox
Some of the training modules use a sandbox VM to simulate a second machine on
the network. There's no reason you couldn't run all the tutorial modules in
the VM though if you'd prefer. The sandbox contains all the prerequisite
software needed for the demo. For more information, please read [Playing in the Sandbox](doc/playing_in_the_sandbox.md).

## Prerequisites
If you'd like to run the training modules on your local machine you'll need
to install some software. This demo assumes you are running on a Linux box.
However, this demo should work just fine on Mac or Windows once the software
is installed. Please install the following software prior to beginning this
demo:

* [Docker CE](https://docs.docker.com/install/) or [Docker Desktop](https://www.docker.com/products/docker-desktop) (v19.0)
* [packer](https://packer.io/downloads.html) (v1.4.4)
* [maven](https://maven.apache.org/download.cgi) (v3.3+)
* Java SDK 11 (choose your own adventure)
* netcat
* [curl](https://github.com/curl/curl)
* [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) (v1.4.0)
* [helm](https://github.com/helm/helm) (v2.15.0)
* [vagrant](https://www.vagrantup.com/downloads.html) (v2.2.5)
* [VirtualBox](https://www.virtualbox.org/) (v6.0.14)

The netcat command (`nc`) should already be installed on Linux and Mac OS X
machines. Windows users may be forced to use curl instead. This works, you'll
just get an error when the demo code closes the socket.

## Training Modules
* [Intro to Containers and Docker](doc/intro_to_containers.md)
* [Intro to Kubernetes](doc/intro_to_kubernetes.md)
* [Intro to Helm](doc/intro_to_helm.md)
* [Intro to Networking in Docker](doc/intro_to_networking_in_docker.md)
* [Intro to Networking in Kubernetes](doc/intro_to_networking_in_k8s.md)
