# Bônus — Tema 3: Tokens e janela de contexto

> Formato: artigo técnico (Medium / Dev.to / blog pessoal)
> Tema: o que todo profissional técnico deveria entender antes de jogar prompt na IA

---

## Tokens e janela de contexto: o que todo profissional técnico deveria entender antes de jogar prompt na IA

Todo mundo aprende a "conversar" com a IA pela interface. Poucos entendem o que acontece
debaixo do capô — e essa lacuna custa caro em duas frentes: **dinheiro** (você paga por
token) e **qualidade** (a resposta degrada quando o contexto estoura ou incha).

Este artigo é o que eu gostaria de ter lido antes de colocar IA em produção.

---

### 1. O que é um token

Um modelo de linguagem não lê palavras. Ele lê **tokens** — pedaços de texto que podem ser
uma palavra inteira, parte de uma palavra, um espaço ou um sinal de pontuação.

Regra de bolso para inglês: **1 token ≈ 4 caracteres ≈ 0,75 palavra.**
Em português a proporção é um pouco pior (mais tokens por palavra), porque a tokenização
foi otimizada majoritariamente para inglês.

Exemplos aproximados:

```
"Kubernetes"        → 1-2 tokens
"kubectl get pods"  → ~4 tokens
"internacionalização" → vários tokens (palavra longa, fragmentada)
```

Por que isso importa? Porque **tudo** que entra e sai do modelo é contado em tokens:
seu prompt (input) + a resposta (output) + o histórico da conversa.

---

### 2. Por que tokens importam para CUSTO

A maioria das APIs cobra **por token**, com preços separados para entrada e saída.
A saída costuma ser várias vezes mais cara que a entrada.

Cálculo realista de um caso comum:

```
Você processa 100.000 documentos.
Cada um: ~2.000 tokens de entrada + ~500 de saída.

Entrada: 100k × 2.000 = 200.000.000 tokens
Saída:   100k × 500   =  50.000.000 tokens
```

Multiplique pelo preço por milhão de tokens do seu provider e você verá que **a diferença
entre um prompt enxuto e um prompt inflado pode ser milhares de dólares por mês.**

Otimizações práticas:
- Não cole arquivos inteiros se só precisa de um trecho.
- Resuma o histórico de conversas longas em vez de reenviar tudo.
- Escolha o modelo certo: tarefa simples não precisa do modelo premium (ver Tema 1).

---

### 3. O que é a janela de contexto

A **janela de contexto** é o número máximo de tokens que o modelo consegue "ver" de uma
vez — input + output somados. É a memória de trabalho do modelo para aquela requisição.

Janelas variam de alguns milhares a centenas de milhares (ou até milhões) de tokens,
dependendo do modelo.

Dois problemas surgem quando você ignora a janela:

**a) Estouro da janela**
Se prompt + histórico + resposta esperada ultrapassam o limite, o modelo **trunca** —
geralmente o começo da conversa. O resultado: ele "esquece" a instrução inicial e responde
fora do esperado, sem te avisar.

**b) Lost in the middle**
Mesmo dentro do limite, modelos têm um viés conhecido: prestam **mais atenção ao início e
ao fim** do contexto e **menos ao meio**. Se você enfia a instrução crítica no meio de
10 mil tokens de dados, há boa chance de ela ser ignorada.

---

### 4. Lost in the middle na prática

❌ **Prompt mal estruturado:**
```
[8.000 tokens de logs colados]
Ah, e me diga qual erro aparece com mais frequência.
[mais 4.000 tokens de logs]
```
A instrução está soterrada. O modelo pode não "enxergá-la" direito.

✅ **Prompt bem estruturado:**
```
TAREFA: identifique o erro mais frequente nos logs abaixo e retorne só o top 3.

[logs]

LEMBRETE DA TAREFA: retorne apenas o top 3 de erros, ordenado por frequência.
```
Instrução no início **e** reforçada no fim — nos pontos de maior atenção do modelo.

---

### 5. Prompt curto vs prompt inflado

Mais contexto **não** é sempre melhor. Contexto irrelevante:
- aumenta o custo (mais tokens de entrada),
- aumenta a latência (mais para processar),
- e dilui a atenção do modelo no que importa (piora a qualidade).

A arte do prompt engineering profissional é dar ao modelo **exatamente o contexto
necessário** — nem menos (ele alucina para preencher lacunas), nem mais (ele se perde
no ruído).

---

### 6. Checklist prático

Antes de jogar um prompt na IA, pergunte-se:

- [ ] Estou enviando só o contexto **necessário** ou colei coisas demais?
- [ ] A instrução crítica está no **início ou no fim** (não enterrada no meio)?
- [ ] O prompt + a resposta esperada **cabem** na janela do modelo?
- [ ] Em conversas longas, estou **resumindo** o histórico em vez de reenviar tudo?
- [ ] O **modelo** que escolhi tem janela e custo adequados para o volume da tarefa?

---

### Conclusão

Quem usa IA só pela interface trata o modelo como caixa-preta. Quem entende **tokens** e
**janela de contexto** consegue controlar custo, latência e qualidade de forma deliberada —
e essa é a diferença entre "usar ChatGPT" e **engenheirar soluções com IA**.

Token é unidade de conta e de atenção. Trate os dois com a mesma seriedade que você trata
recursos de um cluster: dimensione, monitore e otimize.

---

*Gostou? Comenta qual desses conceitos mais impactou seus custos com IA na prática.*

#IA #LLM #PromptEngineering #Tokens #MachineLearning #EngenhariaDeSoftware
