# Questão 05 — Modelo

## Modelo utilizado

- **Modelo:** Claude (Anthropic)
- **Versão:** claude-sonnet-4-6

## Justificativa da escolha

A tarefa é transformação de um artefato existente (manifest YAML legado) em uma versão
modernizada com especificações precisas. O `claude-sonnet-4-6` foi escolhido porque:

1. **Precisão em YAML**: o modelo produz YAML sintaticamente válido com indentação
   correta — crítico aqui porque um único espaço errado em securityContext ou em
   resources invalida o manifest inteiro na aplicação via `kubectl apply`.

2. **Conhecimento de Kubernetes production-grade**: o modelo conhece a semântica
   de `maxUnavailable: 0` + `maxSurge: 1` para zero-downtime deploy, a diferença
   entre securityContext no nível do pod vs container, e o `seccompProfile:
   RuntimeDefault` do PodSecurityStandards — sem precisar de referência externa.

3. **Consciência de segurança em manifests**: ao ver `value: "P@ssw0rd2023!"`, o
   modelo reconhece o padrão de segredo hardcoded e aplica `secretKeyRef`
   corretamente, além de gerar o Secret separado com aviso sobre valores placeholder.
   Não é necessário instruir explicitamente "não coloque o valor real no Secret de
   exemplo" — o modelo já o faz por padrão.

4. **Fidelidade ao artefato de entrada**: o modelo preserva campos existentes válidos
   (`name`, `namespace`, `selector`, `containerPort`) e acrescenta apenas o que foi
   especificado no After — sem inventar campos não pedidos.
