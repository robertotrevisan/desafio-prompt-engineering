# Output gerado pelo modelo para a Questão 07
# Modelo: claude-sonnet-4-6  |  Data: 2026-06-13

---

# Runbook: High Memory Usage — Chronos API Pods

---

## 1. Metadados

| Campo | Valor |
|-------|-------|
| **Título** | High Memory Usage on Chronos API Pods |
| **Serviço afetado** | Chronos API (API gateway principal) |
| **Alerta gatilho** | `[CRITICAL] High memory usage on Chronos API pods (>85% for 10min)` |
| **Severidade** | Critical |
| **Namespace** | `production` |
| **Última revisão** | 2026-06-13 |
| **Canal de plantão** | `#oncall-chronos` no Slack |
| **Escalação** | `@chronos-core` (15 min comercial / 30 min fora do horário) |

---

## 2. Contexto rápido

O **Chronos** é o API gateway da Hill Valley Tech — todo tráfego externo e interno passa
por ele. Uso de memória acima de 85% por mais de 10 minutos indica pressão de heap
sustentada, que tipicamente precede OOMKill dos pods. Um OOMKill reinicia o pod, gera
latência elevada para os clientes durante a drenagem, e pode cascatear se múltiplos pods
reiniciarem em sequência. O HPA está configurado para escalar por CPU (não memória), então
o alerta pode ocorrer mesmo sem escalonamento automático.

---

## 3. Diagnóstico inicial

> **Antes de começar:** confirme no `#oncall-chronos` que você assumiu o alerta.
> ```
> [assumindo] High memory usage Chronos - iniciando diagnóstico - @<seu-nome>
> ```

---

### P1 — Verificar estado dos pods e consumo de memória atual

**Objetivo:** confirmar quais pods estão com alta memória e se algum já foi OOMKilled.

```bash
kubectl top pods -n production -l app=chronos-api --sort-by=memory
```

```bash
kubectl get pods -n production -l app=chronos-api -o wide
```

**O que procurar na saída:**
- Coluna `MEMORY` acima de 85% do limit configurado (`512Mi` = ~435 Mi)
- Coluna `RESTARTS` > 0 indica OOMKill recente
- Status diferente de `Running` (ex: `OOMKilled`, `CrashLoopBackOff`)

**Decisão:**
- Se ≥ 2 pods com memória > 85% → **avançar para P2 imediatamente**
- Se 1 pod isolado com memória alta + `RESTARTS` = 0 → monitorar por 5 min; se não piorar, avançar para P4
- Se algum pod em `OOMKilled` ou `CrashLoopBackOff` → **avançar para P2 e paralelamente executar M1**

---

### P2 — Inspecionar logs recentes dos pods com maior consumo

**Objetivo:** identificar padrão de erro ou spike de tráfego que explique o aumento de memória.

```bash
# Substitua <pod-name> pelo nome do pod com maior consumo identificado no P1
kubectl logs <pod-name> -n production --tail=200 --timestamps | grep -iE "error|warn|oom|memory|heap|leak"
```

```bash
# Verificar eventos do pod (OOMKill, throttling, etc.)
kubectl describe pod <pod-name> -n production | grep -A 10 "Events:"
```

**O que procurar na saída:**
- Erros repetitivos de um mesmo endpoint ou operação (indica loop ou leak pontual)
- `OOMKilled` na seção Events confirma que o container foi reiniciado por falta de memória
- Spike de requisições (`INFO` logs com alta frequência num curto período)
- Erros de conexão com Ledger ou Reactor (pode causar acúmulo de goroutines/threads em espera)

**Decisão:**
- Se logs mostram erros de conexão com Ledger ou Reactor → **executar P4 antes das mitigações**
- Se logs mostram spike de tráfego → **executar M2 (escalar réplicas)**
- Se logs mostram erros repetitivos de um único endpoint → **escalar para @chronos-core com contexto**
- Se logs estão limpos (sem erros) → **avançar para P3**

---

### P3 — Verificar se o HPA já atuou ou está travado

**Objetivo:** confirmar se o escalonamento automático está funcionando e quantas réplicas estão ativas.

