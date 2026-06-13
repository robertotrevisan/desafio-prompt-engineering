# Questão 08 — Prompt

## Framework escolhido: T-A-G (Task–Action–Goal)

A justificativa completa da escolha e a comparação com os frameworks alternativos
está em `justificativa-estendida.md`.

## Prompt utilizado

```
Task:
Você está respondendo a um incidente em produção EM ANDAMENTO durante pico de tráfego.
Analise os artefatos abaixo, determine a causa raiz mais provável e produza um postmortem
técnico que sustente uma decisão imediata entre duas opções de remediação:
  (A) Rollback do deploy v2.48.0 (que subiu ontem)
  (B) Scaling emergencial (aumentar limits do RDS e o pool de conexões)

Artefatos disponíveis para análise:

--- Deploy anterior (ontem, 18:42 UTC) ---
Deploy chronos-api: v2.47.0 -> v2.48.0
Argo CD sync: 2026-04-23 18:42:11 UTC
Changelog:
- Adicionado endpoint POST /v2/transactions/batch
- Refatorado cliente do Ledger (pool de conexoes movido para nova biblioteca interna)
- Bump de psycopg 3.1.18 -> 3.2.0
- Reduzido timeout do Ledger de 5s para 2s

--- Métricas do Beacon (últimos 30 min) ---
timestamp                p99_latency_ms   req_rate_s   err_rate_pct
2026-04-24 13:30 UTC     420              1200         0.2
2026-04-24 13:45 UTC     510              1450         0.3
2026-04-24 14:00 UTC     780              1780         1.1
2026-04-24 14:10 UTC     2400             2100         4.5
2026-04-24 14:15 UTC     5200             2400         8.2
2026-04-24 14:20 UTC     8100             2650         11.7

--- Log do pod chronos-api-79c4d8b9-xk2jp ---
2026-04-24 14:19:48 [ERROR] [ledger-client] connection pool exhausted (max=20, active=20, waiting=147)
2026-04-24 14:19:49 [WARN]  [ledger-client] query timeout after 2000ms: SELECT ... FROM transactions WHERE ...
2026-04-24 14:19:49 [ERROR] [handler] POST /v2/transactions/batch failed: context deadline exceeded
2026-04-24 14:19:50 [ERROR] [ledger-client] connection reset by peer
2026-04-24 14:19:51 [WARN]  [circuit-breaker] ledger-client OPEN (threshold 50%, current 87%)
2026-04-24 14:19:52 [ERROR] [reactor] failed to publish message: chronos-api upstream error

--- Estado do Reactor (fila chronos-transactions) ---
50.127 mensagens acumuladas, crescendo a ~800/min.
Consumer lag atual: 18 minutos e aumentando.

--- Estado do cluster ---
Chronos: 12/12 pods running (HPA no máximo).
CPU médio dos pods: 62%.
Memória média dos pods: 71%.
Conexões ativas ao Ledger: 240/250 (limite do RDS).

Action:
Execute a análise nesta ordem e mostre o raciocínio:
1. Construa a timeline do incidente correlacionando o horário do deploy (ontem 18:42)
   com o início da degradação nas métricas (hoje). Identifique o momento exato em que
   p99 e err_rate começam a sair do baseline.
2. Correlacione cada mudança do changelog com os sintomas observados. Avalie
   especificamente:
   - O impacto da redução de timeout do Ledger de 5s para 2s
   - O impacto da nova biblioteca de pool de conexões (e o limite max=20 por pod)
   - Se o bump de psycopg (3.1.18 -> 3.2.0) pode estar envolvido
3. Faça a aritmética de conexões: relacione o número de pods (12), o pool máximo por
   pod (max=20 visto no log) e as conexões ativas no RDS (240/250). Verifique se há
   uma relação matemática que explique o esgotamento.
4. Determine a causa raiz mais provável e classifique seu nível de confiança
   (alto / médio / baixo) com base na evidência disponível.
5. Avalie as duas opções de remediação contra a causa raiz:
   - Para cada opção, responda: resolve a causa raiz ou apenas o sintoma?
   - Qual o risco de cada opção? Qual o tempo estimado para efeito?
   - Há efeito colateral sobre a fila do Reactor (50k mensagens, lag 18min)?
6. Emita uma recomendação única e inequívoca (A ou B), com a justificativa em uma frase.

Goal:
Doc Brown (CTO) está na call de incidente e tem 20 minutos para decidir entre rollback
e scaling antes que o consumer lag do Reactor ultrapasse o limite de SLA. O postmortem
precisa ser técnico, conciso e terminar com uma recomendação acionável — não um relatório
exaustivo. Doc precisa conseguir ler, entender a causa raiz e tomar a decisão em menos de
5 minutos de leitura.

Formato de saída (Markdown):

## TL;DR
(2-3 linhas: causa raiz provável + recomendação A ou B + nível de confiança)

## Timeline do incidente
(tabela ou lista correlacionando deploy → degradação → colapso)

## Análise de causa raiz
(correlação changelog ↔ sintomas; inclua a aritmética de conexões)

## Avaliação das opções
| Opção | Resolve causa raiz? | Risco | Tempo p/ efeito | Efeito na fila Reactor |
(uma linha para A, uma para B)

## Recomendação
(decisão única A ou B + 1 frase de justificativa + próximos passos imediatos)

## Follow-up pós-incidente
(2-3 itens de ação para evitar recorrência, a tratar depois do incidente)
```
