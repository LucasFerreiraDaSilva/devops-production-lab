# Fase 3 — Docker Compose

## Objetivo
Substituir a criação manual e imperativa de containers (`docker run`) por uma composição declarativa de múltiplos serviços conectados, usando Docker Compose.

## Arquitetura
docker-compose.yml
|
|-- Rede: minha-rede (bridge)
|
|-- Serviço "site"
|     Container: meu-site-compose
|     Build: Dockerfile (nginx:alpine + HTML customizado)
|     Porta: 8082 (VM) -> 80 (container)
|
`-- Serviço "api"
Container: minha-api
Imagem: hashicorp/http-echo
Porta interna: 5678 (não exposta ao host)

## Tecnologias
Docker Compose v5, Nginx:alpine, hashicorp/http-echo

## Comandos-chave
| Ação | Comando |
|---|---|
| Subir toda a composição | `docker compose up -d` |
| Ver status dos serviços | `docker compose ps` |
| Ver logs de todos os serviços | `docker compose logs -f` |
| Entrar dentro de um container | `docker exec -it <container> sh` |
| Testar chamada interna entre serviços | `wget -O- http://<servico>:<porta>` |
| Parar sem remover | `docker compose stop` |
| Parar e remover containers/redes | `docker compose down` |

## Conceitos consolidados
- Declarativo (YAML) vs imperativo (`docker run`)
- `build:` vs `image:` dentro de um serviço
- Rede customizada conectando múltiplos serviços
- DNS interno automático entre containers pelo nome do serviço
- Prefixo automático de nomes evitando conflito entre projetos

## Validações feitas
- Página HTML acessível via navegador na porta 8082
- Comunicação container-a-container confirmada via `docker exec` + `wget` interno
