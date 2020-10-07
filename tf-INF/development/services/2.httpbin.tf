//sa
resource "kubernetes_service_account" "httpbin" {
  metadata {
    name = "httpbin"
  }
  secret {
    name = kubernetes_secret.httpbin.metadata.0.name
  }
}

resource "kubernetes_secret" "httpbin" {
  metadata {
    name = "httpbin"
  }
}
//deployment httpbin
resource "kubernetes_deployment" "httpbin" {
  metadata {
    name = "httpbin"
    labels = {
      app     = "httpbin"
      version = "v1"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = "httpbin"
        version = "v1"
      }
    }

    template {
      metadata {
        labels = {
          app     = "httpbin"
          version = "v1"
        }
      }

      spec {
        container {
          image             = "docker.io/kennethreitz/httpbin"
          name              = kubernetes_service_account.httpbin.metadata.0.name
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 80
          }
        }
        service_account_name = kubernetes_service_account.httpbin.metadata.0.name
      }
    }
  }
}
//svc
resource "kubernetes_service" "httpbin" {
  metadata {
    name = "httpbin"
  }
  spec {
    selector = {
      app = kubernetes_deployment.httpbin.metadata.0.labels.app
    }
    session_affinity = "None"
    port {
      port        = 8000
      name        = "http"
      target_port = 80
    }
    type = "ClusterIP"
  }
}
