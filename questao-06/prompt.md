# Questão 06 — Prompt

## Prompt utilizado

```
Context:
Você está trabalhando na Hill Valley Tech, uma empresa que possui um padrão corporativo
de IaC definido pelo head de segurança e compliance. Todo módulo Terraform novo precisa
seguir esse padrão. O módulo que você vai criar será consumido por todos os times da
empresa para provisionar buckets S3, portanto precisa ser reutilizável, seguro por
padrão e aderente ao estilo de código já estabelecido internamente.

Padrão corporativo obrigatório (não negociável):
- Tags obrigatórias em todo recurso: Owner, CostCenter, Environment
- Prefixo hvt- nos nomes de todos os recursos
- Todo bucket S3 deve ter:
  - Criptografia server-side habilitada (SSE-S3 como mínimo)
  - Versioning ativo
  - Block public access total (todos os quatro flags = true)
  - Logging de acesso configurado (server access logging)
- Variáveis de entrada em variables.tf com campos description e type obrigatórios

Referência de estilo do módulo de VPC já existente na empresa (seguir exatamente
o mesmo padrão de nomenclatura, formatação e estrutura):

variable "environment" {
  description = "Nome do ambiente (dev, staging, production)"
  type        = string
}

locals {
  common_tags = {
    Owner       = var.owner
    CostCenter  = var.cost_center
    Environment = var.environment
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = merge(local.common_tags, {
    Name = "hvt-vpc-${var.environment}"
  })
}

Action:
Crie um módulo Terraform completo para bucket S3 aderente ao padrão corporativo
descrito acima, seguindo o estilo do módulo de VPC como referência. O módulo deve
ser composto por quatro arquivos separados:

1. variables.tf — defina todas as variáveis de entrada necessárias, cada uma com
   description e type obrigatórios. Variáveis mínimas esperadas:
   - bucket_name: sufixo do nome do bucket (o prefixo hvt- é adicionado pelo módulo)
   - environment: ambiente de destino
   - owner: valor para a tag Owner
   - cost_center: valor para a tag CostCenter
   - log_bucket: nome do bucket de destino para os logs de acesso

2. main.tf — implemente os recursos AWS necessários:
   - aws_s3_bucket (recurso principal com nome hvt-{bucket_name})
   - aws_s3_bucket_versioning
   - aws_s3_bucket_server_side_encryption_configuration (SSE-S3)
   - aws_s3_bucket_public_access_block (todos os quatro flags true)
   - aws_s3_bucket_logging
   Use locals { common_tags = ... } igual ao módulo de VPC e aplique
   merge(local.common_tags, { Name = ... }) em cada recurso que suporte tags.

3. outputs.tf — exponha pelo menos: bucket_id, bucket_arn e bucket_name.

4. exemplo-uso.tf — um exemplo completo de como um time consumidor chamaria
   este módulo, com valores fictícios plausíveis preenchidos.

Result:
Os quatro arquivos devem ser entregues em blocos de código separados, cada um
identificado pelo nome do arquivo (```hcl // variables.tf, etc.). O código deve
estar pronto para terraform init && terraform plan — sem placeholders, sem
pseudo-código, sem TODOs. Cada arquivo deve ser autoexplicativo para um engenheiro
que nunca viu o módulo antes.

Example:
Siga o estilo do módulo de VPC como referência canônica:
- Mesma estrutura de locals com common_tags
- Mesmo padrão de merge(local.common_tags, { Name = "hvt-<recurso>-${var.environment}" })
- Mesmo estilo de variáveis com description alinhado à esquerda e type na linha seguinte
- Nomes de recursos em snake_case, sem abreviações desnecessárias
```
