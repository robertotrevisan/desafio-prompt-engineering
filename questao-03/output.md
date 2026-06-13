# Output gerado pelo modelo para a Questão 03
# Modelo: claude-sonnet-4-6  |  Data: 2026-06-13

---

## Sumário executivo

A conta AWS da Hill Valley Tech totalizou **$41.800 em maio**, com compute (EKS + EC2) e databases (RDS + ElastiCache) respondendo por 74% do gasto. A meta trimestral de **15% de redução equivale a $6.270/mês**. A análise identificou **9 oportunidades concretas**, com economia estimada combinada de **$9.460–$10.820/mês** (22,6–25,9% da conta). Apenas com ações de esforço **Baixo e Médio**, a economia potencial é de **$7.310–$8.370/mês** — **suficiente para superar a meta de 15%** sem alterações de arquitetura ou contratos em andamento.

---

## Oportunidades de economia — priorizadas

| # | Serviço / Área | Ação recomendada | Economia est. (USD/mês) | % da conta | Esforço | Riscos / Pré-requisitos |
|---|----------------|------------------|------------------------|------------|---------|------------------------|
| 1 | EC2 on-demand ($8.200, uso 45%) | Contratar **Compute Savings Plan de 1 ano** cobrindo 70% do gasto on-demand (faixa conservadora de 40% de desconto sobre a parcela coberta) | $2.300 | 5,5% | Médio | Requer análise de baseline de uso; compromisso financeiro de 1 ano; não cobre workloads spot |
| 2 | EKS ($6.700, uso 58%) | **Rightsizing dos node groups** + habilitar **Karpenter/Cluster Autoscaler** com scale-down noturno; consolidar de 3 para 2 clusters se workloads permitirem | $1.500–$2.000 | 3,6–4,8% | Médio | Requer análise de carga por cluster; risco de degradação se sizing for excessivamente agressivo; validar PodDisruptionBudgets |
| 3 | RDS PostgreSQL ($8.200, uso 62%) | Contratar **Reserved Instances de 1 ano (multi-AZ)** para a instância principal; desconto médio de 38% sobre on-demand | $1.560 | 3,7% | Médio | Compromisso financeiro de 1 ano; avaliar se o tipo de instância atual está correto antes de reservar |
| 4 | CloudWatch Logs ($2.800, retenção 90 dias) | Reduzir retenção de **90 para 30 dias** em grupos de log que não têm exigência regulatória; arquivar logs frios no S3 com lifecycle policy | $1.120 | 2,7% | Baixo | Validar com Strickland (compliance) quais grupos têm exigência de retenção regulatória; exportar antes de truncar |
| 5 | ElastiCache Redis ($2.100, uso 40%) | **Rightsizing** para tipo de instância menor (ex: de r6g.large para r6g.medium) + avaliar Reserved Nodes de 1 ano | $630–$840 | 1,5–2,0% | Médio | Testar em staging; risco de degradação de latência em picos se sizing for muito agressivo |
| 6 | S3 Standard ($3.100, uso não informado) | Habilitar **S3 Intelligent-Tiering** nos 5 buckets; objetos não acessados há 30 dias migram automaticamente para camada de baixo custo (~40% mais barata) | $620–$930 | 1,5–2,2% | Baixo | Custo de monitoramento por objeto ($0,0025/1k objetos); viável se os buckets tiverem >10k objetos |
| 7 | NAT Gateway ($1.200, 3 gateways) | Avaliar consolidação de **3 NAT Gateways para 1** (ou usar VPC Endpoints para tráfego S3/DynamoDB, eliminando custo de NAT para esses destinos) | $360–$600 | 0,9–1,4% | Médio | Consolidação aumenta blast radius em falha de AZ; VPC Endpoints são mais seguros; requer mapeamento de fluxos de rede |
| 8 | Data Transfer Out ($1.900, inter-região) | Revisar tráfego inter-regiões e **mover dados para a mesma região** onde são consumidos; usar CloudFront para tráfego externo recorrente | $380–$570 | 0,9–1,4% | Alto | Requer mapeamento e refatoração de fluxos; risco de latência se dados forem movidos sem análise de localidade |
| 9 | Lambda ($900, uso 30%, ~12M invocações) | Ajustar **memória alocada por função** (Lambda cobra por GB-segundo); funções superalocadas com uso 30% têm potencial de redução de 20–30% no custo | $90–$180 | 0,2–0,4% | Baixo | Usar Lambda Power Tuning para validar cada função antes de reduzir; risco de timeout em funções com picos |

---

## Subtotal por nível de esforço

| Esforço | Qtd. ações | Economia est. (USD/mês) | % da conta |
|---------|-----------|------------------------|------------|
| Baixo   | 3         | $1.830–$2.210          | 4,4–5,3%   |
| Médio   | 5         | $5.480–$6.160          | 13,1–14,7% |
| **Baixo + Médio** | **8** | **$7.310–$8.370** | **17,5–20,0%** |
| Alto    | 1         | $380–$570              | 0,9–1,4%   |
| **Total geral** | **9** | **$9.460–$10.820** | **22,6–25,9%** |

---

## Conclusão

A meta de 15% ($6.270/mês) é **atingível somente com ações de esforço Baixo e Médio**, sem necessidade das ações de Alto esforço (refatoração de fluxos inter-região). Para o **primeiro mês**, as três ações de maior retorno imediato são: (1) contratação do Compute Savings Plan para EC2 on-demand, (2) redução de retenção do CloudWatch Logs após validação com compliance, e (3) habilitação do S3 Intelligent-Tiering — juntas somam **$4.040–$5.330/mês** com esforço Baixo a Médio. Se todas as ações Baixo+Médio forem executadas ao longo do trimestre, a economia acumulada será de **$65.790–$75.330 em três meses**, superando a meta trimestral com margem de segurança.
