# Questão 01 — Modelo

## Modelo utilizado

- **Modelo:** Claude (Anthropic)
- **Versão:** claude-sonnet-4-6

## Justificativa da escolha

O `claude-sonnet-4-6` foi escolhido por três razões principais:

1. **Precisão técnica em IaC/DevOps**: o modelo demonstra forte conhecimento de boas práticas 
   de containerização (cache de layers, usuário não-root, imagem slim), sem necessidade de 
   prompting extensivo para acertar detalhes como ordem das instruções COPY/RUN.

2. **Fidelidade ao formato solicitado**: o modelo segue fielmente formatos estruturados 
   (tabelas, listas, blocos de código), o que é essencial quando o entregável precisa ser 
   diretamente aproveitável — neste caso, um Dockerfile pronto para uso e uma tabela de 
   justificativas.

3. **Custo-benefício para tarefas de geração de código**: tarefas de geração de artefatos 
   técnicos bem definidos (Dockerfile, scripts, YAML) não exigem o modelo mais capaz da 
   família; o Sonnet equilibra qualidade e velocidade para esse perfil de tarefa.
