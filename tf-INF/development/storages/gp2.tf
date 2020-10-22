//sc with delete policy
resource "kubernetes_storage_class" "gp2_delete" {
  metadata {
    name = "gp2-delete"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Delete"
  parameters = {
    type      = "gp2"
    fsType    = "ext4"
    encrypted = true
  }
  allow_volume_expansion = true
}
//sc with retain policy
resource "kubernetes_storage_class" "gp2_retain" {
  metadata {
    name = "gp2-retain"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"
  parameters = {
    type      = "gp2"
    fsType    = "ext4"
    encrypted = true
  }
  allow_volume_expansion = true
}
