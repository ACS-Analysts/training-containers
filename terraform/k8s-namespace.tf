resource "kubernetes_namespace" "vault" {
    metadata {
        name = var.vault_namespace
    }
}
