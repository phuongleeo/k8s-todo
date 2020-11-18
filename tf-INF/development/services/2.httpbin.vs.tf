resource "kubernetes_manifest" "virtualservice_httpbin" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "networking.istio.io/v1alpha3"
    "kind"       = "VirtualService"
    "metadata" = {
      "name"      = "httpbin"
      "namespace" = "default"
    }
    "spec" = {
      "gateways" = [
        "httpbin-gateway",
      ]
      "hosts" = [
        "httpbin.${var.domain_name}",
      ]
      "http" = [
        {
          "match" = [
            {
              "uri" = {
                "prefix" = "/status"
              }
            },
            {
              "uri" = {
                "prefix" = "/delay"
              }
            },
            {
              "uri" = {
                "prefix" = "/headers"
              }
            },
            {
              "uri" = {
                "prefix" = "/get"
              }
            },
            {
              "uri" = {
                "prefix" = "/ip"
              }
            },
          ]
          "route" = [
            {
              "destination" = {
                "host" = "httpbin.default.svc.cluster.local"
                "port" = {
                  "number" = 8000
                }
              }
            },
          ]
        },
      ]
    }
  }
}
