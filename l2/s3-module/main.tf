# L2 Module: s3-module
# Production-ready S3 bucket with:
#   - Public access blocked
#   - Versioning
#   - AES-256 encryption (or KMS)
#   - Lifecycle rules
#   - Optional access logging
#   - Optional bucket policy

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = merge(var.tags, { Name = var.bucket_name, ManagedBy = "terraform" })
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  depends_on = [aws_s3_bucket_versioning.this]
  bucket     = aws_s3_bucket.this.id

  rule {
    id     = "transition-to-ia"
    status = var.lifecycle_enabled ? "Enabled" : "Disabled"
    filter { prefix = "" }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  count         = var.access_log_bucket_id != null ? 1 : 0
  bucket        = aws_s3_bucket.this.id
  target_bucket = var.access_log_bucket_id
  target_prefix = "${var.bucket_name}/"
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_policy_json != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy_json

  depends_on = [aws_s3_bucket_public_access_block.this]
}
