# Questão 04 — Justificativa

## Como T, A, G aparecem no prompt

---

### Task (T)

> Trecho do prompt:
> _"Escreva uma query SQL para PostgreSQL que produza o relatório mensal de transações
> dos últimos 6 meses, agrupado por mês e por categoria, a partir das tabelas abaixo."_
> _(seguido do schema DDL completo e das regras de negócio)_

A Task desta questão tem três componentes:

**1. O verbo e o artefato esperado**
"Escreva uma query SQL para PostgreSQL" — sem ambiguidade: o output é código SQL,
não uma explicação, não um plano de execução, não uma alternativa em Python. O
dialeto (PostgreSQL) é especificado porque funções como `DATE_TRUNC`, `TO_CHAR` e
o comportamento de divisão inteira variam entre bancos.

**2. O schema DDL completo como contexto**
Fornecer o DDL das duas tabelas — incluindo os índices — serve dois propósitos:
- O modelo não precisa inferir tipos de dados nem nomes de colunas
- O modelo pode avaliar quais índices estão disponíveis e gerar o WHERE que os utilize
  (filtro em `created_at` aproveita `idx_transactions_created_at` diretamente)

**3. As regras de negócio como restrições da Task**
As regras (status, categorias, recorte temporal, conversão de centavos, formato de mês,
ordenação) foram listadas de forma explícita e separada do schema. Isso é deliberado:
misturar regras de negócio dentro do DDL tornaria o prompt mais denso e aumentaria
a chance de o modelo omitir algum requisito por não perceber sua natureza prescritiva.

**Detalhe: a tabela `customers` como armadilha**
O schema inclui a tabela `customers` com DDL parcialmente corrompido no enunciado
(`BIGSERIAL Pegment` em vez de `BIGSERIAL PRIMARY KEY, segment`). A Task não menciona
nenhuma coluna de `customers` nos requisitos de saída — o que sinaliza ao modelo que
ela não deve ser usada. A Action reforça isso explicitamente (passo 1).

---

### Action (A)

> Trecho do prompt (passos 1–7):
> _"1. Identifique quais tabelas e colunas são necessárias... Observe que a tabela
> customers não possui colunas solicitadas..."_
> _"2. Escreva o filtro de data usando created_at >= NOW() - INTERVAL '6 months'..."_
> _"3. Use TO_CHAR(DATE_TRUNC('month', created_at), 'YYYY-MM')..."_
> _"4. Converta amount_cents para reais com ROUND(SUM(amount_cents) / 100.0, 2)..."_
> _"5. Nomeie as colunas... mes, categoria, total_transacoes, volume_total_reais."_
> _"6. Aplique ORDER BY mes ASC, categoria ASC."_
> _"7. Verifique se a query usará os índices disponíveis..."_

A Action desta questão é incomum: ela não descreve *o que* fazer (a Task já fez isso),
mas sim *como resolver cada armadilha técnica* da query. Cada passo da Action corresponde
a um erro clássico que um modelo sem orientação poderia cometer:

| Passo da Action | Erro que previne |
|-----------------|-----------------|
| 1 — Identificar tabelas necessárias + aviso sobre `customers` | JOIN desnecessário com tabela não pedida |
| 2 — `NOW() - INTERVAL` vs data hardcoded | Query que vira lixo após o mês corrente |
| 3 — `TO_CHAR(DATE_TRUNC(...), 'YYYY-MM')` | Usar só `TO_CHAR` sem truncar (resulta em chaves únicas por dia, não por mês) |
| 4 — `/ 100.0` (float) não `/ 100` (inteiro) | Divisão inteira que trunca centavos e entrega valores errados |
| 5 — Nomear colunas descritivamente | Aliases genéricos como `col1`, `sum` que confundem a PM |
| 6 — `ORDER BY mes ASC, categoria ASC` | Ordenação errada ou ausente |
| 7 — Verificar uso de índice | Funções sobre `created_at` no WHERE que invalidam o índice |

**Padrão de uso da Action em geração de código**

Quando o artefato final é código, a Action funciona como uma checklist de decisões
de implementação — não como um tutorial passo a passo. O modelo não precisa seguir
os passos em sequência; ele os usa como guardrails para não tomar o caminho errado.
Isso difere do uso da Action na Questão 02 (script Bash), onde os passos eram
sequenciais e operacionais.

---

### Goal (G)

> Trecho do prompt:
> _"A query será executada diretamente no banco de produção do Ledger (PostgreSQL)
> por um membro do time de engenharia, e o resultado será entregue para Jennifer
> Parker (PM) usar na apresentação de crescimento de transações para Goldie (CEO).
> A query precisa ser correta, eficiente e pronta para copiar e rodar — sem
> placeholders, sem pseudo-código e sem passos intermediários."_

O Goal desta questão opera em dois níveis:

**1. Contexto de execução: banco de produção**
"Será executada diretamente no banco de produção" eleva o critério de qualidade.
O modelo entende que não pode gerar uma query "aproximada" ou com TODOs — o
custo de um erro é alto. Isso reforça a escolha de `/ 100.0` em vez de `/ 100`,
`NOW() - INTERVAL` em vez de data hardcoded, e o não uso de `customers`.

**2. Cadeia de destinatários: engenheiro → Jennifer (PM) → Goldie (CEO)**
Explicitar que o output final vai para uma PM (que não escreve SQL) e depois para
a CEO tem um efeito sutil mas importante: o modelo nomeia as colunas de saída com
nomes legíveis por humanos (`mes`, `total_transacoes`, `volume_total_reais`) em vez
de aliases técnicos ou abreviados. O output de uma query que vai aparecer num slide
de apresentação precisa ser autoexplicativo.

**3. Proibições explícitas no Goal**
"Sem placeholders, sem pseudo-código e sem passos intermediários" fecha três brechas
comuns em respostas de modelos para tarefas de código:
- Placeholders como `<seu_banco>` ou `/* filtro aqui */`
- Pseudo-código como `-- adicione aqui o GROUP BY adequado`
- Respostas explicativas em vez do artefato ("para fazer isso, você precisaria de...")

Essas proibições no Goal complementam a Task (que define o que entregar) ao especificar
o que **não** deve aparecer no output — uma forma de Format embutida no Goal.

---

### Comparação com o uso de R-T-F nesta questão

Aplicar R-T-F aqui exigiria definir um Role como "engenheiro de dados sênior com
especialidade em PostgreSQL". Isso funcionaria, mas seria menos preciso: um Role
não dirige o raciocínio técnico passo a passo do mesmo modo que a Action faz.
A Action de T-A-G permitiu injetar as decisões técnicas específicas (100.0, DATE_TRUNC,
INDEX awareness) diretamente no fluxo de raciocínio, sem depender de que o Role
"lembrasse" de todos esses detalhes por conta própria.
