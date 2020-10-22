resource "aws_efs_file_system" "efs" {
  creation_token = local.cluster_name
  encrypted      = true
  tags = merge(local.common_tags,
    map(
      "Name", "efs-k8s"
  ))
}

resource "aws_efs_mount_target" "efs" {
  count           = length(data.terraform_remote_state.vpc.outputs.subnet_private)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = element(tolist(data.terraform_remote_state.vpc.outputs.subnet_private), count.index)
  security_groups = [data.terraform_remote_state.eks.outputs.worker_secgroup_id]
}

/* Policy that does the following:
- Prevent root access by default
- Enforce read-only access by default
- Enforce in-transit encryption for all clients
*/
# resource "aws_efs_file_system_policy" "efs" {
#   file_system_id = aws_efs_file_system.efs.id
#
#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "*"
#             },
#             "Action": "elasticfilesystem:ClientMount",
#             "Resource": aws_efs_file_system.efs.arn
#         }
#         //the current verison of csi driver seems does not work for awhile
#         //should be fixed in the next version v1.0.0
#         {
#             "Effect": "Deny",
#             "Principal": {
#                 "AWS": "*"
#             },
#             "Action": "*",
#             "Resource": aws_efs_file_system.efs.arn,
#             "Condition": {
#                 "Bool": {
#                     "aws:SecureTransport": "false"
#                 }
#             }
#         }
#     ]
#   })
# }

//SC
resource "kubernetes_storage_class" "efs_delete" {
  metadata {
    name = "efs-delete"
  }
  storage_provisioner    = local.k8s_efs_driver
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  mount_options          = ["tls"]
}

resource "kubernetes_storage_class" "efs_retain" {
  metadata {
    name = "efs-retain"
  }
  storage_provisioner    = local.k8s_efs_driver
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  mount_options          = ["tls"]
}
