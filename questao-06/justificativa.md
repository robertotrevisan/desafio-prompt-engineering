# Questão 06 — Justificativa

## Como C, A, R, E aparecem no prompt

O framework C-A-R-E (Context–Action–Result–Example) é especialmente adequado para tarefas
de geração de código que precisam respeitar um estilo pré-existente. O Context ancora o
modelo no ambiente corporativo, o Action especifica o que criar, o Result define o contrato
de entrega e o Example fornece a referência canônica de estilo — substituindo a necessidade
de descrever verbalmente cada convenção de formatação.

---

### Context (C)

> Trecho do prompt:
> _"Você está trabalhando na Hill Valley Tech, uma empresa que possui um padrão corporativo
> de IaC definido pelo head de segurança e compliance... O módulo que você vai criar será
> consumido por todos os times da empresa para provisionar buckets S3, portanto precisa ser
> reutilizável, seguro por padrão e aderente ao estilo de código já estabelecido internamente."_
> _(seguido do padrão corporativo obrigatório)_

O Context cumpre três funções neste prompt:

**1. Situa o modelo no ambiente da empresa**
"Hill Valley Tech", "padrão corporativo", "head de segurança e compliance" não são
decoração narrativa — eles comunicam ao modelo que as restrições listadas são
obrigatórias e não negociáveis, não sugestões de boas práticas. Um prompt sem esse
contexto empresarial deixaria o modelo livre para omitir, por exemplo, o logging
(que considera opcional em muitos cenários genéricos) ou usar nomes de recurso sem
o prefixo `hvt-`.

**2. Define o escopo de uso do módulo**
"Consumido por todos os times da empresa" sinaliza que o módulo precisa ser genérico
o suficiente para múltiplos casos de uso (variáveis parametrizadas, sem valores
hardcoded) e que omitir qualquer requisito de segurança teria impacto amplo. Isso
eleva o critério de qualidade do output sem precisar dizer "seja rigoroso".

**3. Formaliza o padrão corporativo como lista de requisitos**
A seção "Padrão corporativo obrigatório (não negociável)" com as quatro regras
(tags, prefixo, recursos S3, variáveis) funciona como checklist que o Action e o
Result vão referenciar. Ao colocar no Context — e não no Action — as regras ganham
o status de restrições de ambiente, não de instruções de tarefa.

---

### Action (A)

> Trecho do prompt:
> _"Crie um módulo Terraform completo para bucket S3 aderente ao padrão corporativo
> descrito acima, seguindo o estilo do módulo de VPC como referência. O módulo deve
> ser composto por quatro arquivos separados: [1. variables.tf, 2. main.tf,
> 3. outputs.tf, 4. exemplo-uso.tf]"_

A Action desta questão tem granularidade por arquivo — cada arquivo recebe sua
própria especificação de conteúdo:

| Arquivo | Especificação na Action |
|---------|------------------------|
| `variables.tf` | 5 variáveis mínimas com nomes e semântica definidos |
| `main.tf` | 5 recursos AWS explícitos com instrução de usar `locals` e `merge` |
| `outputs.tf` | 3 outputs mínimos com nomes definidos |
| `exemplo-uso.tf` | Exemplo de consumo com valores fictícios plausíveis |

**Por que nomear os recursos AWS explicitamente na Action:**
`aws_s3_bucket_server_side_encryption_configuration` vs o antigo bloco `server_side_encryption_configuration` inline são a mesma funcionalidade em versões diferentes do provider AWS. Ao listar o nome do recurso correto na Action, o prompt garante que o código gerado seja compatível com o provider AWS v4+, sem depender de o modelo escolher a forma correta por conta própria.

**A instrução de estilo na Action:**
_"Use `locals { common_tags = ... }` igual ao módulo de VPC e aplique `merge(...)` em cada
recurso que suporte tags"_ é uma instrução de implementação na Action que reforça o Example
— o modelo recebe tanto o padrão em código (Example) quanto a instrução explícita de
replicá-lo (Action).

