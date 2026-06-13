# ==============================================================================
# main.tf — Módulo hvt-s3-bucket
# Gerado por: claude-sonnet-4-6  |  Data: 2026-06-13
# ==============================================================================

locals {
  common_tags = {
    Owner       = var.owner
    CostCenter  = var.cost_center
    Environment = var.environment
  }

  bucket_full_name = "hvt-${var.bucket_name}"
}

# ------------------------------------------------------------------------------
# Recurso principal — bucket S3
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "main" {
  bucket = local.bucket_full_name

  tags = merge(local.common_tags, {
    Name = "hvt-${var.bucket_name}-${var.environment}"
  })
}

# ------------------------------------------------------------------------------
# Versioning
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ------------------------------------------------------------------------------
# Criptografia server-side (SSE-S3)
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# ------------------------------------------------------------------------------
# Block public access — todos os quatro flags obrigatoriamente true
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# Server access logging
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_logging" "main" {
  bucket        = aws_s3_bucket.main.id
  target_bucket = var.log_bucket
  target_prefix = var.log_prefix
}
