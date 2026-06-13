#!/usr/bin/env bash
# ==============================================================================
# ledger-backup.sh
# Backup diário do PostgreSQL ledger_prod → S3 hvt-ledger-backups
# Gerado por: claude-sonnet-4-6  |  Data: 2026-06-13
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Configuração
# ------------------------------------------------------------------------------
DB_HOST="ledger-db.internal.hvt.io"
DB_PORT="5432"
DB_NAME="ledger_prod"
DB_USER="backup_user"
AWS_REGION="us-east-1"
S3_BUCKET="hvt-ledger-backups"
BACKUP_DIR="/var/backups/ledger"
LOG_FILE="/var/log/ledger-backup.log"
RETENTION_DAYS=30

TIMESTAMP="$(date -u +%Y%m%d_%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/ledger_prod_${TIMESTAMP}.sql.gz"

# ------------------------------------------------------------------------------
# Funções auxiliares
# ------------------------------------------------------------------------------
log() {
    local level="$1"
    local message="$2"
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [${level}] ${message}" | tee -a "${LOG_FILE}"
}

check_dependency() {
    local cmd="$1"
    if ! command -v "${cmd}" &>/dev/null; then
        log "ERROR" "Dependência ausente: '${cmd}' não encontrado no PATH"
        exit 1
    fi
}

cleanup() {
    if [[ -f "${BACKUP_FILE}" ]]; then
        log "INFO" "Removendo arquivo local temporário: ${BACKUP_FILE}"
        rm -f "${BACKUP_FILE}"
    fi
}

# Em qualquer saída inesperada (set -e), garante log e cleanup
trap 'log "ERROR" "Script encerrado inesperadamente na linha ${LINENO}. Exit code: $?"; cleanup; exit 1' ERR

# ------------------------------------------------------------------------------
# Validação de dependências
# ------------------------------------------------------------------------------
log "INFO" "Iniciando backup do banco '${DB_NAME}' em ${DB_HOST}:${DB_PORT}"
log "INFO" "Validando dependências..."

for dep in pg_dump gzip aws; do
    check_dependency "${dep}"
done

log "INFO" "Todas as dependências encontradas."

# ------------------------------------------------------------------------------
# Validação de variáveis de ambiente obrigatórias
# ------------------------------------------------------------------------------
if [[ -z "${PGPASSWORD:-}" ]]; then
    log "ERROR" "Variável de ambiente PGPASSWORD não está definida. Abortando."
    exit 1
fi

# ------------------------------------------------------------------------------
# Dump + compressão
# ------------------------------------------------------------------------------
log "INFO" "Iniciando pg_dump → ${BACKUP_FILE}"

pg_dump \
    --host="${DB_HOST}" \
    --port="${DB_PORT}" \
    --username="${DB_USER}" \
    --no-password \
    --format=plain \
    --verbose \
    "${DB_NAME}" \
    2>>"${LOG_FILE}" \
    | gzip > "${BACKUP_FILE}"

DUMP_SIZE="$(du -sh "${BACKUP_FILE}" | cut -f1)"
log "INFO" "Dump concluído. Tamanho: ${DUMP_SIZE} → ${BACKUP_FILE}"

# ------------------------------------------------------------------------------
# Upload para S3
# ------------------------------------------------------------------------------
S3_KEY="backups/ledger_prod_${TIMESTAMP}.sql.gz"
S3_URI="s3://${S3_BUCKET}/${S3_KEY}"

log "INFO" "Iniciando upload para ${S3_URI}"

aws s3 cp "${BACKUP_FILE}" "${S3_URI}" \
    --region "${AWS_REGION}" \
    --storage-class STANDARD_IA \
    2>>"${LOG_FILE}"

log "INFO" "Upload concluído: ${S3_URI}"

# ------------------------------------------------------------------------------
# Limpeza do arquivo local
# ------------------------------------------------------------------------------
cleanup
log "INFO" "Arquivo local removido. Espaço em disco preservado."

