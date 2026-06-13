# Questão 03 — Modelo

## Modelo utilizado

- **Modelo:** Claude (Anthropic)
- **Versão:** claude-sonnet-4-6

## Justificativa da escolha

Esta questão envolve raciocínio quantitativo (calcular percentuais, somar economias,
verificar se meta é atingível), conhecimento de domínio AWS (faixas de desconto reais de
Savings Plans, Reserved Instances, S3 Intelligent-Tiering) e produção de output executivo
estruturado. O `claude-sonnet-4-6` foi escolhido porque:

1. **Raciocínio aritmético confiável em escala de prompt**: a Action exige somar o CSV,
   calcular percentuais e verificar se a soma das economias atinge a meta — operações
   simples mas que modelos menores frequentemente erram quando combinadas com geração
   de texto longa.

2. **Conhecimento atualizado de precificação AWS**: o modelo conhece as faixas de desconto
   reais (Compute Savings Plans até 66%, RIs multi-AZ ~38%, S3 Intelligent-Tiering ~40%
   para dados frios) sem precisar de retrieval externo para uma análise de ordem de grandeza.

3. **Capacidade de produzir output executivo**: o relatório é destinado à diretoria (Goldie,
   CEO), o que exige linguagem direta, tabelas limpas e um sumário que responde à pergunta
   "atingimos a meta?" na primeira leitura. O modelo calibra o tom sem instrução adicional
   quando o contexto do destinatário está explícito no Goal.

4. **Custo-benefício**: a análise é de uma única iteração com dados estáticos. Não há
   necessidade de tool use, web search ou raciocínio estendido — o Sonnet entrega a
   relação qualidade/custo ideal para esse perfil.
