#!/usr/bin/env bash
set -e
trap 'echo "❌ Erro na linha $LINENO"; exit 1' ERR

[[ $EUID -ne 0 ]] && echo "❌ Execute como root (sudo)." && exit 1

echo "--- Instalação Fedora KDE Minimal ---"

# Repositórios
echo "[1/5] Repositórios..."
dnf config-manager addrepo --overwrite --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
dnf config-manager addrepo --overwrite --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
dnf config-manager setopt fedora-nvidia.priority=90 fedora-multimedia.priority=90
dnf install -y fedora-workstation-repositories
dnf config-manager setopt google-chrome.enabled=1
dnf copr enable -y bieszczaders/kernel-cachyos
dnf copr enable -y bieszczaders/kernel-cachyos-add-ons
dnf install -y https://repo.linrunner.de/fedora/tlp/repos/releases/tlp-release.fc$(rpm -E %fedora).noarch.rpm
dnf install -y https://download.onlyoffice.com/repo/centos/main/noarch/onlyoffice-repo.noarch.rpm

cat > /etc/yum.repos.d/antigravity.repo << 'EOL'
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL

# KDE Plasma (minimalista)
echo "[2/5] Pacotes..."
dnf group install -y kde-desktop \
  --exclude=sddm* \
  --exclude=plasma-welcome \
  --exclude=plasma-drkonqi \
  --exclude=kdeplasma-addons \
  --exclude=kdebugsettings \
  --exclude=akonadi* \
  --exclude=abrt* \
  --exclude=toolbox \
  --exclude=firewall-config \
  --exclude=intel* \
  --exclude=tuned* \
  --exclude=audiocd-kio \
  --exclude=plasma-thunderbolt \
  --skip-unavailable

# [2.1] Kernel CachyOS e Ferramentas (Antes da NVIDIA)
echo "--- Instalando Kernel CachyOS ---"
dnf install -y kernel-cachyos kernel-cachyos-devel-matched scx-scheds scx-tools

# Pacotes complementares (--allowerasing: ffmpeg substitui ffmpeg-free)
dnf install -y --allowerasing \
  plasma-login-manager \
  kcm-plasmalogin \
  nvidia-driver \
  nvidia-driver-libs \
  nvidia-driver-cuda-libs \
  nvidia-gpu-firmware \
  nvidia-modprobe \
  nvidia-persistenced \
  nvidia-settings \
  libnvidia-cfg \
  libnvidia-gpucomp \
  libnvidia-ml \
  tlp \
  tlp-rdw \
  tlp-pd \
  ffmpeg \
  distrobox \
  onlyoffice-desktopeditors \
  google-chrome-stable \
  antigravity \
  git \
  fzf \
  fastfetch \
  unrar \
  unzip \
  curl \
  switcheroo-control \
  mesa-dri-drivers \
  mesa-vulkan-drivers \
  mesa-va-drivers \
  mesa-vdpau-drivers \
  libva-utils \
  elisa \
  kalk \
  koko \
  marknotes \
  merkuro \
  okular \
  skanpage

# [2.2] Swap ZRAM por CachyOS Settings
dnf swap -y zram-generator-defaults cachyos-settings --allowerasing

# Serviços
echo "[3/5] Serviços..."
systemctl enable tlp.service
systemctl enable tlp-pd.service
systemctl mask systemd-rfkill.service systemd-rfkill.socket
systemctl enable plasmalogin.service
systemctl enable switcheroo-control.service
systemctl set-default graphical.target

# Kernel e Boot
echo "[4/5] Configurando kernel e GRUB..."

# SELinux para o kernel CachyOS
setsebool -P domain_kernel_load_modules on

# Script de post-instalação para manter o kernel CachyOS como padrão
mkdir -p /etc/kernel/postinst.d/
cat > /etc/kernel/postinst.d/99-default << 'EOL'
#!/bin/sh
set -e
grubby --set-default=/boot/$(ls /boot | grep vmlinuz.*cachy | sort -V | tail -1)
EOL
chown root:root /etc/kernel/postinst.d/99-default
chmod u+rx /etc/kernel/postinst.d/99-default

# Selecionar o kernel CachyOS imediatamente para o primeiro boot
CACHY_VMLINUZ=$(ls /boot/vmlinuz-*cachy* | sort -V | tail -1)
if [ -n "$CACHY_VMLINUZ" ]; then
    echo "--- Definindo $CACHY_VMLINUZ como kernel padrão ---"
    grubby --set-default="$CACHY_VMLINUZ"
fi

# Configurações do GRUB
grubby --update-kernel=ALL --args="rd.driver.blacklist=nouveau,nova_core modprobe.blacklist=nouveau,nova_core"
sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
grep -q 'GRUB_SAVEDEFAULT' /etc/default/grub || echo 'GRUB_SAVEDEFAULT=true' >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# Atualizar initramfs (focado no kernel CachyOS instalado)
CACHY_KVER=$(ls /lib/modules | grep cachy | sort -V | tail -1)
if [ -n "$CACHY_KVER" ]; then
    echo "--- Gerando initramfs para o kernel $CACHY_KVER ---"
    dracut -f --kver "$CACHY_KVER"
else
    dracut -f
fi

# Fontes Windows
echo "[5/5] Instalando fontes Windows..."
curl -Lo /tmp/winfonts.zip https://mktr.sbs/fonts
mkdir -p /usr/local/share/fonts/windows
unzip /tmp/winfonts.zip -d /usr/local/share/fonts/windows
rm -f /tmp/winfonts.zip
fc-cache -fv

echo "✅ Concluído! Reinicie o sistema."