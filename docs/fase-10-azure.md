# Fase 10 — Microsoft Azure

## Objetivo
Provisionar infraestrutura real na nuvem (Azure) usando Terraform, conectando todo o aprendizado das fases anteriores (IaC, redes, SSH, seguranca) a um provedor cloud de producao, com IP publico real.

## Arquitetura final

Internet
|
v
IP Publico (Standard SKU) - 20.102.74.16
|
v
Network Security Group (NSG) - libera 22 (SSH) e 80 (HTTP)
|
v
Network Interface (NIC)
|
v
VM Linux (Standard_D2ads_v7, Ubuntu 22.04) - dentro de:
|
v
Subnet (10.0.1.0/24) dentro de Virtual Network (10.0.0.0/16)
|
v
Resource Group (rg-devops-lab) - container logico de tudo


## Tecnologias
Terraform (provider azurerm ~>3.0), Azure CLI, Azure Resource Manager

## Comandos-chave
| Ação | Comando |
|---|---|
| Login na Azure via CLI | `az login` |
| Ver assinatura ativa | `az account show` |
| Listar recursos de um grupo | `az resource list --resource-group <rg> --output table` |
| Ver tamanhos de VM disponiveis numa regiao | `az vm list-skus --location <regiao> --size <prefixo> --output table --all` |
| Ver cotas de vCPU por familia | `az vm list-usage --location <regiao> --output table` |
| Deletar um resource group (e tudo dentro) | `az group delete --name <rg> --yes --no-wait` |
| Confirmar exclusao completa | `az group exists --name <rg>` |
| Importar recurso existente para o state | `terraform import <tipo>.<nome> <resource_id>` |
| Aplicar evitando condicao de corrida | `terraform apply -parallelism=1` |
| Listar recursos no state | `terraform state list` |

## Conceitos consolidados
- Conta gratuita Azure: US$200/30 dias + 12 meses de servicos selecionados + 55+ sempre gratuitos
- Upgrade para pay-as-you-go nao gera cobranca automatica: e' preciso configurar orcamento/alertas por seguranca
- Resource Group como container logico: organiza e permite exclusao em cascata de tudo relacionado
- Location de um Resource Group e' imutavel: mudar exige destruir e recriar
- SKU de IP publico "Basic" foi descontinuado (30/set/2025); "Standard" e' obrigatorio agora, exige allocation_method="Static"
- VMs ARM64 (sufixo "p" no nome, ex: B2pts_v2) exigem imagem de SO compativel (sku "-arm64")
- Cota de vCPU por familia e' independente de "restricao de SKU" — uma pode estar OK e a outra zerada
- `az vm list-skus` mostra disponibilidade teorica; `az vm list-usage` mostra cota real da assinatura; nenhum dos dois sozinho garante que a criacao vai funcionar
- Regioes podem estar temporariamente restritas para uma assinatura especifica (comum apos upgrade de conta), independente de capacidade real do datacenter
- Bug conhecido do provider azurerm: "Provider produced inconsistent result after apply" por condicao de corrida — mitigado com `-parallelism=1` e, quando necessario, `terraform import` dos recursos que ja existiam de fato

## Problemas reais enfrentados (em ordem cronologica)

### 1. Chave SSH Ed25519 rejeitada pelo provider
**Erro:** `the provided ssh-ed25519 SSH key is not supported. Only RSA SSH keys are supported by Azure`
**Causa:** validacao propria do provider Terraform azurerm, mais restritiva que a API real da Azure.
**Solucao:** geracao de chave RSA 4096 dedicada (`azure-devops-lab-rsa`).

### 2. SKU de IP publico "Basic" indisponivel
**Erro:** `IPv4BasicSkuPublicIpCountLimitReached: Cannot create more than 0 IPv4 Basic SKU public IP addresses`
**Causa:** Basic SKU foi oficialmente descontinuado pela Microsoft em 30/09/2025.
**Solucao:** adicao de `sku = "Standard"` ao recurso `azurerm_public_ip`.

### 3. Capacidade indisponivel para Standard_B1s
**Erro:** `SkuNotAvailable ... capacity restrictions` em Brazil South e East US.
**Causa:** esgotamento real de capacidade fisica do datacenter para esse tamanho popular/legado, que esta sendo descontinuado.
**Tentativa de solucao:** troca de regiao (Brazil South -> East US), que forcou destroy+recreate de toda a infra dependente do Resource Group (location e' imutavel).

### 4. Bug de condicao de corrida no provider (recriacao em massa)
**Erro:** `Provider produced inconsistent result after apply ... Root object was present, but now absent`
**Causa:** bug conhecido do provider azurerm ao destruir/recriar multiplos recursos interdependentes em paralelo.
**Solucao:** `terraform apply -parallelism=1` (execucao sequencial) + `terraform import` dos recursos que foram criados de fato na Azure mas nao reconhecidos corretamente pelo Terraform apos o erro.

### 5. Cota zero para familia de VM ARM (Bpsv2)
**Erro:** `OperationNotAllowed ... exceeding approved standardBpsv2Family Cores quota ... Current Limit: 0`
**Causa:** cota por familia de VM zerada por padrao para essa assinatura, mesmo com o SKU teoricamente "disponivel" na regiao.
**Investigacao:** uso de `az vm list-usage` para identificar familias com cota > 0 (ex: `Standard BS Family`, `Standard DSv3 Family`, ambas com limite 10).

### 6. Infraestrutura duplicada apos criacao manual via Portal
**Causa:** apos multiplas falhas via Terraform, a VM foi criada manualmente pelo Portal Azure (que filtra e mostra apenas combinacoes realmente disponiveis), gerando recursos de rede paralelos aos ja existentes no state do Terraform, e uma VM com chave SSH gerada pela Azure (incompativel com nossa chave RSA gerenciada via Terraform).
**Solucao final:** reset completo (`az group delete` + limpeza do state local), identificacao do tamanho real e funcional (`Standard_D2ads_v7`) a partir da VM criada pelo Portal, e recriacao 100% via Terraform com esse tamanho confirmado.

## Licao central da fase
Provisionar infraestrutura em nuvem publica real envolve lidar com restricoes dinamicas de capacidade, cota e politica que nao existem em ambiente local/laboratorio. A estrategia eficaz nao foi "adivinhar" a configuracao certa, mas sim: (1) ler mensagens de erro com atencao, (2) consultar as APIs de disponibilidade/cota diretamente, e (3) quando a investigacao via CLI se esgota, usar o Portal como ferramenta de descoberta e trazer o resultado de volta para IaC — mantendo o codigo como fonte da verdade.

## Pendências atualizadas
1. Docker fura o UFW via iptables (Fase 13)
2. Relógio da VM dessincronizado (VM local)
3. IP dinâmico da VM local
4. Promtail não descobre containers de outros projetos Compose
5. **Lembrar de rodar `terraform destroy` na Fase 10 ao final dos testes, para nao gerar custo continuo na Azure**
