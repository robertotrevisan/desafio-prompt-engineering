# Questão 02 — Prompt

## Prompt utilizado

```
Você é uma engenheira SRE sênior responsável pela confiabilidade e operação do banco de dados
PostgreSQL de produção de uma fintech. Você tem domínio avançado de shell scripting Bash,
administração de PostgreSQL e AWS CLI, e segue rigorosamente as práticas de infraestrutura
segura: nunca hardcoda segredos, sempre trata erros, sempre produz logs auditáveis.

Sua tarefa é escrever um script Bash de backup automatizado para o banco de dados PostgreSQL
abaixo, pronto para ser agendado via cron diária.

Especificações do ambiente:
- Host: ledger-db.internal.hvt.io
- Porta: 5432
- Banco: ledger_prod
- Usuário de backup: backup_user
- Senha: variável de ambiente PGPASSWORD, populada pelo AWS Secrets Manager via IAM role
  da instância (nunca deve aparecer hardcoded no script)
- Região AWS: us-east-1
- SO: Ubuntu 22.04 LTS
- Diretório de trabalho local: /var/backups/ledger (com 80 GB disponíveis)
- Tamanho médio do dump compactado: ~12 GB
- Bucket S3 de destino: hvt-ledger-backups

Requisitos funcionais (todos obrigatórios):
1. Gerar o dump com pg_dump em formato plain SQL compactado com gzip
2. Nome do arquivo deve incluir data e hora no formato ledger_prod_YYYYMMDD_HHMMSS.sql.gz
3. Fazer upload do arquivo para o bucket S3 via aws s3 cp
4. Aplicar retenção de 30 dias no S3: remover objetos mais antigos que 30 dias do bucket
5. Registrar cada etapa em /var/log/ledger-backup.log com timestamp ISO-8601
6. Em qualquer falha, registrar o erro no log e sair com exit code 1
7. Em execução bem-sucedida, sair com exit code 0
8. Limpar o arquivo local após upload bem-sucedido para não consumir o disco

Requisitos não-funcionais:
- Usar set -euo pipefail no início
- Validar que as ferramentas necessárias (pg_dump, gzip, aws) estão disponíveis antes de executar
- Não armazenar a senha em nenhuma variável intermediária além da PGPASSWORD já existente no ambiente
- O script deve ser idempotente: re-execuções no mesmo dia não sobrescrevem backups anteriores
  (o timestamp no nome garante isso)

Formato de entrega:
- Primeiro, o script Bash completo, sem omitir nenhuma linha, dentro de um bloco ```bash
- Depois, uma seção "Decisões técnicas" com tópicos explicando as escolhas não-óbvias
- Por fim, uma linha de cron pronta para uso (crontab -e) que execute o script diariamente às 02:00
```
