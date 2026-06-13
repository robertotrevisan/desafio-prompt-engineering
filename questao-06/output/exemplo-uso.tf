# ==============================================================================
# exemplo-uso.tf — Exemplo de consumo do módulo hvt-s3-bucket
# Gerado por: claude-sonnet-4-6  |  Data: 2026-06-13
#
# Este arquivo demonstra como um time consumidor chama o módulo para criar um
# bucket S3 aderente ao padrão corporativo da Hill Valley Tech.
# ==============================================================================

# Exemplo: bucket de artefatos de build do time de plataforma em produção
module "platform_artifacts" {
  source = "git::https://github.com/hvt/terraform-modules//s3-bucket?ref=v1.0.0"

  bucket_name = "platform-artifacts"
  environment = "production"
  owner       = "platform-team"
  cost_center = "CC-1042"
  log_bucket  = "hvt-access-logs-production"
  log_prefix  = "logs/platform-artifacts/"
}

# Outputs disponíveis após o apply:
output "artifacts_bucket_arn" {
  description = "ARN do bucket de artefatos de plataforma."
  value       = module.platform_artifacts.bucket_arn
}

output "artifacts_bucket_name" {
  description = "Nome do bucket de artefatos de plataforma."
  value       = module.platform_artifacts.bucket_name
}
