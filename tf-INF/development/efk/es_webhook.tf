{
  "apiVersion" = "admissionregistration.k8s.io/v1beta1"
  "kind" = "ValidatingWebhookConfiguration"
  "metadata" = {
    "name" = "elastic-webhook.k8s.elastic.co"
  }
  "webhooks" = [
    {
      "clientConfig" = {
        "caBundle" = "Cg=="
        "service" = {
          "name" = "elastic-webhook-server"
          "namespace" = "elastic-system"
          "path" = "/validate-apm-k8s-elastic-co-v1-apmserver"
        }
      }
      "failurePolicy" = "Ignore"
      "name" = "elastic-apm-validation-v1.k8s.elastic.co"
      "rules" = [
        {
          "apiGroups" = [
            "apm.k8s.elastic.co",
          ]
          "apiVersions" = [
            "v1",
          ]
          "operations" = [
            "CREATE",
            "UPDATE",
          ]
          "resources" = [
            "apmservers",
          ]
        },
      ]
    },
    {
      "clientConfig" = {
        "caBundle" = "Cg=="
        "service" = {
          "name" = "elastic-webhook-server"
          "namespace" = "elastic-system"
          "path" = "/validate-apm-k8s-elastic-co-v1beta1-apmserver"
        }
      }
      "failurePolicy" = "Ignore"
      "name" = "elastic-apm-validation-v1beta1.k8s.elastic.co"
      "rules" = [
        {
          "apiGroups" = [
            "apm.k8s.elastic.co",
          ]
          "apiVersions" = [
            "v1beta1",
          ]
          "operations" = [
            "CREATE",
            "UPDATE",
          ]
          "resources" = [
            "apmservers",
          ]
        },
      ]
    },
    {
      "clientConfig" = {
        "caBundle" = "Cg=="
        "service" = {
          "name" = "elastic-webhook-server"
          "namespace" = "elastic-system"
          "path" = "/validate-elasticsearch-k8s-elastic-co-v1-elasticsearch"
        }
      }
      "failurePolicy" = "Ignore"
      "name" = "elastic-es-validation-v1.k8s.elastic.co"
      "rules" = [
        {
          "apiGroups" = [
            "elasticsearch.k8s.elastic.co",
          ]
          "apiVersions" = [
            "v1",
          ]
          "operations" = [
            "CREATE",
            "UPDATE",
          ]
          "resources" = [
            "elasticsearches",
          ]
        },
      ]
    },
    {
      "clientConfig" = {
        "caBundle" = "Cg=="
        "service" = {
          "name" = "elastic-webhook-server"
          "namespace" = "elastic-system"
          "path" = "/validate-elasticsearch-k8s-elastic-co-v1beta1-elasticsearch"
        }
      }
      "failurePolicy" = "Ignore"
      "name" = "elastic-es-validation-v1beta1.k8s.elastic.co"
      "rules" = [
        {
          "apiGroups" = [
            "elasticsearch.k8s.elastic.co",
          ]
          "apiVersions" = [
            "v1beta1",
          ]
          "operations" = [
            "CREATE",
            "UPDATE",
          ]
          "resources" = [
            "elasticsearches",
          ]
        },
      ]
    },
    {
      "clientConfig" = {
        "caBundle" = "Cg=="
        "service" = {
          "name" = "elastic-webhook-server"
          "namespace" = "elastic-system"
          "path" = "/validate-kibana-k8s-elastic-co-v1-kibana"
        }
      }
      "failurePolicy" = "Ignore"
      "name" = "elastic-kb-validation-v1.k8s.elastic.co"
      "rules" = [
        {
          "apiGroups" = [
            "kibana.k8s.elastic.co",
          ]
          "apiVersions" = [
            "v1",
          ]
          "operations" = [
            "CREATE",
            "UPDATE",
          ]
          "resources" = [
            "kibanas",
          ]
        },
      ]
    },
    {
      "clientConfig" = {
        "caBundle" = "Cg=="
        "service" = {
          "name" = "elastic-webhook-server"
          "namespace" = "elastic-system"
          "path" = "/validate-kibana-k8s-elastic-co-v1beta1-kibana"
        }
      }
      "failurePolicy" = "Ignore"
      "name" = "elastic-kb-validation-v1beta1.k8s.elastic.co"
      "rules" = [
        {
          "apiGroups" = [
            "kibana.k8s.elastic.co",
          ]
          "apiVersions" = [
            "v1beta1",
          ]
          "operations" = [
            "CREATE",
            "UPDATE",
          ]
          "resources" = [
            "kibanas",
          ]
        },
      ]
    },
  ]
}
