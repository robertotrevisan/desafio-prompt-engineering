# Bônus — Tema 1: Como escolher o modelo de IA certo

> Formato: carrossel de LinkedIn (7 slides)
> Tema: custo, latência, qualidade e privacidade na escolha entre GPT, Claude, Gemini e Llama

---

## Slide 1 — Hook (capa)

**Qual modelo de IA seu time deveria estar usando?**

GPT, Claude, Gemini ou Llama?

A resposta não é "o mais inteligente".
É o que equilibra **4 critérios** para o SEU caso de uso.

➡️ Arrasta pro lado.

*(visual: 4 logos lado a lado com um "?" no centro)*

---

## Slide 2 — O erro mais comum

A maioria dos times escolhe modelo por **hype**:
"saiu um novo benchmark, vamos migrar tudo."

Profissionais sênior escolhem por **trade-off**.

Os 4 critérios que importam:

1. 💰 Custo
2. ⚡ Latência
3. 🎯 Qualidade
4. 🔒 Privacidade

Nenhum modelo vence nos quatro. A escolha é sempre contextual.

---

## Slide 3 — Critério 1: Custo (pay-per-token)

Você paga por **token de entrada + token de saída**. Prompt grande = conta grande.

- **Tarefa de alto volume** (classificar 1M de tickets/dia)?
  → modelo menor/mais barato (GPT-4o-mini, Claude Haiku, Gemini Flash)
- **Tarefa pontual de alto valor** (revisar um contrato)?
  → modelo premium vale o custo

📌 Exemplo: gerar 10 mil descrições de produto não justifica o modelo top de linha.
Um modelo "médio" entrega 95% da qualidade por 1/10 do preço.

---

## Slide 4 — Critério 2: Latência

Qualidade não serve se a resposta chega tarde demais.

- **Chatbot ao vivo / autocomplete de código** → latência é rei.
  Modelos "flash/mini" e até modelos locais ganham.
- **Relatório noturno em batch** → latência é irrelevante.
  Use o modelo mais capaz, deixe rodar.

📌 Exemplo real: num runbook de incidente, um diagnóstico que demora 40s
pode custar SLA. Às vezes o modelo "bom o suficiente e rápido" vence o "perfeito e lento".

---

## Slide 5 — Critério 3: Qualidade (por tipo de tarefa)

"Qualidade" não é um número único — depende da tarefa:

- **Raciocínio complexo / código** → modelos de fronteira (Claude, GPT, Gemini Pro)
- **Texto criativo / resumo** → quase todos entregam bem
- **Multimodal (imagem, áudio)** → Gemini e GPT lideram

📌 Dica: rode SEU caso de uso real em 2-3 modelos antes de decidir.
Benchmark público ≠ desempenho no seu problema.

---

## Slide 6 — Critério 4: Privacidade e soberania de dados

O critério que mais elimina opções em empresa:

- **Dados sensíveis / regulados (LGPD, saúde, financeiro)?**
  → API pública pode estar fora de questão
- **Opções:** modelo self-hosted (Llama via Ollama / vLLM), ou
  endpoints com garantia contratual (Azure OpenAI, Bedrock, Vertex)

📌 Exemplo: rodar Llama localmente via Ollama mantém o dado dentro do seu
perímetro — troca um pouco de qualidade por controle total.

---

## Slide 7 — Matriz de decisão (fechamento)

| Sua prioridade | Caminho provável |
|----------------|------------------|
| Menor custo em escala | Modelo pequeno (mini/flash/haiku) |
| Menor latência | Flash ou modelo local |
| Máxima qualidade | Modelo de fronteira via API |
| Dado não pode sair | Self-hosted (Llama/Ollama) |

**A pergunta certa não é "qual é o melhor modelo?".**
É **"qual é o melhor modelo para ESTA tarefa, com ESTAS restrições?"**

💬 Como seu time escolhe modelo hoje? Comenta aí.
♻️ Compartilha com quem ainda responde "uso ChatGPT".

#IA #LLM #Cloud #DevOps #PromptEngineering
