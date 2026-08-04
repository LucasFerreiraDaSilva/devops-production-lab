# DevOps Production Lab

Projeto de estudo prático em DevOps, construído de forma incremental: de um servidor Linux único até uma arquitetura completa com containers, CI/CD, observabilidade, Infraestrutura como Código, Kubernetes e Cloud.

Cada fase depende da anterior e representa uma etapa real de evolução de infraestrutura, como acontece em empresas que crescem de um MVP simples até uma arquitetura de produção madura.

## Objetivo

Aprender DevOps na prática, entendendo o "porquê" de cada decisão técnica — não apenas executar comandos, mas compreender arquitetura, trade-offs e boas práticas usadas no mercado.

## Progresso — Projeto Concluído ✅

- [x] Fase 1 — Servidor único (Linux, SSH, UFW, Nginx)
- [x] Fase 2 — Containerização com Docker
- [x] Fase 3 — Docker Compose (múltiplos serviços, rede interna)
- [x] Fase 4 — Git e GitHub
- [x] Fase 5 — Nginx como Reverse Proxy, SSL e DNS
- [x] Fase 6 — CI/CD com GitHub Actions
- [x] Fase 7 — Observabilidade (Prometheus, Grafana, Loki, Alertmanager)
- [x] Fase 8 — Terraform (Infraestrutura como Código)
- [x] Fase 9 — Ansible (Configuração automatizada)
- [x] Fase 10 — Azure (Cloud)
- [x] Fase 11 — Kubernetes
- [x] Fase 12 — Alta disponibilidade, escalabilidade e SRE
- [x] Fase 13 — Segurança avançada
- [x] Fase 14 — Consolidação final

## Documentação

Cada fase possui documentação detalhada em [`/docs`](./docs), incluindo objetivo, arquitetura, comandos utilizados, boas práticas e problemas reais enfrentados durante a implementação.

## Stack utilizada

**Infraestrutura e SO:** Linux (Ubuntu Server), VirtualBox, SSH, UFW
**Containers:** Docker, Docker Compose, Kubernetes (k3s)
**Reverse Proxy / Rede:** Nginx, SSL/TLS (certificados autoassinados)
**Versionamento e CI/CD:** Git, GitHub, GitHub Actions
**Observabilidade:** Prometheus, Grafana, Loki, Promtail, Alertmanager
**Infraestrutura como Código:** Terraform, Ansible (+ Ansible Vault)
**Cloud:** Microsoft Azure (VMs, redes, IPs públicos via Terraform)
**Segurança:** ufw-docker, Ansible Vault, hardening SSH

## Autor

Lucas Ferreira da Silva