```bash
kubectl get hpa -n production chronos-api
```

```bash
kubectl describe hpa -n production chronos-api
```

**O que procurar na saída:**
- Campo `REPLICAS`: se igual ao máximo (`12`) e memória ainda alta → HPA não resolve (target é CPU)
- Campo `TARGETS`: CPU atual vs target 70% — se CPU < 70% mas memória alta, HPA não vai escalar
- Coluna `CONDITIONS` no `describe`: `ScalingLimited` ou `AbleToScale: False` indica HPA travado
- Eventos de `FailedGetScale` ou `DesiredReplicas` não sendo atingido indica problema no HPA

**Decisão:**
- Se HPA está no máximo (12 réplicas) e memória ainda > 85% → **executar M3 e escalar para @chronos-core**
- Se HPA não atuou e CPU < 70% → problema é específico de memória; **executar M1 e M2 manualmente**
- Se HPA travado (`AbleToScale: False`) → **escalar para @chronos-core imediatamente**
- Se HPA funcionando normalmente e réplicas subindo → **aguardar 5 min e remonitorar com P1**

---

### P4 — Checar se as dependências estão respondendo

**Objetivo:** descartar que Ledger (PostgreSQL) ou Reactor (SQS) estejam causando acúmulo de
conexões ou threads em espera nos pods do Chronos.

```bash
# Verificar endpoints do Ledger a partir de um pod do Chronos
kubectl exec -n production -it $(kubectl get pod -n production -l app=chronos-api -o jsonpath='{.items[0].metadata.name}') -- \
  sh -c "nc -zv ledger-db.internal.hvt.io 5432 && echo 'Ledger OK' || echo 'Ledger UNREACHABLE'"
```

```bash
# Verificar filas SQS via AWS CLI (substitua a região se necessário)
aws sqs get-queue-attributes \
  --queue-url https://sqs.us-east-1.amazonaws.com/<account-id>/reactor-main \
  --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible \
  --region us-east-1
```

**O que procurar na saída:**
- `Ledger UNREACHABLE` → dependência crítica offline; **escalar para @chronos-core imediatamente**
- `ApproximateNumberOfMessagesNotVisible` muito alto (> 10.000) → Reactor com fila represada,
  Chronos pode estar tentando reconectar em loop
- Ambos respondendo normalmente → problema é interno ao Chronos; **avançar para mitigações**

**Decisão:**
- Se Ledger inacessível → postar no `#oncall-chronos` + **escalar para @chronos-core**
- Se fila SQS represada → verificar se há consumidores do Reactor ativos; postar no `#oncall-chronos`
- Se ambas as dependências OK → **executar M1**

---

## 4. Ações de mitigação imediata

> Executar somente após diagnóstico confirmar que o problema é nos pods do Chronos
> (não nas dependências).

---

### M1 — Rollout restart para liberar memória (mitigação temporária)

**Quando usar:** pods com memória > 85% sem causa externa identificada; OOMKill iminente.

```bash
kubectl rollout restart deployment/chronos-api -n production
```

```bash
# Acompanhar o rollout (aguardar até completion)
kubectl rollout status deployment/chronos-api -n production --timeout=5m
```

**Verificação esperada:**
```
Waiting for deployment "chronos-api" rollout to finish: 1 out of 6 new replicas have been updated...
...
deployment "chronos-api" successfully rolled out
```

**Atenção:** o rollout restart com `maxUnavailable: 0` não gera downtime, mas pode
aumentar temporariamente a carga nos pods remanescentes. Monitore com `kubectl top pods`
durante o processo.

**Após M1:** reexecutar P1. Se memória voltar abaixo de 60% → mitigação efetiva;
**abrir ticket para investigação da causa raiz**. Se memória retornar a > 85% em menos
de 30 minutos → **escalar para @chronos-core**.

---

### M2 — Escalar réplicas manualmente

**Quando usar:** HPA não está atuando e memória alta em múltiplos pods simultaneamente.

```bash
# Escalar para 10 réplicas (2 abaixo do máximo, preserva margem para o HPA)
kubectl scale deployment/chronos-api -n production --replicas=10
```

