# //Argo CI/CD
# resource "helm_release" "argo_workflows" {
#   name       = "argo-workflows"
#   repository = local.char_repository["argocd"]
#   chart      = "argo"
#   version    = "0.9.8"
#   namespace  = kubernetes_namespace.argocd.metadata.0.name
#   lint       = true
#
#   values = [
#     # data.template_file.external_dns.rendered
#     yamlencode({ "controller" : { "workflowNamespaces" : [
#       kubernetes_namespace.bootstrap.metadata.0.name,
#       kubernetes_namespace.monitoring.metadata.0.name,
#     "api"] } })
#   ]
# }
resource "helm_release" "argo-cd" {
  name       = "argo-cd"
  repository = local.char_repository["argocd"]
  chart      = "argo-cd"
  version    = "2.10.0"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  lint       = true
  //Argo controller log format, pls don't change the default logformat text to json, otherwise https://github.com/argoproj/argo-cd/issues/4117
  # set {
  #   name  = "controller.logFormat"
  #   value = "json"
  # }
  //Argo server log format
  # set {
  #   name  = "server.logFormat"
  #   value = "json"
  # }
  //Argo server admin password https://argoproj.github.io/argo-cd/faq/#i-forgot-the-admin-password-how-do-i-reset-it
  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = "$2a$10$P2PB2hBnDfJp/vBjkn7YNelZfDuyQDFPjRBuK9jFbGwlKTT9/GHrq" //admin
    type  = "string"
  }
  set {
    name  = "configs.secret.argocdServerAdminPasswordMtime"
    value = "MjAwNi0wMS0wMlQxNTowNDowNVoK" //date "2006-01-02T15:04:05Z" now, since the difference timezone between local and server
    type  = "string"
  }
  ## ArgoCD config
  set {
    name  = "server.config.url"
    value = "https://argocd.${local.eks_domain}"
  }
  //server extralArgs
  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
    type  = "string"
  }
  //server ingress
  set {
    name  = "server.ingress.enabled"
    value = true
  }
  set {
    name  = "server.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "%{if local.enable_ingress_nginx}nginx%{else}istio%{endif}"
  }
  set {
    name  = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/ssl-redirect"
    value = "false"
  }
  set {
    name  = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/backend-protocol"
    value = "HTTP"
  }
  set {
    name  = "server.ingress.annotations.external-dns"
    value = "enable"
  }
  set {
    name  = "server.ingress.hosts"
    value = "{argocd.${local.eks_domain}}"
  }
  set {
    name  = "server.ingress.tls[0].secretName"
    value = "argocd-secret"
  }
  set {
    name  = "server.ingress.tls[0].hosts"
    value = "{argocd.${local.eks_domain}}"
  }
  //server gRPC ingress 
  set {
    name  = "server.ingressGrpc.enabled"
    value = true
  }
  set {
    name  = "server.ingressGrpc.annotations.external-dns"
    value = "enable"
  }
  set {
    name  = "server.ingressGrpc.annotations.kubernetes\\.io/ingress\\.class"
    value = "%{if local.enable_ingress_nginx}nginx%{else}istio%{endif}"
  }
  set {
    name  = "server.ingressGrpc.hosts"
    value = "{grpc-argocd.${local.eks_domain}}"
  }
  set {
    name  = "server.ingressGrpc.tls[0].secretName"
    value = "argocd-secret"
  }
  set {
    name  = "server.ingressGrpc.tls[0].hosts"
    value = "{grpc-argocd.${local.eks_domain}}"
  }
  set {
    name  = "server.ingressGrpc.annotations.nginx\\.ingress\\.kubernetes\\.io/backend-protocol"
    value = "GRPC"
  }
  set {
    name  = "server.ingressGrpc.annotations.nginx\\.ingress\\.kubernetes\\.io/ssl-redirect"
    value = "false"
  }
}
# resource "helm_release" "argo_events" {
#   name       = "argo-events"
#   repository = local.char_repository["argocd"]
#   chart      = "argo-events"
#   version    = "0.14.0"
#   namespace  = kubernetes_namespace.argocd.metadata.0.name
#   lint       = true
#   values = [
#     templatefile("files/argo.yaml", {
#     namespace = kubernetes_namespace.argocd.metadata.0.name
#     })
#   ]
# }
# resource "helm_release" "argo_rollouts" {
#   name       = "argo-rollouts"
#   repository = local.char_repository["argocd"]
#   chart      = "argo-rollouts"
#   version    = "0.3.2"
#   namespace  = kubernetes_namespace.argocd.metadata.0.name
#   lint       = true
# }
# resource "helm_release" "argocd_notifications" {
#   name       = "argocd-notifications"
#   repository = local.char_repository["argocd"]
#   chart      = "argocd-notifications"
#   version    = "1.0.7"
#   namespace  = kubernetes_namespace.argocd.metadata.0.name
#   lint       = true
# }
