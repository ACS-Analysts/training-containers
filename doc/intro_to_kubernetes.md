
## Setup a local docker repository
Next let's setup a local docker image repository in preparation for uploading our image into a Kubernetes
cluster. For now we'll use a pre-made container from Docker:

```
$ docker run -d -p 5000:5000 --name registry registry:2
```

This starts up a container that runs a small web server that acts as a basic Docker image repository. Now we
need to tag our image and push it up to our new repo:

```
$ docker tag hello localhost:5000/hello
$ docker push localhost:5000/hello
```
