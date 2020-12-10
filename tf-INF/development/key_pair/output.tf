output "key_name" {
  value = aws_key_pair.eks.key_name
}
output "ssh_ssm_path" {
  value = module.ssh_key_pair.ssh_private_key_ssm_path
}
output "ssh_private_key" {
  value = data.aws_ssm_parameter.eks.value
}
