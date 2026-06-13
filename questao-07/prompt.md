# Questão 07 — Prompt

## Prompt utilizado

```
Role:
Você é um engenheiro SRE sênior da Hill Valley Tech, responsável por documentar
procedimentos operacionais para equipes de plantão. Você conhece profundamente o
ambiente Kubernetes/EKS da empresa, tem experiência em resposta a incidentes e sabe
escrever runbooks que qualquer plantonista — inclusive quem nunca trabalhou com o
sistema — consiga seguir sem travar. Seu estilo de documentação é direto: cada passo
tem um comando concreto para rodar, uma verificação esperada para confirmar que o
passo funcionou, e um critério claro para decidir o que fazer a seguir.

Input:
Alerta recorrente que dispara em produção em média 4 vezes por semana:

  [CRITICAL] High memory usage on Chronos API pods (>85% for 10min)

Ambiente onde o runbook vai ser executado:
- Serviço: Chronos API (API gateway principal da empresa)
- Plataforma: AWS EKS, namespace production
- Réplicas: 6 ativas, HPA configurado (min 4, max 12, target CPU 70%)
- Deploy: Argo CD, repositório hvt/chronos-api
- Dependências diretas: Ledger (PostgreSQL) e Reactor (filas SQS)
- Observabilidade: métricas em /metrics, logs centralizados no Beacon,
  dashboards no Grafana
- Ferramentas disponíveis no plantão: kubectl, aws cli, argocd cli
- Canal de comunicação: #oncall-chronos no Slack
- Escalação para time sênior: @chronos-core
  (SLA: 15 min em horário comercial, 30 min fora)

Steps:
Estruture o runbook em seções sequenciais obrigatórias:

1. Metadados do runbook
   - Título, serviço afetado, alerta gatilho, severidade, última revisão

2. Contexto rápido (máximo 5 linhas)
   - O que é o Chronos, por que esse alerta importa, impacto típico no negócio

3. Diagnóstico inicial (passos 1–4, executar nesta ordem)
   Cada passo deve conter:
   - Objetivo do passo em uma linha
   - Comando exato para rodar (com namespace, labels e flags corretos)
   - Saída esperada / o que procurar na saída
   - Decisão: o que fazer se a saída indicar problema vs se estiver normal

   Passos esperados:
   - P1: Verificar estado dos pods e consumo de memória atual
   - P2: Inspecionar logs recentes dos pods com maior consumo
   - P3: Verificar se o HPA já atuou ou está travado
   - P4: Checar se as dependências (Ledger e Reactor) estão respondendo

4. Ações de mitigação imediata (executar se diagnóstico confirmar problema)
   - M1: Forçar rollout restart dos pods para liberar memória temporariamente
   - M2: Escalar manualmente o número de réplicas se o HPA não estiver agindo
   - M3: Verificar e ajustar memory limits se claramente subdimensionados

5. Critérios de escalação para @chronos-core
   - Liste pelo menos 3 condições objetivas e mensuráveis que obrigam escalar
   - Inclua o template de mensagem para postar no #oncall-chronos ao escalar

6. Critério de encerramento do incidente
   - Condição objetiva para considerar o incidente resolvido
   - Ação de follow-up obrigatória (ex: abrir ticket, atualizar postmortem)

Expectation:
O runbook será usado por qualquer plantonista da Hill Valley Tech, inclusive quem
está no primeiro mês de empresa e nunca tocou no Chronos. O documento precisa:
- Ser autocontido: todos os comandos incluem namespace, context e flags necessários
  para rodar sem consultar documentação adicional
- Ter zero ambiguidade nos critérios de decisão: cada passo termina com "se X → faça Y,
  se Z → faça W" — nunca com "avalie o contexto"
- Reduzir o tempo médio de resolução de 30–40 minutos para menos de 15 minutos
- Ser formatado em Markdown com cabeçalhos, blocos de código e tabelas onde aplicável,
  pronto para publicar em Confluence ou Notion
```
