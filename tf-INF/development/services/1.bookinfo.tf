//sa
resource "kubernetes_service_account" "bookinfo" {
  metadata {
    name = "bookinfo"
  }
  secret {
    name = kubernetes_secret.bookinfo.metadata.0.name
  }
}

resource "kubernetes_secret" "bookinfo" {
  metadata {
    name = "bookinfo"
  }
}

//svc
resource "kubernetes_service" "bookinfo_details" {
  metadata {
    name = "bookinfo-details"
  }
  spec {
    selector = {
      app = kubernetes_deployment.bookinfo_details_v1.metadata.0.labels.app
    }
    session_affinity = "None"
    port {
      port = 9080
      name = "http"
    }

    type = "ClusterIP"
  }
}

//deployment details
resource "kubernetes_deployment" "bookinfo_details_v1" {
  metadata {
    name = "bookinfo-details-v1"
    labels = {
      app     = "details"
      version = "v1"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = "details"
        version = "v1"
      }
    }

    template {
      metadata {
        labels = {
          app     = "details"
          version = "v1"
        }
      }

      spec {
        container {
          image             = "docker.io/istio/examples-bookinfo-details-v1:1.15.1"
          name              = lookup(local.bookinfo_details.v1, "app")
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 9080
          }
        }
      }
    }
  }
}
