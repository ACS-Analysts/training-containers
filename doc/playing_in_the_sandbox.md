# Playing in the Sandbox
## Summary
This repo includes a Vagrant box that can run all the demos. The sandbox is
tested enough now that most users should just use the sandbox. Windows users in
particular should probably go straight to using the sandbox and not bother
installing all the required applications. The box runs on VirtualBox and is
deployed using Vagrant. The use of Vagrant allows for the deployment of
pre-configured images for several VM images types from a central repository
([Vagrant Cloud](https://app.vagrantup.com/)).

The sandbox is on Vagrant Cloud as [bwmaas/sandbox-minikube](https://app.vagrantup.com/bwmaas/boxes/sandbox-minikube).

You don't need to configure anything though because the root of the repo
contains a [Vagrantfile](../Vagrantfile) that will automatically start the
box for you.

## Prerequisites
Using the sandbox only requires the following:

* [vagrant](https://www.vagrantup.com/downloads.html) (v2.2.7)
* [VirtualBox](https://www.virtualbox.org/) (v6.0.18)

## Configuring Host-Only Networking
Host-Only networking is a way of configuring your VirtualBox virtual machine to
have a network interface that acts like a real network between your host machine
and your VM. It allows the host and guest to communicate without using NAT
(Network Address Translation). For our demos we want to use it so we get the
clearest picture of what would happen on a real network.

Unfortunately host-only networking can be a bit of a pain to setup.

### Custom Host-Only Networking
These instructions assume that you are only using host-only networking for the
training modules. This allows us to assume we can use vboxnet0. If you are using
host-only networking for other projects you can follow these same instructions,
just delete all your other host-only interfaces and use a new interface. If you
do that, make sure you modify the [Vagrantfile](../Vagrantfile) to use the
correct interface.

### Configuring Host-Only Networking
**WARNING: These instructions assume that you are not using host-only networking
for any other VMs. If you are, please use caution and see the note above.**

First list the existing host-only interfaces on your system:
```
$ VBoxManage list hostonlyifs
```

The command should return nothing. If it returns anything please delete the
existing host-only interfaces and any DHCP servers associated with it:

```
$ VBoxManage dhcpserver remove --ifname <interface_name>
$ VBoxManage hostonlyif remove <interface_name>
```

Once the `list` command shows there are no interfaces configured, create a new
interface:

```
$ VBoxManage hostonlyif create
```

You should get a message saying that `Interface 'vboxnet0' was successfully created`.

Set the IP address of your local machine to `172.16.0.1` on the `vboxnet0`
interface:

```
$ VBoxManage hostonlyif ipconfig vboxnet0 --ip 172.16.0.1
```

Running `ifconfig` (or it's equivalent) on your host machine should now show an
interface called `vboxnet0` with an IP address of `172.16.0.1`.

Listing the host-only interfaces should now show something similar to this:

```
$ VBoxManage list hostonlyifs
Name:            vboxnet0
GUID:            786f6276-656e-4074-8000-0a0027000000
DHCP:            Disabled
IPAddress:       172.16.0.1
NetworkMask:     255.255.255.0
IPV6Address:     
IPV6NetworkMaskPrefixLength: 0
HardwareAddress: 0a:00:27:00:00:00
MediumType:      Ethernet
Wireless:        No
Status:          Up
VBoxNetworkName: HostInterfaceNetworking-vboxnet0
```

Make sure that `Status` is `Up`.

## Using the sandbox VM
### Bring up the vagrant box
To download the vagrant box (VM image) and instantiate the VM you can `up`
the vagrant environment.

```
$ vagrant up
```

Once the command completes you should be able to ping the VM on the host-only
interface:

```
$ ping 172.16.0.2
```

### Log into the box
Next, log in to the vagrant box as the `vagrant` user using a private key
stored in the vagrant config. The primary interface on the VM is a NAT
interface. This makes it easier and safer for the VM to connect to the
internet without exposing the VM directly to the rest of your physical
network. The only problem is that your host can't directly contact the VM
in the normal way. To work around this Vagrant creates a port forwarding
tunnel from port 22 on the VM to port 2222 on your host box.

Sound confusing? It is. That's why Vagrant provides a simple command to
handle the SSH connection for you: 

```
$ vagrant ssh
```

You should now have a shell prompt logged in as the `vagrant` user on the VM.

### Next Steps
The vagrant box will automagically mount your local directory to `/vagrant` on
the sandbox. To continue using the files from the repo, just go to that
directory on the sandbox:

```
$ cd /vagrant
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
$ sudo chown -R vagrant:vagrant ~/.kube ~/.minikube
```

You should now be able to issue commands to the minikube cluster as the
vagrant user.

## Building the Sandbox image
I've uploaded the sandbox image to Vagrant Cloud so you don't
have to build the image yourself. However, if you'd like to build the image
yourself, I've included a packer build that utilizes vagrant and ansible to
provide a VirtualBox image which can be used by vagrant.

NOTE: Just to be clear this is not necessary to run the training modules.

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
