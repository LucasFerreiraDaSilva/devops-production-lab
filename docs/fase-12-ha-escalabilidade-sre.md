# Fase 12 — Alta Disponibilidade, Escalabilidade e SRE

## Objetivo
Aplicar conceitos de confiabilidade (SRE) sobre a infraestrutura ja construida: testar alta disponibilidade sob falha, configurar escalonamento automatico baseado em carga real, e definir um SLO simples para o servico.

## Arquitetura

Carga de trafego (ab - Apache Bench)
|
v
Service (meu-site-service)
|
v
HPA (Horizontal Pod Autoscaler)
|-- monitora uso de CPU dos Pods via metrics-server
|-- min: 2 replicas / max: 6 replicas
|-- meta: 50% de utilizacao media de CPU
|
v
Deployment escala automaticamente: 2 -> 3 -> 6 (sob carga) -> 2 (repouso)


## Tecnologias
Kubernetes HPA, metrics-server (ja embutido no k3s), Apache Bench (ab)

## Comandos-chave
| Ação | Comando |
|---|---|
| Ver metrics-server | `kubectl get deployment metrics-server -n kube-system` |
| Criar HPA | `kubectl apply -f hpa.yaml` |
| Ver estado do HPA | `kubectl get hpa` |
| Ver detalhes/eventos do HPA | `kubectl describe hpa <nome>` |
| Gerar carga de teste | `ab -n <total> -c <concorrencia> <url>` |
| Observar em tempo real | `watch -n 2 kubectl get hpa` |

## Conceitos consolidados
- Escalabilidade vertical (mais recursos por maquina) vs horizontal (mais replicas/maquinas) — Kubernetes e HPA sao primariamente horizontais
- SLI (metrica medida) vs SLO (meta definida) vs SLA (compromisso formal com consequencia)
- HPA precisa de `requests` de CPU definidos no Deployment para calcular percentual de utilizacao
- `maxReplicas` funciona como protecao contra escalonamento descontrolado (custo e recursos)
- Stabilization window: o HPA reduz replicas mais devagar que aumenta, evitando oscilacao ("flapping") por picos passageiros
- Alta disponibilidade validada com teste real de carga, nao apenas observacao teorica

## Validação prática realizada
Teste de carga com `ab` (200.000 requisicoes, concorrencia 50) contra o Service do Kubernetes, observando em tempo real:
1. HPA em repouso: 2 replicas, 0% CPU
2. Sob carga: escalonamento automatico ate o teto de 6 replicas
3. `kubectl describe hpa` usado para investigar historico de eventos quando o estado momentaneo pareceu inconsistente com a leitura de CPU
4. Apos fim da carga: reducao automatica de volta a 2 replicas (minimo configurado)

## Decisão de escopo
Integracao completa entre Prometheus (Fase 7, rodando via Docker Compose) e o cluster Kubernetes (k3s) para medicao tecnica de SLO foi mantida conceitual nesta fase, documentada como proximo passo de evolucao, para nao expandir excessivamente o escopo.

## SLO definido (conceitual)
**95% das requisicoes HTTP devem retornar status 200 dentro de uma janela de 30 dias.**
Medicao tecnica ficaria a cargo de um `nginx-prometheus-exporter` + paineis de error budget no Grafana + alertas no Alertmanager.

## Pendências atualizadas
1. Docker fura o UFW via iptables (Fase 13)
2. Relógio da VM dessincronizado
3. IP dinâmico da VM local
4. Promtail não descobre containers de outros projetos Compose
5. Importar imagens Docker customizadas para o containerd do k3s
6. Integração técnica Prometheus + Kubernetes para medição real de SLO (evolução futura)
