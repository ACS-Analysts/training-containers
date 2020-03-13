resource "helm_release" "hello-vault" {
    chart = "../deploy/helm/hello-vault/chart/hello-vault"
    name  = "hello-vault"
}

resource "helm_release" "vault" {
    chart = "../deploy/helm/vault/chart/vault"
    name = "vault"

    set {
        name  = "server.dev.enabled"
        value = true
    }
}
