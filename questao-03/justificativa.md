# Questão 03 — Justificativa

## Como T, A, G aparecem no prompt

O framework T-A-G difere do R-T-F usado nas questões anteriores em um aspecto fundamental:
não define uma persona (Role), mas decompõe o trabalho em **o que fazer (Task)**, **como
fazer passo a passo (Action)** e **por que e para quem (Goal)**. Isso torna o T-A-G mais
adequado para tarefas analíticas onde o processo de raciocínio importa tanto quanto o output.

---

### Task (T)

> Trecho do prompt:
> _"Analise o CSV de custos AWS abaixo e identifique oportunidades concretas de redução de
> gastos cloud. Para cada oportunidade, calcule a economia estimada em dólares e em
> percentual sobre a conta total, classifique o esforço de implementação e liste os riscos
> ou pré-requisitos envolvidos."_

A Task cumpre duas funções:

**1. Define o escopo do problema em uma frase**
"Analise o CSV... e identifique oportunidades" — o modelo sabe imediatamente que está
fazendo análise de dados (não geração criativa, não Q&A) e que o entregável são
oportunidades com atributos específicos (economia, esforço, riscos).

**2. Delimita os atributos obrigatórios de cada oportunidade**
Ao listar explicitamente "economia estimada em dólares e em percentual", "esforço de
implementação" e "riscos ou pré-requisitos" na própria Task, o prompt garante que esses
campos apareçam para **todas** as oportunidades — sem precisar repetir nos passos da Action.

**Dado fornecido na Task: o CSV completo com total calculado**
O total ($41.800) foi incluído explicitamente na Task para evitar que o modelo cometa
erros aritméticos ao somar o CSV e depois use esse valor errado em todos os percentuais.
Fornecer o total pré-calculado é uma técnica de Task que ancora o raciocínio quantitativo.

---

### Action (A)

> Trecho do prompt (itens 1–7):
> _"1. Some os custos do CSV e confirme o total ($41.800)._
> _2. Para cada serviço ou categoria, aplique seu conhecimento de otimização de custos AWS..._
> _3. Estime a economia mensal realista... usando as faixas de desconto conhecidas do AWS..._
> _4. Priorize as oportunidades em ordem decrescente de impacto financeiro._
> _5. Para cada oportunidade, classifique o esforço... Baixo, Médio ou Alto, usando o seguinte critério: ..._
> _6. Liste os riscos operacionais ou pré-requisitos técnicos..._
> _7. Ao final, some as economias... e verifique se a meta de 15% ($6.270/mês) é atingível..."_

A Action é a seção mais densa do prompt T-A-G e serve como **roteiro de raciocínio** para
o modelo. Cada passo corresponde a uma etapa do processo analítico:

| Passo | Função no raciocínio |
|-------|---------------------|
| 1 — Confirmar total | Ancora o cálculo; detecta erro aritmético antes de prosseguir |
| 2 — Aplicar conhecimento AWS | Transforma dados brutos em diagnóstico técnico |
| 3 — Estimar com faixas reais | Dá credibilidade aos números; impede estimativas genéricas ("economize 50%") |
| 4 — Priorizar por impacto | Define a ordem da tabela; força o modelo a ranquear antes de escrever |
| 5 — Critério de esforço explícito | Previne subjetividade; define o que "Baixo/Médio/Alto" significa neste contexto |
| 6 — Riscos e pré-requisitos | Garante que o relatório seja acionável, não só aspiracional |
| 7 — Verificar meta | Fecha o loop: conecta o output de volta à pergunta do negócio |

**Detalhe crítico no passo 5:**
Definir os critérios de esforço dentro da Action ("Baixo: configuração em console/CLI sem
mudança de arquitetura...") elimina ambiguidade que levaria outputs inconsistentes — sem
isso, o modelo poderia classificar "contratar Savings Plan" como Baixo (é só um clique no
console) ou Alto (é um compromisso financeiro de 1 ano). O critério explícito força a
classificação correta: Médio, por exigir análise de workload.

---

### Goal (G)

> Trecho do prompt:
> _"O relatório final será apresentado por Goldie Wilson, CEO, à diretoria da Hill Valley Tech
> para aprovar o plano de redução de 15% no custo cloud sem degradar SLA. O relatório precisa
> ser executivo, direto e baseado em números, para que a diretoria aprove as ações de maior
> impacto e esforço compatível."_

O Goal opera em dois níveis simultâneos:

**1. Destinatário e contexto de uso**
"Goldie Wilson, CEO, à diretoria" muda o tom do output sem instrução adicional de estilo.
O modelo calibra o nível de detalhe técnico (suficiente para ser crível, não excessivo
para ser acessível a executivos) e adota linguagem de negócio ("meta trimestral",
"esforço compatível") em vez de linguagem técnica pura.

**2. Pergunta de negócio que o output precisa responder**
"para que a diretoria aprove as ações" — o modelo entende que o output não é apenas
informativo, mas **argumentativo**: precisa convencer a diretoria de que a meta é atingível
e que as ações recomendadas são as corretas. Isso produziu o Sumário executivo com veredicto
explícito ("suficiente para superar a meta de 15%") e a Conclusão com economia trimestral
projetada — elementos que um relatório puramente técnico não incluiria.

**Goal vs Role: por que T-A-G é mais adequado aqui do que R-T-F**

No R-T-F (questões 01 e 02), o Role define *quem* o modelo deve ser para executar a tarefa.
No T-A-G, o Goal define *para quem* o output é destinado e qual decisão ele deve suportar.
Para tarefas analíticas com audiência executiva, o Goal é mais poderoso que o Role porque:
- Não restringe a perspectiva técnica (o modelo pode trazer conhecimento AWS completo)
- Orienta o nível de abstração do output (executivo, não operacional)
- Define o critério de sucesso do relatório (aprovação da diretoria, não acurácia técnica)
