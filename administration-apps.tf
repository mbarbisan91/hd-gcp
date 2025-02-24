
resource "helm_release" "vault" {
  count = var.install_vault ? 1 : 0
  #provider         = kubernetes.cluster
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "vault"
  create_namespace = true
  values = [
    <<-EOF
      ha:
        enabled: true
        raft:
          enabled: true
          setNodeId: true
    storage:
      raft:
        path: "/vault/data"
    EOF
  ]
  depends_on = [
    google_container_cluster.cluster
  ]
}

resource "helm_release" "argocd" {
  count = var.install_argocd ? 1 : 0
  #provider         = kubernetes.cluster
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [
    <<-EOF
    crds:
      install: true
      keep: true    
    service:
      enabled: true
      type: LoadBalancer
      annotations:
        cloud.google.com/load-balancer-type: "External"
      ports:
        - name: http
          port: 80
          targetPort: 8080
        - name: https
          port: 443
          targetPort: 8080
    EOF
  ]
  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
  depends_on = [
    google_container_cluster.cluster
  ]
}

resource "helm_release" "istio" {
  count = var.install_istio ? 1 : 0
  #provider         = kubernetes.cluster
  name       = "istio"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.23.5"
  create_namespace = true

  values = [
    <<-EOT
    global:
      istioNamespace: istio-system
      proxy:
        autoInject: enabled
      multiCluster:
        enabled: false
      meshConfig:
        enableAutoMtls: true

    telemetry:
      enabled: true
      prometheus:
        enabled: true
      kiali:
        enabled: true

    pilot:
      enabled: true

    ingressGateways:
      - enabled: true
        name: istio-ingressgateway
        type: LoadBalancer  # Exponer el Ingress Gateway externamente
    EOT
  ]

  depends_on = [
    google_container_cluster.cluster
  ]
}

resource "helm_release" "kyverno" {
  count = var.install_kyverno ? 1 : 0
  #provider         = kubernetes.cluster
  name             = "kyverno"
  namespace        = "kyverno"
  repository       = "https://kyverno.github.io/kyverno"
  chart            = "kyverno"
  version          = "3.3.7"
  create_namespace = true
  depends_on = [
    google_container_cluster.cluster
  ]  
}

resource "helm_release" "kyverno_policies" {
  count = var.install_kyverno_policies ? 1 : 0
  #provider         = kubernetes.cluster
  name             = "kyverno-policies"
  namespace        = "kyverno"
  repository       = "https://kyverno.github.io/kyverno"
  chart            = "kyverno-policies"
  version          = "3.3.4"
  create_namespace = true
  depends_on = [
    helm_release.kyverno
  ]
}


resource "helm_release" "grafana" {
  count = var.install_grafana ? 1 : 0
  #provider         = kubernetes.cluster
  name             = "grafana"
  namespace        = "monitoring"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  create_namespace = true

  values = [
    <<-EOT
    adminPassword: "grafito"
    podSecurityPolicy:
      enabled: false    
    service:
      enabled: true
      type: LoadBalancer
      port: 80
      targetPort: 3000
    EOT
  ]
  depends_on = [
    google_container_cluster.cluster
  ]
}

resource "helm_release" "prometheus" {
  count = var.install_prometheus ? 1 : 0
  #provider         = kubernetes.cluster
  name             = "prometheus"
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  create_namespace = true

  values = [
    <<-EOF
    prometheus:
      server:
        service:
          enabled: true
          type: LoadBalancer
          port: 80
          targetPort: 9090
    EOF
  ]
  depends_on = [
    google_container_cluster.cluster
  ]
}

resource "helm_release" "prometheus_adapter" {
  count = var.install_prometheus_adapter ? 1 : 0
  #provider         = kubernetes.cluster
  name             = "prometheus-adapter"
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus-adapter"
  create_namespace = true

  values = [
    <<-EOT
    prometheus:
      url: "http://prometheus.monitoring.svc.cluster.local"
    EOT
  ]
  depends_on = [
    google_container_cluster.cluster
  ]
}