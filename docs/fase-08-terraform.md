# Fase 8 — Terraform (Infraestrutura como Código)

## Objetivo
Aprender os fundamentos e o fluxo de trabalho do Terraform (init, plan, apply, destroy) e o conceito de state, usando o provider Docker como ambiente de pratica antes de aplicar isso a infraestrutura real na nuvem (Fase 10).

## Arquitetura

main.tf + variables.tf (declaracao do estado desejado)
|
v
terraform init -> baixa o provider (docker)
|
v
terraform plan -> compara desejado vs real, mostra diferencas
|
v
terraform apply -> cria/altera recursos reais (Docker)
|
v
terraform.tfstate -> "retrato" do que foi criado (nunca versionar)
|
v
terraform destroy -> remove os recursos criados


## Tecnologias
Terraform 1.15, provider kreuzwerker/docker

## Comandos-chave
| Ação | Comando |
|---|---|
| Inicializar projeto (baixa providers) | `terraform init` |
| Ver plano de mudancas sem aplicar | `terraform plan` |
| Aplicar mudancas | `terraform apply` |
| Destruir recursos criados pelo Terraform | `terraform destroy` |
| Ver versao instalada | `terraform version` |

## Conceitos consolidados
- Terraform provisiona infraestrutura (VMs, redes); Docker Compose orquestra containers dentro de uma infra já existente
- Ciclo de trabalho: declarar -> init -> plan -> apply
- State (`terraform.tfstate`): "retrato" do que o Terraform acredita que existe; nunca deve ser versionado (pode conter dados sensíveis)
- `.terraform.lock.hcl` DEVE ser versionado — trava versão exata do provider, garantindo consistência entre ambientes/pessoas do time
- Infraestrutura descartável ("cattle" vs "pet"): destruir e recriar com confiança, ao invés de tratar cada recurso como único e precioso
- Terraform só gerencia o que está no seu próprio state — não interfere em recursos criados por fora dele (ex: containers do Docker Compose)
- Variáveis (`variables.tf` + `var.nome`) tornam o código reutilizável, evitando valores fixos espalhados

## Problema real enfrentado
**Sintoma:** `terraform destroy` falhou ao tentar remover a imagem `nginx:alpine`: `conflict: unable to remove repository reference (must force) - container ... is using its referenced image`.

**Causa raiz:** outro container (`nginx-proxy`, da Fase 5), parado mas ainda existente, também usava a mesma imagem `nginx:alpine` — o Docker impede remoção de imagem em uso, mesmo por container parado.

**Solução:** remoção do container antigo não utilizado (`docker rm nginx-proxy`), liberando a imagem para ser destruída pelo Terraform.

**Lição:** Terraform gerencia apenas seus próprios recursos (via state), mas recursos criados fora dele (Docker Compose, docker run manual) podem gerar conflitos de dependência compartilhada (ex: mesma imagem base).

## Pendências (sem alteração nesta fase)
1. Docker fura o UFW via iptables (Fase 13)
2. Relógio da VM dessincronizado
3. IP dinâmico da VM
4. Promtail não descobre containers de outros projetos Compose
