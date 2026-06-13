# Questão 01 — Prompt

## Prompt utilizado

```
Você é um engenheiro de plataforma sênior especializado em containers e Kubernetes, 
responsável por containerizar aplicações Python para ambientes de produção corporativos.

Sua tarefa é criar um Dockerfile de produção para a aplicação abaixo, seguindo rigorosamente 
as boas práticas de containerização. A aplicação é uma API Python/Flask servida pelo Gunicorn 
na porta 8080.

Contexto da aplicação:
- Estrutura de arquivos:
  lift/
  ├── app.py
  ├── requirements.txt
  ├── lib/
  │   ├── auth.py
  │   └── storage.py
  └── tests/
      └── test_app.py

- Conteúdo de requirements.txt:
  Flask==3.0.0
  gunicorn==21.2.0
  requests==2.31.0
  python-dotenv==1.0.0
  psycopg2-binary==2.9.9

- Comando de inicialização em produção:
  gunicorn --bind 0.0.0.0:8080 --workers 4 app:app

- Variáveis de ambiente obrigatórias em runtime (não devem ter valores default no Dockerfile):
  DATABASE_URL
  API_KEY

Boas práticas que devem ser aplicadas:
1. Imagem base oficial Python slim (versão estável mais recente do Python 3)
2. Separação da camada de instalação de dependências da camada de cópia do código-fonte 
   (para aproveitar o cache de layers do Docker)
3. Usuário não-root dedicado para execução da aplicação
4. Variáveis de ambiente declaradas com ENV apenas para configurações não-sensíveis 
   (DATABASE_URL e API_KEY devem ser injetadas em runtime, não hardcoded)
5. Diretório de trabalho explícito
6. EXPOSE da porta correta
7. Não copiar arquivos desnecessários (diretório tests/ e arquivos de desenvolvimento)
8. Instrução HEALTHCHECK configurada para o endpoint raiz

Formato de entrega:
- Primeiro, apresente o Dockerfile completo e funcional, sem omitir nenhuma linha
- Depois, apresente uma tabela com três colunas: Instrução | Boas práticas aplicada | Justificativa
- Por fim, liste qualquer .dockerignore recomendado para este projeto
```
