#!/bin/env bash
# Script de Instalação Fedora KDE Minimalista
# Objetivo: Instalação limpa, rápida e funcional.
set -e 

echo "--- Iniciando Instalação Minimalista ---"

# 1. Preparação de Repositórios
echo "[1/4] Configurando repositórios externos..."
dnf install -y 'dnf-command(config-manager)'
dnf config-manager addrepo --overwrite --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
dnf config-manager addrepo --overwrite --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
dnf config-manager setopt fedora-nvidia.priority=90

# Repositório TLP para economia de energia
dnf install -y https://repo.linrunner.de/fedora/tlp/repos/releases/tlp-release.fc$(rpm -E %fedora).noarch.rpm

# 2. Instalação de Pacotes
echo "[2/4] Instalando pacotes (isso pode demorar um pouco)..."

# Instalação do grupo KDE com exclusões específicas para minimalismo
dnf5 group install -y kde-desktop \
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

# Instalação dos pacotes complementares solicitados
dnf install -y --allowerasing \
  plasma-login-manager \
  kcm-plasmalogin \
  distrobox \
  ffmpeg \
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
  git \
  fzf \
  unrar \
  unzip \
  fastfetch

# 3. Configurações de Sistema e Serviços
echo "[3/4] Aplicando configurações e habilitando serviços..."

# Gerenciamento de Energia (TLP)
systemctl enable tlp.service
systemctl enable --now tlp-pd.service
systemctl mask systemd-rfkill.service systemd-rfkill.socket

# Interface e Login
systemctl enable --force plasmalogin.service
systemctl set-default graphical.target

# 4. Kernel e Boot
echo "[4/4] Configurando blacklist de drivers conflitantes (Nouveau/Nova)..."
grubby --update-kernel=ALL --args="rd.driver.blacklist=nouveau,nova_core modprobe.blacklist=nouveau,nova_core"

echo "------------------------------------------------"
echo "✅ Instalação concluída com sucesso!"
echo "⚠️  Por favor, reinicie o sistema para aplicar as mudanças."