# Intro to Kubernetes
## Summary
In this demo we will use the basic container we created in [Introduction to Continaers](../intro_to_containers/README.md)
and deploy it to Kubernetes  (also known as "k8s"). We will be using a simple single node cluster using `minikube`. Once
we've deployed the cluster we will show the basics of managing pods and containers in Kubernetes.

## Assumptions
All commands and file locations are assumed to be run from the root of the module directory.

This module assumes you have already built the container from [Introduction to Containers](../intro_to_containers/README.md).

## Start minikube cluster
Please see [Playing in the Sandbox](../../doc/playing_in_the_sandbox.md).

## kubectl
The main management interface for Kubernetes is the `kubectl` command. It has a similar function (and interface) to the
`docker` command we've used previously.

In k8s we manage a number of different "resources". Our container will now run inside a "pod" resource. A pod is
composed of one or more containers that work together. All the containers in a pod all live on the same "node", or
server in the Kubernetes cluster. Pods can provide or consume other resources. The resources are associated with each
other using labels.

The most basic command in `kubectl` is the `get` command. Let's get a list of the running pods in the cluster:

```shell script
sandbox$ kubectl get po
```

The `po` here is an alias for `pod`. The command should tell us that there are
currently no pods running. This is of course because we just started our cluster.

Actually though there are several pods running. They are just running a different
"namespace". Namespaces are a further means of isolating parts of the cluster. By
default the `kubectl` command uses the "default" namespace. However, there is
another namespace that is always running in the cluster, the "kube-system"
namespace. This namespace contains resources needed to keep the cluster functioning.

Let's see what pods are running in the "kube-system" namespace:

```shell script
sandbox$ kubectl get po -n kube-system
```

This should return a number of pods such as "core-dns" and "etcd".

## Setup a docker registry in minikube
In order for Kubernetes to be able to see our image the image needs to reside
in a docker registry visible to the cluster. We could upload the image to a
remote registry (DockerHub, Artifactory, etc) but for demonstration purposes
we will install a registry inside the minikube cluster. Luckily, minikube has
an addon to make this easy.

```shell script
sandbox$ minikube addons enable registry
```

If you're running minikube on the sandbox (or any other Linux using the
`vm-driver=none` option) you need to run the command using sudo.

We should now be able to see two new pods running in the "kube-system" namespace
that start with "registry". We should also now see a new "service" resource
associated with the registry:

```shell script
sandbox$ kubectl get svc -n kube-system
```

You should see that the registry service is running on port 80.

If you're using the sandbox you should be all set to go. However, if you're
running on your local machine then the minikube cluster is actually running
on an isolated network. Without some magic we won't be able to connect. The
simplest solution is to use port forwarding to attach the port inside the
cluster to a port on our local network. The port forward will stay up as long
as the process is running, so let's ignore any output and run it in the
background.

Again, this is not necessary if you're using the sandbox VM.

```shell script
host$ kubectl port-forward -n kube-system svc/registry 5000:80 &> /dev/null &
```

We should now be able to get a response from the registry if we connect to
port 5000 using HTTP:

```shell script
sandbox$ curl localhost:5000/v2/_catalog
```

You should get back a JSON document:

```json
{"repositories":[]}
```

## Push image to the registry
### Docker Server (Linux)
If you are using Linux (or the sandbox VM) you can use "localhost" to get to
the registry...
```shell script
sandbox$ docker tag hello localhost:5000/hello
sandbox$ docker push localhost:5000/hello
```

### Docker Desktop (MacOS & Windows)
If you are using Docker Desktop on MacOS or Windows the above commands won't
work. This is because behind the scenes Docker is running a thin VM that can't
see your local network. To work around this you can use a special hostname
that only works on Docker Desktop.

