# Introduction to Networking in Docker
## Summary
In this module we will investigate the basics of networking in Docker. Since our original container only outputted a
log, we will introduce a new container that uses a simple socket connection so we can test out the different network
configurations.

## Getting Ready
### Using the sandbox
This module will use the sandbox VM so we can get a better feel for what the different network configurations look like
to the outside world. If you haven't done so already, please read
[Playing in the Sandbox](../../doc/playing_in_the_sandbox.md).

Using the instructions from [Playing in the Sandbox](../../doc/playing_in_the_sandbox.md), go ahead and bring up the
sandbox, log in, and start minikube.

### Setup a Docker Registry on the Sandbox
We're going to setup an Docker registry on the sandbox, similar to what we did in
[Introduction to Kubernetes](../intro_to_kubernetes/README.md). This time though we have a real networking interface
(the host-only interface) to use so we can interact with the registry by IP.

From inside the sandbox we'll enable the registry just as before (the `sudo` is required because we are running
minikube with `vm-driver` set to `none`):

```shell script
sandbox$ sudo minikube addons enable registry
```

You should now see that the registry is listening on port 5000 on the VM:

```shell script
sandbox$ sudo netstat -antpl | grep :5000
```

So how did that get configured automatically? If you look at the pods in the `kube-system` namespace you should see one
with the name `registry-proxy-*`. If you `describe` the pod you'll see that the pod proxy's traffic from the `registry`
service in `kube-system` to port 5000 on the host (see the `Host Port` value under the container). Note that the pod
name will be different on your cluster.

```shell script
sandbox$ kubectl describe po -n kube-system registry-proxy-mjnzt
```

So what does this mean? Well, now that we have a host-only network attached we can work with the registry from our host
machine. To prove this, use `curl` to list the registry on the sandbox:

```shell script
host$ curl 172.16.0.2:5000/v2/_catalog
```

You should get something back similar to:

```json
{"repositories":[]}
```

### Adding docker images to our registry
Now that we have a working registry we can add some docker images to it. Let's create a new container that supports a
very basic socket connection and push it to the registry. The new class is
[HelloSocket](src/main/java/com/analysts/containerdemo/HelloSocket.java). The new JAR file uses the HelloSocket class
as the default class. The container just runs the JAR again. If you're interested you can verify this for yourself in
the [hello-socket.json](packer/hello-socket.json) file.

Where you run the next few commands depends on if you're using your local host or the sandbox VM. Run the commands in
the same place you built the `hello` demo code.

#### Sandbox
```shell script
sandbox$ mvn -Psocket package
sandbox$ packer build packer/hello-socket.json
```

Now we can tag our new container for upload to the sandbox registry and push it.

```shell script
sandbox$ docker tag hello-socket localhost:5000/hello-socket
sandbox$ docker push localhost:5000/hello-socket
```

#### Local Host
```shell script
host$ mvn -Psocket package
host$ packer build packer/hello-socket.json
```

