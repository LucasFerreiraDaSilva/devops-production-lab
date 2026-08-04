# Fase 13 — Segurança Avançada

## Objetivo
Resolver debitos tecnicos de seguranca acumulados no projeto (Docker furando o UFW) e implementar gerenciamento seguro de segredos com Ansible Vault, aplicando o principio de defesa em profundidade.

## Conceito central
Defesa em profundidade: multiplas camadas de protecao independentes, para que a falha de uma nao comprometa o sistema inteiro.

Camada 1: Firewall (UFW)
Camada 2: Autenticacao por chave SSH (sem senha)
Camada 3: UFW-Docker (fecha brecha do Docker no iptables)
Camada 4: Segredos criptografados (Ansible Vault)
Camada 5: Principio de menor privilegio (sudo com senha, nao NOPASSWD)


## Tecnologias
ufw-docker (integração UFW + Docker), Ansible Vault (AES256)

## Comandos-chave
| Ação | Comando |
|---|---|
| Instalar integracao ufw-docker | `sudo ufw-docker install` |
| Permitir explicitamente um container | `sudo ufw-docker allow <container> <porta>` |
| Criptografar arquivo com Vault | `ansible-vault encrypt <arquivo>` |
| Rodar playbook com segredo criptografado | `ansible-playbook ... --ask-vault-pass` |
| Editar arquivo criptografado | `ansible-vault edit <arquivo>` |
| Ver conteudo sem editar | `ansible-vault view <arquivo>` |

## Problemas resolvidos nesta fase

### 1. Docker furando o UFW via iptables (pendência desde a Fase 2)
**Causa raiz:** Docker manipula iptables diretamente, ignorando regras do UFW.
**Solução aplicada:** instalação do `ufw-docker`, script de integração que reconcilia as duas camadas sem desabilitar funcionalidade padrão do Docker.
**Validação:** porta 8080 (container `web`, exposta desde a Fase 2) testada e confirmada como bloqueada externamente apos a correcao, mesmo com o container publicando a porta normalmente.
**Trade-off:** containers agora exigem liberação explícita via `ufw-docker allow` para ficarem acessíveis de fora — mais seguro, exige um passo manual a mais.

### 2. Segredos em texto puro (risco latente desde a Fase 9)
**Solução aplicada:** Ansible Vault com criptografia AES256.
**Validação:** playbook consumindo segredo criptografado funcionou corretamente com senha do Vault; mesma execução sem a senha foi corretamente bloqueada pelo Ansible.

## Conceitos consolidados
- Defesa em profundidade: seguranca em camadas independentes
- Segredos nunca devem existir em texto puro em arquivos versionados
- Ansible Vault descriptografa apenas em memoria, durante a execucao — nunca expõe o valor em log/tela por padrão
- Ferramentas de automação podem introduzir brechas de segurança silenciosas (Docker x iptables) que só aparecem sob investigação ativa

## Pendências atualizadas
1. Relógio da VM dessincronizado (não resolvido)
2. IP dinâmico da VM local (não resolvido)
3. Promtail não descobre containers de outros projetos Compose (não resolvido)
4. Importar imagens Docker customizadas para o containerd do k3s (não resolvido)
5. Integração técnica Prometheus + Kubernetes para medição real de SLO (evolução futura)

~Docker fura o UFW via iptables~~ — **RESOLVIDO nesta fase**
