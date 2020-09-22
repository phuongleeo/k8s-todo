# //Argo CI/CD
# resource "helm_release" "argo_workflows" {
#   name       = "argo-workflows"
#   repository = local.char_repository["argocd"]
#   chart      = "argo"
#   version    = "0.9.8"
#   namespace  = kubernetes_namespace.bootstrap.metadata.0.name
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
# resource "helm_release" "argo-cd" {
#   name       = "argo-cd"
#   repository = local.char_repository["argocd"]
#   chart      = "argo-cd"
#   version    = "2.5.4"
#   namespace  = kubernetes_namespace.bootstrap.metadata.0.name
#   lint       = true
# }
# # resource "helm_release" "argo_events" {
# #   name       = "argo-events"
# #   repository = local.char_repository["argocd"]
# #   chart      = "argo-events"
# #   version    = "0.14.0"
# #   namespace  = kubernetes_namespace.bootstrap.metadata.0.name
# #   lint       = true
# #   values = [
# #     templatefile("files/argo.yaml", {
# #     namespace = kubernetes_namespace.bootstrap.metadata.0.name
# #     })
# #   ]
# # }
# resource "helm_release" "argo_rollouts" {
#   name       = "argo-rollouts"
#   repository = local.char_repository["argocd"]
#   chart      = "argo-rollouts"
#   version    = "0.3.2"
#   namespace  = kubernetes_namespace.bootstrap.metadata.0.name
#   lint       = true
# }
# resource "helm_release" "argocd_notifications" {
#   name       = "argocd-notifications"
#   repository = local.char_repository["argocd"]
#   chart      = "argocd-notifications"
#   version    = "1.0.7"
#   namespace  = kubernetes_namespace.bootstrap.metadata.0.name
#   lint       = true
# }
