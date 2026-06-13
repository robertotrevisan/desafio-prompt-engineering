# Questão 02 — Justificativa

## Como R, T, F aparecem no prompt

### Role (R)

> Trecho do prompt:
> _"Você é uma engenheira SRE sênior responsável pela confiabilidade e operação do banco
> de dados PostgreSQL de produção de uma fintech. Você tem domínio avançado de shell
> scripting Bash, administração de PostgreSQL e AWS CLI, e segue rigorosamente as práticas
> de infraestrutura segura: nunca hardcoda segredos, sempre trata erros, sempre produz
> logs auditáveis."_

O Role cumpre três funções simultâneas neste prompt:

**a) Persona técnica específica (SRE sênior)**
Não é apenas "escreva um script Bash" — é uma SRE que *responde pela confiabilidade*.
Isso ativa um padrão de resposta orientado a operação em produção: o modelo prioriza
tratamento de erros, logging e idempotência em vez de gerar o script mais curto possível.

**b) Stack tecnológica declarada (PostgreSQL + AWS CLI)**
Ao mencionar explicitamente o domínio técnico, o prompt evita que o modelo recorra a
alternativas (ex: usar `boto3` em Python em vez de `aws cli`, ou `pg_basebackup` em vez
de `pg_dump`). O Role estreita o espaço de solução.

**c) Princípios de segurança embutidos no papel**
A frase "nunca hardcoda segredos, sempre trata erros, sempre produz logs auditáveis"
funciona como uma restrição implícita que vale para todo o script — sem precisar repetir
"não faça X" em cada requisito individual da Task.

---

### Task (T)

> Trecho do prompt:
> _"Sua tarefa é escrever um script Bash de backup automatizado para o banco de dados
> PostgreSQL abaixo, pronto para ser agendado via cron diária."_
> _(seguido das especificações do ambiente e dos requisitos funcionais e não-funcionais)_

A Task foi estruturada em três camadas:

**1. Especificações do ambiente (contexto técnico)**
Todos os valores reais foram fornecidos: host, porta, banco, usuário, região, bucket,
diretório, tamanho médio. Isso elimina suposições do modelo e garante que o script
gerado seja diretamente utilizável sem substituições de placeholder.

**2. Requisitos funcionais numerados (8 itens)**
Cada requisito é verificável de forma independente. O uso de lista numerada:
- Força o modelo a não omitir nenhum item (ele pode rastrear o que já implementou)
- Facilita a revisão humana (é possível checar 1 a 1 no output)
- Inclui requisitos negativos explícitos: "nunca deve aparecer hardcoded no script"

**3. Requisitos não-funcionais separados**
Separar funcional de não-funcional é uma técnica de Task que previne que o modelo
trate `set -euo pipefail` como opcional. Ao colocar em seção própria, esses requisitos
têm o mesmo peso que os funcionais.

**Destaque — restrição negativa na Task:**
O requisito _"Não armazenar a senha em nenhuma variável intermediária além da PGPASSWORD
já existente"_ é um exemplo de Task com proibição explícita. Sem isso, o modelo poderia
gerar `DB_PASS="${PGPASSWORD}"` — tecnicamente funcional, mas uma má prática de segurança.

---

### Format (F)

> Trecho do prompt:
> _"Formato de entrega:_
> _- Primeiro, o script Bash completo, sem omitir nenhuma linha, dentro de um bloco ```bash_
> _- Depois, uma seção "Decisões técnicas" com tópicos explicando as escolhas não-óbvias_
> _- Por fim, uma linha de cron pronta para uso (crontab -e) que execute o script diariamente às 02:00"_

O Format foi desenhado para produzir três entregáveis distintos com propósitos diferentes:

| Entregável | Destinatário | Propósito |
|------------|--------------|-----------|
| Script Bash completo em bloco de código | Lorraine / SRE | Copiar e usar diretamente em produção |
| Seção "Decisões técnicas" | Time de engenharia / revisão | Rastrear o porquê de cada escolha não-óbvia |
| Linha de cron pronta | Operador que vai agendar | Eliminar erro de sintaxe no crontab |

**Detalhe relevante no Format:**
A instrução _"sem omitir nenhuma linha"_ é necessária porque modelos de linguagem
frequentemente resumem scripts longos com `# ... resto do script ...` quando percebem
que o conteúdo é repetitivo ou extenso. Essa instrução explícita previne esse comportamento.

**Por que pedir "decisões técnicas" separadas?**
Um script de infraestrutura de produção precisa ser revisado antes de ser aplicado.
Ao forçar o modelo a documentar escolhas como `STANDARD_IA` vs `STANDARD`, `s3api`
vs `s3`, e o `trap ERR`, o prompt transforma o output em um artefato auditável —
alinhado com a persona de SRE definida no Role.
