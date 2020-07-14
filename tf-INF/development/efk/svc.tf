{
  "apiVersion" = "v1"
  "kind" = "Service"
  "metadata" = {
    "name" = "elastic-webhook-server"
    "namespace" = "elastic-system"
  }
  "spec" = {
    "ports" = [
      {
        "port" = 443
        "targetPort" = 9443
      },
    ]
    "selector" = {
      "control-plane" = "elastic-operator"
    }
  }
}
