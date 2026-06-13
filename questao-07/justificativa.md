# Questão 07 — Justificativa

## Como R, I, S, E aparecem no prompt

O framework R-I-S-E (Role–Input–Steps–Expectation) é estruturalmente adequado para
tarefas de geração de documentação procedural. O Role define a voz do documento, o
Input fornece o contexto operacional, os Steps estruturam o conteúdo e o Expectation
define os critérios de qualidade do output — mapeando diretamente para as quatro
dimensões de um runbook: quem escreve, sobre o quê, como se organiza e qual o padrão
de legibilidade.

---

### Role (R)

> Trecho do prompt:
> _"Você é um engenheiro SRE sênior da Hill Valley Tech, responsável por documentar
> procedimentos operacionais para equipes de plantão. Você conhece profundamente o
> ambiente Kubernetes/EKS da empresa, tem experiência em resposta a incidentes e sabe
> escrever runbooks que qualquer plantonista — inclusive quem nunca trabalhou com o
> sistema — consiga seguir sem travar. Seu estilo de documentação é direto: cada passo
> tem um comando concreto para rodar, uma verificação esperada para confirmar que o
> passo funcionou, e um critério claro para decidir o que fazer a seguir."_

O Role desta questão é mais rico do que nas anteriores e cumpre três funções distintas:

**1. Persona técnica com domínio específico**
"SRE sênior com experiência em resposta a incidentes" não é o mesmo que
"engenheiro de plataforma" ou "DevOps sênior". A persona SRE carrega uma semântica
específica: prioriza operabilidade sobre elegância, escreve para ser seguido às 3h
da manhã, e conhece a diferença entre mitigação imediata e correção de causa raiz.
Isso impacta diretamente o tom e a estrutura do runbook gerado.

**2. Audiência embutida no Role**
"Qualquer plantonista, inclusive quem nunca trabalhou com o sistema" instrui o modelo
sobre o nível de detalhe dos comandos (nenhum flag pode ser omitido por "óbvio") e
o grau de explicação de cada passo (o que procurar na saída precisa ser explícito,
não implícito).

**3. Estilo de documentação como contrato**
"Cada passo tem um comando concreto, uma verificação esperada e um critério claro de
decisão" é a estrutura de cada passo do runbook declarada no Role. Isso faz com que
o modelo aplique esse padrão a todos os passos dos Steps sem precisar de instrução
repetida — o Role define o template que os Steps vão preencher.

**Role vs Context (C-A-R-E):**
Na Questão 06, o Context estabelecia o ambiente corporativo como restrição.
Aqui, o Role faz algo diferente: define o *ponto de vista* a partir do qual o
documento é escrito — o que impacta o tom, o nível de detalhe e os critérios de
qualidade, não apenas as restrições de conteúdo.

---

### Input (I)

> Trecho do prompt:
> _"Alerta recorrente que dispara em produção em média 4 vezes por semana:_
> _[CRITICAL] High memory usage on Chronos API pods (>85% for 10min)_
> _Ambiente onde o runbook vai ser executado: [lista de especificações]"_

O Input desta questão tem dois componentes:

**1. O alerta como objeto concreto**
Fornecer a string exata do alerta (`[CRITICAL] High memory usage on Chronos API pods
(>85% for 10min)`) ancora o runbook no gatilho real — o modelo sabe exatamente o que
disparou o documento e pode usar o threshold (85%, 10 min) nos critérios de diagnóstico
e encerramento. Sem isso, o modelo usaria thresholds genéricos ou vagos.

**2. O ambiente operacional como mapa de ferramentas e dependências**
O Input lista sistematicamente: plataforma (EKS), configuração do HPA (min/max/target),
deploy (Argo CD), dependências (Ledger e Reactor), ferramentas disponíveis (kubectl,
aws cli, argocd cli) e canais de comunicação (#oncall-chronos, @chronos-core com SLAs).

Cada item do Input tem impacto direto num passo do runbook:
- HPA configurado para CPU → explica por que o alerta ocorre sem escalonamento automático (P3)
- Dependências Ledger e Reactor → origina o passo P4 de verificação de dependências
- Ferramentas disponíveis → delimita quais comandos o modelo pode usar (sem Lens, sem k9s, só CLI)
- SLA de escalação (15/30 min) → informa os critérios de escalação na seção 5

O Input funciona como o "mapa do sistema" que o modelo precisa para gerar comandos
corretos e procedimentos relevantes — sem ele, o runbook seria genérico e inaplicável.

---

### Steps (S)

> Trecho do prompt:
> _"Estruture o runbook em seções sequenciais obrigatórias: [6 seções com
> especificações detalhadas de cada uma]"_

