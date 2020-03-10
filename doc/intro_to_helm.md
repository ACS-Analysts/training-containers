# Introduction to Helm
## Summary
In our [previous module](intro_to_kubernetes.md) we deployed our example
container to Kubernetes by manually creating deployments and pods on the
cluster. This wasn't too bad with the very simple app we've created so far.
In a more realistic app Kubernetes deployments can quickly become complicated.

The [helm](https://helm.sh) tool is a common way to combat this complexity.
Helm is often described as a package manager for Kubernetes. It allows users
to create templates based on the Go templating engine to create complex
deployments with flexible configurations.

Helm is maintained by the [CNCF](https://www.cncf.io) and has several large
collaborators including Microsoft and Google.

## Assumptions
Note that all the commands for this module should be run from the [deploy/helm](../deploy/helm)
directory. Please make sure you have installed all the prerequisites from
the main [README](../README.md).

This module assumes you have already built the container from [Introduction to Containers](intro_to_containers.md).

## Creating a simple deployment
### Structure of a chart
Helm charts are directories with a specific structure.

```
└── deploy
    └── helm
        └── hello
            ├── Chart.yaml
            ├── README.md
            ├── templates
            │   └── pod.yaml
            └── values.yaml
```

In the structure above the `helm` directory is root of the helm chart named "hello".

The objects are as follows:

* `Chart.yaml`: Contains metadata for the chart such as chart name and version
* `README.md`: Basic documentation about the chart
* `templates`: Files to template and add to the K8s manifest
* `templates/pod.yaml`: An example resource file
* `values.yaml`: Default values

### Basic templating
Spend some time familiarizing yourself with the files. In particular pay attention
to the [values.yaml](../deploy/helm/hello/values.yaml) and
[pod.yaml](../deploy/helm/hello/templates/pod.yaml) files. The `pod.yaml` file
should look familiar. This is because it's based on the first
[resource file](../deploy/pod-args.yaml) we created in the last module. 

Notice that we've replaced some values with template objects. Template objects are
denoted by double curly braces (`{{ }}`). Values passed to the chart are in the
`.Values` scope. To see the values we've specified see the `values.yaml` file. So,
for instance, if we want to get the `dockerTag` value we use `{{.Values.dockerTag}}`.
Also note that helm respects YAML objects. Our `helloArgs` value is an array to match
the `args` value in the resource file.

### Perform syntax validation of chart
```shell script
sandbox$ helm lint hello
```

### Setup environment
Don't forget to push your image to the registry on your minikube cluster.

```shell script
sandbox$ docker push localhost:5000/hello
```

NOTE: Docker Desktop users on MacOS and Windows who are not using the sandbox
VM need to remember to use `host.docker.internal` rather than `localhost`.

#### Helm v2 vs Helm v3
The sandbox now defaults to using helm v3. If you would still like to use helm
v2 you will need to take some extra steps.

First, because the sandbox defaults to helm v3, you will need to use the `helm2`
command instead of just `helm`. Second, helm v2 requires that the `tiller`
component be deployed in any cluster you want to use. Once the cluster is up you
need to setup helm in the cluster.

```shell script
sandbox$ helm2 init
```

This installs the "tiller" component of helm in the `kube-system` namespace.

### Validate template on server
To have the server output the template without passing the data on to k8s:

```shell script
sandbox$ helm install --dry-run --debug hello
```

Then try testing passing an argument to the chart:

```shell script
sandbox$ helm install --dry-run --debug hello --set 'helloArgs[0]=Ben'
```

The output should look similar to the [pod-args.yaml](../deploy/pod-args.yaml)
resource file we used in the previous module.

### Install the chart
OK, it's finally time to install a "release" of our chart:

```shell script
sandbox$ helm install hello
```

Note the "NAME" of the release is made up of two random words, usually a verb
and an animal name. The output also tells us that we created a pod (under the
"RESOURCES" section. In our example, the release name is also used as part of
the pod name in case multiple releases are installed at the same time.

Give the pod a couple seconds to start. Let's list the pods on the cluster:

```shell script
sandbox$ kubectl get po
```

## Overriding the release name
If for some reason you don't like the randomly generated release name you can
override the name at install:

```shell script
sandbox$ helm install hello --name foo
```

## Removing a helm release
To remove the helm release and all it's resources from the cluster pass the
release name from above to the `helm delete` command:

```shell script
sandbox$ helm delete guiding-ibis
```

## Passing values to helm
As mentioned above, the default values for the chart are in the [values.yaml](../deploy/helm/hello/values.yaml)
file. There are multiple ways to override the values. Most common is pass a
YAML file containing the values to be overridden to `helm install` using the
`-f` or `--values` options. For single values though we can use the `--set`
option. For instance, to pass an argument to our container:

```shell script
sandbox$ helm install hello --set 'helloArgs[0]=Ben'
```

In this case we have to specify element zero because helloArgs is an array.

## Chart repositories
In production environments charts are usually stored in a chart repository
rather than being run from the local filesystem. You can get a list of your
currently configured chart repos:

```shell script
sandbox$ helm repo list
```

You should have at a minimum two repos: "stable" and "local". The stable
repo is the default repo for helm and contains all the publicly maintained
helm charts. The local repo is an optional local repo running on your machine.

You can add private repos using the `helm repo add` command. See the [helm
documentation](https://helm.sh/docs/helm/#helm-repo-add) for more details.

Installing a chart from a remote repo works the same as installing a chart
off your local filesystem. If no repo is specified helm will attempt to
select the most recent version of the chart across all your repos. You can
also specify which repo to use be utilizing the `--repo` option.

## References
* [Helm Documentation](https://docs.helm.sh/) 

## Up Next
Next up is an [introduction to networking in Docker](intro_to_networking_in_docker.md).
