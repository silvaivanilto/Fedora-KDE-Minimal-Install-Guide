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
dnf config-manager setopt google-chrome.enabled=1
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
  --skip-unavailable

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
  libva-utils

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
grubby --update-kernel=ALL --args="rd.driver.blacklist=nouveau,nova_core modprobe.blacklist=nouveau,nova_core"
sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
grep -q 'GRUB_SAVEDEFAULT' /etc/default/grub || echo 'GRUB_SAVEDEFAULT=true' >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# Fontes Windows
echo "[5/5] Instalando fontes Windows..."
curl -Lo /tmp/winfonts.zip https://mktr.sbs/fonts
mkdir -p /usr/local/share/fonts/windows
unzip /tmp/winfonts.zip -d /usr/local/share/fonts/windows
rm -f /tmp/winfonts.zip
fc-cache -fv

echo "✅ Concluído! Reinicie o sistema."