Os Steps desta questão são a espinha dorsal do prompt — eles definem tanto a
**estrutura** do documento quanto o **conteúdo mínimo** de cada seção:

**Estrutura das seções (o que o documento contém):**

| Seção | Propósito operacional |
|-------|-----------------------|
| 1. Metadados | Identificação rápida do runbook correto na correria do incidente |
| 2. Contexto rápido | Informa o plantonista sobre o impacto sem demandar leitura longa |
| 3. Diagnóstico (P1–P4) | Sequência de investigação com comandos e decisões binárias |
| 4. Mitigações (M1–M3) | Ações de alívio imediato, ordenadas por agressividade |
| 5. Critérios de escalação | Remove a subjetividade da decisão de escalar |
| 6. Encerramento | Define quando o incidente terminou e o que fazer em seguida |

**Conteúdo obrigatório de cada passo de diagnóstico:**
A instrução _"cada passo deve conter: objetivo, comando exato, saída esperada e
decisão"_ transforma os passos dos Steps em um template que o modelo preenche para
cada P1–P4. Isso garante uniformidade sem precisar especificar a estrutura de cada
passo individualmente.

**A granularidade dos Steps é calibrada para o tipo de tarefa:**
Em geração de código (Q04, Q06), os Steps especificam arquivos e recursos. Aqui,
os Steps especificam seções de documento e o conteúdo mínimo de cada uma. O grau
de detalhe dos Steps é proporcional ao risco de o modelo omitir algo importante —
e num runbook operacional, omitir os critérios de escalação ou o critério de
encerramento tornaria o documento inutilizável em produção.

---

### Expectation (E)

> Trecho do prompt:
> _"O runbook será usado por qualquer plantonista da Hill Valley Tech, inclusive quem
> está no primeiro mês de empresa e nunca tocou no Chronos. O documento precisa:_
> _- Ser autocontido: todos os comandos incluem namespace, context e flags necessários_
> _- Ter zero ambiguidade nos critérios de decisão: cada passo termina com 'se X → faça Y'_
> _- Reduzir o tempo médio de resolução de 30–40 minutos para menos de 15 minutos_
> _- Ser formatado em Markdown com cabeçalhos, blocos de código e tabelas, pronto para
>    publicar em Confluence ou Notion"_

O Expectation desta questão vai além de especificar formato — define critérios de
**qualidade operacional** mensuráveis:

**1. "Autocontido: todos os comandos incluem namespace, context e flags"**
Esta é uma restrição técnica que previne o erro mais comum em runbooks: comandos
que funcionam no laptop do autor (com contexto kubectl configurado) mas falham para
o plantonista (que pode estar num contexto diferente). A instrução forçou o modelo
a incluir `-n production` e `-l app=chronos-api` em todos os comandos kubectl.

**2. "Zero ambiguidade: se X → faça Y, nunca 'avalie o contexto'"**
Esta instrução no Expectation é o que produziu as tabelas de decisão ao final de
cada passo de diagnóstico. Sem ela, o modelo tenderia a escrever "se a situação
parecer grave, considere escalar" — o que é inútil para um plantonista júnior
às 3h da manhã. O Expectation transforma um runbook descritivo em um runbook
prescritivo.

**3. "Reduzir MTTR de 30–40 min para menos de 15 min"**
Incluir a métrica de MTTR no Expectation é uma técnica de prompting que ancora
o documento num objetivo de negócio mensurável. O modelo entende que a brevidade
de cada passo (objetivo em uma linha, comando direto, decisão binária) é um
requisito de qualidade, não uma preferência estética.

**4. "Markdown pronto para publicar em Confluence ou Notion"**
Esta instrução de formato no Expectation produziu cabeçalhos `##`, blocos ` ```bash `
para todos os comandos, tabelas para metadados e critérios de escalação — output
que pode ser colado diretamente na wiki sem reformatação.

**Expectation vs Format (R-T-F):**
Na Questão 01, o Format especificava a estrutura do output. Aqui, o Expectation vai
além: define os critérios de qualidade operacional que o output precisa satisfazer
(autocontido, sem ambiguidade, MTTR < 15 min), não apenas sua estrutura. Isso faz
do Expectation um componente mais rico que o Format para tarefas onde a utilidade
do output depende de requisitos não-estruturais.
