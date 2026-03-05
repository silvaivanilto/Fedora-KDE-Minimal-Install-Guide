#!/usr/bin/env bash
set -e
trap 'echo "Erro na linha $LINENO"; exit 1' ERR

[[ $EUID -ne 0 ]] && echo "Execute como root (sudo)." && exit 1

echo "--- Fedora KDE Plasma Minimal ---"

# Repositorios
echo "[1/5] Repositorios..."

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

# KDE Plasma (minimalista)
echo "[2/5] Pacotes..."

KDE_EXCLUDE_PKGS=(
  abrt*
  akonadi*
  audiocd-kio
  firewall-config
  intel*
  kdebugsettings
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
dnf install -y --allowerasing nvidia-driver nvidia-driver-cuda-libs nvidia-driver-libs nvidia-gpu-firmware nvidia-modprobe nvidia-persistenced nvidia-settings libnvidia-cfg libnvidia-gpucomp libnvidia-ml

# Mesa (AMD) e codecs: VA-API, VDPAU, Vulkan
dnf install -y --allowerasing mesa-dri-drivers mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers libva-utils ffmpeg switcheroo-control

# TLP: gerenciamento de energia
dnf install -y tlp tlp-pd tlp-rdw

# Aplicativos KDE
dnf install -y elisa-player kalk koko marknote merkuro okular skanpage

# Navegador
dnf install -y google-chrome-stable

# Office
dnf install -y onlyoffice-desktopeditors

# IDE
dnf install -y antigravity

# Containers
dnf install -y distrobox

# Ferramentas CLI
dnf install -y curl fastfetch fzf git unrar unzip

# Swap ZRAM por CachyOS Settings
echo "--- Configurando ZRAM com CachyOS Settings ---"
dnf swap -y zram-generator-defaults cachyos-settings --allowerasing

# Servicos
echo "[3/5] Servicos..."
systemctl mask systemd-rfkill.service systemd-rfkill.socket
systemctl enable tlp.service
systemctl enable tlp-pd.service
systemctl enable plasmalogin.service
systemctl enable switcheroo-control.service
systemctl set-default graphical.target

# Kernel e Boot
echo "[4/5] Configurando kernel e GRUB..."

# Hook de post-instalacao para manter o kernel CachyOS como padrao
mkdir -p /etc/kernel/postinst.d/
cat > /etc/kernel/postinst.d/99-default << 'EOL'
#!/bin/sh
set -e
grubby --set-default=/boot/$(ls /boot | grep vmlinuz.*cachy | sort -V | tail -1)
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

# Fontes Windows (por usuario)
echo "[5/5] Instalando fontes Windows..."
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
FONT_DIR="$REAL_HOME/.local/share/fonts/windows"
curl -Lo /tmp/winfonts.zip https://mktr.sbs/fonts
mkdir -p "$FONT_DIR"
unzip -o /tmp/winfonts.zip -d "$FONT_DIR"
chown -R "$REAL_USER":"$REAL_USER" "$REAL_HOME/.local/share/fonts"
rm -f /tmp/winfonts.zip
sudo -u "$REAL_USER" fc-cache -fv

echo "Concluido! Reinicie o sistema."