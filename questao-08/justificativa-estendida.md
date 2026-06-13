# Questão 08 — Justificativa estendida

## Framework escolhido: T-A-G (Task–Action–Goal)

Esta justificativa tem duas partes: (1) por que o T-A-G é o framework ideal para este
cenário e como seus componentes aparecem no prompt; (2) comparação explícita com dois
frameworks candidatos, apontando o que se ganharia e o que se perderia em cada um.

---

## Parte 1 — Por que T-A-G e como seus componentes aparecem

### A natureza da tarefa define o framework

O cenário tem características muito específicas que orientam a escolha:

- **É análise, não geração**: o entregável é um diagnóstico a partir de dados, não um
  artefato de código ou configuração.
- **Os dados são heterogêneos e precisam ser correlacionados**: changelog + série temporal
  de métricas + log + estado de fila + estado de cluster. A qualidade do output depende
  inteiramente da qualidade do raciocínio de correlação.
- **O resultado é uma decisão binária sob pressão de tempo**: rollback (A) ou scaling (B),
  em 20 minutos, para um CTO.

O T-A-G é o único dos cinco frameworks cujo componente central — a **Action** — permite
prescrever o *processo de raciocínio analítico* passo a passo. Em uma análise de incidente,
o caminho do raciocínio (timeline → correlação → aritmética → causa raiz → avaliação de
opções → recomendação) é tão importante quanto a conclusão, porque é o que torna o
diagnóstico auditável e confiável para quem vai decidir.

### Como Task aparece

> _"Analise os artefatos abaixo, determine a causa raiz mais provável e produza um
> postmortem técnico que sustente uma decisão imediata entre duas opções..."_

A Task estabelece três coisas: o tipo de trabalho (análise diagnóstica), o entregável
(postmortem técnico) e a finalidade explícita (sustentar a decisão A vs B). Os cinco
blocos de artefatos vêm embutidos na Task como dados de entrada — é o material bruto
sobre o qual a Action vai operar.

### Como Action aparece

> _"Execute a análise nesta ordem e mostre o raciocínio: 1. Construa a timeline...
> 2. Correlacione cada mudança do changelog com os sintomas... 3. Faça a aritmética de
> conexões... 4. Determine a causa raiz e classifique o nível de confiança... 5. Avalie
> as duas opções contra a causa raiz... 6. Emita uma recomendação única."_

A Action é o coração do prompt e o motivo da escolha do T-A-G. Cada passo dirige uma
etapa do raciocínio de incidente:

| Passo da Action | O que força o modelo a fazer |
|-----------------|------------------------------|
| 1 — Timeline | Separar o momento do deploy (latente) do início real da degradação (sob carga) |
| 2 — Correlação changelog↔sintomas | Ligar cada mudança do deploy a uma evidência de log |
| 3 — Aritmética de conexões | Descobrir 12×20=240=RDS — a evidência quantitativa decisiva |
| 4 — Causa raiz + confiança | Comprometer-se com um diagnóstico e calibrar a incerteza |
| 5 — Avaliar opções contra a causa | Distinguir o que resolve a causa do que trata o sintoma |
| 6 — Recomendação única | Eliminar ambiguidade na decisão final |

O passo 3 (aritmética de conexões) é especialmente importante: sem ele, o modelo poderia
diagnosticar "esgotamento de conexões" genericamente. Ao instruir explicitamente a relacionar
pods × pool × limite do RDS, o prompt direciona o modelo à evidência mais forte do caso.

### Como Goal aparece

> _"Doc Brown (CTO) está na call de incidente e tem 20 minutos para decidir entre rollback
> e scaling antes que o consumer lag do Reactor ultrapasse o limite de SLA. O postmortem
> precisa ser técnico, conciso e terminar com uma recomendação acionável — não um relatório
> exaustivo. Doc precisa conseguir ler... em menos de 5 minutos."_

O Goal define o destinatário (CTO técnico), a restrição de tempo (decisão em 20 min, leitura
em 5 min) e o critério de sucesso (recomendação acionável, não relatório exaustivo). Isso
calibra o output para priorizar o TL;DR e a tabela de decisão, mantendo o rigor técnico
sem inflar o documento. O Goal é o que impede o modelo de produzir um postmortem acadêmico
de 10 páginas quando o que se precisa é uma decisão em 20 minutos.

---

## Parte 2 — Comparação com frameworks candidatos

### Candidato 1: R-I-S-E (Role–Input–Steps–Expectation)

O R-I-S-E é o concorrente mais forte do T-A-G neste cenário, porque também permite
estruturar processo (via Steps) e definir critérios de output (via Expectation). Foi
o framework usado na Questão 07 (runbook), que também é um documento operacional.

**O que se ganharia com R-I-S-E:**
- O **Role** ("você é um SRE sênior de resposta a incidentes") adicionaria uma persona
  que reforça o tom técnico e a mentalidade de incidente — útil para calibrar a voz.
