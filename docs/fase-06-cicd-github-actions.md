# Fase 6 — CI/CD com GitHub Actions

## Objetivo
Implementar Integracao Continua (CI), automatizando build e validacao do projeto a cada push, eliminando a dependencia de testes manuais e detectando erros o mais cedo possivel (principio de "shift left").

## Arquitetura

git push (branch main)
|
v
GitHub Actions detecta o push
|
v
Runner temporario (ubuntu-latest, provisionado do zero)
|
|-- Checkout do codigo (actions/checkout@v4)
|-- Build da imagem Docker do site (Fase 3)
`-- Validacao de sintaxe do docker-compose (Fase 5)
|
v
Resultado: sucesso (verde) ou falha (vermelho), visivel no GitHub


## Tecnologias
GitHub Actions, YAML (workflow), Docker (build dentro do runner)

## Comandos-chave
| Ação | Comando/Local |
|---|---|
| Local do workflow | `.github/workflows/*.yml` (obrigatorio) |
| Trigger por push/PR | `on: push / pull_request: branches: [main]` |
| Definir onde o job roda | `runs-on: ubuntu-latest` |
| Clonar o repositorio no runner | `uses: actions/checkout@v4` |
| Rodar comando shell | `run: <comando>` |
| Validar sintaxe do Compose sem subir nada | `docker compose -f <arquivo> config` |
| Ver execuções | aba "Actions" do repositorio no GitHub |

## Conceitos consolidados
- Diferenca entre CI (integracao continua) e CD (entrega/deploy continuo)
- CI roda em ambiente limpo e neutro (nao herda "sujeira" da maquina local)
- CI nao bloqueia push por padrao — isso exige branch protection rules (nao configurado ainda)
- Exit code 0 = sucesso, != 0 = falha (padrao usado internamente pelo CI para decidir sucesso/erro)
- Principio de "shift left": quanto mais cedo um erro e' detectado, mais barato ele e' de corrigir
- Falha em um step cancela os steps seguintes por padrao

## Exercicio pratico realizado
Foi introduzido um erro proposital no Dockerfile (`FROM ngnix:alpine`, digitacao errada) para observar o comportamento de falha do pipeline.

**Resultado observado:**
- Pipeline falhou em ~3s no step de build
- Log apontou exatamente a causa raiz: `pull access denied, repository does not exist`, referenciando a linha exata do Dockerfile
- Step seguinte (validacao do compose) foi automaticamente pulado
- Apos correcao (`FROM nginx:alpine`) e novo push, pipeline voltou a passar

## Decisao de escopo
Deploy automatizado (CD) foi deliberadamente adiado para a Fase 10 (Azure), pois a VM atual esta em rede local sem IP publico, inviabilizando o GitHub Actions (rodando na nuvem do GitHub) de acessar a VM diretamente sem configuracao adicional (tunel ou runner self-hosted).

## Pendências (herdadas, sem alteração nesta fase)
1. Docker fura o UFW via iptables
2. Relógio da VM dessincronizado
3. IP dinâmico da VM
