output "storage_type" {
  value = map(
    "gp2-delete", kubernetes_storage_class.gp2_delete.metadata[0].name,
    "gp2-retain", kubernetes_storage_class.gp2_retain.metadata[0].name,
    "efs-retain", kubernetes_storage_class.efs_retain.metadata[0].name,
  "efs-delete", kubernetes_storage_class.efs_delete.metadata[0].name)
}

output "efs_id" {
  value = aws_efs_file_system.efs.id
}
