# Intro to Hashicorp Vault
## Summary

## Getting Ready
### Using the sandbox
This module will use the sandbox VM so we have a consistent minikube environment to work from. If you haven't done so
already, please read [Playing in the Sandbox](../../doc/playing_in_the_sandbox.md). We're also going to setup a local
docker registry. For more info on that see [Introduction to Networking in Docker](../intro_to_networking_in_docker/README.md).

```shell script
sandbox$ sudo minikube start
sandbox$ sudo minikube addons enable registry
sandbox$ sudo chown -R vagrant:vagrant ~/.kube ~/.minikube
```

You should now see that the registry is listening on port 5000 on the VM:

```shell script
sandbox$ sudo netstat -antpl | grep :5000
```

## Build a test app

We have a new test class call [HelloVault.java](src/main/java/com/analysts/containerdemo/HelloVault.java) that now reads
a file to reveal secrets about whoever it says hello to. We're using a build process similar to what we've done before.
Notice however that we've improved our packer file to automatically tag and push our image to our "remote" registry.

```shell script
sandbox$ cd /vagrant/mod/intro_to_vault
sandbox$ mvn -Pvault package
sandbox$ packer build packer/hello-vault.json
```

Now that our Docker image has been pushed to our private registry we are ready to deploy it to our cluster. We are going
to use terraform to manage the deployment of our helm charts so we can build even more complicated environments later.
For more information on the basics of terraform see [Intro to Terraform](../intro_to_terraform/README.md).

This terraform deployment will deploy our new `hello-vault` app and `vault` for us by way of helm charts. The new
`hello-vault` helm chart defines both a Kubernetes deployment and service for our application.

First, we'll execute a `plan` so we know what terraform expects to do. Assuming everything looks good, we'll do an
`apply` to execute our changes.

```shell script
sandbox$ cd terraform
sandbox$ terraform init
sandbox$ terraform plan
sandbox$ terraform apply -auto-approve
``` 

A couple quick checks using `kubectl` should show us our app and vault are both deployed:

```shell script
sandbox$ kubectl get deployment
sandbox$ kubectl get pod
sandbox$ kubectl get service
sandbox$ kubectl get ingress
```

There is no ingress setup though so we'll have to use port forwarding to talk to our app:

```shell script
sandbox$ kubectl port-forward service/hello-vault 8080 &> /dev/null &
```

We should now be able to talk to our app.

```shell script
sandbox$ curl -q localhost:8080
```

We haven't given it any secrets yet so it should tell us that:
```text
Hello world! You have no secrets. (0)
```
