# Fedora KDE Minimal Install Guide

A modern and streamlined guide/script to install a minimal Fedora KDE Plasma environment.

## Overview

This project provides a script to transform a "Minimal Install" of Fedora into a functional, lightweight KDE Plasma desktop. It avoids the bloat of the official spin by selecting only essential components.

## Features

- **Kernel CachyOS**: High-performance kernel with `scx` (Sched-ext) schedulers and custom optimizations.
- **KDE Plasma Minimal**: Installed with specific exclusions to remove unnecessary pre-installed apps.
- **Advanced Performance**: Includes `ananicy-cpp` for process prioritization and `scx_bpfland` for ultra-low latency.
- **NVIDIA Drivers**: Automated setup using the [Negativo17](https://negativo17.org/) repositories, including hardware video acceleration and power management.
- **AMD GPU Support**: Mesa drivers with full hardware codecs (VA-API/Vulkan) from Negativo17.
- **Hybrid GPU**: `switcheroo-control` for intelligent GPU switching (great for Nitro 5 and similar laptops).
- **Multimedia**: `ffmpeg` (Negativo17), Elisa, Kalk, Koko, Marknote, Merkuro, Okular, Plasma Firewall, Skanpage.
- **IDE**: Antigravity (Advanced Agentic Coding IDE).
- **Containers**: `Podman` via `podman-docker` for full Docker CLI compatibility.
- **Productivity**: LibreOffice (Writer, Calc, Impress) installed via group install.
- **Flatpak**: Pre-configured with Flathub for easy application management.
- **Utilities**: `git`, `fzf`, `fastfetch`, `curl`, `unrar`, `unzip`, `libva-utils`.
- **GRUB & Boot**: Configured with `saved` default and a `postinst` hook to ensure CachyOS remains the primary kernel.
- **System Hardening**: Blacklists `nouveau` and `nova_core` for NVIDIA stability.

## Prerequisites

1.  **Fedora Minimal Install**: Start with a "Minimal Install" from the Fedora Everything/Network ISO.
2.  **Internet Connection**: Required to download all components.

## How to Use

1.  **Download/Copy the script**:
    Ideally, have the script on a USB drive or download it directly if you have terminal access.

2.  **Make it executable and run**:
    ```bash
    chmod +x fedora-plasma-minimal.sh
    sudo ./fedora-plasma-minimal.sh
    ```

3.  **Reboot** your system after the script finishes to enter your new KDE Plasma environment.

## Script Details

The `fedora-plasma-minimal.sh` is organized into 5 phases:

- **[1/5] Repositories** — Adds Negativo17 (NVIDIA/Multimedia), Antigravity, Google Chrome, and Kernel CachyOS COPRs.
- **[2/5] System Update** — Refreshes cache and upgrades the base system to the latest versions.
- **[3/5] Package Installation** — Installs KDE Plasma (base), CachyOS Kernel, NVIDIA/AMD drivers, core apps, and utilities.
- **[4/5] System Adjustments** — Configures NVIDIA Dynamic Power Management and the SCX Scheduler (`bpfland`).
- **[5/5] Services & Boot** — Activates services, sets graphical target, installs the kernel boot hook, and updates GRUB/Initramfs.

## Warning

This script modifies system repositories, services, and kernel parameters. It is designed for new, clean installations. Use at your own risk.

---
*Maintained for modern Fedora releases (Fedora 44+).*
