resource "helm_release" "hello-vault" {
    chart = "../deploy/helm/hello-vault"
    name  = "hello-vault"

    values = [
        file("../deploy/helm/superman.yaml")
    ]
}

resource "helm_release" "vault" {
    chart = "..//deploy/helm/vault"
    name = "vault"

    set {
        name  = "server.dev.enabled"
        value = true
    }
}
