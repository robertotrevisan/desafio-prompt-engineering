# Questão 02 — Modelo

## Modelo utilizado

- **Modelo:** Claude (Anthropic)
- **Versão:** claude-sonnet-4-6

## Justificativa da escolha

O `claude-sonnet-4-6` foi escolhido pelas mesmas razões da Questão 01, com um fator
adicional relevante para esta tarefa:

1. **Tratamento correto de segurança em scripts**: o modelo não propõe soluções que
   exponham credenciais em argumentos de linha de comando (visíveis em `ps aux`) nem
   em variáveis intermediárias desnecessárias — comportamento crítico para um script
   que manipula acesso a banco de dados de produção.

2. **Conhecimento de idiomas Bash modernos**: `set -euo pipefail`, `trap ERR`, process
   substitution (`< <(...)`), e a diferença entre `command -v` e `which` são detalhes
   que modelos menores frequentemente erram ou omitem.

3. **Consciência de AWS CLI**: conhece a diferença entre `aws s3 cp` e `aws s3api`,
   sabe usar queries JMESPath no `--query` e entende as classes de armazenamento S3,
   sem precisar de prompting adicional para acertar esses detalhes.

4. **Custo-benefício**: assim como na Questão 01, a tarefa tem escopo técnico bem
   delimitado — um script de ~100 linhas com requisitos explícitos. Não justifica o
   uso de um modelo mais caro da família para geração de artefato técnico definido.
