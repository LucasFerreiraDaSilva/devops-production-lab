# Fase 2 — Containerização com Docker

## Objetivo
Entender containerização na prática, construindo uma imagem Docker própria a partir de um Dockerfile, e compreender como containers se relacionam com volumes, rede e o host.

## Arquitetura
VM Ubuntu
|
|-- Nginx nativo (Fase 1)         -> porta 80
|-- Container "web" (herdado)     -> porta 8080 -> volume bind mount
`-- Container "meu-site" (novo)   -> porta 8081 -> imagem própria (meu-site:v1)

## Tecnologias
Docker Engine 29, Dockerfile, Nginx:alpine

## Comandos-chave
| Ação | Comando |
|---|---|
| Listar containers (todos) | `docker ps -a` |
| Inspecionar container | `docker inspect <nome>` |
| Ver volumes de um container | `docker inspect <nome> --format '{{json .Mounts}}'` |
| Build de imagem | `docker build -t <nome>:<tag> .` |
| Rodar container | `docker run -d --name <nome> -p <host>:<container> <imagem>` |
| Testar DNS em container | `docker run --rm busybox nslookup <dominio>` |
| Configurar DNS do daemon | editar `/etc/docker/daemon.json` |
| Reiniciar Docker | `sudo systemctl restart docker` |

## Conceitos consolidados
- Container vs VM (isolamento de kernel vs virtualização de hardware)
- Camadas de imagem e cache de build
- Bind mounts (dados sobrevivem à destruição do container)
- `EXPOSE` é documentação, não abre porta de fato
- Boas práticas de tag (nunca só `latest` em produção)

## Problema real enfrentado
**Sintoma:** `docker build` falhava ao resolver `registry-1.docker.io` (timeout de DNS).

**Investigação:** isolamos camada por camada (rede da VM -> DNS do host -> DNS do Docker daemon -> teste com `ping` vs `docker pull`).

**Descoberta:** parte do problema era falso positivo (bloqueio de ICMP, não DNS real); a correção efetiva foi reiniciar o Docker daemon após configurar `/etc/docker/daemon.json`.

**Lição:** nem toda falha após uma correção significa que a correção estava errada — é preciso isolar antes de concluir.

## Pendências registradas
1. Docker "fura" o UFW via iptables — portas publicadas ficam acessíveis mesmo sem regra explícita no UFW (resolver na Fase 13 - Segurança)
2. Relógio da VM dessincronizado (resolver antes da Fase 5/6)
