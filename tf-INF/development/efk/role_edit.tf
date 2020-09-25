{
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRole"
  "metadata" = {
    "labels" = {
      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
      "rbac.authorization.k8s.io/aggregate-to-edit" = "true"
    }
    "name" = "elastic-operator-edit"
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
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update",
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
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update",
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
        "create",
        "delete",
        "deletecollection",
        "patch",
        "update",
      ]
    },
  ]
}
