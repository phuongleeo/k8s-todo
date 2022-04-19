
resource "aws_s3_bucket" "vault" {

  bucket = "${var.project}-${var.environment}-s3-bucket-vault"


  acl = "private"

  versioning {
    enabled = true
  }

  tags = merge(local.common_tags,
  map("Name", "${var.project}-${var.environment}-S3-Bucket-Vault"))


  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}