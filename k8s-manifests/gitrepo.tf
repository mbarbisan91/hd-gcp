resource "kubectl_manifest" "argocd_application" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${var.app_name}
  namespace: argocd
spec:
  project: "default"
  destination:
    server: "https://kubernetes.default.svc"
    namespace: "default"
  source:
    repoURL: ${var.app_repository}
    targetRevision: ${var.app_branch}
    path: ${var.app_path}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - Validate=true
YAML
  depends_on = [
    helm_release.argocd
  ]
}