Because we're not running HTTPS on our registry yet docker will complain if we push to it. Follow the instructions
[here](https://docs.docker.com/registry/insecure/#deploy-a-plain-http-registry). Note that if you don't follow the
instructions in that link you won't be able to upload your image because docker will refuse to connect to an insecure
registry. We're running an isolated environment so the security risks are limited.

Now we can tag our new container for upload to the sandbox registry and push it.

```shell script
host$ docker tag hello-socket 172.16.0.2:5000/hello-socket
host$ docker push 172.16.0.2:5000/hello-socket
```


### Verifying the Image Has Been Uploaded
You should now see the `hello-socket` repository if you list the registry on the sandbox from either the sandbox or your
local host:

```json
{"repositories":["hello-socket"]}
```

### Pulling the Container in the Sandbox
The image is now available to for our use inside the sandbox! Let's pull the container into our docker cache in the
sandbox:

```shell script
sandbox$ docker pull localhost:5000/hello-socket
```

## Networking in Docker
A good place to learn about the different types of network drivers is to read the
[Docker network documentation](https://docs.docker.com/network/). Most of the information below is derived from there.

### Bridging
The default networking model for Docker is called [bridging](https://docs.docker.com/network/bridge/). In bridge mode
the container is attached to a virtual network that is segregated from any other physical or bridge networks. Users can
setup multiple bridge networks to further isolate containers from one another. Any containers on the same bridge network
can communicate with each other.

To see what this looks like in practice, deploy our new `hello-socket` container using all the defaults (ie, use the
`default` bridge network):

```shell script
sandbox$ docker run -d --name hello-bridge localhost:5000/hello-socket bridge
```

If we inspect the container you should see that the bridge driver is setup. Note the IP address that was auto assigned
the container.

```shell script
sandbox$ docker inspect hello-bridge
```

Listing the interfaces on the container shows only a single interface:

```shell script
sandbox$ docker exec -it hello-bridge ip addr
```

Similar to our other container, if we pass an argument we change the message we receive, in this case we should get
`Hello bridge!` when we connect to the socket along with the usual incrementing value. To test the container use the
netcat (`nc`) command; replace the IP address with the one identified above.

```shell script
sandbox$ nc -d 172.17.0.6 8080
```

If you do an `ifconfig` command you should see that the `docker0` interface is configured with an IP address similar to
the one above (probably `172.17.0.1`). Investigating the `iptables` output should confirm that no forwarding is setup.

NOTE: You may see the port forwarding settings for the minikube API server.

```shell script
sandbox$ sudo iptables -L DOCKER -v -n
```

If you're interested, feel free to investigate all the iptables settings Docker and K8s use to orchestrate network
connectivity. Most of the interesting stuff happens in the `FORWARD` chain.

```shell script
sandbox$ sudo iptables -L -v -n
```

This means that the network is only accessible from the sandbox. If we needed to access our service from an external
network we would setup port-forwarding to do so.

Let's recreate the container and this time we'll "publish" the port so external
clients can attach.

```shell script
sandbox$ docker rm --force hello-bridge
sandbox$ docker run -d --name hello-bridge -p 8080:8080 localhost:5000/hello-socket bridge
```

If we check `netstat` we should now see that the container has been proxied to port 8080 on the sandbox:

```shell script
sandbox$ sudo netstat -atnpl | grep :8080 | grep LISTEN
```

Note that the process is named `docker-proxy` because docker is proxying the connection from the sandbox to the
container.

Now that the port has been forwarded (proxied) we can attach to it from our host machine (note the IP of the sandbox):

NOTE: If your host doesn't have the `nc` tool you may need to install
[ncat](https://nmap.org/ncat/).

```shell script
host$ nc -d 172.16.0.2 8080
```

If you inspect the iptables you'll see that Docker has added a DNAT (destination network address translation) into the
firewall:

```shell script
sandbox$ sudo iptables -L DOCKER -v -n
```

If you're done with the bridge container, feel free to remove it:

```shell script
sandbox$ docker rm --force hello-bridge
```

### Host
[Host networking](https://docs.docker.com/network/host/) directly attaches the container to the host's (the machine
running Docker) network interfaces. It's important to recognize that directly connected means just that. The container
can see **everything** that the docker host can. There is no isolation between the container and the docker host OS.

Start up our container using host networking:

```shell script
sandbox$ docker run -d --name hello-host --network host localhost:5000/hello-socket host
```

The first thing to notice is that the container sees **all** the network interfaces from the docker host:

```shell script
sandbox$ docker exec -it hello-host ip addr
```

This also means that when the container creates a socket it does it directly on the host interface(s). 

```shell script
sandbox$ sudo netstat -atnpl | grep :8080 | grep LISTEN
```

Note that the process shows as `java` instead of `docker-proxy` like it did with bridge networking. Also note that no
port forwarding is occurring:

```shell script
sandbox$ sudo iptables -L DOCKER -v -n
```

You should be able to connect to the container directly from your host machine as well:

```shell script
host$ nc -d 172.16.0.2 8080
```

If you're done with the host container, feel free to remove it:

```shell script
sandbox$ docker rm --force hello-host
```

### Macvlan
[Macvlan networking](https://docs.docker.com/network/macvlan/) is a bit of  hybrid of bridged and host networking. It
creates a virtual interface on the docker hosts's physical interface that is assigned it's own MAC address. This gives
the appearance to devices on the same network segment as the docker host that another physical network interface has
joined the network.

This may be necessary when legacy applications or applications which require layer 2 network connectivity such as SCTP
and TIPC need to be directly attached to a physical network segment. The down side is that any network infrastructure
connected to the docker host must support multiple MAC addresses being connected to a single port, also known as
"promiscuous mode".

Connecting to a macvlan requires some extra configuration. The level of complexity is high enough that we're going to
push this off to a later module. 

### Overlay
[Overlay networks](https://docs.docker.com/network/overlay/) are Docker's method for connecting multiple docker daemons
together into a "Docker Swarm". Docker Swarm is outside the scope of this training.

## Up Next
Next up is an [introduction to networking in Kubernetes](../intro_to_networking_in_k8s/README.md).
