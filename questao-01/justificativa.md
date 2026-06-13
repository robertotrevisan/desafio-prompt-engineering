# Questão 01 — Justificativa

## Como R, T, F aparecem no prompt

### Role (R)

> Trecho do prompt:
> _"Você é um engenheiro de plataforma sênior especializado em containers e Kubernetes,
> responsável por containerizar aplicações Python para ambientes de produção corporativos."_

O papel foi definido logo na primeira linha, antes de qualquer instrução. Isso é deliberado:
ao estabelecer a persona de **engenheiro de plataforma sênior** com especialidade em
**containers e Kubernetes**, o modelo é condicionado a:

- Priorizar segurança (usuário não-root, sem segredos na imagem)
- Pensar em performance de build (cache de layers)
- Considerar o destino final (Kubernetes) nas decisões, como o uso de `CMD` em formato exec
  para propagação correta de sinais UNIX
- Adotar convenções de produção, não de desenvolvimento

Sem o Role, o modelo poderia gerar um Dockerfile funcional mas simplório — sem HEALTHCHECK,
sem separação de layers, com `root` como usuário.

---

### Task (T)

> Trecho do prompt:
> _"Sua tarefa é criar um Dockerfile de produção para a aplicação abaixo, seguindo
> rigorosamente as boas práticas de containerização."_

A tarefa foi especificada com:

1. **Verbo de ação claro**: "criar um Dockerfile de produção"
2. **Contexto técnico completo**: estrutura de diretórios, conteúdo do `requirements.txt`,
   comando de inicialização exato e as variáveis de ambiente obrigatórias
3. **Lista explícita de boas práticas** numeradas (1 a 8): isso transforma o pedido genérico
   "siga boas práticas" em requisitos verificáveis, reduzindo a chance de o modelo omitir
   algum item por sua própria priorização

A inclusão das variáveis `DATABASE_URL` e `API_KEY` com a instrução explícita de que
**não devem ter valores default** é um exemplo de Task com restrição negativa — informa
o que o modelo **não deve fazer**, fechando uma brecha comum em Dockerfiles gerados sem
esse cuidado.

---

### Format (F)

> Trecho do prompt:
> _"Formato de entrega:_
> _- Primeiro, apresente o Dockerfile completo e funcional, sem omitir nenhuma linha_
> _- Depois, apresente uma tabela com três colunas: Instrução | Boa prática aplicada | Justificativa_
> _- Por fim, liste qualquer .dockerignore recomendado para este projeto"_

O formato foi especificado em três partes sequenciais com ordem explícita:

| Parte | Elemento de Format | Efeito no output |
|-------|--------------------|-----------------|
| Dockerfile completo | Artefato principal, sem omissões | Evita que o modelo resuma ou use `# ...` como atalho |
| Tabela de três colunas | Estrutura tabular com colunas nomeadas | Força rastreabilidade de cada decisão técnica |
| `.dockerignore` | Entregável complementar | Fecha o escopo da tarefa; um Dockerfile sem `.dockerignore` está incompleto |

A sequência **artefato → explicação → complemento** é uma estratégia de Format que separa
o que é entregável do que é documentação, facilitando a revisão e o aproveitamento direto
do Dockerfile gerado.
