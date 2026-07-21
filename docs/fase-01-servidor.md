# Fase 1 — Servidor Único

## Objetivo
Provisionar e proteger um servidor Linux único, servindo como base para toda a infraestrutura futura, seguindo princípios básicos de acesso remoto e segurança.

## Arquitetura
Internet/Rede Local
|
Firewall (UFW) - deny incoming por padrão
| (portas liberadas: 22/tcp, 80/tcp)
VM Ubuntu Server (VirtualBox)
|
SSH (autenticação por chave pública apenas)
|
Nginx (servindo página estática, sem container)
## Tecnologias
Ubuntu Server, VirtualBox, OpenSSH, UFW, Nginx

## Comandos-chave
| Ação | Comando |
|---|---|
| Status do SSH | `sudo systemctl status ssh` |
| Verificar permissões sudo | `sudo -l` |
| Ativar firewall | `sudo ufw enable` |
| Liberar porta | `sudo ufw allow <porta ou perfil>` |
| Ver portas em uso | `sudo ss -tulpn` |
| Gerar chave SSH (host) | `ssh-keygen -t ed25519 -C "comentário"` |
| Desabilitar senha no SSH | editar `PasswordAuthentication no` em `/etc/ssh/sshd_config` |

## Boas práticas aplicadas
- Least privilege (sudo com senha, não irrestrito)
- Deny by default no firewall
- Ordem segura ao ativar firewall (liberar porta essencial antes de ativar)
- Autenticação por chave pública em vez de senha
- Nunca remover método de acesso sem validar o substituto primeiro

## Problemas encontrados
- `ufw status verbose` não mostrava regras com firewall inativo -> resolvido com `ufw show added`
