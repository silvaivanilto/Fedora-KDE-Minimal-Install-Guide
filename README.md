# 🚀 Fedora KDE Plasma Minimal Install Guide

![Fedora](https://img.shields.io/badge/Fedora-44-blue?style=for-the-badge&logo=fedora)
![KDE Plasma](https://img.shields.io/badge/KDE_Plasma-6.6-1d99f3?style=for-the-badge&logo=kde)
![Wayland](https://img.shields.io/badge/Wayland-Pure-success?style=for-the-badge)
![Architecture](https://img.shields.io/badge/Arch-Pure_64--bit-purple?style=for-the-badge)

Este repositório contém um **guia cirúrgico e um script automatizado (`fedora-plasma-minimal.sh`)** projetado para decolar a partir de uma instalação cega do **Fedora Everything (Minimal)** e construir um ambiente de altíssima performance estruturado tijolo-por-tijolo.

> [!IMPORTANT]
> **Arquitetura Alvo:** Otimizado especialmente para Hardwares Híbridos modernos (**Acer Nitro 5 / Ryzen 7 Zen+ / Nvidia Optimus**) operando puramente em 64-bits (sem resquícios `.i686`). Utiliza tecnologias avançadas como **Kernel CachyOS**, **Schedulers BPF** e módulos nativos multimídia para total supressão de uso da CPU na renderização de vídeos.

---

## 🛠️ A Engenharia por trás do Script

Diferente de instaladores comuns, este projeto implementa práticas avançadas de *Sysadmin*:

1. **Blindagem Anti-Falhas e Logging (`set -euo pipefail`)**: 
   A instalação é monitorada milissegundo a milissegundo. Qualquer falha de repositório aborta a instalação para proteger a máquina, gerando um log completo de auditoria (`fedora-install-[Data].txt`) automaticamente na sua pasta pessoal.
   
2. **Repositórios de Elite (Negativo17)**: 
   Foge das compilações genéricas do Fedora. Usa *Negativo17* para entregar os drivers NVIDIA puríssimos, e o FFmpeg "super-carregado", habilitando `NVENC/CUDA` em tocadores nativos como `Haruna`/`MPV` em 0% de uso de CPU.

3. **Arquitetura Purista Minimalista**: 
   Instala o `kde-desktop` removendo propositalmente 10+ metapacotes inúteis (Bloatwares como telemetria, centrais de ajuda legadas, pacotes de crash reporting e modems Intel). Todo o legado `32-bits` foi limpo!

4. **Schedulers BPF Avançados**: 
   Substitui o escalonador Linux padrão pelo `scx_bpfland`, criando uma "consciência de topologia" para processadores Ryzen (evitando *Thermal Throttling* e migração excessiva de *threads*).

5. **Bloqueio de Regressões do Boot**: 
   Um `Hook` customizado em `/etc/kernel/postinst.d/99-default` monitora ativamente as atualizações futuras e garante que o Grub **sempre** force o mais novo Kernel CachyOS como dominante, excluindo kernels RedHat fantasmas da memória.

---

## 🚀 Como Executar a Instalação

### 1. Ponto de Partida
Baixe a [ISO Everything do Fedora](https://fedoraproject.org/everything/). Na interface Anaconda, selecione a categoria de software: **Minimal Install** e selecione "NetworkManager submodules". Deixe a máquina reiniciar na tela preta apenas com acesso à internet.

### 2. Download da Instalação
Clone este repositório ou baixe o script:
```bash
git clone https://github.com/silvaivanilto/Fedora-KDE-Minimal-Install-Guide.git
cd Fedora-KDE-Minimal-Install-Guide
```

### 3. Permissão e Disparo
Configure a execução e inicie o canhão (O script rodará de forma 100% autônoma até o fim):
```bash
chmod +x fedora-plasma-minimal.sh
sudo ./fedora-plasma-minimal.sh
```

---

## 💎 Aplicativos Base Inclusos
* **Navegador**: Google Chrome Stable
* **Vídeo e Áudio**: Haruna (Player Wayland/CUDA) e Elisa
* **Comunicação**: AyuGram Desktop (via Antigravity Repo)
* **Escritório e Produtividade**: LibreOffice completo, Marknote, Merkuro, Okular
* **Utilitários Híbridos**: `switcheroo-control` (clique direito > *abrir com NVIDIA*), `fwupd`, `podman-docker`
* **Estética**: Microsoft Core Fonts (Arial, Times... exclusão no erro de documentos de trabalho)

---

## 🤝 Créditos Técnicos
* **Negativo17** - Repositórios de Hardware Nvidia e Codecs Multimídia.
* **CachyOS Team (Bieszczaders Copr)** - Kernels de ultrabaixa latência (BORE) e Schedulers Scx.
* **Projeto Antigravity** - Integrações avançadas e repositórios paralelos.

> *Criado para extrair cada gota de FPS e bateria do seu laptop, sem sacrificar a beleza do Plasma 6.*
