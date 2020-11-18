#chart bucket
resource "aws_s3_bucket" "chart" {
  bucket = "${var.project}-${var.environment}-chart-data"
  acl    = "private"

  versioning {
    enabled    = true
    mfa_delete = false
  }

  tags = merge(local.common_tags,
  map("Name", "${var.project}-${var.environment}-chart-data"))

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
