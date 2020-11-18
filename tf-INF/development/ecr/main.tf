terraform {
  backend "s3" {
    key = "stacks/ecr"
  }
}

resource "aws_ecr_repository" "project" {
  name                 = var.project
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
