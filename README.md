# 🚀 Fedora KDE Plasma Minimal Install Guide

Este repositório contém um guia otimizado e um script automatizado para transformar uma instalação **Fedora Everything (Minimal)** em um ambiente **KDE Plasma 6** de alta performance, focado em minimalismo e eficiência.

> [!IMPORTANT]
> Este guia foi otimizado para hardware híbrido (**AMD + NVIDIA**) e utiliza tecnologias de ponta como o **Kernel CachyOS** e **Schedulers BPF**.

---

## 🛠️ O que o Script faz?

O `fedora-plasma-minimal.sh` automatiza 5 etapas cruciais:

1.  **Repositórios Elite**: Configura Negativo17 (Prioritário), RPM Fusion, Google Chrome e CachyOS.
2.  **Kernel Performance**: Instala o Kernel CachyOS para menor latência e maior fluidez.
3.  **KDE Minimal**: Instala apenas o essencial do Plasma 6, removendo bloatware nativo (ABRT, ajuda, ícones legados).
4.  **Drivers Híbridos**: Configura a GTX 1650 (NVIDIA) e a Vega 10 (AMD) com aceleração VA-API no Wayland.
5.  **Fontes & Produtividade**: Instala fontes Microsoft Core Fonts e aplicativos essenciais (Chrome, AyuGram, LibreOffice).

---

## 🚀 Como usar (Passo a Passo)

### 1. Requisitos Iniciais
Instale o Fedora utilizando a ISO **Everything** e selecione "Minimal Install". Após o primeiro boot, certifique-se de estar conectado à internet.

### 2. Prepare o Script
Clone este repositório ou baixe apenas o script:
```bash
git clone https://github.com/silvaivanilto/Fedora-KDE-Minimal-Install-Guide.git
cd Fedora-KDE-Minimal-Install-Guide
```

### 3. Dê permissão de execução
```bash
chmod +x fedora-plasma-minimal.sh
```

### 4. Execute a Instalação
O script cuidará de tudo para você:
```bash
sudo ./fedora-plasma-minimal.sh
```

---

## 💎 Aplicativos Incluídos
*   **Navegador**: Google Chrome Stable
*   **Comunicação**: AyuGram Desktop (via RPM Fusion)
*   **Escritório**: Suíte LibreOffice completa
*   **Utilitários**: Fastfetch (info), FZF (busca), Okular (PDF), Elisa (Música)
*   **Fontes**: Microsoft Core Fonts (Arial, Times New Roman, etc.)

---

## 🏎️ Otimizações de Performance Incluídas
*   **zRAM**: Substituído por configurações de performance do CachyOS.
*   **SCX Loader**: Ativa schedulers modernos como o `scx_bpfland`.
*   **NVIDIA Wayland**: Blacklist de drivers conflitantes (`nouveau`, `nova_core`) e ativação do `nvidia-drm.modeset=1`.
*   **Power Management**: Gerenciamento dinâmico de energia para notebooks (Optimus).

---

## 🤝 Créditos
*   **Drivers**: [Negativo17](https://negativo17.org/)
*   **Kernel**: [CachyOS Team](https://cachyos.org/)
*   **Frequência**: Antigravity RPM Repository

---

**Ficou tudo certo! Obrigado por usar este guia.**
**Fim. Tchau!** 🚀
