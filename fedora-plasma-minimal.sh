#!/usr/bin/env bash

# Verificação de sudo e Integridade de execução
set -euo pipefail
trap 'echo "Erro na linha $LINENO em: $BASH_COMMAND"; exit 1' ERR
[[ $EUID -ne 0 ]] && echo "Execute com: sudo $0" && exit 1

# Inicialização do Log Automático
LOG_FILE="fedora-install-$(date +%Y%m%d-%H%M%S).txt"
exec > >(tee -i "$LOG_FILE") 2>&1

echo "=== Instalação do KDE Plasma Minimal — Fedora ==="
echo "Logs gravados automaticamente em: $LOG_FILE"


# ------------------------------------------------------------------------------
# [1/5] Inicialização: Fontes de Software e Repositórios
# ------------------------------------------------------------------------------
echo "[1/5] Preparando fontes de software e repositórios..."

# Otimização de Velocidade Global do Motor DNF5
dnf config-manager setopt max_parallel_downloads=10 fastestmirror=True

dnf install -y dnf-plugins-core fedora-workstation-repositories grubby pciutils

# Repositórios Negativo17 (Drivers e Multimídia)
dnf config-manager addrepo --overwrite --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
dnf config-manager addrepo --overwrite --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
dnf config-manager setopt fedora-nvidia.priority=90 fedora-multimedia.priority=90

# Kernel CachyOS (COPR)
dnf copr enable -y bieszczaders/kernel-cachyos
dnf copr enable -y bieszczaders/kernel-cachyos-addons

# KDE Desktop Beta (COPR)
dnf copr enable -y @kdesig/kde-beta

# Repositórios RPM Fusion (Free e Nonfree)
dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Repositório Antigravity
cat > /etc/yum.repos.d/antigravity.repo << 'EOF'
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOF

# Repositório do Google Chrome
dnf config-manager setopt google-chrome.enabled=1


# ------------------------------------------------------------------------------
# [2/5] Atualização: Upgrade de Pacotes do Sistema
# ------------------------------------------------------------------------------
echo "[2/5] Atualizando os pacotes do sistema..."

dnf makecache --refresh
dnf upgrade -y


# ------------------------------------------------------------------------------
# [3/5] Instalação: Ambiente Desktop, Kernel e Drivers Híbridos
# ------------------------------------------------------------------------------
echo "[3/5] Instalando ambiente desktop, kernel e drivers..."

# Configuração de pacotes excluídos para um KDE Minimal
KDE_EXCLUDE=(
    "abrt*" "firewall-config" "intel*"
    "audiocd-kio" "kdebugsettings" "khelpcenter" 
    "kdeplasma-addons" "plasma-drkonqi" "plasma-thunderbolt" 
    "plasma-welcome" "plasma-workspace-wallpapers"
)

# Instalação do grupo KDE com exclusões
dnf group install -y kde-desktop $(printf -- '--exclude=%s ' "${KDE_EXCLUDE[@]}") --skip-unavailable

# Kernel CachyOS e ferramentas de performance
dnf install -y kernel-cachyos kernel-cachyos-devel-matched scx-scheds scx-tools ananicy-cpp

# Drivers de Vídeo e Firmwares (Híbrido AMD + NVIDIA)
dnf install -y --allowerasing nvidia-driver nvidia-gpu-firmware nvidia-settings libva-nvidia-driver amd-gpu-firmware --skip-unavailable

dnf install -y --allowerasing mesa-dri-drivers mesa-vulkan-drivers ffmpeg --skip-unavailable

# Aplicativos Core e Utilitários
dnf install -y \
    elisa-player haruna kalk koko marknote merkuro okular \
    plasma-firewall skanpage kdepim-runtime \
    google-chrome-stable ayugram-desktop antigravity \
    curl fastfetch fzf git unrar unzip \
    switcheroo-control libva-utils fwupd podman-docker podman-compose flatpak

