data "helm_repository" "stable" {
    name = "stable"
    url = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "registry" {
    chart      = "stable/docker-registry"
    name       = "docker-registry"
    repository = data.helm_repository.stable.name
}

resource "helm_release" "vault" {
    chart = "../deploy/helm/vault/chart/vault"
    name = "vault"

    set {
        name  = "server.dev.enabled"
        value = true
    }
}
