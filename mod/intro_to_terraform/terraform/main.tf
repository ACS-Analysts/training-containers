resource "helm_release" "hello-vault" {
    chart = "../../intro_to_vault/deploy/helm/hello-vault/chart/hello-vault"
    name  = "hello-vault"

    values = [
        file("../../intro_to_vault/deploy/helm/hello-vault/override-values.yaml")
    ]
}

resource "helm_release" "vault" {
    chart = "../../intro_to_vault/deploy/helm/vault/chart/vault"
    name = "vault"

    set {
        name  = "server.dev.enabled"
        value = true
    }
}
