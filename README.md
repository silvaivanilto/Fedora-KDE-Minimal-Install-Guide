# Fedora KDE Minimal Install Guide

A modern and streamlined guide/script to install a minimal Fedora KDE Plasma environment.

## Overview

This project provides a script to transform a "Minimal Install" of Fedora into a functional, lightweight KDE Plasma desktop. It avoids the bloat of the official spin by selecting only essential components.

## Features

- **Kernel CachyOS**: High-performance kernel with `scx` schedulers and custom optimizations.
- **KDE Plasma Minimal**: Installed with specific exclusions to remove unnecessary pre-installed apps.
- **Modern Power Management**: Uses `TLP` optimized for laptops.
- **NVIDIA Drivers**: Automated setup using the [Negativo17](https://negativo17.org/) repositories, installed after CachyOS kernel for maximum stability.
- **AMD GPU Support**: Mesa drivers with full codec support (VA-API/VDPAU) from Negativo17.
- **Hybrid GPU**: `switcheroo-control` for choosing between integrated and dedicated GPU.
- **Multimedia**: `ffmpeg` (Negativo17) and KDE apps like Elisa and Koko.
- **Applications**: Google Chrome, OnlyOffice, Kalk, Marknotes, Merkuro, Okular, Plasma Firewall, Skanpage.
- **IDE**: Antigravity (VS Code fork by Google).
- **Containers**: `Docker` (for Antigravity Dev Containers) and `distrobox` for running any Linux distribution inside your terminal.
- **Utilities**: `git`, `fzf`, `fastfetch`, `curl`, `unrar`, `unzip`, `libva-utils`.
- **GRUB & Boot**: Configured with `saved` default and a post-install hook to always boot the latest CachyOS kernel.
- **System Hardening**: Blacklists `nouveau` and `nova_core` drivers for NVIDIA stability.

## Prerequisites

1.  **Fedora Minimal Install**: Start with a "Minimal Install" from the Fedora Everything/Network ISO.
2.  **Internet Connection**: Required to download all components.
3.  **USB Drive**: Have the script available on a USB drive (pendrive).

## How to Use

1.  **Mount the USB drive and copy the script**:
    ```bash
    # Identify your USB drive
    lsblk

    # Mount and copy (adjust sdX1 as needed)
    mount /dev/sdX1 /mnt
    cp /mnt/fedora-plasma-minimal.sh /root/
    umount /mnt
    ```

2.  **Make it executable and run**:
    ```bash
    chmod +x /root/fedora-plasma-minimal.sh
    sudo /root/fedora-plasma-minimal.sh
    ```

3.  **Reboot** your system after the script finishes to enter your new KDE Plasma environment.

## Script Details

The `fedora-plasma-minimal.sh` is organized into 4 phases:

- **Phase 1: Repositories** — Adds Negativo17, TLP, OnlyOffice, Antigravity, Docker, Google Chrome, and Kernel CachyOS COPRs.
- **Phase 2: Packages** — Installs KDE Plasma (minimal), Kernel CachyOS (before NVIDIA), drivers, applications, Docker, and utilities.
- **Phase 3: Services** — Configures TLP, login manager, switcheroo-control, Docker, and Swap ZRAM for CachyOS settings.
- **Phase 4: Kernel & Boot** — Blacklists nouveau, installs CachyOS boot hook, and updates initramfs/dracut.

## Warning

This script modifies system repositories, services, and kernel parameters. It is designed for new, clean installations. Use at your own risk.

---
*Maintained for modern Fedora releases (Fedora 43+).*
