# Fase 5 — Nginx Reverse Proxy, SSL e DNS

## Objetivo
Transformar o Nginx em um reverse proxy real na frente de múltiplos containers, implementando roteamento por path e HTTPS com certificado SSL.

## Arquitetura

Navegador
|
v
http://192.168.0.244 -> redireciona (301) para https
https://192.168.0.244
|
v
Nginx (container "proxy") - porta 80 (redirect) e 443 (SSL)
|
|-- location / -> container "site" (porta 80, interna)
`-- location /api/ -> container "api" (porta 5678, interna)


Apenas o container "proxy" expõe portas ao host. "site" e "api" são acessíveis somente dentro da rede Docker.

## Tecnologias
Nginx:alpine, OpenSSL (certificado autoassinado), Docker Compose

## Comandos-chave
| Ação | Comando |
|---|---|
| Gerar certificado autoassinado | `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ... -out ... -subj "..."` |
| Testar HTTPS ignorando validação de certificado | `curl -vk https://localhost` |
| Ver portas escutando | `sudo ss -tulpn \| grep :80` |
| Testar conectividade de porta (Windows) | `Test-NetConnection -ComputerName <ip> -Port <porta>` |
| Limpar cache ARP (Windows) | `arp -d *` |
| Ver containers com nome conflitante | `docker ps -a \| grep <nome>` |
| Remover container parado | `docker rm <nome>` |

## Conceitos consolidados
- Reverse proxy: papel de ponto único de entrada, roteamento por path
- SSL/TLS termination: criptografia tratada centralizadamente no proxy
- Diferença entre certificado autoassinado (dev/lab) e validado por CA (produção)
- "Criptografia funcionando" != "certificado confiável" — são coisas distintas
- Isolamento de rede: serviços internos sem exposição direta de porta

## Problemas reais enfrentados

### 1. Conflito de IP na rede local (ARP)
**Sintoma:** SSH parou de conectar após reboot da VM ("Connection refused", depois "Connection reset").
**Causa raiz:** outro dispositivo da rede assumiu o IP 192.168.0.18 via DHCP enquanto a VM estava reiniciando; cache ARP do Windows apontava para o MAC errado.
**Solução:** identificação via `arp -a` comparado com `ip link show`; limpeza do cache ARP (`arp -d *`); VM recebeu novo IP (192.168.0.244) do DHCP.
**Pendência gerada:** configurar IP estático/reserva DHCP para evitar recorrência.

### 2. Porta 80 ocupada
**Sintoma:** erro esperado de bind ao subir o container proxy.
**Causa raiz:** Nginx nativo da Fase 1 ainda rodando direto no sistema operacional.
**Solução:** `systemctl stop nginx` e `systemctl disable nginx` — decisão consciente de aposentar o Nginx nativo em favor da arquitetura containerizada.

### 3. Conflito de nomes de container entre fases
**Sintoma:** `Conflict. The container name "/minha-api" is already in use`.
**Causa raiz:** containers de fases anteriores (Fase 2 e 3) continuavam existindo (parados) na VM, reservando os nomes.
**Solução:** remoção dos containers antigos com `docker rm`.

### 4. Erro de caminho relativo no OpenSSL
**Sintoma:** `Can't open "nginx/certs/selfsigned.key" for writing, No such file or directory`.
**Causa raiz:** comando executado de dentro da própria pasta `nginx/certs`, duplicando o caminho relativo.
**Solução:** `cd` para a pasta raiz do projeto antes de rodar o comando; lição: sempre `pwd` antes de comandos com caminho relativo.

## Pendências atualizadas
1. Docker fura o UFW via iptables (Fase 13)
2. Relógio da VM dessincronizado
3. **IP dinâmico da VM causando instabilidade — configurar IP estático/reserva DHCP**