```bash
# Confirmar que os novos pods subiram saudáveis
kubectl get pods -n production -l app=chronos-api -w
```

**Verificação esperada:** novos pods em `Running` com `READY 1/1` em até 2 minutos.

**Após M2:** monitorar por 10 minutos. Se o alerta cessar → mitigação efetiva;
**abrir ticket para revisar configuração do HPA (target de memória ausente)**.

---

### M3 — Verificar e ajustar memory limits

**Quando usar:** M1 e M2 aplicados e memória retorna ao threshold em menos de 30 minutos;
indicativo de subdimensionamento de recursos.

```bash
# Verificar limits atuais
kubectl get deployment chronos-api -n production -o jsonpath='{.spec.template.spec.containers[0].resources}'
```

**Atenção:** ajuste de limits requer mudança no repositório `hvt/chronos-api` via Argo CD
— **não fazer `kubectl edit` diretamente em produção** (será sobrescrito no próximo sync).

```bash
# Verificar status de sync do Argo CD
argocd app get chronos-api --server argocd.internal.hvt.io
```

Se os limits estiverem claramente subdimensionados (ex: `memory: 512Mi` com uso médio de
480 Mi), postar no `#oncall-chronos` e **escalar para @chronos-core** para aprovação da
mudança — não alterar sem aprovação do time sênior.

---

## 5. Critérios de escalação para @chronos-core

Escale **imediatamente** se qualquer uma das condições abaixo for verdadeira:

| # | Condição | Como identificar |
|---|----------|-----------------|
| 1 | ≥ 3 pods com status `OOMKilled` ou `CrashLoopBackOff` simultaneamente | `kubectl get pods -n production -l app=chronos-api` — coluna STATUS |
| 2 | Alerta retorna dentro de 30 min após M1 (rollout restart) | Memória > 85% novamente em `kubectl top pods` |
| 3 | HPA em estado `AbleToScale: False` ou travado no máximo (12 réplicas) com memória ainda alta | `kubectl describe hpa -n production chronos-api` |
| 4 | Ledger ou Reactor inacessíveis a partir dos pods do Chronos | Resultado de P4 |
| 5 | Tempo total de diagnóstico + mitigação ultrapassando 20 minutos sem resolução | Relógio |

**Template de mensagem para `#oncall-chronos`:**

```
🔴 [ESCALAÇÃO] High memory usage Chronos — @chronos-core

**Alerta:** [CRITICAL] High memory usage on Chronos API pods (>85% for 10min)
**Horário do alerta:** <HH:MM UTC>
**Situação atual:** <descreva: ex. "4 pods acima de 85%, 1 OOMKilled, restart realizado sem melhora">
**Passos executados:** <liste: P1, P2, M1, etc.>
**Logs relevantes:** <cole o trecho mais significativo ou link para o Beacon>
**Dependências:** Ledger <OK/UNREACHABLE>, Reactor <OK/REPRESADO>
**Plantão:** @<seu-nome>
```

---

## 6. Critério de encerramento do incidente

**Condição objetiva para encerrar:**
Todos os pods do Chronos com memória abaixo de **70%** por pelo menos **15 minutos
consecutivos**, confirmado por:

```bash
kubectl top pods -n production -l app=chronos-api --sort-by=memory
```

**E** sem novos disparos do alerta `[CRITICAL] High memory usage` no Beacon nos últimos
15 minutos.

**Ação de follow-up obrigatória (independente de como foi resolvido):**

1. Postar encerramento no `#oncall-chronos`:
   ```
   ✅ [RESOLVIDO] High memory usage Chronos
   Duração: <HH:MM> → <HH:MM> (<X min>)
   Causa identificada: <descreva ou "a investigar">
   Ação tomada: <M1 / M2 / escalação>
   Ticket aberto: <link ou "pendente">
   ```

2. Abrir ticket no sistema de rastreamento com:
   - Timestamp do alerta e do encerramento
   - Passos executados e resultados
   - Causa raiz identificada (ou "investigação pendente")
   - Proposta de ação corretiva para evitar recorrência