---

### Result (R)

> Trecho do prompt:
> _"Os quatro arquivos devem ser entregues em blocos de código separados, cada um
> identificado pelo nome do arquivo. O código deve estar pronto para terraform init
> && terraform plan — sem placeholders, sem pseudo-código, sem TODOs. Cada arquivo
> deve ser autoexplicativo para um engenheiro que nunca viu o módulo antes."_

O Result desta questão define três atributos do output:

**1. Estrutura de entrega (como apresentar)**
"Blocos de código separados, identificados pelo nome do arquivo" garante que o output
seja diretamente mapeável para os arquivos reais do módulo — não uma mistura de código
em um único bloco ou uma narrativa intercalada com snippets.

**2. Critério de prontidão (quando está pronto)**
"`terraform init && terraform plan` sem erros" é um critério objetivo e verificável.
Equivale ao "pronto para `kubectl apply`" da Questão 05 — transforma a avaliação do
output de subjetiva ("parece certo") para binária (passa ou não passa no plan).

**3. Critério de legibilidade (para quem é)**
"Autoexplicativo para um engenheiro que nunca viu o módulo antes" justifica por que
os arquivos têm comentários de seção (`# Versioning`, `# Block public access`) e
descriptions detalhadas nas variáveis — não é verbosidade, é o Result pedindo
documentação inline.

---

### Example (E)

> Trecho do prompt:
> _"Siga o estilo do módulo de VPC como referência canônica:_
> _- Mesma estrutura de locals com common_tags_
> _- Mesmo padrão de merge(local.common_tags, { Name = "hvt-<recurso>-${var.environment}" })_
> _- Mesmo estilo de variáveis com description alinhado à esquerda e type na linha seguinte_
> _- Nomes de recursos em snake_case, sem abreviações desnecessárias"_
> _(precedido pelo trecho de código do módulo de VPC no Context)_

O Example é o elemento que diferencia o C-A-R-E dos outros frameworks nesta questão.
Ele aparece em duas camadas:

**1. O trecho de código do módulo de VPC (no Context)**
O código real do módulo de VPC funciona como few-shot example: o modelo extrai as
convenções diretamente do código — alinhamento por espaços em `common_tags`,
`merge(local.common_tags, {...})` como padrão de tagging, `"hvt-vpc-${var.environment}"`
como padrão de nomenclatura — sem que essas convenções precisem ser descritas
verbalmente uma a uma.

**2. A lista de referências no Example (no final do prompt)**
A seção Example no final do prompt reforça as convenções mais importantes do
trecho de código, funcionando como um índice do que o modelo deve priorizar ao
replicar o estilo. Isso previne que o modelo "perca" alguma convenção ao processar
o trecho de código no meio do prompt.

**Por que o Example é mais eficaz que descrever o estilo verbalmente:**
Descrever "use alinhamento por espaços nas tags" é ambíguo — o modelo pode alinhar
de formas diferentes. Mostrar o código real com `Owner       = var.owner` alinhado
a `CostCenter  = var.cost_center` comunica a convenção de forma inequívoca. O Example
substitui uma especificação verbal de estilo por demonstração direta — técnica de
few-shot learning aplicada ao prompt engineering.

---

### Comparação: por que C-A-R-E e não os outros frameworks aqui

| Framework | Por que não é ideal nesta questão |
|-----------|----------------------------------|
| R-T-F | O Role não tem onde ancorar o estilo de código existente — precisaria descrever verbalmente todas as convenções |
| T-A-G | O Goal descreveria a audiência (Strickland, times consumidores), mas não há um mecanismo natural para injetar o exemplo de código como referência canônica |
| B-A-B | Adequado para transformação de artefato existente; aqui não há artefato legado a modernizar — o módulo S3 é novo |
| **C-A-R-E** | **O Context ancora o padrão corporativo, o Example injeta o estilo via código real, o Action especifica os 4 arquivos e o Result define o critério de prontidão** |
