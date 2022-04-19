resource "helm_release" "vault" {
  count = local.enable_vault ? 1 : 0
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  chart      = "vault"
  namespace  = kubernetes_namespace.bootstrap.metadata.0.name
  name       = "vault"
  version    = "0.18.0"
  repository = "https://helm.releases.hashicorp.com"

  set {
    name  = "server.serviceAccount.create"
    value = true
  }
  set {
    name  = "server.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_vault.this_iam_role_arn
  }
  set {
    name  = "server.ingress.enabled"
    value = true
  }
  set {
    name  = "server.ingress.annotations.external-dns\\.alpha\\.kubernetes\\.io"
    value = "enable"
  }
  set {
    name  = "server.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "internal-nginx"
  }

  set {
    name  = "server.ingress.ingressClassName"
    value = "internal-nginx"
  }
  set {
    name  = "server.ingress.hosts[0].host"
    value = "vault.${var.domain_name}"
  }
  set {
    name  = "server.ingress.hosts[0].paths"
    value = "{/}"
  }
  set {
    name  = "server.ha.enabled"
    value = true
  }
  set {
    name  = "server.ha.config"
    value = <<EOF
          ui = true
          disable_mlock = true
          listener "tcp" {
            address     = "0.0.0.0:8200"
            tls_disable = "true"
          }
          ha_storage "consul" {
            address = "${helm_release.consul.metadata.0.name}-consul-server:8500"
            path = "vault/"
          }
          storage "s3" {
            bucket     = "${data.terraform_remote_state.s3.outputs.vault_name}"
            region     = "${var.aws_region}"
            path       = "${var.environment}"
          }
          seal "awskms" {
            region     = "${var.aws_region}"
            kms_key_id = "${aws_kms_key.vault_prod.key_id}"
          }
EOF
    type  = "string"
  }

  ///// vault configuration affinitty
  set {
    name  = "server.affinity"
    value = <<EOF
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              - labelSelector:
                  matchLabels:
                    app.kubernetes.io/name: {{ template "vault.name" . }}
                    app.kubernetes.io/instance: "{{ .Release.Name }}"
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
  set {
    name  = "injector.affinity"
    value = <<EOF
          podAntiAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
              - labelSelector:
                  matchLabels:
                    app.kubernetes.io/name: {{ template "vault.name" . }}-agent-injector
                    app.kubernetes.io/instance: "{{ .Release.Name }}"
                topologyKey: kubernetes.io/hostname
EOF
    type  = "string"
  }
  set {
    name  = "injector.tolerations"
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
    name  = "injector.nodeSelector"
    value = <<EOF
          application: vault
EOF
    type  = "string"
  }
  set {
    name  = "server.dataStorage.enabled"
    value = false
  }
  set {
    name  = "server.auditStorage.enabled"
    value = false
  }


}
