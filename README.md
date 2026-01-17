# Hytale Launcher Installer

A simple script to install the Hytale Launcher on Linux via Flatpak.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/aaddrick/hytale-install-script/main/install.sh | bash
```

## What it does

- Checks that flatpak is installed
- Configures the flathub remote if needed
- Downloads the latest Hytale Launcher flatpak
- Installs the launcher with required dependencies

## Requirements

- Linux with flatpak installed
- curl or wget

## Running the Launcher

After installation:

```bash
flatpak run com.hypixel.HytaleLauncher
```

Or find "Hytale Launcher" in your application menu.
