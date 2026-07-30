# Fase 9 — Ansible (Configuracao Automatizada)

## Objetivo
Aprender os fundamentos do Ansible (inventory, playbooks, tasks, modulos, idempotencia), automatizando configuracoes que antes eram feitas manualmente (Fase 1) e validando o ambiente Docker atual de forma idempotente.

## Arquitetura

inventory.ini -> define quais servidores existem (aqui: localhost)
|
v
playbook.yml -> receita de configuracao desejada (tasks)
|
v
ansible-playbook -> executa, comparando estado real vs desejado
|
v
Resultado: ok (sem mudanca) ou changed (mudanca aplicada) por task


## Tecnologias
Ansible 2.10 (modulos: apt, ufw, service, copy, user, command, debug)

## Comandos-chave
| Ação | Comando |
|---|---|
| Testar conectividade | `ansible <grupo> -i inventory.ini -m ping` |
| Rodar playbook | `ansible-playbook -i inventory.ini playbook.yml` |
| Rodar playbook pedindo senha de sudo | `ansible-playbook -i inventory.ini playbook.yml --ask-become-pass` |

## Conceitos consolidados
- Diferenca entre Terraform (infraestrutura/existencia) e Ansible (configuracao/estado interno)
- Ansible nao precisa de agente instalado no destino (usa SSH + Python)
- Idempotencia: rodar múltiplas vezes = mesmo resultado, sem efeitos colaterais repetidos
- `ok` vs `changed` no resultado: indica se uma task precisou alterar algo de fato
- Variáveis dentro do playbook (`vars:`) vs em arquivo separado (usado no Terraform) — ambos válidos, escolha depende da complexidade
- `register` + `changed_when: false` para capturar saída de comandos sem marcar falsa mudança
- Idempotência garante resultado consistente, mas não garante que o playbook reflete a intenção *atual* da infraestrutura — playbooks desatualizados podem reverter decisões arquiteturais válidas

## Problemas reais enfrentados

### 1. Sudo exigindo senha durante execução automatizada
**Sintoma:** `sudo: a password is required` ao rodar playbook com `become: true`.
**Causa:** usuário configurado com sudo exigindo senha (boa prática de segurança da Fase 1) conflitando com necessidade de automação sem interação.
**Solução (didática, para este lab):** uso de `--ask-become-pass` para fornecer a senha no momento da execução.
**Observação:** em produção, resolve-se com chaves dedicadas ou NOPASSWD granular para comandos específicos de automação.

### 2. Playbook reativou Nginx nativo, causando risco de conflito de porta
**Sintoma:** playbook que replicava a Fase 1 reativou o Nginx nativo (`systemctl start/enable nginx`), que havia sido deliberadamente desativado na Fase 5 para eliminar conflito de porta 80 com o container `nginx-proxy`.
**Causa raiz:** o playbook representava um estado antigo da arquitetura (pré-containerização completa), desatualizado em relação à evolução do projeto.
**Solução:** reversão manual (`stop` + `disable` do Nginx nativo) após o teste.
**Lição:** playbooks precisam ser mantidos sincronizados com a intenção *atual* da infraestrutura, não apenas serem tecnicamente corretos/idempotentes.
**AVISO:** `playbook-fase01.yml` não deve ser executado novamente sem revisão, pois reativa o Nginx nativo.

### 3. Conflito de pacotes ao tentar instalar Docker via apt (docker.io)
**Sintoma:** `E: Error, pkgProblemResolver::Resolve generated breaks` — `containerd.io : Conflicts: containerd`.
**Causa raiz:** VM já possuía Docker instalado via repositório oficial da Docker (pacote `containerd.io`), incompatível com o pacote `docker.io` do repositório padrão do Ubuntu.
**Solução:** playbook ajustado para **verificar** a presença do Docker (`docker --version`) em vez de tentar instalar via `apt`, respeitando a instalação já existente.

## Pendências (sem alteração nesta fase)
1. Docker fura o UFW via iptables (Fase 13)
2. Relógio da VM dessincronizado
3. IP dinâmico da VM
4. Promtail não descobre containers de outros projetos Compose
