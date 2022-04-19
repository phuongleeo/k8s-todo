resource "helm_release" "consul" {
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  chart      = "consul"
  version    = "0.39.0"
  namespace  = kubernetes_namespace.bootstrap.metadata.0.name
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"

  set {
    name  = "global.domain"
    value = "consul"
  }
  set {
    name  = "global.datacenter"
    value = var.environment
  }
  set {
    name  = "server.replicas"
    value = "3"
  }
  set {
    name  = "client.enabled"
    value = true
  }
  set {
    name  = "client.grpc"
    value = true
  }
  set {
    name  = "ui.enabled"
    value = true
  }
  set {
    name  = "connectInject.enabled"
    value = true
  }
  set {
    name  = "server.storage"
    value = "2Gi"
  }
  set {
    name  = "controller.enabled"
    value = true
  }


  // Consul configuration taint and affinity consul pods

  set {
    name  = "server.affinity"
    value = <<EOF
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              - labelSelector:
                  matchLabels:
                    app: {{ template "consul.name" . }}
                    release: "{{ .Release.Name }}"
                    component: server
                topologyKey: kubernetes.io/hostname
EOF
    type  = "string"
  }

  set {
    name  = "server.tolerations"
    value = <<EOF
          -
            key: "application"
            operator: "Equal"
            value: "vault"
            effect: "NoExecute"
EOF
    type  = "string"
  }

  set {
    name  = "server.nodeSelector"
    value = <<EOF
          application: vault
EOF
    type  = "string"
  }
  //// consul client tolerationa and affinity
  set {
    name  = "client.tolerations"
    value = <<EOF
          -
            key: "application"
            operator: "Equal"
            value: "vault"
            effect: "NoExecute"
EOF
    type  = "string"
  }

  set {
    name  = "client.nodeSelector"
    value = <<EOF
          application: vault
EOF
    type  = "string"
  }
  // consul controller tolerationa and affinity
  set {
    name  = "controller.tolerations"
    value = <<EOF
          -
            key: "application"
            operator: "Equal"
            value: "vault"
            effect: "NoExecute"
EOF
    type  = "string"
  }

  set {
    name  = "controller.nodeSelector"
    value = <<EOF
          application: vault
EOF
    type  = "string"
  }

  // Connect injector client toleration and affinity
  set {
    name  = "connectInject.tolerations"
    value = <<EOF
          -
            key: "application"
            operator: "Equal"
            value: "vault"
            effect: "NoExecute"
EOF
    type  = "string"
  }

  set {
    name  = "connectInject.nodeSelector"
    value = <<EOF
          application: vault
EOF
    type  = "string"
  }
}
