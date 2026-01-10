# ===================================================================
# KUBERNETES ADD-ONS MODULE
# Deploys: ArgoCD, Monitoring Stack, Security Tools
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
    name  = "server.extraArgs[0]"
    value = "--insecure" # Allow HTTP access (for demo/dev)
  }

  depends_on = [kubernetes_namespace.argocd]
}

# -------------------------------------------------------------------
# 2. MONITORING NAMESPACE
# -------------------------------------------------------------------

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# -------------------------------------------------------------------
# 3. PROMETHEUS - Metrics Collection
# -------------------------------------------------------------------

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "25.8.0"

  timeout = 900  # 15 minutes timeout
  wait    = true
  wait_for_jobs = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = "false" # Use emptyDir for demo
  }

  set {
    name  = "alertmanager.enabled"
    value = "false" # Disable alertmanager for simplicity
  }

  # Add scrape config for backends
  values = [
    yamlencode({
      serverFiles = {
        "prometheus.yml" = {
          scrape_configs = [
            {
              job_name = "prometheus"
              static_configs = [{
                targets = ["localhost:9090"]
              }]
            },
            {
              job_name = "backend-a"
              kubernetes_sd_configs = [{
                role = "pod"
                namespaces = {
                  names = ["microservices-app"]
                }
              }]
              relabel_configs = [
                {
                  source_labels = ["__meta_kubernetes_pod_label_app"]
                  action        = "keep"
                  regex         = "backend-a"
                },
                {
                  source_labels = ["__meta_kubernetes_pod_ip"]
                  action        = "replace"
                  target_label  = "__address__"
                  replacement   = "$1:8080"
                }
              ]
            },
            {
              job_name = "backend-b"
              kubernetes_sd_configs = [{
                role = "pod"
                namespaces = {
                  names = ["microservices-app"]
                }
              }]
              relabel_configs = [
                {
                  source_labels = ["__meta_kubernetes_pod_label_app"]
                  action        = "keep"
                  regex         = "backend-b"
                },
                {
                  source_labels = ["__meta_kubernetes_pod_ip"]
                  action        = "replace"
                  target_label  = "__address__"
                  replacement   = "$1:8080"
                }
              ]
            }
          ]
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

# -------------------------------------------------------------------
# 4. GRAFANA - Visualization & Dashboards
# -------------------------------------------------------------------

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "7.0.8"

  timeout = 900  # 15 minutes timeout
  wait    = true
  wait_for_jobs = true

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "adminPassword"
    value = "admin123"
  }

  set {
    name  = "persistence.enabled"
    value = "false"
  }

  # Pre-configure Prometheus datasource
  values = [
    yamlencode({
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "Prometheus"
              type      = "prometheus"
              access    = "proxy"
              url       = "http://prometheus-server:80"
              isDefault = true
            },
            {
              name   = "Loki"
              type   = "loki"
              access = "proxy"
              url    = "http://loki:3100"
            }
          ]
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.prometheus
  ]
}

# -------------------------------------------------------------------
# 5. LOKI - Log Aggregation
# -------------------------------------------------------------------

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "2.9.11"

  timeout = 900  # 15 minutes timeout
  wait    = true
  wait_for_jobs = true

  set {
    name  = "loki.enabled"
    value = "true"
  }

  set {
    name  = "promtail.enabled"
    value = "true"
  }

  set {
    name  = "grafana.enabled"
    value = "false" # We already deployed Grafana separately
  }

  set {
    name  = "loki.persistence.enabled"
    value = "false"
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# -------------------------------------------------------------------
# 6. SECURITY NAMESPACE
# -------------------------------------------------------------------

resource "kubernetes_namespace" "security" {
  metadata {
    name = "security"
  }
}

# -------------------------------------------------------------------
# 7. OWASP ZAP - Security Vulnerability Scanner
# -------------------------------------------------------------------

resource "kubernetes_deployment" "owasp_zap" {
  metadata {
    name      = "owasp-zap"
    namespace = kubernetes_namespace.security.metadata[0].name
    labels = {
      app = "owasp-zap"
    }
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
          name  = "zap"
          image = "zaproxy/zap-stable:latest"
          command = ["zap-webswing.sh"]

          port {
            container_port = 8080
            name           = "http"
          }

          port {
            container_port = 8090
            name           = "api"
          }

          resources {
            requests = {
              memory = "512Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "500m"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.security]
}

resource "kubernetes_service" "owasp_zap" {
  metadata {
    name      = "owasp-zap"
    namespace = kubernetes_namespace.security.metadata[0].name
    labels = {
      app = "owasp-zap"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 8080
      target_port = 8080
      name        = "webswing"
      protocol    = "TCP"
    }

    port {
      port        = 8090
      target_port = 8090
      name        = "api"
      protocol    = "TCP"
    }

    selector = {
      app = "owasp-zap"
    }
  }

  timeouts {
    create = "10m"
  }

  depends_on = [kubernetes_deployment.owasp_zap]
}

# -------------------------------------------------------------------
# 8. TRIVY - Container Vulnerability Scanner
# -------------------------------------------------------------------

resource "kubernetes_deployment" "trivy_server" {
  metadata {
    name      = "trivy-server"
    namespace = kubernetes_namespace.security.metadata[0].name
    labels = {
      app = "trivy-server"
    }
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
          args = [
            "server",
            "--listen",
            "0.0.0.0:8080"
          ]

          port {
            container_port = 8080
            name           = "http"
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "250m"
            }
          }

          volume_mount {
            name       = "cache"
            mount_path = "/root/.cache"
          }
        }

        volume {
          name = "cache"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.security]
}

resource "kubernetes_service" "trivy_server" {
  metadata {
    name      = "trivy-server"
    namespace = kubernetes_namespace.security.metadata[0].name
    labels = {
      app = "trivy-server"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 8080
      target_port = 8080
      name        = "http"
      protocol    = "TCP"
    }

    selector = {
      app = "trivy-server"
    }
  }

  timeouts {
    create = "10m"
  }

  depends_on = [kubernetes_deployment.trivy_server]
}
