output "repository_arn" {
  value = aws_ecr_repository.project.arn
}

output "repository_url" {
  value = aws_ecr_repository.project.repository_url
}
