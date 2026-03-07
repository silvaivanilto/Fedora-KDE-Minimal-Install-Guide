#!/usr/bin/env bash
set -euo pipefail
trap 'echo "Erro na linha $LINENO"; exit 1' ERR

[[ $EUID -ne 0 ]] && echo "Execute como root (sudo)." && exit 1

echo "--- Fedora KDE Plasma Minimal ---"

# Repositorios
echo "[1/4] Repositorios..."

# Negativo17: drivers NVIDIA e multimedia
dnf config-manager addrepo --overwrite --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
dnf config-manager addrepo --overwrite --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
dnf config-manager setopt fedora-nvidia.priority=90 fedora-multimedia.priority=90

# Google Chrome
dnf install -y fedora-workstation-repositories
dnf config-manager setopt google-chrome.enabled=1

# Kernel CachyOS (COPR)
dnf copr enable -y bieszczaders/kernel-cachyos
dnf copr enable -y bieszczaders/kernel-cachyos-addons

# TLP: gerenciamento de energia
dnf install -y "https://repo.linrunner.de/fedora/tlp/repos/releases/tlp-release.fc$(rpm -E %fedora).noarch.rpm"

# OnlyOffice
dnf install -y https://download.onlyoffice.com/repo/centos/main/noarch/onlyoffice-repo.noarch.rpm

# Antigravity
cat > /etc/yum.repos.d/antigravity.repo << 'EOL'
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL

# Docker
dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

# KDE Plasma (minimalista)
echo "[2/4] Pacotes..."

KDE_EXCLUDE_PKGS=(
  abrt*
  akonadi*
  audiocd-kio
  firewall-config
  intel*
  kdebugsettings
  khelpcenter
  kdeplasma-addons
  plasma-drkonqi
  plasma-thunderbolt
  plasma-welcome
  power-profiles-daemon
  sddm*
  toolbox
  tuned*
)

# shellcheck disable=SC2046
dnf group install -y kde-desktop $(printf -- '--exclude=%s ' "${KDE_EXCLUDE_PKGS[@]}") --skip-unavailable

# Kernel CachyOS e Ferramentas (antes da NVIDIA)
echo "--- Instalando Kernel CachyOS ---"
dnf install -y kernel-cachyos kernel-cachyos-devel-matched scx-scheds scx-tools

# KDE: login manager
dnf install -y --allowerasing plasma-login-manager kcm-plasmalogin

# Drivers NVIDIA
dnf install -y --allowerasing nvidia-driver nvidia-gpu-firmware nvidia-settings

# Mesa (AMD) e codecs: VA-API, VDPAU, Vulkan
dnf install -y --allowerasing mesa-dri-drivers mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers ffmpeg

# TLP: gerenciamento de energia
dnf install -y tlp tlp-pd tlp-rdw

# Aplicativos KDE
dnf install -y elisa-player kalk koko marknote merkuro okular plasma-firewall skanpage

# Navegador
dnf install -y google-chrome-stable

# Office
dnf install -y onlyoffice-desktopeditors

# IDE
dnf install -y antigravity

# Containers
dnf install -y docker-ce docker-ce-cli containerd.io distrobox

# Ferramentas CLI
dnf install -y bash-color-prompt curl fastfetch fzf git unrar unzip switcheroo-control libva-utils

# Swap ZRAM por CachyOS Settings
echo "--- Configurando ZRAM com CachyOS Settings ---"
dnf swap -y zram-generator-defaults cachyos-settings --allowerasing

# Servicos
echo "[3/4] Servicos..."

# Desativa rfkill (conflita com TLP)
systemctl mask systemd-rfkill.service systemd-rfkill.socket
# Gerenciamento de energia (bateria)
systemctl enable tlp.service
# TLP: deteccao de dock/AC
systemctl enable tlp-pd.service
# Login manager do KDE Plasma
systemctl enable plasmalogin.service
# Switching GPU hibrida AMD/NVIDIA
systemctl enable switcheroo-control.service
# Runtime de containers
systemctl enable docker.service
# Boot direto na interface grafica
systemctl set-default graphical.target

# Adicionar usuario ao grupo docker (sem precisar sudo)
usermod -aG docker "${SUDO_USER:?Execute com sudo}"

# Kernel e Boot
echo "[4/4] Configurando kernel e GRUB..."

# Hook de post-instalacao para manter o kernel CachyOS como padrao
mkdir -p /etc/kernel/postinst.d/
cat > /etc/kernel/postinst.d/99-default << 'EOL'
#!/bin/sh
set -e
grubby --set-default="$(printf '%s\n' /boot/vmlinuz-*cachy* | sort -V | tail -1)"
EOL
chown root:root /etc/kernel/postinst.d/99-default
chmod u+rx /etc/kernel/postinst.d/99-default

# Selecionar o kernel CachyOS para o primeiro boot
CACHY_VMLINUZ=$(printf '%s\n' /boot/vmlinuz-*cachy* | sort -V | tail -1)
if [ -n "$CACHY_VMLINUZ" ]; then
    echo "--- Definindo $CACHY_VMLINUZ como kernel padrao ---"
    grubby --set-default="$CACHY_VMLINUZ"
fi

# Configuracoes do GRUB
grubby --update-kernel=ALL --args="rd.driver.blacklist=nouveau,nova_core modprobe.blacklist=nouveau,nova_core"
sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
grep -q 'GRUB_SAVEDEFAULT' /etc/default/grub || echo 'GRUB_SAVEDEFAULT=true' >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# Atualizar initramfs (focado no kernel CachyOS instalado)
CACHY_KVER=$(printf '%s\n' /lib/modules/*cachy* | sort -V | tail -1)
CACHY_KVER=$(basename "$CACHY_KVER")
if [ -n "$CACHY_KVER" ]; then
    echo "--- Gerando initramfs para o kernel $CACHY_KVER ---"
    dracut -f --kver "$CACHY_KVER"
else
    dracut -f
fi

echo "Concluido! Reinicie o sistema."