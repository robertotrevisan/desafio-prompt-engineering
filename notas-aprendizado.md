# Notas de Aprendizado

Reflexões e aprendizados ao longo do processo de construção dos prompts para o desafio
de Prompt Engineering, ambientado na fictícia Hill Valley Tech.

## Observações Gerais

O desafio cobriu cinco frameworks de prompt engineering aplicados a oito cenários reais
de Cloud, DevOps e SRE. A grande lição não foi "como escrever um bom prompt" no abstrato,
mas perceber que **o framework certo depende da natureza da tarefa** — e que escolher mal
o framework custa mais do que escrever mal dentro do framework certo.

Mapeamento que emergiu do desafio:

| Questão | Tarefa | Framework | Por quê |
|---------|--------|-----------|---------|
| 01 | Dockerfile do zero | R-T-F | Geração de artefato com persona técnica e formato definido |
| 02 | Script de backup | R-T-F | Idem — persona SRE embute restrições de segurança |
| 03 | Relatório de custos | T-A-G | Análise de dados com audiência executiva |
| 04 | Query SQL | T-A-G | Geração com armadilhas técnicas que a Action neutraliza |
| 05 | Modernizar deployment | B-A-B | Transformação de artefato existente |
| 06 | Módulo Terraform | C-A-R-E | Geração que precisa replicar estilo via exemplo |
| 07 | Runbook | R-I-S-E | Documentação procedural com critérios operacionais |
| 08 | Postmortem | T-A-G (escolhido) | Diagnóstico que exige prescrever o raciocínio |

## Guia de referência rápida — quando usar cada framework

Tabela para consulta futura. A ideia é olhar a coluna "Use quando" e a "situação-exemplo"
para decidir o framework antes de escrever o prompt.

| Framework | Componentes | Use quando... | Situação-exemplo (genérica) | Componente que faz a diferença |
|-----------|-------------|---------------|-----------------------------|--------------------------------|
| **R-T-F** | Role · Task · Format | Você vai **gerar um artefato do zero** e a persona/tom técnico importa | "Gere um Dockerfile / um script de deploy / um e-mail de comunicado de manutenção" | **Role** — embute boas práticas e tom sem precisar listá-las |
| **T-A-G** | Task · Action · Goal | Você vai **analisar dados ou diagnosticar** e o **raciocínio passo a passo** importa | "Analise estes logs e diga a causa raiz" / "Resuma este CSV de gastos para a diretoria" / "Compare estas 3 opções e recomende uma" | **Action** — prescreve o caminho do raciocínio, evita conclusão sem fundamento |
| **B-A-B** | Before · After · Bridge | Você vai **transformar/refatorar/migrar algo que já existe** e o caminho é conhecido | "Modernize este manifest" / "Migre este script de Python 2 para 3" / "Refatore esta função para usar async" | **Before** — ancora no artefato real e preserva o que já funciona |
| **C-A-R-E** | Context · Action · Result · Example | Você vai **gerar seguindo um padrão/estilo existente** e tem um exemplo para mostrar | "Crie um módulo novo no padrão deste módulo" / "Escreva um teste no estilo dos testes do repo" / "Gere um endpoint seguindo este controller" | **Example** — comunica convenções de forma inequívoca, melhor que descrevê-las |
| **R-I-S-E** | Role · Input · Steps · Expectation | Você vai **escrever procedimento/documentação operacional** seguida por outras pessoas | "Escreva um runbook para o alerta X" / "Crie um SOP de onboarding" / "Documente o processo de rotação de credenciais" | **Steps + Expectation** — estruturam o documento e definem critérios de qualidade operacional |

### Atalho de decisão (pergunte nesta ordem)

1. **Estou transformando algo que já existe?** → **B-A-B**
2. **Estou analisando dados / diagnosticando?** → **T-A-G**
3. **Estou escrevendo um procedimento para outros seguirem?** → **R-I-S-E**
4. **Estou gerando código que precisa copiar um estilo existente?** → **C-A-R-E**
5. **Nenhum acima — só gerar um artefato com tom técnico?** → **R-T-F**

### Sinais de que você escolheu o framework errado

