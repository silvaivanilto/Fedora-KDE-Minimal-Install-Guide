# Fedora KDE Minimal Install Guide

A modern and streamlined guide/script to install a minimal Fedora KDE Plasma environment.

## Overview

This project provides a script to transform a "Minimal Install" of Fedora into a functional, lightweight KDE Plasma desktop. It avoids the bloat of the official spin by selecting only essential components and using modern tools like `dnf5`.

## Features

- **KDE Plasma Minimal**: Installed via `dnf5` with specific exclusions to remove unnecessary pre-installed apps.
- **Modern Power Management**: Uses `TLP` optimized for laptops (automatically replaces `power-profiles-daemon`).
- **NVIDIA Drivers**: Automated setup using the high-quality [Negativo17](https://negativo17.org/) repositories.
- **Multimedia Support**: Includes `ffmpeg` and multimedia codecs from Negativo17.
- **Container Ready**: Pre-installed `distrobox` for running any Linux distribution inside your terminal.
- **Performance & Utility**: Includes `git`, `fzf`, `fastfetch`, `rar`, and `unzip`.
- **System Hardening**: Automatically blacklists `nouveau` and `nova_core` drivers to ensure NVIDIA stability.

## Prerequisites

1.  **Fedora Minimal Install**: Start with a "Minimal Install" from the Fedora Everything/Network ISO.
2.  **Internet Connection**: Required to download all components.
3.  **Sudo Privileges**: The script must be run as root.

## Fast Install (Recommended for Fedora Minimal)

If you just finished a minimal install and don't have `git`, you can download and run the script directly:

```bash
wget https://v.gd/fedora_plasma_min -O install.sh
chmod +x install.sh
sudo ./install.sh
```

## How to Use (Git Clone)
    ```bash
    git clone https://github.com/silvaivanilto/Fedora-KDE-Minimal-Install-Guide.git
    cd Fedora-KDE-Minimal-Install-Guide
    ```

2.  **Ensure the script is executable**:
    ```bash
    chmod +x fedora-plasma-minimal.sh
    ```

3.  **Run the script**:
    ```bash
    sudo ./fedora-plasma-minimal.sh
    ```

4.  **Reboot** your system after the script finishes to enter your new KDE Plasma environment.

## Script Details

The `fedora-plasma-minimal.sh` is organized into 4 main phases:
- **Phase 1: Repositories**: Adds Negativo17 (NVIDIA & Multimedia) and TLP repositories.
- **Phase 2: Installation**: Uses `dnf5` for the KDE group install and `dnf` for specific drivers and utilities.
- **Phase 3: Services**: Configures `TLP`, sets the graphical boot target, and enables the login manager.
- **Phase 4: Optimization**: Applies `grubby` kernel parameters to prevent driver conflicts.

## Warning
This script modifies system repositories, services, and kernel parameters. It is designed for new, clean installations. Use at your own risk.

---
*Maintained for modern Fedora releases (Fedora 40+).*