- O **Input** organizaria os artefatos de forma explícita como "dados de entrada", o que
  é natural para este caso com cinco fontes distintas.
- Os **Steps** poderiam estruturar as seções do postmortem (como fizeram no runbook).

**O que se perderia com R-I-S-E:**
- Os **Steps** do R-I-S-E são orientados a *estruturar o documento* (quais seções ele tem),
  não a *prescrever o raciocínio analítico* (como pensar para chegar à conclusão). Na
  Questão 07 isso era ideal, porque o runbook é uma sequência de seções. Aqui, o desafio
  central não é a estrutura do documento — é a *qualidade da correlação entre artefatos*.
  A Action do T-A-G é melhor que os Steps do R-I-S-E para forçar o passo da aritmética de
  conexões e a distinção causa-vs-sintoma, porque ela descreve operações de raciocínio,
  não seções de output.
- O **Role** seria redundante aqui: o tom técnico já é garantido pela Task ("postmortem
  técnico") e pelo Goal (destinatário CTO). Investir em definir um Role agregaria pouco
  e consumiria espaço do prompt.

**Veredicto:** R-I-S-E entregaria um bom postmortem, mas com risco de produzir um documento
bem-estruturado e mal-raciocinado — porque seus Steps guiam a forma, não o pensamento.
O T-A-G inverte a prioridade corretamente para um problema de diagnóstico.

---

### Candidato 2: B-A-B (Before–After–Bridge)

O B-A-B é superficialmente tentador porque um incidente tem um estado "antes" (sistema
saudável, v2.47.0) e um estado "depois" desejado (sistema recuperado). Foi o framework
usado na Questão 05 (modernizar deployment).

**O que se ganharia com B-A-B:**
- O **Before** capturaria muito bem o estado degradado atual (métricas em colapso, fila
  crescendo, conexões no limite) — o B-A-B é forte em ancorar o modelo num estado concreto.
- O **After** descreveria o estado-alvo (p99 normalizado, circuit breaker fechado, fila
  drenando), dando um critério claro de sucesso da remediação.

**O que se perderia com B-A-B:**
- O B-A-B pressupõe que o caminho do Before para o After é uma *transformação conhecida* —
  na Questão 05, sabíamos exatamente o que mudar no YAML. **Aqui, qual é a transformação é
  justamente a pergunta a ser respondida** (rollback ou scaling?). O B-A-B não tem um
  componente para *analisar e decidir* entre caminhos alternativos; o Bridge assume que
  já sabemos a ponte a construir.
- O B-A-B não tem onde acomodar o raciocínio de causa raiz. Ele descreveria os estados,
  mas não forçaria a correlação changelog↔log↔aritmética que produz o diagnóstico. O
  postmortem resultante diria "estávamos mal, queremos ficar bem" sem explicar *por quê*
  estamos mal — exatamente a informação que o Doc precisa para escolher entre A e B.

**Veredicto:** B-A-B é o framework errado para diagnóstico. Ele brilha em transformação de
artefato com caminho conhecido (Q05), mas o desafio aqui é determinar o caminho, não
executá-lo. Usar B-A-B esconderia a parte mais importante do trabalho.

---

### Por que não os outros dois (menção breve)

- **R-T-F**: bom para geração de artefato com persona e formato definidos (Q01, Q02). Não
  tem componente para prescrever raciocínio analítico; o postmortem dependeria inteiramente
  de o Role "lembrar" de correlacionar tudo, sem garantia do passo da aritmética.
- **C-A-R-E**: forte quando há um exemplo/estilo a replicar (Q06). Não há um postmortem de
  referência aqui, e o Example seria artificial; o componente que importaria (Action) o
  C-A-R-E tem de forma menos central que o T-A-G.

---

## Síntese da decisão

| Framework | Estrutura processo de raciocínio? | Acomoda decisão A-vs-B? | Adequação |
|-----------|-----------------------------------|-------------------------|-----------|
| **T-A-G** | **Sim — via Action passo a passo** | **Sim — passo 5 e 6** | **Ideal** |
| R-I-S-E | Parcial — Steps estruturam o documento, não o raciocínio | Implícito | Bom 2º lugar |
| B-A-B | Não — assume transformação conhecida | Não — pressupõe o caminho | Inadequado |
| R-T-F | Não | Não | Fraco |
| C-A-R-E | Parcial via Action | Sim, mas Example é artificial | Fraco |

O T-A-G vence porque o gargalo deste problema é **o raciocínio de correlação que leva ao
diagnóstico**, e a Action é o único componente, entre todos os frameworks, projetado para
prescrever explicitamente esse raciocínio passo a passo — enquanto o Goal garante que a
saída seja calibrada para a decisão urgente de um CTO em 20 minutos.
