resource "helm_release" "datadog_agent" {
  count = local.enable_datadog ? 1 : 0
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  name       = "datadog-agent"
  chart      = "datadog"
  repository = "https://helm.datadoghq.com"
  version    = "2.27.8"
  wait       = false
  namespace  = kubernetes_namespace.bootstrap.metadata.0.name
  values = [
    yamlencode(
      {
        "agents" : {
          "tolerations" : [{
            "effect" : "NoExecute",
            "key" : "application",
            "operator" : "Equal",
            "value" : "vault"
            },
            {
              "effect" : "NoExecute",
              "key" : "application",
              "operator" : "Equal",
              "value" : "recommendation-engine"
          }]
        }
      }
    )
  ]
  set_sensitive {
    name  = "datadog.apiKey"
    value = var.dd_api_key
  }

  set_sensitive {
    name  = "datadog.appKey"
    value = var.dd_app_key
  }

  set {
    name  = "datadog.logs.enabled"
    value = true
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = true
  }

  set {
    name  = "datadog.leaderElection"
    value = true
  }

  set {
    name  = "datadog.collectEvents"
    value = true
  }

  set {
    name  = "clusterAgent.enabled"
    value = true
  }

  set {
    name  = "clusterAgent.metricsProvider.enabled"
    value = true
  }

  set {
    name  = "datadog.networkMonitoring.enabled"
    value = true
  }
  set {
    name  = "datadog.processAgent.processCollection"
    value = true
  }

  set {
    name  = "datadog.hostVolumeMountPropagation"
    value = "HostToContainer"
  }

  set {
    name  = "datadog.apm.enabled"
    value = true
  }
  set {
    name  = "datadog.apm.portEnabled"
    value = true
  }
  set {
    name  = "clusterAgent.admissionController.enabled"
    value = true
  }
  set {
    name  = "datadog.tags"
    value = "{env:${var.environment}}"
  }
  set {
    name  = "datadog.clusterName"
    value = local.cluster_name
  }
}
