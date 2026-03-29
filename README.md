# 🚀 Fedora KDE Plasma Minimal Install Guide

<div align="center">
  <img src="https://img.shields.io/badge/Fedora-44-blue?style=for-the-badge&logo=fedora" alt="Fedora" />
  <img src="https://img.shields.io/badge/KDE_Plasma-6.6-1d99f3?style=for-the-badge&logo=kde" alt="KDE" />
  <img src="https://img.shields.io/badge/Wayland-Pure-success?style=for-the-badge" alt="Wayland" />
  <img src="https://img.shields.io/badge/Arch-Pure_64--bit-purple?style=for-the-badge" alt="Arch" />
  <img src="https://img.shields.io/badge/Containers-Toolbox-blue?style=for-the-badge&logo=fedora" alt="Toolbox" />
</div>

<br>

Este repositório contém um **guia cirúrgico e um script automatizado (`fedora-plasma-minimal.sh`)** projetado para redefinir do zero uma instalação cega do **Fedora Everything (Minimal)** e construir um ecossistema Desktop de altíssima performance para "Power-Users".

> [!IMPORTANT]
> **Arquitetura Alvo:** Projetado sob-medida para Hardwares Híbridos exigentes (**Acer Nitro 5 / Ryzen 7 Zen+ / Nvidia Optimus**) operando puramente em 64-bits (sem bibliotecas residuais `.i686`). Utiliza tecnologias corporativas como **Kernel CachyOS**, **Schedulers BPF avançados**, **Motor Tuned de Energia**, e repositórios multimídia nativos para aceleração por hardware perfeita no Wayland.

---

## 🛠️ A Arquitetura Avançada do Script

Ao contrário de scripts leigos que apenas tentam remover pacotes após instalá-los, este projeto intercepta falhas e constrói a fundação com precisão *Sysadmin*:

1. **Blindagem e Logging (`set -euo pipefail`)**: 
   A instalação inteira é auditada frame-a-frame. Qualquer falha técnica (ex: queda de host de repositório) interrompe a alteração antes de estragar a máquina, gerando um log diagnóstico completo (`fedora-install-[Data].txt`).
   
2. **Abordagem Definitiva em Multimídia (Negativo17 vs RPMFusion)**: 
   O script extingue a dependência dos famosos "comandos gambiarra" dos antigos fóruns do Fedora (como a troca cansativa do grupo `@multimedia` e GStreamer do RPMFusion). Ele eleva a prioridade do pacote *Negativo17* à `90`, o que obriga o DNF a baixar o pacote `FFmpeg` original irrestrito e puro (com os encoders libVA NVIDIA pareados), desintegrando a versão `ffmpeg-free` legalmente castrada do Fedora no próprio ato da instalação.

3. **Automação de Dual-Boot no Relógio da BIOS**: 
   Uma orquestração rápida (`timedatectl set-local-rtc 0`) avisa ao Kernel para travar os ciclos da sua placa-mãe no relógio atômico Universal (UTC), poupando você das conhecidas "horas dessincronizadas" que assolam quem navega em máquinas com Windows dual-boot. *(Ps: É o Windows que tem dificuldade de ler RTC, basta aplicar a chave `RealTimeIsUniversal=1` também nele)*.

4. **KDE Plasma Minimal (Puro)**: 
   Uma instalação contundente do grupo `kde-desktop` rejeitando mais de 10 metapacotes inúteis no console. Sem widgets pesados, sem instaladores de crash (ABRT), sem modems legados. O peso de leitura do boot cai vertiginosamente.

5. **Regência de Energia Nível RHEL (Daemon Tuned)**: 
   O Fedora 41+ aboliu o superficial `power-profiles-daemon`. Consequentemente, o seu script aproveita o pacote `tuned-ppd` para fazer o **Desktop KDE se comunicar nativamente com motor Tuned**. Ao puxar o seletor da bateria na interface gráfica para *Economia* ou plugar ele na tomada em *Desempenho*, toda a P-State do Ryzen, Buffers de Rede e HDs SSDs são estranguladas ou esticadas simultaneamente para a máxima performance como se fosse o clássico pacote *TLP*.