Because we're not running HTTPS on our registry yet docker will complain if we
push to it. Follow the instructions [here](https://docs.docker.com/registry/insecure/#deploy-a-plain-http-registry).
Note that if you don't follow the instructions in that link you won't be able
to upload your image because docker will refuse to connect to an insecure
registry. We're running an isolated environment so the security risks are
limited.

```shell script
host$ docker tag hello host.docker.internal:5000/hello
host$ docker push host.docker.internal:5000/hello
```

### Validating the push
Running the curl command from above should now show the "hello" repo has
been added to the registry:

```json
{"repositories":["hello"]}
```

## Creating a K8s Deployment Resource
Using a k8s deployment resource creates a `deployment.app` which in turn sets
up a basic pod with a single instance of our container.

```shell script
sandbox$ kubectl create deployment --image localhost:5000/hello hello
```

Note that Docker Desktop users *should* use `localhost` here. This is because
we want localhost from the perspective of the minikube cluster.

We should now be able to see a deployment using the `kubectl` command:

```shell script
sandbox$ kubectl get deploy
```

We should also now see a pod in the default namespace:

```shell script
sandbox$ kubectl get po
```

You should see the "STATUS" as "Running" and the "READY" column should say "1/1".
This means that we have a signle container in the pod and that it is ready.

## Retrieving Logs
Simlar to the `docker` command, `kubectl` let's us see STDOUT on the container by
using the `logs` command. Instead of passing the container name though we now need
to pass the pod name. Take the pod name you got in the last command to output it's
logs. For example:

```shell script
sandbox$ kubectl logs hello-7f5c49b6c6-nlxd7
```

You should see the now familiar output of our app.

## Deleting the deployment
To remove our app deployment we use the `delete" command:

```shell script
sandbox$ kubectl delete deploy hello
```

## Creating pods directly
Often times we want to have more control over the makeup of our pods. In that
case we can use the `apply` command to create the pod directly. The `apply`
command uses YAML files to create resources within the cluster. The [deploy](deploy)
directory contains several YAML files with example resources we can create.

Let's create a pod that passes a positional argument to JAR file so we can
change the output of our app. Take a look at the [deploy/pod-args.yaml](deploy/pod-args.yaml)
file. Note that our pod will have a single container. Also note the optional
`args` line which specifies what we want to pass.

Now let's create our pod:

```shell script
sandbox$ kubectl apply -f deploy/pod-args.yaml
```

List the pods and note that the pod is named "hello" (without all the extra
hashes we saw when using a deployment). Use the `logs` cammand to show that
you are getting the expected output.

## Attaching to a running pod
Just like how we were able to attach to a running container using the `docker`
command we can attach to a container within a pod using `kubectl`. Right now
we only have a single container so we can just specify the pod name:

```shell script
sandbox$ kubectl exec -it hello bash
```

You should get a command prompt that indicates you are running inside the
container.

## Deleting a pod
When you're done looking around, remove the pod:

```shell script
sandbox$ kubectl delete po hello
```

## Multiple containers in one pod
Let's create two copies of our container inside one pod. Look at the
[deploy/pods-multi.yaml](deploy/pod-multi.yaml) file. Note that we
are now defining two containers in the pod, each with different output.

Create the new pod:

```shell script
sandbox$ kubectl apply -f deploy/pod-multi.yaml
```

Note that when you list the pods you should now see "2/2" for the "hello"
pod.

Now that we have more than one container we will need to specify which
container we wnat when using the `logs` command:

```shell script
sandbox$ kubectl logs hello hello-1
sandbox$ kubectl logs hello hello-2
```

You should see different output on the two containers.

If you need a list of the containers in a pod you can use the `describe`
command:

```shell script
sandbox$ kubectl describe po hello
```

## Shutting down minikube
Safely stop the minikube cluster and any VMs associated with it:
```shell script
sandbox$ minikube stop
```

## Destroying the cluster
If you're needing to start from scratch you can delete the minikube cluster and start over:

```shell script
sandbox$ minikube delete
```

## Up Next
Next up is an [introduction to Helm](../intro_to_helm/README.md).
