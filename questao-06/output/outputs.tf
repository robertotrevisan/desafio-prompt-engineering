# ==============================================================================
# outputs.tf — Módulo hvt-s3-bucket
# Gerado por: claude-sonnet-4-6  |  Data: 2026-06-13
# ==============================================================================

output "bucket_id" {
  description = "ID do bucket S3 criado (igual ao nome do bucket)."
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN do bucket S3 criado. Usado para políticas IAM e notificações."
  value       = aws_s3_bucket.main.arn
}

output "bucket_name" {
  description = "Nome completo do bucket S3 criado, incluindo o prefixo hvt-."
  value       = aws_s3_bucket.main.bucket
}
