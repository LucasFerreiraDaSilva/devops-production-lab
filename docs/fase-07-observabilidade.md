# Fase 7 — Observabilidade (Prometheus, Grafana, Loki, Alertmanager)

## Objetivo
Implementar os tres pilares de observabilidade (metricas, logs, alertas), permitindo enxergar o estado interno da infraestrutura sem depender de comandos manuais na VM.

## Arquitetura

Node Exporter (metricas SO) --> Prometheus (coleta/armazena) --> Alertmanager (alertas)
|
Containers (docker.sock) --> Promtail --> Loki (logs)
|
v
Grafana (visualiza tudo: metricas + logs)


## Tecnologias
Prometheus, Node Exporter, Alertmanager, Loki, Promtail, Grafana — todos como containers Docker Compose

## Comandos-chave
| Ação | Comando |
|---|---|
| Consultar API de targets do Prometheus | `curl -s http://localhost:9090/api/v1/targets` |
| Consultar API de regras/alertas | `curl -s http://localhost:9090/api/v1/rules` |
| Consultar alertas ativos no Alertmanager | `curl -s http://localhost:9093/api/v2/alerts` |
| Consultar labels disponiveis no Loki | `curl -s http://localhost:3100/loki/api/v1/labels` |
| Consultar valores de um label especifico | `curl -s http://localhost:3100/loki/api/v1/label/<label>/values` |
| Simular consumo de memoria (teste de alerta) | `stress --vm 2 --vm-bytes 2500M --timeout 300s` |
| Importar dashboard pronto no Grafana | Dashboards > New > Import > ID (ex: 1860 = Node Exporter Full) |

## Conceitos consolidados
- Tres pilares de observabilidade: metricas, logs, traces (traces nao aprofundado nesta fase)
- Diferenca entre monitoramento (perguntas conhecidas) e observabilidade (investigar o desconhecido)
- Prometheus faz "pull" (puxa métricas periodicamente dos exporters)
- Ciclo de vida de um alerta: Inactive -> Pending -> Firing -> (resolve) -> Inactive
- `for:` em uma regra evita falso positivo por pico momentâneo
- Ferramentas separadas por responsabilidade (coleta / armazenamento / visualização / notificação) permitem trocar peças independentemente e usar uma única interface (Grafana) para múltiplas fontes
- Loki indexa metadados, nao o conteudo completo do log (mais leve que Elasticsearch)
- Quando a interface grafica diverge da API, confiar na API/dados brutos para diagnosticar

## Validação prática realizada
Simulação de alta utilização de memória via `stress`, observando em tempo real:
1. Estado `Inactive` (condição normal)
2. Estado `Pending` (condição violada, aguardando confirmação de 1 minuto)
3. Estado `Firing` (alerta confirmado e disparado)
4. Alerta replicado corretamente no Alertmanager (confirmado via API `/api/v2/alerts`)
5. Retorno automático a `Inactive` após fim do teste de estresse

## Problemas encontrados

### 1. Interface do Prometheus não exibia página de Targets pelo menu
**Causa:** navegação por menu não funcionou como esperado (possível mudança de versão da interface).
**Solução:** acesso direto via URL (`/targets`).

### 2. Alerta não aparecia na interface do Alertmanager
**Causa:** cache do navegador / timing (alerta resolvia antes de a interface atualizar).
**Solução:** confirmação via API (`curl /api/v2/alerts`) e refresh forçado (Ctrl+Shift+R).

### 3. Promtail não descobre containers fora da stack de observabilidade (pendência aberta)
**Sintoma:** label `container` no Loki só lista os containers da própria stack (prometheus, grafana, loki, etc.), não os containers de aplicação (meu-site, minha-api, nginx-proxy).
**Status:** não resolvido nesta fase — registrado no backlog para investigação futura.

## Pendências atualizadas
1. Docker fura o UFW via iptables (Fase 13)
2. Relógio da VM dessincronizado
3. IP dinâmico da VM
4. Promtail não descobre containers de outros projetos Compose — investigar antes da Fase 11