6. **Bloqueio Inviolável no GRUB via Hook CachyOS**: 
   Um `Hook` escrito internamente em `/etc/kernel/postinst.d/99-default` vigia os diretórios do sistema a cada update. Ele destrói instantaneamente a preferência por Kernels normais do Fedora, mantendo eternamente o menu do GRUB forçando o uso do **CachyOS** para extrair BPFland de baixa latência no Wayland.

7. **Integração Absoluta com a RedHat Toolbox e VS Code IDE**: 
   Cumprindo rigorosamente o design original do Fedora, o sistema mantém o `toolbox` padrão da casa. No entanto, para satisfazer desenvolvedores exigentes, injetamos silenciosamente o par `podman-docker` e `podman-compose`, aliados à ativação Global do Sistema de Sockets Rootless (`systemctl --global enable podman.socket`). Esse tripé garante que extensões implacáveis da Microsoft (ex: *Dev Containers* do VS Code / Antigravity) enxerguem, invoquem e acessem contêineres e Toolboxes locais instantaneamente, com a mesma fluidez de um daemon docker-engine original (mantendo a segurança rootless).

8. **Sobrescrita do Estrangulador de Banda (DNF5)**: 
   Sendo letalmente racional, a primeira instrução matemática do script reescreve temporariamente o comportamento das portas lógicas do motor Red Hat (`max_parallel_downloads=10` e `fastestmirror=True`). Ignoramos as amarras conservadoras e multiplicamos os blocos de download do Servidor Mundial de menor latência geográfico, engolindo os milhares de pacotes da formatação no menor tempo físico que o seu roteador Fibra suportar.

---

## 🚀 Como Executar a Instalação Impecável

### 1. Preparação (ISO "Everything")
Baixe a [ISO Everything do Fedora](https://fedoraproject.org/everything/). Na interface do Anaconda, escolha o perfil **Minimal Install** e selecione "NetworkManager submodules". Conclua a instalação minimalista, formato os discos e certifique-se que subiu apenas uma tela preta solicitando "Log-in".

### 2. Download da Central de Formatação
No terminal TTY1 com Wi-Fi/cabo vivo:
```bash
git clone https://github.com/silvaivanilto/Fedora-KDE-Minimal-Install-Guide.git
cd Fedora-KDE-Minimal-Install-Guide
```

### 3. Disparo Total do Script
Mire e atire. (O script é 100% autônomo, baixando repositórios, injetando Kernels, Dracut, Plymouth com compilação e trocando RTCs).
```bash
chmod +x fedora-plasma-minimal.sh
sudo ./fedora-plasma-minimal.sh
```

---

## 💎 Aplicativos Core Selecionados a Dedo
O ambiente sobe de cara preenchendo as necessidades básicas essenciais do Power-User, mantendo zero redundâncias:
* **Escritório Minimalista**: LibreOffice completo, Marknote, Okular (Leitor Padrão Internacional).
* **Navegação Web e Dev**: Google Chrome Stable via repositório original (livre das amarras do Flatpak) e ambiente isolado via Toolbox.
* **Mídias Imparáveis**: Elisa (Música leve) e o soberano **Haruna (Motor MPV)** — O Haruna usa nativamente o `FFmpeg` do Negativo17, não encostando em um milímetro nas dezenas de bibliotecas bloatware do *GStreamer Video*. Decodificação de Hardware garantida.
* **Extras**: AyuGram Desktop, Controle Ativo Optimus Switcheroo.

---

> *Este repositório prova que o poder e customização de distribuições avulsas existem internamente dentro do próprio modelo de caixas da Red Hat se a sintaxe exata for aplicada no console. Manutenção e Atualizações Frequentes.*
