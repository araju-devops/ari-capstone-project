# ===================================================================
# KUBERNETES ADD-ONS MODULE - SIMPLIFIED
# Deploys only ArgoCD for GitOps
# Monitoring and Security tools are commented out for simplicity
# ===================================================================

# -------------------------------------------------------------------
# 1. ARGOCD - GitOps Continuous Deployment
# -------------------------------------------------------------------

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.51.6"

  timeout = 900  # 15 minutes timeout
  wait    = true
  wait_for_jobs = true

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "server.insecure"
    value = "true"
  }
}

# -------------------------------------------------------------------
# MONITORING STACK - ENABLED (Assignment Requirement)
# -------------------------------------------------------------------

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
    }
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "25.8.0"
  timeout    = 900
  wait       = true
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "7.0.8"
  timeout    = 900
  wait       = true
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "2.9.11"
  timeout    = 900
  wait       = true
}

# -------------------------------------------------------------------
# SECURITY TOOLS - ENABLED (Assignment Requirement)
# -------------------------------------------------------------------

resource "kubernetes_namespace" "security" {
  metadata {
    name = "security"
  }
}

resource "kubernetes_deployment" "owasp_zap" {
  metadata {
    name      = "owasp-zap"
    namespace = kubernetes_namespace.security.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "owasp-zap"
      }
    }
    template {
      metadata {
        labels = {
          app = "owasp-zap"
        }
      }
      spec {
        container {
          name  = "owasp-zap"
          image = "zaproxy/zap-stable:latest"
          command = ["zap.sh"]
          args    = ["-daemon", "-host", "0.0.0.0", "-port", "8080", "-config", "api.disablekey=true", "-config", "api.addrs.addr.name=.*", "-config", "api.addrs.addr.regex=true"]
          port {
            container_port = 8080
          }
          resources {
            limits = {
              cpu    = "200m"
              memory = "384Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }

  timeouts {
    create = "15m"
    update = "15m"
  }
}

resource "kubernetes_service" "owasp_zap" {
  metadata {
    name      = "owasp-zap"
    namespace = kubernetes_namespace.security.metadata[0].name
  }
  spec {
    selector = {
      app = "owasp-zap"
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "trivy_server" {
  metadata {
    name      = "trivy-server"
    namespace = kubernetes_namespace.security.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "trivy-server"
      }
    }
    template {
      metadata {
        labels = {
          app = "trivy-server"
        }
      }
      spec {
        container {
          name  = "trivy"
          image = "aquasec/trivy:latest"
          command = ["trivy"]
          args    = ["server", "--listen", "0.0.0.0:8080"]
          port {
            container_port = 8080
          }
          resources {
            limits = {
              cpu    = "200m"
              memory = "384Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }

  timeouts {
    create = "15m"
    update = "15m"
  }
}

resource "kubernetes_service" "trivy_server" {
  metadata {
    name      = "trivy-server"
    namespace = kubernetes_namespace.security.metadata[0].name
  }
  spec {
    selector = {
      app = "trivy-server"
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
  }
}
