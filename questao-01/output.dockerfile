# ==============================================================================
# Output gerado pelo modelo para a Questão 01
# Modelo: claude-sonnet-4-6  |  Data: 2026-06-13
# ==============================================================================

# ---- Dockerfile ---------------------------------------------------------------

FROM python:3.12-slim

# Metadados da imagem
LABEL maintainer="platform-team@empresa.com" \
      app="lift-api" \
      version="1.0"

# Variáveis de ambiente não-sensíveis
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

# Diretório de trabalho
WORKDIR /app

# Instalar dependências do sistema necessárias para psycopg2-binary
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc \
       libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar e instalar dependências Python primeiro (camada cacheável)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Criar usuário não-root dedicado
RUN groupadd --gid 1001 appgroup \
    && useradd --uid 1001 --gid appgroup --shell /bin/sh --create-home appuser

# Copiar apenas o código-fonte necessário (sem tests/)
COPY app.py .
COPY lib/ ./lib/

# Ajustar ownership para o usuário não-root
RUN chown -R appuser:appgroup /app

# Trocar para usuário não-root
USER appuser

# Expor a porta da aplicação
EXPOSE 8080

# Healthcheck no endpoint raiz
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/')" || exit 1

# Comando de inicialização em produção
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "app:app"]


# ==============================================================================
# Tabela de boas práticas aplicadas
# ==============================================================================
#
# Instrução                     | Boa prática aplicada               | Justificativa
# ------------------------------|------------------------------------|-----------------------------------------
# FROM python:3.12-slim         | Imagem base slim                   | Reduz tamanho final (~50 MB vs ~900 MB
#                               |                                    | da imagem full); menos superfície de ataque
# COPY requirements.txt → RUN   | Cache de layers                    | Dependências mudam menos que o código;
# pip install → COPY app.py     |                                    | build subsequentes reusam a camada de deps
# ENV PYTHONDONTWRITEBYTECODE=1 | Configurações não-sensíveis via    | Melhora performance e legibilidade de logs
# ENV PYTHONUNBUFFERED=1        | ENV                                | sem expor segredos na imagem
# DATABASE_URL e API_KEY        | Sem valores default sensíveis      | Segredos são injetados via Secret do K8s
# (ausentes no Dockerfile)      |                                    | em runtime, nunca baked na imagem
# WORKDIR /app                  | Diretório de trabalho explícito    | Evita operações em diretórios inesperados
# useradd appuser → USER appuser| Usuário não-root                   | Princípio do menor privilégio; obrigatório
#                               |                                    | em muitos clusters K8s (PodSecurityPolicy)
# COPY app.py + COPY lib/       | Não copiar tests/                  | Reduz tamanho da imagem e evita vazar
# (sem COPY tests/)             |                                    | código de testes em produção
# EXPOSE 8080                   | Documentação de porta              | Deixa explícito para orquestradores e devs
# HEALTHCHECK                   | Verificação de saúde               | K8s usa liveness/readiness probes; a
#                               |                                    | instrução serve como fallback e documentação
# CMD ["gunicorn", ...]         | Formato exec (lista JSON)          | Evita shell intermediário; sinais UNIX
#                               |                                    | (SIGTERM) chegam direto ao processo


# ==============================================================================
# .dockerignore recomendado
# ==============================================================================
#
# .git
# .gitignore
# __pycache__/
# *.pyc
# *.pyo
# *.pyd
# .Python
# .env
# .env.*
# venv/
# .venv/
# tests/
# *.md
# .dockerignore
# Dockerfile
# .pytest_cache/
# .coverage
# htmlcov/
