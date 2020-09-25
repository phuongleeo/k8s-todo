resource "aws_s3_bucket" "terraform_state" {
  bucket = var.remote_state_bucket
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = merge(local.common_tags,
    map(
      "Name", var.remote_state_bucket
  ))

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
