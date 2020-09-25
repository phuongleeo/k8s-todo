output "harbor_name" {
  value = aws_iam_user.harbor.name
}
output "harbor_secret_key" {
  value = aws_iam_access_key.harbor.secret
}
output "harbor_access_key" {
  value = aws_iam_access_key.harbor.id
}
