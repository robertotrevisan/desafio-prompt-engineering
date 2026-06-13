# Questão 05 — Prompt

## Prompt utilizado

```
Before:
O manifest Kubernetes abaixo é o Deployment de produção do Chronos, o API gateway
da Hill Valley Tech. Ele foi escrito há três anos e nunca foi atualizado. Hoje ele
apresenta os seguintes problemas críticos que violam os padrões de produção da empresa:

1. Segredos hardcoded no manifest (DB_PASSWORD e JWT_SECRET em texto puro)
2. Imagem com tag :latest — não rastreável e propensa a comportamento não determinístico
3. Sem resource requests nem limits — o pod pode consumir todo o nó ou ser OOMKilled
4. Sem liveness nem readiness probes — o Kubernetes não sabe se o serviço está saudável
5. Sem securityContext — o container roda como root com capacidades Linux padrão
6. replicas: 1 — sem alta disponibilidade; qualquer restart gera downtime
7. Sem RollingUpdate strategy configurada — atualizações podem derrubar o serviço
8. Sem labels de observabilidade — Beacon (stack de observabilidade) não consegue
   identificar o serviço para scraping de métricas

Manifest atual:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: chronos-api
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: chronos-api
  template:
    metadata:
      labels:
        app: chronos-api
    spec:
      containers:
      - name: api
        image: chronos-api:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_PASSWORD
          value: "P@ssw0rd2023!"
        - name: JWT_SECRET
          value: "hvt-jwt-prod-secret"

After:
O manifest modernizado deve ser um Deployment Kubernetes pronto para produção,
resolvendo todos os 8 problemas listados acima e aplicando as seguintes especificações:

- replicas: 3 (alta disponibilidade)
- Imagem: chronos-api:1.0.0 (substituir :latest por versão semântica)
- DB_PASSWORD e JWT_SECRET referenciados via secretKeyRef (Secret do Kubernetes),
  sem nenhum valor em texto puro no manifest; o Secret se chama chronos-secrets
- resource requests: cpu: "250m", memory: "256Mi"
- resource limits: cpu: "500m", memory: "512Mi"
- readinessProbe: HTTP GET /health na porta 8080, initialDelaySeconds: 10,
  periodSeconds: 5, failureThreshold: 3
- livenessProbe: HTTP GET /health na porta 8080, initialDelaySeconds: 30,
  periodSeconds: 10, failureThreshold: 3
- securityContext no nível do container:
    runAsNonRoot: true
    runAsUser: 1000
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
- securityContext no nível do pod:
    runAsNonRoot: true
    seccompProfile: RuntimeDefault
- strategy RollingUpdate: maxUnavailable: 0, maxSurge: 1
  (garante zero downtime: sobe o novo antes de derrubar o antigo)
- Labels adicionais no template para observabilidade:
    version: "1.0.0"
    component: api-gateway
    managed-by: platform-team

Bridge:
Reescreva o manifest do Before aplicando todas as especificações do After.
Entregue:
1. O manifest YAML completo e válido do Deployment modernizado, dentro de um bloco ```yaml,
   pronto para kubectl apply — sem comentários inline que quebrem o YAML
2. Um manifest YAML separado do Secret chronos-secrets com os dois campos
   (DB_PASSWORD e JWT_SECRET) usando valores placeholder Base64 devidamente sinalizados
3. Uma tabela diff resumindo cada problema do Before e como foi resolvido no After
```
