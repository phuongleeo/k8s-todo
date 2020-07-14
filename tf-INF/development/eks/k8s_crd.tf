//Download kubernetes alpha plugins: https://www.hashicorp.com/blog/deploy-any-resource-with-the-new-kubernetes-provider-for-hashicorp-terraform/
//https://download.elastic.co/downloads/eck/1.1.2/all-in-one.yaml
//https://banzaicloud.com/docs/one-eye/logging-operator/quickstarts/es-nginx/
provider "kubernetes-alpha" {
 server_side_planning = true
}

resource "kubernetes_manifest" "test-crd" {
 provider = kubernetes-alpha

 manifest = {
   apiVersion = "apiextensions.k8s.io/v1"
   kind = "CustomResourceDefinition"
   metadata = {
     name = "testcrds.hashicorp.com"
     labels = {
       app = "test"
     }
   }
   spec = {
     group = "hashicorp.com"
     names = {
       kind = "TestCrd"
       plural = "testcrds"
     }
     scope = "Namespaced"
     versions = [{
       name = "v1"
       served = true
       storage = true
       schema = {
         openAPIV3Schema = {
           type = "object"
           properties = {
             data = {
               type = "string"
             }
             refs = {
               type = "number"
             }
           }
         }
       }
     }]
   }
 }
}
