# Output gerado pelo modelo para a Questão 08
# Modelo: claude-sonnet-4-6  |  Data: 2026-06-13

---

# Postmortem técnico — Chronos API: degradação durante pico (2026-04-24)

## TL;DR

**Causa raiz provável (confiança ALTA):** o deploy **v2.48.0** reduziu o timeout do Ledger
de 5s para 2s e introduziu nova biblioteca de pool com `max=20` conexões por pod. Sob pico
de tráfego, 12 pods × 20 conexões = **240 conexões**, esgotando o limite do RDS (240/250).
O timeout agressivo de 2s transforma queries lentas em falhas, abrindo o circuit breaker e
cascateando para o Reactor.
**Recomendação: OPÇÃO A — Rollback do v2.48.0.** O scaling (B) trata o sintoma mas mantém o
timeout de 2s, que continuará gerando falhas sob carga.

---

## Timeline do incidente

| Horário (UTC) | Evento | Sinal |
|---------------|--------|-------|
| 2026-04-23 18:42 | Deploy v2.47.0 → v2.48.0 (Argo CD sync) | Mudança latente; sem carga de pico ontem à noite |
| 2026-04-24 13:30 | Baseline normal | p99 420ms, err 0.2% |
| 2026-04-24 13:45 | Tráfego subindo, ainda saudável | p99 510ms, err 0.3% |
| 2026-04-24 14:00 | **Início da degradação** | p99 780ms (+53%), err 1.1% (3x baseline) |
| 2026-04-24 14:10 | Degradação acelera | p99 2400ms, err 4.5% |
| 2026-04-24 14:15 | Colapso em curso | p99 5200ms, err 8.2% |
| 2026-04-24 14:20 | Estado crítico atual | p99 8100ms (19x baseline), err 11.7% |

A degradação **não** começou no momento do deploy (18:42 de ontem), mas quando o tráfego
de pico de hoje (req_rate subindo de 1200 para 2650/s) expôs o gargalo de conexões
introduzido pelo deploy. Clássico de bug latente que só aparece sob carga.

---

## Análise de causa raiz

**Correlação changelog ↔ sintomas:**

| Mudança no v2.48.0 | Impacto observado | Evidência |
|--------------------|-------------------|-----------|
| Timeout Ledger 5s → 2s | Queries que antes completavam em 2–4s agora falham | Log: `query timeout after 2000ms` |
| Nova lib de pool (max=20/pod) | Pool esgota sob carga, requests enfileiram | Log: `connection pool exhausted (max=20, active=20, waiting=147)` |
| psycopg 3.1.18 → 3.2.0 | Não há evidência direta de envolvimento | Sem erro específico de driver nos logs |
| Endpoint POST /v2/transactions/batch | Endpoint que falha sob a cadeia de erros | Log: `POST /v2/transactions/batch failed: context deadline exceeded` |

**Aritmética de conexões (a evidência mais forte):**

```
12 pods (HPA no máximo) × 20 conexões/pool (max do log) = 240 conexões
Conexões ativas observadas no RDS                       = 240 / 250
```

A correspondência exata (240 = 12 × 20) indica que **cada pod está saturando seu pool ao
máximo simultaneamente**. O limite do RDS (250) está a 10 conexões de ser atingido — o
sistema está no limite teórico de conexões que a configuração atual permite.

**Cadeia causal reconstruída a partir do log:**

```
Pool exhausted (waiting=147)
  → query timeout 2000ms  (timeout agressivo do deploy)
    → context deadline exceeded  (request abortado)
      → connection reset by peer
        → circuit breaker OPEN em 87%  (acima do threshold 50%)
          → Reactor falha em publicar  (cascata para fila)
```

**Por que NÃO é problema de compute:** CPU 62% e memória 71% estão dentro do normal. O
gargalo é I/O de conexões com o Ledger, não recursos do pod. Por isso o HPA (que escala
por CPU) chegou ao máximo de 12 pods sem resolver — e, pior, **mais pods = mais conexões =
agravamento do esgotamento do RDS.**

**Causa raiz (confiança ALTA):** a combinação de timeout reduzido (2s) + nova lib de pool
limitada a 20 conexões/pod, exposta pelo tráfego de pico, é a causa raiz. A evidência
aritmética (240 = 12×20) e a cadeia de log consistente sustentam o nível de confiança alto.

---

## Avaliação das opções

| Opção | Resolve causa raiz? | Risco | Tempo p/ efeito | Efeito na fila Reactor |
|-------|---------------------|-------|-----------------|------------------------|
| **A — Rollback v2.48.0** | **Sim** — restaura timeout 5s e pool anterior, eliminando ambos os gatilhos | Baixo — v2.47.0 é versão estável conhecida; rollback via Argo CD é rápido e reversível | ~3–5 min (sync Argo CD + rollout) | Para de crescer assim que o circuit breaker fechar; lag começa a drenar |
| **B — Scaling RDS + pool** | **Não** — aumenta o teto de conexões mas mantém timeout 2s, que continua falhando queries lentas sob pico | Médio/Alto — aumentar pool com timeout 2s pode gerar MAIS conexões falhando; mudança de limit do RDS pode exigir restart/failover | ~10–15 min (mudança de parameter group, possível reboot do RDS) | Risco de prolongar o incidente; lag continua crescendo durante a janela |

---

## Recomendação

**OPÇÃO A — Rollback imediato do v2.48.0 para v2.47.0 via Argo CD.**

> O rollback é a única opção que remove a causa raiz (timeout 2s + pool max=20) em vez de
> mascará-la; o scaling aumentaria o teto de conexões mas manteria o timeout agressivo que
> está convertendo queries lentas em falhas em cascata.

**Próximos passos imediatos (ordem de execução):**
1. `argocd app rollback chronos-api <revision-v2.47.0>` — reverter o deploy
2. Acompanhar `circuit-breaker` fechar e p99 cair via dashboard do Grafana
3. Confirmar conexões do RDS recuando abaixo de 240 conforme o pool antigo (timeout 5s) volta
4. Monitorar o consumer lag do Reactor começar a drenar (deve reverter a tendência em ~5 min)

---

## Follow-up pós-incidente

1. **Revisar a mudança de timeout em PR separado**: a redução de 5s → 2s deve ser validada
   sob carga em staging antes de reaplicar; provavelmente foi a mudança mais danosa do deploy.
2. **Tornar o pool de conexões configurável e dimensioná-lo contra o limite do RDS**: com
   HPA até 12 pods, `12 × pool_max` precisa ficar com folga abaixo de 250 (ex: pool_max=18
   → 216 conexões, deixando margem).
3. **Adicionar alerta proativo de conexões do RDS** (ex: > 80% do limite) no Beacon, para
   detectar saturação de conexões antes que o circuit breaker abra.
4. **Desacoplar o batch endpoint do caminho síncrono**: o POST /v2/transactions/batch
   pode estar amplificando o consumo de conexões; avaliar processamento assíncrono via Reactor.
