# Questão 04 — Modelo

## Modelo utilizado

- **Modelo:** Claude (Anthropic)
- **Versão:** claude-sonnet-4-6

## Justificativa da escolha

A tarefa é geração de SQL com regras de negócio precisas e armadilhas técnicas
conhecidas (divisão inteira, alias em GROUP BY, uso de índice). O `claude-sonnet-4-6`
foi escolhido porque:

1. **SQL correto na primeira tentativa**: o modelo conhece as nuances de PostgreSQL
   — como a impossibilidade de referenciar aliases do SELECT no GROUP BY, o
   comportamento de divisão inteira e a diferença entre DATE_TRUNC e TO_CHAR —
   sem precisar de prompting adicional para cada detalhe.

2. **Fidelidade a schemas explícitos**: quando o schema DDL é fornecido no prompt,
   o modelo não inventa colunas nem tabelas. Isso é crítico aqui porque a tabela
   `customers` estava presente no schema mas **não deveria** ser usada, e o modelo
   reconhece corretamente que um JOIN seria desnecessário.

3. **Output diretamente executável**: a tarefa exige SQL pronto para rodar em
   produção — sem comentários de "substitua X por Y", sem pseudo-código. O Sonnet
   produz código executável por padrão quando o Goal especifica "pronto para copiar
   e rodar".

4. **Custo-benefício**: geração de uma única query com schema e regras definidas
   é uma tarefa de complexidade baixa a média. Não justifica modelo mais poderoso;
   o Sonnet entrega qualidade adequada com menor latência e custo.
