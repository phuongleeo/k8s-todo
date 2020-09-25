{
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRole"
  "metadata" = {
    "labels" = {
      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
      "rbac.authorization.k8s.io/aggregate-to-edit" = "true"
      "rbac.authorization.k8s.io/aggregate-to-view" = "true"
    }
    "name" = "elastic-operator-view"
  }
  "rules" = [
    {
      "apiGroups" = [
        "elasticsearch.k8s.elastic.co",
      ]
      "resources" = [
        "elasticsearches",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
      ]
    },
    {
      "apiGroups" = [
        "apm.k8s.elastic.co",
      ]
      "resources" = [
        "apmservers",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
      ]
    },
    {
      "apiGroups" = [
        "kibana.k8s.elastic.co",
      ]
      "resources" = [
        "kibanas",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
      ]
    },
  ]
}
