# Questão 03 — Prompt

## Prompt utilizado

```
Task:
Analise o CSV de custos AWS abaixo e identifique oportunidades concretas de redução de
gastos cloud. Para cada oportunidade, calcule a economia estimada em dólares e em
percentual sobre a conta total, classifique o esforço de implementação e liste os riscos
ou pré-requisitos envolvidos.

Dados de entrada (custo AWS — último mês):

servico,categoria,custo_mensal_usd,uso_medio_pct,observacao
EC2 reservada,compute,4200,72,contrato de 1 ano
EC2 on-demand,compute,8200,45,workloads variaveis
EKS,compute,6700,58,3 clusters
RDS PostgreSQL,databases,8200,62,multi-AZ
ElastiCache Redis,databases,2100,40,cluster de producao
S3 Standard,storage,3100,,5 buckets principais
EBS gp3,storage,1600,68,volumes de producao
CloudWatch Logs,observability,2800,,retencao de 90 dias
CloudWatch Metrics,observability,900,,
Data Transfer Out,network,1900,,trafego entre regioes
NAT Gateway,network,1200,,3 gateways ativos
Lambda,compute,900,30,~12M invocacoes/mes

Total da conta: $41.800/mês

Action:
1. Some os custos do CSV e confirme o total ($41.800).
2. Para cada serviço ou categoria, aplique seu conhecimento de otimização de custos AWS
   e identifique a oportunidade mais relevante (ex: Savings Plans, rightsizing, mudança
   de classe de armazenamento, ajuste de retenção, Spot Instances, consolidação).
3. Estime a economia mensal realista de cada oportunidade em USD, usando as faixas de
   desconto conhecidas do AWS (ex: Compute Savings Plans oferecem até 66% sobre on-demand;
   S3 Intelligent-Tiering elimina custo de objetos inativos; redução de retenção de logs
   é linear).
4. Priorize as oportunidades em ordem decrescente de impacto financeiro.
5. Para cada oportunidade, classifique o esforço de implementação como Baixo, Médio ou
   Alto, usando o seguinte critério:
   - Baixo: configuração em console/CLI sem mudança de arquitetura ou código
   - Médio: requer análise de workload, testes ou aprovação de mudança
   - Alto: requer refatoração, migração ou mudança de contrato
6. Liste os riscos operacionais ou pré-requisitos técnicos de cada oportunidade.
7. Ao final, some as economias estimadas e verifique se a meta de 15% ($6.270/mês) é
   atingível somente com as oportunidades de esforço Baixo e Médio.

Goal:
O relatório final será apresentado por Goldie Wilson, CEO, à diretoria da Hill Valley Tech
para aprovar o plano de redução de 15% no custo cloud sem degradar SLA. O relatório precisa
ser executivo, direto e baseado em números, para que a diretoria aprove as ações de maior
impacto e esforço compatível.

Estrutura obrigatória do relatório:

## Sumário executivo
(3-4 linhas: conta total, meta, economia total estimada com oportunidades identificadas,
veredicto sobre viabilidade da meta)

## Oportunidades de economia — priorizadas

| # | Serviço / Área | Ação recomendada | Economia est. (USD/mês) | % da conta | Esforço | Riscos / Pré-requisitos |
|---|----------------|------------------|------------------------|------------|---------|------------------------|
(linhas ordenadas por economia estimada decrescente)

## Subtotal por nível de esforço
(tabela com colunas: Esforço | Qtd. ações | Economia est. (USD/mês) | % da conta)

## Conclusão
(2-3 linhas: se a meta é atingível só com ações Baixo+Médio, quais ações priorizar no
primeiro mês e qual seria a economia no trimestre se executadas)
```
