# Intro to Hashicorp Vault
## Summary
TODO

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

## Deploy Vault
OK, time to start investigating Vault. To get things off the ground faster, we're going to deploy Vault in
["Dev" Server Mode](https://www.vaultproject.io/docs/concepts/dev-server/). Note that dev mode should never be used in
production servers. For more information about setting up a production Vault server see
[Run Vault on Kubernetes](https://learn.hashicorp.com/vault?track=getting-started-k8s) on Hashicorp's 
[Vault training site](https://learn.hashicorp.com/vault).

The first step is to install Vault via helm. Hashicorp does not currently provide a helm repo so we've pre-cloned a copy
into the [deploy/helm/vault](../../deploy/helm/vault) directory.

```shell script
sandbox$ helm install vault --set='server.dev.enabled=true' deploy/helm/vault
```

The first few commands we will need to run on the `vault-0` pod. After that we can interact with the vault server using
the `vault` CLI command on the sandbox. Also note that all of this could be done using REST API calls.

We need to log into the server pod so we can enable and configure the `kubernetes` auth method. We could do this from
the CLI on the sandbox but it would take a bunch of extra commands.

```shell script
sandbox$ kubectl exec -it vault-0 -- /bin/sh
vault$ vault auth enable kubernetes
vault$ vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443 \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
vault$ exit
```

From here on in we can use the `vault` CLI. We need to setup some environment variables to get started:

```shell script
sandbox$ export VAULT_ADDR=http://$(kubectl get service vault -o json | jq -r '.spec.clusterIP'):8200
sandbox$ export VAULT_TOKEN=root
```

With that out of the way, let's check the status of the vault server:

```shell script
sandbox$ vault status
```

Next we can create a policy for our application. We've provided a very basic policy file in the [vault](../../vault) directory to
make things easy. The policy gives read access to all the secrets in the `secrets` namespace. Clearly, a much more
restrictive policy would be required for production environments. Once our policy is created we will associate the
policy with the `kubernetes` auth method we set up previously.

```shell script
sandbox$ vault policy write hello vault/hello-policy.hcl
sandbox$ vault write auth/kubernetes/role/hello \
    bound_service_account_names=hello \
    bound_service_account_namespaces=default \
    policies=hello \
    ttl=1h
```

Let's create our first secret and read it back.

```shell script
sandbox$ vault kv put secret/hello secret="You are Clark Kent."
sandbox$ vault kv get secret/hello
```

## Deploy a test app
We have a new test class call [HelloVault.java](../../src/main/java/com/analysts/containerdemo/HelloVault.java) that now
optionally reads a file to reveal secrets about whoever it says hello to. We're using a build process similar to what
we've done before. Notice however that we've improved our packer file to automatically tag and push our image to our
"remote" registry.

```shell script
sandbox$ mvn package
sandbox$ packer build packer/hello-vault.json
```

Now that our Docker image has been pushed to our private registry we are ready to deploy it to our cluster. We are going
to use helm to deploy our application and Vault. For more information on the basics of helm see
[Intro to Helm](../intro_to_helm/README.md).

```shell script
sandbox$ helm install hello-vault deploy/helm/hello-vault
```

The new `hello-vault` helm chart defines the following Kubernetes resources for our application:
- deployment
- serviceaccount
- service

A couple quick checks using `kubectl` should show us our app and vault are both deployed:

```shell script
sandbox$ kubectl get deployment
sandbox$ kubectl get pod
sandbox$ kubectl get serviceaccount
sandbox$ kubectl get service
```

Let's set an environment variable to make it easier to refer to the cluster IP our service got assigned:

```shell script
sandbox$ HELLO_IP=$(kubectl get service hello-vault -o json | jq -r '.spec.clusterIP')
```

We should now be able to talk to our app.

```shell script
sandbox$ nc -d ${HELLO_IP} 8080
```

We haven't given it any secrets yet so it should tell us that:

```text
Hello world! You have no secrets. (1)
```

Let's redeploy our app, this time with some annotations that tell the vault-agent to mount our secret to the pod. To see
what values we changed take a look at the [override-values.yaml](../../deploy/helm/superman.yaml) file.

```shell script
sandbox$ helm upgrade hello-vault --values deploy/helm/superman.yaml deploy/helm/hello-vault
```

Let's try talking to our app again.

```shell script
sandbox$ nc -d ${HELLO_IP} 8080
```

Oh no! Superman's secret has been revealed!

```text
Hello Superman! I know your secret: You are Clark Kent. (1)
```

## How it works
TODO

## Other topics
- [Security](security.md)
