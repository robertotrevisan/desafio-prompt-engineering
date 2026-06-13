# Bônus — Tema 2: Os 5 frameworks de prompt engineering aplicados a Cloud, DevOps e SRE

> Formato: thread no X / artigo longo no LinkedIn (8 posts)
> Exemplos genéricos da área (não os do desafio)

---

## Post 1 — Abertura

A maioria dos engenheiros de Cloud/DevOps usa IA como um Google melhorado.

Quem extrai 10x mais valor usa **frameworks de prompt**.

5 frameworks, 5 casos de uso de infra. Quando usar cada um 🧵👇

---

## Post 2 — R-T-F (Role · Task · Format)

**Quando usar:** gerar um artefato do zero, quando a persona técnica importa.

> **Role:** Você é um engenheiro de plataforma sênior especialista em Kubernetes.
> **Task:** Escreva um HorizontalPodAutoscaler para um serviço web com target de CPU 60%, min 3 e max 15 réplicas.
> **Format:** YAML válido pronto para kubectl apply + tabela explicando cada campo.

✅ Ganha: tom técnico correto e formato previsível.
⚠️ Limite: não dirige o raciocínio — bom para gerar, fraco para analisar.

---

## Post 3 — T-A-G (Task · Action · Goal)

**Quando usar:** análise de dados ou tarefas onde o RACIOCÍNIO passo a passo importa.

> **Task:** Analise este output de `kubectl top nodes` e identifique gargalos.
> **Action:** 1) Ranqueie nós por uso de memória. 2) Identifique nós acima de 85%.
> 3) Verifique se há pods sem limits. 4) Recomende rebalanceamento.
> **Goal:** Relatório para o time de plantão decidir se precisa escalar o cluster hoje.

✅ Ganha: a Action força o modelo a mostrar o raciocínio.
⚠️ Limite: verboso para tarefas triviais de geração.

---

## Post 4 — B-A-B (Before · After · Bridge)

**Quando usar:** transformar / modernizar / refatorar um artefato que JÁ EXISTE.

> **Before:** [cola um pipeline de CI legado com deploy manual e sem testes]
> **After:** Pipeline com estágios de lint, test, build e deploy automatizado com gate de aprovação.
> **Bridge:** Reescreva o pipeline do Before aplicando o After. Liste o que mudou e por quê.

✅ Ganha: ancora o modelo no código real, preserva o que já funciona.
⚠️ Limite: pressupõe que você JÁ SABE qual é a transformação. Ruim para diagnóstico.

---

## Post 5 — C-A-R-E (Context · Action · Result · Example)

**Quando usar:** gerar código que precisa seguir um PADRÃO/ESTILO existente.

> **Context:** Padrão interno: todo recurso AWS leva tags Owner, CostCenter, Env.
> **Action:** Crie um módulo Terraform para uma fila SQS aderente ao padrão.
> **Result:** Arquivos .tf prontos para terraform plan.
> **Example:** [cola um módulo S3 já existente como referência de estilo]

✅ Ganha: o Example comunica convenções de formatação sem descrevê-las.
⚠️ Limite: depende de você TER um bom exemplo para fornecer.

---

## Post 6 — R-I-S-E (Role · Input · Steps · Expectation)

**Quando usar:** documentação procedural — runbooks, SOPs, guias de onboarding.

> **Role:** SRE sênior que escreve runbooks para plantão.
> **Input:** Alerta "disk usage > 90% on node X". Ferramentas: kubectl, ssh, df.
> **Steps:** Estruture em diagnóstico → mitigação → escalação → encerramento.
> **Expectation:** Cada passo com comando exato e critério "se X → faça Y". Markdown pronto pra wiki.

✅ Ganha: Steps estruturam o documento, Expectation define qualidade operacional.
⚠️ Limite: estrutura a FORMA do documento, não o raciocínio analítico.

---

## Post 7 — Árvore de decisão

Como escolher em 10 segundos:

- Vai **gerar** artefato + persona importa? → **R-T-F**
- Vai **analisar** dados / precisa mostrar raciocínio? → **T-A-G**
- Vai **transformar** algo que já existe? → **B-A-B**
- Vai gerar seguindo um **padrão/estilo**? → **C-A-R-E**
- Vai escrever **procedimento/runbook**? → **R-I-S-E**

📌 Dica: o componente CENTRAL de cada framework revela seu caso de uso.

---

## Post 8 — Fechamento

Frameworks de prompt não são fórmulas mágicas.

São **lentes de organização** que garantem que você não esqueça:
quem (Role), o quê (Task), como (Action/Steps), pra quê (Goal) e em que formato (Format).

Escolher mal o framework custa mais do que escrever mal dentro do certo.

💬 Qual desses você já usa no dia a dia de infra?
♻️ Salva essa thread pro próximo prompt.

#DevOps #SRE #Cloud #PromptEngineering #IA #Kubernetes #Terraform
