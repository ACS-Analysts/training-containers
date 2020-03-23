# Introduction to terraform
TODO

```shell script
$ kubectl get appbinding -n vault vault -o jsonpath='{.spec.clientConfig.caBundle}' | base64 -d > ~/vault-ca.crt
$ kubectl get secrets -n vault vault-vault-tls -o jsonpath="{.data.tls\.crt}" | base64 -d > ~/vault-tls.crt
$ kubectl get secrets -n vault vault-vault-tls -o jsonpath="{.data.tls\.key}" | base64 -d > ~/vault-tls.key
$ export VAULT_ADDR="https://127.0.0.1:8200"
$ export VAULT_ROOT_TOKEN=$(kubectl get secret -n vault vault-keys -o jsonpath='{.data.vault-root-token}' | base64 -d)
$ export VAULT_CACERT=~/vault-ca.crt
$ export VAULT_CLIENT_CERT=~/vault-tls.crt
$ export VAULT_CLIENT_KEY=~/vault-tls.key
$ kubectl port-forward -n vault svc/vault 8200 &> /dev/null &
```
