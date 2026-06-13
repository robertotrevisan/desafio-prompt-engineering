# Questão 05 — Justificativa

## Como B, A, B aparecem no prompt

O framework B-A-B (Before–After–Bridge) é estruturalmente diferente dos anteriores.
Enquanto R-T-F define papel e tarefa, e T-A-G decompõe o processo, o B-A-B é
um framework de **transformação de estado**: define onde o artefato está, onde precisa
chegar e instrui o modelo a construir a ponte entre os dois. Isso o torna
especialmente eficaz para tarefas de modernização, refatoração e migração, onde o
input e o output são artefatos concretos e a distância entre eles precisa ser
percorrida de forma auditável.

---

### Before (B)

> Trecho do prompt:
> _"O manifest Kubernetes abaixo é o Deployment de produção do Chronos... Hoje ele
> apresenta os seguintes problemas críticos que violam os padrões de produção da empresa:
> 1. Segredos hardcoded no manifest... 2. Imagem com tag :latest... [...]"_
> _(seguido do manifest atual)_

O Before cumpre duas funções simultâneas:

**1. O artefato de entrada como objeto concreto**
Fornecer o manifest completo — e não apenas descrevê-lo — é essencial no B-A-B.
O modelo precisa do artefato real para preservar o que é válido (nome, namespace,
porta, labels existentes) e substituir apenas o que precisa mudar. Uma descrição
textual forçaria o modelo a reconstruir o manifest do zero, com risco de inventar
campos ou perder contexto.

**2. O diagnóstico explícito dos problemas como lista numerada**
Enumerar os 8 problemas no Before serve dois propósitos:
- Torna o Before auditável: é possível verificar se o After resolve cada item
  (o Bridge fecha esse loop ao pedir a tabela diff)
- Previne que o modelo priorize por conta própria — sem a lista, ele poderia
  modernizar apenas os problemas que reconhece como mais críticos e ignorar,
  por exemplo, as labels de observabilidade para o Beacon

**Por que nomear os problemas no Before e não só no After:**
Se o Before fosse apenas o manifest (sem diagnóstico), o modelo inferiria os
problemas e poderia divergir do que a empresa considera prioritário. Ao diagnosticar
explicitamente, o prompt transfere o critério de "o que está errado" do modelo
para o engenheiro — o modelo só precisa resolver.

---

### After (A)

> Trecho do prompt:
> _"O manifest modernizado deve ser um Deployment Kubernetes pronto para produção,
> resolvendo todos os 8 problemas listados acima e aplicando as seguintes especificações:
> - replicas: 3... - Imagem: chronos-api:1.0.0... - resource requests: cpu: '250m'..."_

O After é o estado-alvo, especificado com valores concretos para cada campo — não
como intenções vagas ("adicione resources") mas como configurações aplicáveis
diretamente:

| Especificação no After | Por que valores concretos e não genéricos |
|------------------------|------------------------------------------|
| `replicas: 3` | "Alta disponibilidade" sem número forçaria o modelo a escolher 2, 3 ou N |
| `cpu: "250m"`, `memory: "256Mi"` | Sem valores, o modelo poderia usar heurísticas inadequadas para o Chronos |
| `initialDelaySeconds: 10`, `periodSeconds: 5` | Valores de probe dependem do tempo de inicialização real da aplicação |
| `runAsUser: 1000` | UID genérico como 65534 (nobody) ou 999 teria semântica diferente |
| `maxUnavailable: 0`, `maxSurge: 1` | A semântica de zero-downtime é específica dessa combinação |

**O After como especificação, não como instrução**
O After não diz "faça X para resolver o problema Y". Ele descreve o estado final
desejado. É o Bridge que instrui o modelo a transformar o Before no After. Essa
separação é o que define o B-A-B: Before e After são estados, Bridge é a ação.

---

### Bridge (B)

> Trecho do prompt:
> _"Reescreva o manifest do Before aplicando todas as especificações do After.
> Entregue:
> 1. O manifest YAML completo e válido do Deployment modernizado... pronto para
>    kubectl apply — sem comentários inline que quebrem o YAML
> 2. Um manifest YAML separado do Secret chronos-secrets...
> 3. Uma tabela diff resumindo cada problema do Before e como foi resolvido no After"_

O Bridge é a instrução de transformação e o contrato de entrega. Nesta questão,
ele cumpre três funções:

**1. A instrução de transformação**
"Reescreva o manifest do Before aplicando todas as especificações do After" é a
sentença central do Bridge — direta, sem ambiguidade. Não pede para "sugerir
melhorias" nem para "analisar o manifest": pede a reescrita completa com os
critérios definidos.

**2. Os três entregáveis com propósito distinto**

| Entregável | Por que é necessário |
|------------|---------------------|
| Deployment YAML pronto para `kubectl apply` | Artefato principal — direto ao cluster |
| Secret YAML com placeholders | Um Deployment com `secretKeyRef` é inválido sem o Secret correspondente; o placeholder sinaliza que valores reais devem ser injetados via pipeline seguro |
| Tabela diff Before→After | Fecha o loop de auditoria: garante que todos os 8 problemas do Before foram tratados |

**3. A restrição "sem comentários inline que quebrem o YAML"**
Comentários YAML com `#` são válidos, mas modelos frequentemente inserem comentários
explicativos dentro do bloco de código que interrompem a estrutura do documento
quando o arquivo é copiado diretamente para `kubectl apply`. A restrição no Bridge
previne isso sem proibir comentários úteis na seção de notas fora do YAML.

---

### Por que B-A-B é o framework ideal para modernização de artefatos

| Framework | Ponto forte | Limitação nesta tarefa |
|-----------|------------|------------------------|
| R-T-F | Define persona técnica | Não estrutura a transformação Before→After; o Role não ancora o manifest legado |
| T-A-G | Decompõe o processo passo a passo | Eficaz para análise (Q03) e geração (Q04), mas exigiria listar os 8 campos do YAML como passos — verboso |
| **B-A-B** | **Ancora o artefato de entrada, especifica o destino e instrui a transformação** | **Ideal para refatoração, migração e modernização** |

O B-A-B é eficaz aqui porque o manifest legado **já existe** e precisa ser
transformado — não gerado do zero. O Before prende o modelo ao artefato real,
o After define o destino com precisão, e o Bridge exige a entrega do
artefato transformado mais a prova de que a transformação foi completa (tabela diff).
