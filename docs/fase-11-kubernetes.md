# Fase 11 — Kubernetes

## Objetivo
Aprender os fundamentos do Kubernetes (cluster, node, pod, deployment, service) usando k3s, observando na pratica conceitos de replicas, self-healing e alta disponibilidade.

## Arquitetura

Cluster k3s (1 node = a propria VM)
|
v
Deployment (meu-site-deployment)
|-- declara: 3 replicas do Pod
|
v
3 Pods (nginx:alpine) - cada um com sistema de arquivos isolado
|
v
Service (meu-site-service, tipo NodePort)
|-- porta estavel 30080 na VM -> distribui entre os 3 Pods
|
v
Acesso externo: http://<ip-da-vm>:30080


## Tecnologias
k3s (distribuicao leve e completa de Kubernetes, usada tambem em producao real), kubectl

## Comandos-chave
| Ação | Comando |
|---|---|
| Instalar k3s | `curl -sfL https://get.k3s.io \| sh -` |
| Ver nos do cluster | `kubectl get nodes` |
| Aplicar um manifesto YAML | `kubectl apply -f arquivo.yaml` |
| Ver pods | `kubectl get pods` |
| Deletar um pod (testar self-healing) | `kubectl delete pod <nome>` |
| Ver services | `kubectl get svc` |

## Conceitos consolidados
- Cluster (conjunto de nos) vs Node (uma maquina) vs Pod (menor unidade, geralmente 1 container)
- Deployment garante que o numero de replicas declarado sempre exista (self-healing automatico)
- Replicas != Nos: multiplas copias podem rodar no mesmo no (nosso caso) ou distribuidas em varios
- Cada Pod tem sistema de arquivos isolado — mudancas feitas manualmente dentro de um Pod NAO se propagam para os outros e se perdem se o Pod for recriado (a nao ser que estejam na imagem ou em armazenamento externo)
- Service da um endereco estavel para acessar um grupo de Pods, mesmo que eles morram/nascam trocando de IP interno
- NodePort e' o tipo mais simples de Service, expondo uma porta fixa (30000-32767) diretamente no node
- Alta disponibilidade na pratica: aplicacao continua respondendo mesmo com 1 de 3 replicas sendo recriada

## Problema real enfrentado
**Sintoma:** `kubectl get nodes` falhava com `permission denied` ao ler `/etc/rancher/k3s/k3s.yaml`, mesmo apos copiar o arquivo para `~/.kube/config` com as permissoes corretas.
**Causa raiz:** o `kubectl` embutido no k3s (diferente do kubectl "padrao"/upstream) nao busca automaticamente em `~/.kube/config` — ele sempre tenta o caminho original do sistema, a nao ser que a variavel de ambiente `KUBECONFIG` aponte explicitamente para outro lugar.
**Solucao:** `export KUBECONFIG=~/.kube/config`, tornado permanente via `.bashrc`.

## Observacao tecnica importante
k3s usa containerd como runtime, diferente do Docker Engine usado nas fases anteriores. Imagens construidas localmente com `docker build` nao ficam automaticamente disponiveis para o k3s. Por isso, esta fase usou a imagem publica `nginx:alpine` diretamente. Importar imagens customizadas para o containerd do k3s fica como proximo desafio.

## Pendências atualizadas
1. Docker fura o UFW via iptables (Fase 13)
2. Relógio da VM dessincronizado
3. IP dinâmico da VM local
4. Promtail não descobre containers de outros projetos Compose
5. Importar imagens Docker customizadas para o containerd do k3s (nao resolvido nesta fase)
