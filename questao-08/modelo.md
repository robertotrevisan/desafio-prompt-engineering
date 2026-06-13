# Questão 08 — Modelo

## Modelo utilizado

- **Modelo:** Claude (Anthropic)
- **Versão:** claude-sonnet-4-6

## Justificativa da escolha

Esta é a tarefa mais analiticamente exigente do conjunto: requer correlacionar artefatos
heterogêneos (changelog, série temporal de métricas, log de aplicação, estado de fila,
estado de cluster), reconstruir uma cadeia causal e emitir uma recomendação binária sob
restrição de tempo. O `claude-sonnet-4-6` foi escolhido porque:

1. **Raciocínio de correlação multi-fonte**: a tarefa exige cruzar o changelog do deploy
   com os sintomas do log e com a aritmética de conexões (12 pods × 20 = 240 = RDS 240/250).
   O modelo identifica essa correspondência numérica — a evidência mais forte do diagnóstico
   — sem que ela seja apontada explicitamente no prompt.

2. **Distinção entre causa raiz e sintoma**: o modelo separa corretamente o gargalo de
   conexões (causa) dos efeitos em cascata (circuit breaker, falha do Reactor, lag da fila)
   e avalia cada opção de remediação contra a causa raiz, não contra os sintomas. Essa é a
   capacidade central que torna o postmortem útil para a decisão do Doc.

3. **Calibração de confiança**: o modelo classifica o diagnóstico como "confiança alta" e
   justifica com a evidência aritmética e a consistência da cadeia de log — em vez de afirmar
   certeza absoluta. Calibração de incerteza é desejável em postmortems de incidente real.

4. **Concisão sob restrição de formato**: o Goal exige leitura em menos de 5 minutos. O
   modelo prioriza o TL;DR e a tabela de avaliação de opções, mantendo o detalhe técnico
   sem inflar o documento — comportamento adequado para um CTO decidindo em 20 minutos.

### Observação sobre a escolha do modelo para incidente real

Em um incidente de produção real, com mais tempo, faria sentido considerar um modelo de
raciocínio estendido (ex: variantes com reasoning) para maximizar a robustez da correlação.
Para o escopo deste exercício — artefatos estáticos fornecidos e um diagnóstico de cadeia
causal bem definida — o Sonnet entrega a relação qualidade/latência ideal, e a latência
importa quando a decisão precisa sair em 20 minutos.
