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
          volume_mount {
            mount_path = "/gp2"
            name       = "gp2"
          }
          volume_mount {
            mount_path = "/efs"
            name       = "efs"
          }
        }
        service_account_name = kubernetes_service_account.httpbin.metadata.0.name
        volume {
          name = "gp2"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.httpbin_gp2.metadata[0].name
          }
        }
        volume {
          name = "efs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.httpbin_efs.metadata[0].name
          }
        }
      }
    }
  }
}


resource "kubernetes_persistent_volume_claim" "httpbin_gp2" {
  metadata {
    name = "cache-pv-claim"
    labels = {
      app = "httpbin"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = lookup(data.terraform_remote_state.storages.outputs.storage_type, "gp2-delete")
  }
}
resource "kubernetes_persistent_volume" "httpbin_efs" {
  metadata {
    name = "httpbin-efs-pv"
  }
  spec {
    storage_class_name               = lookup(data.terraform_remote_state.storages.outputs.storage_type, "efs-delete")
    persistent_volume_reclaim_policy = "Delete"
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      csi {
        driver        = local.k8s_efs_driver
        volume_handle = data.terraform_remote_state.storages.outputs.efs_id
        read_only     = false
        //https://github.com/kubernetes-sigs/aws-efs-csi-driver#encryption-in-transit
        # volume_attributes = {
        #   "encryptInTransit" = "true"
        # }
      }
    }
  }
}
resource "kubernetes_persistent_volume_claim" "httpbin_efs" {
  metadata {
    name = "efs-pv-claim"
    labels = {
      app = "httpbin"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name        = kubernetes_persistent_volume.httpbin_efs.metadata[0].name
    storage_class_name = lookup(data.terraform_remote_state.storages.outputs.storage_type, "efs-delete")
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
