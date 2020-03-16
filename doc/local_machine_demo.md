# Running the Demos on Your Local Machine
## Why You Don't Want to Do This
The biggest reason is time. Now that the sandbox has been pretty well tested
there isn't much reason to run the demos on your local machine unless you're
short on RAM or really want to learn how to install all the necessary software.
That's not to say that isn't a good exercise, but using the sandbox allows you
to focus on learning how to use the software first without getting lost in the
details of installing it.

If you're running on Windows you should really just use the sandbox. Things
get a lot more complicated on Windows. Running things in sandbox saves a lot
of headaches.

## Prerequisites
Again, it's probably easier to just use the sandbox. Really. Try reading
[Playing in the Sandbox](playing_in_the_sandbox.md) first before you
install any other software.

If you want to take the more advanced path and run the training modules on
your local machine you'll need to install some software. This demo assumes
you are running on a Linux box. However, this demo should work just fine on
Mac or Windows once the software is installed. Some testing has been done on
Mac but Windows users may have some extra hurdles.

If you are not going to use the sandbox please install the following software
prior to beginning this demo:

* [Docker CE](https://docs.docker.com/install/) or [Docker Desktop](https://www.docker.com/products/docker-desktop) (v19.0)
* [packer](https://packer.io/downloads.html) (v1.5.1)
* [maven](https://maven.apache.org/download.cgi) (v3.3+)
* Java SDK 11 (choose your own adventure)
* netcat
* [curl](https://github.com/curl/curl)
* [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) (v1.8.1)
* [helm](https://github.com/helm/helm) (v3.1.1)
* [terraform](https://)
* [vagrant](https://www.vagrantup.com/downloads.html) (v2.2.7)
* [VirtualBox](https://www.virtualbox.org/) (v6.1.4)

The netcat command (`nc`) should already be installed on Linux and Mac OS X
machines. Windows users may be forced to use curl instead. This works, you'll
just get an error when the demo code closes the socket.
