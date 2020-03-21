data "helm_repository" "appscode" {
    name = "appscode"
    url  = "https://charts.appscode.com/stable/"
}

resource "helm_release" "vault-catalog" {
    name  = "vault-catalog"
    chart = "appscode/vault-catalog"
    repository = "appscode"
    namespace = "kube-system"

    depends_on = [
        helm_release.vault-operator
    ]
}

resource "helm_release" "vault-operator" {
    name  = "vault-operator"
    chart = "appscode/vault-operator"
    repository = "appscode"
    version = "v0.3.0"
    namespace = "kube-system"
}

resource "helm_release" "consul" {
    chart = "../deploy/helm/consul"
    name = "consul"
    namespace = kubernetes_namespace.vault.metadata[0].name

    set {
        name  = "global.datacenter"
        value = var.name
    }

    values = [
        file("../deploy/helm/consul-values.yaml")
    ]
}

resource "helm_release" "vault-catalog-local" {
    name  = "vault-catalog-local"
    chart = "../deploy/helm/vault-catalog-local"
    namespace = "kube-system"

    depends_on = [
        helm_release.vault-operator
    ]
}


resource "helm_release" "vault-config" {
    name      = "vault-config"
    chart     = "../deploy/helm/vault-config"
    namespace = kubernetes_namespace.vault.metadata[0].name

    depends_on = [
        helm_release.vault-catalog,
        helm_release.vault-catalog-local,
        helm_release.vault-operator,
        helm_release.consul
    ]
}

resource "helm_release" "hello-vault" {
    name  = "hello-vault"
    chart = "../deploy/helm/hello-vault"

    # values = [
    #    file("../deploy/helm/hello-vault-superman.yaml")
    # ]

    depends_on = [
        helm_release.vault-config
    ]
}