- Usou **B-A-B** mas ainda não sabe qual deve ser a transformação → era um caso de análise (**T-A-G**).
- Usou **R-T-F** e o modelo "esqueceu" de correlacionar dados → faltou a **Action** do **T-A-G**.
- Usou **R-I-S-E** e o documento ficou bem-formatado mas mal-raciocinado → o desafio era análise, não estrutura.
- Usou **C-A-R-E** mas não tinha um bom exemplo para fornecer → o **Example** ficou artificial; provavelmente era **R-T-F**.

## O que funcionou bem

- **Restrições negativas explícitas.** Dizer ao modelo o que NÃO fazer foi tão importante
  quanto dizer o que fazer. Exemplos: "não armazenar a senha em variável intermediária"
  (Q02), "sem valores default sensíveis no Dockerfile" (Q01), "sem placeholders nem
  pseudo-código" (Q04). Sem isso, o modelo gera saídas tecnicamente corretas mas que
  violam boas práticas.

- **Ancorar números no prompt.** Na Q03, fornecer o total do CSV ($41.800) já calculado
  evitou que o modelo errasse a aritmética e propagasse o erro em todos os percentuais.
  Na Q08, instruir explicitamente a "fazer a aritmética de conexões" levou o modelo à
  evidência decisiva (12 pods × 20 = 240 = limite do RDS).

- **Critérios objetivos em vez de adjetivos.** No runbook (Q07), trocar "avalie o contexto"
  por "se X → faça Y, se Z → faça W" transformou o documento de descritivo em prescritivo —
  utilizável por um plantonista júnior sob pressão.

- **Exemplo de código como referência de estilo.** Na Q06 (C-A-R-E), fornecer o trecho do
  módulo de VPC comunicou as convenções de formatação de forma inequívoca — muito mais
  eficaz que descrever "use alinhamento por espaços nas tags".

## Desafios encontrados

- **Escolher o framework na Q08.** A tentação inicial foi usar B-A-B (incidente tem estado
  "antes" e "depois"), mas isso esconderia a parte mais importante: B-A-B pressupõe que a
  transformação é conhecida, quando justamente *qual* transformação (rollback ou scaling)
  era a pergunta. O T-A-G venceu porque a Action permite prescrever o raciocínio diagnóstico.

- **Distinguir Role (R-T-F/R-I-S-E) de Goal (T-A-G).** Ambos influenciam o tom, mas de
  formas diferentes: o Role define *quem o modelo é*; o Goal define *para quem o output é
  e qual decisão ele suporta*. Para tarefas analíticas com audiência executiva, o Goal é
  mais preciso.

- **Dados de entrada corrompidos no enunciado.** Alguns enunciados vieram com trechos
  truncados (DDL da tabela customers na Q04, linhas do CSV na Q03). Foi preciso reconstruir
  o input de forma limpa e coerente antes de montar o prompt.

## Insights sobre Prompt Engineering

- **O componente central de cada framework revela seu caso de uso.** A Action (T-A-G)
  serve para prescrever raciocínio; o Before/After (B-A-B) para transformar artefatos;
  o Example (C-A-R-E) para replicar estilo; os Steps (R-I-S-E) para estruturar documentos;
  o Role (R-T-F) para embutir uma persona técnica. Saber qual componente o problema mais
  precisa indica o framework.

- **Frameworks não são mutuamente exclusivos na prática.** Vários prompts misturaram
  elementos: o R-T-F da Q02 tinha uma seção de Format estruturada; o T-A-G da Q04 tinha
  Action que parecia checklist de implementação. Os frameworks são lentes de organização,
  não fórmulas rígidas.

- **A justificativa força clareza sobre o próprio prompt.** Escrever "como R, T, F aparecem
  no prompt" depois de escrever o prompt revelou quando um componente estava fraco ou
  ausente — funcionou como revisão de qualidade do próprio prompt.

- **Output verificável > output bonito.** Os melhores prompts terminaram com um critério
  objetivo de prontidão: "pronto para kubectl apply" (Q05), "passa em terraform plan" (Q06),
  "executável no banco de produção" (Q04). Isso transforma a avaliação de subjetiva
  ("parece certo") em binária (funciona ou não).
