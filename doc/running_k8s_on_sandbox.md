# Running Kubernetes in the Sandbox VM
There is a pre-configured sandbox VM image that can be used to run all the
tutorial modules. The box is runs on VirtualBox and is deployed using Vagrant.
The use of Vagrant allows for the deployment of pre-configured images for
several VM images types from a central repoistory ([Vagrant Cloud](https://app.vagrantup.com/)).

The sandbox is on Vagrant Cloud as [bwmaas/sandbox-minikube](https://app.vagrantup.com/bwmaas/boxes/sandbox-minikube).

You don't need to configure anything though because the root of the repo
contains a [Vagrantfile](../Vagrantfile) that will automatically start the
box for you.

## Bring up the vagrant box

```
$ vagrant up
```

This will download the vagrant box (VM image) and instantiate the VM.

## Log into the box
```
$ vagrant ssh
```

This will log you in to the vagrant box as the `vagrant` user using a
private key stored in the vagrant config.

## Starting minikube
Because the sandbox is running Linux it doesn't need to start another
VM inside the VM in order to run Kubernetes. The image has been setup
to set the `vm-driver` setting of minikube to `none` to prevent this
from happening. Unfortunately this means minikube has to be run as root.

If we use the `sudo` command though it will keep all the files in the
right places so we can still interact with k8s as a normal user. From
inside the sandbox do the following:

```
$ sudo minikube start
$ sudo chown -R vagrant:vagrant .kube .minikube
```

You should now be able to issue commands to the minikube cluster as the
vagrant user.
