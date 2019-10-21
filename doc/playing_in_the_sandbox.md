# Playing in the Sandbox
## Uaing the sandbox VM
Some of the training modules use a sandbox VM to simulate a second machine on
the network. There's no reason you couldn't run all the tutorial modules in
the VM though if you'd prefer. The box is runs on VirtualBox and is deployed
using Vagrant. The use of Vagrant allows for the deployment of pre-configured
images for several VM images types from a central repoistory ([Vagrant Cloud](https://app.vagrantup.com/)).

The sandbox is on Vagrant Cloud as [bwmaas/sandbox-minikube](https://app.vagrantup.com/bwmaas/boxes/sandbox-minikube).

You don't need to configure anything though because the root of the repo
contains a [Vagrantfile](../Vagrantfile) that will automatically start the
box for you.

### Bring up the vagrant box
To download the vagrant box (VM image) and instantiate the VM you can `up`
the vagrant environment.

```
$ vagrant up
```

### Log into the box
Next, log in to the vagrant box as the `vagrant` user using a private key
stored in the vagrant config:

```
$ vagrant ssh
```

### Starting minikube
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

## Building the Sandbox image
I've uploaded the sandbox image to Vagrant Cloud so you don't
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
