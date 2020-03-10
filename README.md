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
This repo includes a Vagrant box that can run all the demos. The sandbox is
tested enough now that most users should just use the sandbox. Windows users in
particular should probably go straight to using the sandbox and not bother
installing all the required applications. The sandbox contains all the
prerequisite software needed for the demo.

Using the sandbox only requires the following:

* [vagrant](https://www.vagrantup.com/downloads.html) (v2.2.7)
* [VirtualBox](https://www.virtualbox.org/) (v6.0.18)

For more information, please read [Playing in the Sandbox](doc/playing_in_the_sandbox.md).

If you're into the more advanced path and want to try using your local machine
then please read [Running the Demos On Your Local Machine](doc/local_machine_demo.md).

## Training Modules
The training modules are intended to be read in order.

* [Intro to Containers and Docker](doc/intro_to_containers.md)
* [Intro to Kubernetes](doc/intro_to_kubernetes.md)
* [Intro to Helm](doc/intro_to_helm.md)
* [Intro to Networking in Docker](doc/intro_to_networking_in_docker.md)
* [Intro to Networking in Kubernetes](doc/intro_to_networking_in_k8s.md)
* [Intro to Hashicorp Vault](doc/intro_to_vault.md)
