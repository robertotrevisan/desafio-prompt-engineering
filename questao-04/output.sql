-- ==============================================================================
-- Output gerado pelo modelo para a Questão 04
-- Modelo: claude-sonnet-4-6  |  Data: 2026-06-13
-- Relatório mensal de transações do Ledger — últimos 6 meses por categoria
-- ==============================================================================

SELECT
    TO_CHAR(DATE_TRUNC('month', created_at), 'YYYY-MM')  AS mes,
    category                                              AS categoria,
    COUNT(*)                                              AS total_transacoes,
    ROUND(SUM(amount_cents) / 100.0, 2)                  AS volume_total_reais
FROM
    transactions
WHERE
    status      = 'completed'
    AND category IN ('subscription', 'one_time', 'refund', 'credit_adjustment')
    AND created_at >= NOW() - INTERVAL '6 months'
GROUP BY
    DATE_TRUNC('month', created_at),
    category
ORDER BY
    mes ASC,
    categoria ASC;


-- ==============================================================================
-- Notas técnicas
-- ==============================================================================

-- (a) Por que customers foi omitida
--     O relatório solicita apenas mês, categoria, quantidade de transações e volume
--     em reais — todos os campos vêm exclusivamente da tabela transactions.
--     Um JOIN com customers sem necessidade introduziria custo de I/O desnecessário
--     e potencial de multiplicação de linhas se o relacionamento não fosse 1:1
--     no contexto da query. A tabela foi ignorada.

-- (b) NOW() - INTERVAL '6 months' vs data hardcoded
--     Usar NOW() - INTERVAL '6 months' torna a query dinâmica: ela sempre retornará
--     os últimos 6 meses a partir da data de execução, sem precisar de atualização
--     manual. Uma data hardcoded ('2025-10-24') tornaria a query obsoleta já no mês
--     seguinte. Para fins de auditoria ou reprodutibilidade de resultado histórico,
--     basta substituir NOW() por uma constante de timestamp.

-- (c) 100.0 na divisão inteira
--     Em PostgreSQL, a divisão entre dois inteiros produz um inteiro:
--     5 / 100 → 0 (truncamento). Ao usar 100.0 (literal float), o PostgreSQL
--     promove a operação para divisão de ponto flutuante antes do ROUND,
--     garantindo que 550 centavos se torne 5.50 reais e não 5.00 ou 0.
--     Alternativamente, poderia-se usar CAST(amount_cents AS NUMERIC) / 100,
--     mas a forma com 100.0 é mais concisa e igualmente correta.

-- (d) GROUP BY com DATE_TRUNC vs alias
--     O GROUP BY referencia DATE_TRUNC('month', created_at) diretamente, não o
--     alias 'mes', porque PostgreSQL não permite referenciar aliases de SELECT
--     no GROUP BY (comportamento padrão SQL). O TO_CHAR é aplicado apenas no
--     SELECT para formatação da saída.
