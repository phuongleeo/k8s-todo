{
  "apiVersion" = "apps/v1"
  "kind" = "StatefulSet"
  "metadata" = {
    "labels" = {
      "control-plane" = "elastic-operator"
    }
    "name" = "elastic-operator"
    "namespace" = "elastic-system"
  }
  "spec" = {
    "selector" = {
      "matchLabels" = {
        "control-plane" = "elastic-operator"
      }
    }
    "serviceName" = "elastic-operator"
    "template" = {
      "metadata" = {
        "annotations" = {
          "co.elastic.logs/raw" = "[{\"type\":\"container\",\"json.keys_under_root\":true,\"paths\":[\"/var/log/containers/*${data.kubernetes.container.id}.log\"],\"processors\":[{\"convert\":{\"mode\":\"rename\",\"ignore_missing\":true,\"fields\":[{\"from\":\"error\",\"to\":\"_error\"}]}},{\"convert\":{\"mode\":\"rename\",\"ignore_missing\":true,\"fields\":[{\"from\":\"_error\",\"to\":\"error.message\"}]}},{\"convert\":{\"mode\":\"rename\",\"ignore_missing\":true,\"fields\":[{\"from\":\"source\",\"to\":\"_source\"}]}},{\"convert\":{\"mode\":\"rename\",\"ignore_missing\":true,\"fields\":[{\"from\":\"_source\",\"to\":\"event.source\"}]}}]}]"
        }
        "labels" = {
          "control-plane" = "elastic-operator"
        }
      }
      "spec" = {
        "containers" = [
          {
            "args" = [
              "manager",
              "--enable-webhook",
              "--log-verbosity=0",
            ]
            "env" = [
              {
                "name" = "OPERATOR_NAMESPACE"
                "valueFrom" = {
                  "fieldRef" = {
                    "fieldPath" = "metadata.namespace"
                  }
                }
              },
              {
                "name" = "WEBHOOK_SECRET"
                "value" = "elastic-webhook-server-cert"
              },
              {
                "name" = "OPERATOR_IMAGE"
                "value" = "docker.elastic.co/eck/eck-operator:1.1.2"
              },
            ]
            "image" = "docker.elastic.co/eck/eck-operator:1.1.2"
            "name" = "manager"
            "ports" = [
              {
                "containerPort" = 9443
                "name" = "webhook-server"
                "protocol" = "TCP"
              },
            ]
            "resources" = {
              "limits" = {
                "cpu" = 1
                "memory" = "512Mi"
              }
              "requests" = {
                "cpu" = "100m"
                "memory" = "150Mi"
              }
            }
            "volumeMounts" = [
              {
                "mountPath" = "/tmp/k8s-webhook-server/serving-certs"
                "name" = "cert"
                "readOnly" = true
              },
            ]
          },
        ]
        "serviceAccountName" = "elastic-operator"
        "terminationGracePeriodSeconds" = 10
        "volumes" = [
          {
            "name" = "cert"
            "secret" = {
              "defaultMode" = 420
              "secretName" = "elastic-webhook-server-cert"
            }
          },
        ]
      }
    }
  }
}
