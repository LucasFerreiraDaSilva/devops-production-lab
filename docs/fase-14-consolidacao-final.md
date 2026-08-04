# Fase 14 — Consolidação Final

## Objetivo
Encerrar o projeto de forma organizada: revisar recursos ativos, limpar containers/imagens nao utilizados, consolidar documentacao e produzir um resumo geral acessivel de toda a jornada.

## Acoes realizadas
- Revisao de containers ativos/parados na VM
- Limpeza de containers parados (`docker container prune`)
- Atualizacao final do README principal do repositorio
- Consolidacao do backlog de pendencias tecnicas

## Backlog final de pendências técnicas (não resolvidas, registradas para referência)
1. Relógio da VM local dessincronizado
2. IP dinâmico da VM local (sem IP estático/reserva DHCP configurada)
3. Promtail não descobre containers de outros projetos Compose (Fase 7)
4. Imagens Docker customizadas não importadas para o containerd do k3s (Fase 11)
5. Integração técnica Prometheus + Kubernetes para medição real de SLO (Fase 12)

## Pendências resolvidas ao longo do projeto
- ~~Docker fura o UFW via iptables~~ — resolvido na Fase 13 com `ufw-docker`
