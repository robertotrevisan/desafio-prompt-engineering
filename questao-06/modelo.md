# Questão 06 — Modelo

## Modelo utilizado

- **Modelo:** Claude (Anthropic)
- **Versão:** claude-sonnet-4-6

## Justificativa da escolha

A tarefa exige geração de código Terraform multi-arquivo com consistência de estilo
entre arquivos, aderência a um padrão corporativo e correspondência com um exemplo
de referência fornecido. O `claude-sonnet-4-6` foi escolhido porque:

1. **Consistência de estilo cross-file**: o módulo é composto por quatro arquivos
   interdependentes. O modelo mantém o mesmo padrão de `locals.common_tags`,
   `merge(...)` e nomenclatura `hvt-` em todos os arquivos sem instrução
   específica por arquivo — basta o Context e o Example estabelecerem o padrão.

2. **Conhecimento de recursos Terraform AWS modernos**: os recursos de S3 no
   Terraform AWS provider v4+ foram separados em recursos individuais
   (`aws_s3_bucket_versioning`, `aws_s3_bucket_server_side_encryption_configuration`,
   etc.) em vez do bloco monolítico `lifecycle` inline. O modelo usa os recursos
   corretos da API atual sem precisar de instrução explícita sobre a versão do provider.

3. **Fidelidade ao Example como referência de estilo**: o modelo extrai o padrão
   do trecho de código fornecido (alinhamento de `description`, estrutura de `locals`,
   `merge` com `Name`) e replica fielmente — comportamento de few-shot que o CARE
   explora pela seção Example.

4. **Output diretamente aplicável**: o código gerado passa em `terraform validate`
   sem ajustes manuais, com dependências implícitas corretas entre os recursos
   (ex: `aws_s3_bucket_versioning.main` referencia `aws_s3_bucket.main.id`).