# ------------------------------------------------------------------------------
# Retenção: remover objetos no S3 mais antigos que RETENTION_DAYS dias
# ------------------------------------------------------------------------------
log "INFO" "Aplicando política de retenção: removendo backups com mais de ${RETENTION_DAYS} dias no S3..."

CUTOFF_DATE="$(date -u -d "${RETENTION_DAYS} days ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
    || date -u -v-"${RETENTION_DAYS}"d +%Y-%m-%dT%H:%M:%SZ)"  # fallback para macOS

DELETED_COUNT=0

while IFS= read -r object_key; do
    if [[ -n "${object_key}" ]]; then
        log "INFO" "Removendo objeto expirado: s3://${S3_BUCKET}/${object_key}"
        aws s3 rm "s3://${S3_BUCKET}/${object_key}" \
            --region "${AWS_REGION}" \
            2>>"${LOG_FILE}"
        (( DELETED_COUNT++ )) || true
    fi
done < <(
    aws s3api list-objects-v2 \
        --bucket "${S3_BUCKET}" \
        --prefix "backups/" \
        --query "Contents[?LastModified<='${CUTOFF_DATE}'].Key" \
        --output text \
        --region "${AWS_REGION}" \
        2>>"${LOG_FILE}"
)

log "INFO" "Retenção aplicada. Objetos removidos: ${DELETED_COUNT}"

# ------------------------------------------------------------------------------
# Conclusão
# ------------------------------------------------------------------------------
log "INFO" "Backup concluído com sucesso. Arquivo: ${S3_URI}"
exit 0


# ==============================================================================
# Decisões técnicas
# ==============================================================================
#
# 1. set -euo pipefail
#    Aborta o script em qualquer comando com exit code != 0 (-e), trata variáveis
#    não definidas como erro (-u) e propaga falhas em pipes (-o pipefail).
#    Sem isso, `pg_dump | gzip` poderia silenciar uma falha do pg_dump se o gzip
#    concluísse com sucesso.
#
# 2. trap ERR
#    Captura saídas inesperadas causadas pelo set -e e garante que o log receba
#    o número da linha e o exit code antes de encerrar. Também aciona o cleanup
#    para não deixar arquivo parcial no disco.
#
# 3. PGPASSWORD via variável de ambiente, sem intermediário
#    O pg_dump lê PGPASSWORD diretamente. Nunca é atribuída a outra variável
#    nem passada como argumento (que ficaria visível em `ps aux`).
#
# 4. --no-password no pg_dump
#    Impede que o pg_dump tente abrir um prompt interativo caso PGPASSWORD esteja
#    ausente — o script falharia silenciosamente em cron sem essa flag.
#
# 5. --format=plain + gzip via pipe
#    Formato plain é mais portável e inspecionável que o custom (-Fc). O pipe
#    evita escrever o dump descompactado em disco (economiza ~3x o espaço).
#
# 6. STANDARD_IA no S3
#    Backups são acessados raramente (somente em restore). Standard-IA reduz
#    custo de armazenamento em ~58% vs Standard, mantendo durabilidade 11 9's.
#
# 7. aws s3api list-objects-v2 para retenção
#    Usa a query JMESPath do CLI para filtrar por LastModified no lado do servidor,
#    evitando baixar a lista completa de objetos para processar no shell.
#
# 8. Compatibilidade de data (Linux/macOS)
#    date -d é GNU; date -v é BSD. O fallback garante que o script rode em
#    ambos os ambientes durante testes locais no macOS do desenvolvedor.
#
# 9. Idempotência
#    O timestamp no nome do arquivo (YYYYMMDD_HHMMSS) garante que re-execuções
#    no mesmo dia gerem arquivos distintos, sem sobrescrever backups anteriores.


# ==============================================================================
# Linha de cron (crontab -e)
# ==============================================================================
#
# Executa diariamente às 02:00 UTC. Redireciona stdout/stderr para o log
# (o script já faz isso internamente, mas o redirecionamento externo captura
# erros de inicialização do próprio bash antes de o script chegar ao set -e).
#
# 0 2 * * * /usr/local/bin/ledger-backup.sh >> /var/log/ledger-backup.log 2>&1