# Tela de Boot Animada (Plymouth Spinner Padrão)
dnf install -y plymouth plymouth-system-theme plymouth-theme-spinner
plymouth-set-default-theme spinner

# Instalação de fontes Microsoft (Core Fonts)
dnf install -y cabextract mkfontscale xset xorg-x11-font-utils
rpm -ivh --replacepkgs --nodigest --nofiledigest https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Suíte de Produtividade (LibreOffice)
dnf group install -y libreoffice --skip-unavailable

# Repositório de Aplicativos Flatpak (Flathub)
flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo


# ------------------------------------------------------------------------------
# [4/5] Otimização: Ajustes de Sistema e Performance
# ------------------------------------------------------------------------------
echo "[4/5] Aplicando ajustes de sistema e performance..."

# Troca de zRAM por configurações de performance CachyOS
dnf swap -y zram-generator-defaults cachyos-settings --allowerasing

# Configuração de Gerenciamento de Energia NVIDIA
cat > /etc/modprobe.d/nvidia.conf << 'EOF'
options nvidia NVreg_DynamicPowerManagement=0x02
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

# Configuração do Loader SCX
cat > /etc/scx_loader.toml << 'EOF'
# Configuração padrão de scheduler BPF
default_sched = "scx_bpfland"
default_mode = "Auto"
EOF


# ------------------------------------------------------------------------------
# [5/5] Finalização: Serviços e Configuração de Boot
# ------------------------------------------------------------------------------
echo "[5/5] Finalizando serviços e configuração de boot..."

# Sincronização de Relógio de Hardware (UTC) para consistência no Dual-Boot
timedatectl set-local-rtc 0

# Ativa o login da interface gráfica KDE
systemctl enable plasmalogin.service

# Habilita o canal de Contêineres (Socket) para IDEs como VS Code Globalmente
systemctl --global enable podman.socket

# Loader de schedulers BPF (CachyOS)
systemctl enable scx_loader.service

# Priorizador de processos para performance
systemctl enable ananicy-cpp.service

# Controle de GPUs híbridas
systemctl enable switcheroo-control.service

# Define a interface gráfica como padrão no boot
systemctl set-default graphical.target

# Hook de Kernel para manter o CachyOS como padrão
mkdir -p /etc/kernel/postinst.d
cat > /etc/kernel/postinst.d/99-default << 'EOF'
#!/bin/sh
set -e
grubby --set-default=/boot/$(ls /boot | grep vmlinuz.*cachy | sort -V | tail -1)
EOF

chmod u+rx /etc/kernel/postinst.d/99-default

# Atualização de Parâmetros do Kernel e GRUB (Habilita Boot Silencioso e Plymouth)
grubby --update-kernel=ALL --args="rhgb quiet vt.global_cursor_default=0 rd.driver.blacklist=nouveau,nova_core modprobe.blacklist=nouveau,nova_core nvidia-drm.modeset=1"

# Remoção de kernels antigos (Mantém apenas o CachyOS)
echo "Limpando kernels antigos do Fedora..."
dnf remove -y kernel kernel-core kernel-modules kernel-devel --exclude="*cachyos*" || true

# Configuração da Memória de Boot do GRUB (SAVEDEFAULT)
echo "Salvando o último kernel inicializado como padrão no GRUB..."
sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
grep -q 'GRUB_SAVEDEFAULT' /etc/default/grub || echo 'GRUB_SAVEDEFAULT=true' >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# Refresh do Initramfs (Compilando o Plymouth no Boot do CachyOS)
CACHY_KVER=$(ls /lib/modules | grep cachy | sort -V | tail -1)
dracut -f --kver "$CACHY_KVER"

echo "=== Instalação Concluída! ==="

# Finalização: Informa sobre o log, ajusta permissões e encerra
echo ""
chown "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" "$LOG_FILE"
echo "O log completo da instalação foi salvo em: $LOG_FILE"

echo "--------------------------------------------------------"
echo "Sistema pronto! Reinicie agora com: sudo reboot"
echo "--------------------------------------------------------"

