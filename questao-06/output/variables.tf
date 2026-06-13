# ==============================================================================
# variables.tf — Módulo hvt-s3-bucket
# Gerado por: claude-sonnet-4-6  |  Data: 2026-06-13
# ==============================================================================

variable "bucket_name" {
  description = "Sufixo do nome do bucket. O prefixo hvt- é adicionado automaticamente pelo módulo."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente de destino (dev, staging, production)."
  type        = string
}

variable "owner" {
  description = "Time ou indivíduo responsável pelo bucket. Usado na tag Owner."
  type        = string
}

variable "cost_center" {
  description = "Centro de custo associado ao bucket. Usado na tag CostCenter."
  type        = string
}

variable "log_bucket" {
  description = "Nome do bucket S3 de destino para os logs de acesso ao servidor (server access logging)."
  type        = string
}

variable "log_prefix" {
  description = "Prefixo dos objetos de log dentro do bucket de logs. Padrão: logs/."
  type        = string
  default     = "logs/"
}
