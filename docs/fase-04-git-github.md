# Fase 4 — Git e GitHub

## Objetivo
Versionar o projeto, eliminando dependência exclusiva da VM local, e publicar em repositório remoto (GitHub) como portfólio profissional.

## Arquitetura
VM (repositorio local)
|
|-- git init / git add / git commit
|
`-- git push (via SSH)
|
v
GitHub (repositorio remoto)
https://github.com/LucasFerreiraDaSilva/devops-production-lab

## Tecnologias
Git 2.34, GitHub, autenticação SSH (chave ed25519 dedicada VM -> GitHub)

## Comandos-chave
| Ação | Comando |
|---|---|
| Configurar identidade | `git config --global user.name/email` |
| Inicializar repositório | `git init` |
| Renomear branch padrão | `git branch -m main` |
| Ver status | `git status` |
| Adicionar ao stage | `git add .` |
| Commit | `git commit -m "tipo: mensagem descritiva"` |
| Adicionar remote | `git remote add origin <url>` |
| Enviar para o remoto | `git push -u origin main` |
| Testar autenticação SSH com GitHub | `ssh -T git@github.com` |
| Trocar remote de HTTPS para SSH | `git remote set-url origin git@github.com:...` |

## Conceitos consolidados
- Diferença entre master (legado) e main (padrão atual)
- Working directory -> Staging area -> Repository (commit)
- Conventional Commits (feat, fix, docs, chore, refactor)
- Autenticação Git via SSH (chave dedicada, separada da chave de acesso à VM)
- Boas práticas de .gitignore (nunca versionar segredos)

## Boas práticas aplicadas
- Chave SSH exclusiva para VM -> GitHub, separada da chave Windows -> VM
- Uso de Personal Access Token apenas como etapa transitória, substituído por SSH
- .gitignore criado desde o primeiro commit, prevendo fases futuras (Terraform)
