# Questão 04 — Prompt

## Prompt utilizado

```
Task:
Escreva uma query SQL para PostgreSQL que produza o relatório mensal de transações dos
últimos 6 meses, agrupado por mês e por categoria, a partir das tabelas abaixo.

Schema do banco (Ledger — PostgreSQL):

CREATE TABLE transactions (
  id              BIGSERIAL PRIMARY KEY,
  customer_id     BIGINT NOT NULL REFERENCES customers(id),
  category        VARCHAR(32) NOT NULL,
  amount_cents    BIGINT NOT NULL,
  status          VARCHAR(16) NOT NULL,
  payment_method  VARCHAR(16),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at    TIMESTAMPTZ
);

CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_status     ON transactions(status);
CREATE INDEX idx_transactions_category   ON transactions(category);

CREATE TABLE customers (
  id          BIGSERIAL PRIMARY KEY,
  segment     VARCHAR(16) NOT NULL,
  country     CHAR(2) NOT NULL,
  signup_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

Regras de negócio:
- Incluir apenas transações com status = 'completed'
- Incluir apenas as categorias: subscription, one_time, refund, credit_adjustment
- Recorte temporal: últimos 6 meses corridos a partir de hoje (referência: 2026-04-24),
  ou seja, created_at >= '2025-10-24'
- O campo amount_cents está em centavos de real; deve ser convertido para reais com
  2 casas decimais na saída
- Agrupar por mês no formato YYYY-MM e por categoria
- Duas métricas por linha: quantidade de transações e volume total em reais
- Ordenação: mês crescente, depois categoria crescente

Action:
1. Identifique quais tabelas e colunas são necessárias para atender os requisitos.
   Observe que a tabela customers não possui colunas solicitadas no relatório — use
   apenas a tabela transactions.
2. Escreva o filtro de data usando created_at >= NOW() - INTERVAL '6 months' para
   que a query continue funcionando corretamente em execuções futuras, sem datas
   hardcoded.
3. Use TO_CHAR(DATE_TRUNC('month', created_at), 'YYYY-MM') para gerar a coluna de
   mês no formato pedido.
4. Converta amount_cents para reais com ROUND(SUM(amount_cents) / 100.0, 2) —
   use 100.0 (float), não 100 (inteiro), para evitar divisão inteira.
5. Nomeie as colunas de saída de forma descritiva: mes, categoria,
   total_transacoes, volume_total_reais.
6. Aplique ORDER BY mes ASC, categoria ASC.
7. Verifique se a query usará os índices disponíveis: o filtro em created_at deve
   aproveitar idx_transactions_created_at; evite funções sobre created_at no WHERE
   que impeçam o uso do índice.

Goal:
A query será executada diretamente no banco de produção do Ledger (PostgreSQL) por um
membro do time de engenharia, e o resultado será entregue para Jennifer Parker (PM) usar
na apresentação de crescimento de transações para Goldie (CEO). A query precisa ser
correta, eficiente e pronta para copiar e rodar — sem placeholders, sem pseudo-código
e sem passos intermediários.

Formato de entrega:
- Primeiro, a query SQL completa dentro de um bloco ```sql, pronta para execução
- Depois, uma seção curta "Notas técnicas" explicando: (a) por que customers foi
  omitida, (b) a escolha de NOW() - INTERVAL vs data hardcoded, e (c) o uso de
  100.0 na divisão
```
