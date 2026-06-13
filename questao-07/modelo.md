# Questão 07 — Modelo

## Modelo utilizado

- **Modelo:** Claude (Anthropic)
- **Versão:** claude-sonnet-4-6

## Justificativa da escolha

Runbooks operacionais exigem um tipo específico de qualidade: precisão técnica nos
comandos, lógica de decisão sem ambiguidade e linguagem direta para operadores sob
pressão. O `claude-sonnet-4-6` foi escolhido porque:

1. **Comandos kubectl/AWS CLI corretos e completos**: o modelo produz comandos com
   flags, namespaces e labels corretos na primeira tentativa — `kubectl top pods -n
   production -l app=chronos-api --sort-by=memory`, `kubectl rollout status ...
   --timeout=5m` — sem precisar de correção manual antes de usar em produção.

2. **Estrutura de decisão binária**: o Expectation do prompt exige "se X → faça Y,
   se Z → faça W" sem "avalie o contexto". O modelo entende e implementa essa
   lógica de árvore de decisão em cada passo, o que é crítico para um runbook
   seguido por plantonistas sob pressão às 3h da manhã.

3. **Conhecimento do ecossistema SRE**: o modelo conhece a interação entre HPA
   baseado em CPU e alertas de memória (o HPA não resolve um problema de memória
   se o target é CPU), a diferença entre `kubectl edit` em produção vs mudança
   via GitOps/Argo CD, e o impacto de `maxUnavailable: 0` no rollout restart —
   detalhes operacionais que um modelo sem conhecimento de SRE erraria.

4. **Tom adequado para documentação de plantão**: linguagem imperativa, direta,
   sem jargão desnecessário. O modelo calibra o tom quando o Role especifica
   "qualquer plantonista, inclusive quem está no primeiro mês de empresa".
