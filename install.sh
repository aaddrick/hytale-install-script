#!/bin/bash
set -e

DOWNLOAD_URL="https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak"
FLATPAK_FILE="/tmp/hytale-launcher-latest.flatpak"

echo "=== Hytale Launcher Installer ==="
echo

# Check for flatpak
if ! command -v flatpak &> /dev/null; then
    echo "Error: flatpak is not installed."
    echo "Please install flatpak for your distribution:"
    echo "  Fedora/RHEL: sudo dnf install flatpak"
    echo "  Ubuntu/Debian: sudo apt install flatpak"
    echo "  Arch: sudo pacman -S flatpak"
    exit 1
fi
echo "[OK] flatpak is installed"

# Check for flathub remote
if ! flatpak remotes | grep -q flathub; then
    echo "Adding flathub remote..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi
echo "[OK] flathub remote configured"

# Check for curl or wget
if command -v curl &> /dev/null; then
    DOWNLOADER="curl"
elif command -v wget &> /dev/null; then
    DOWNLOADER="wget"
else
    echo "Error: curl or wget is required to download the launcher."
    exit 1
fi
echo "[OK] $DOWNLOADER available for download"

echo
echo "Downloading Hytale Launcher..."
if [ "$DOWNLOADER" = "curl" ]; then
    curl -L -o "$FLATPAK_FILE" "$DOWNLOAD_URL"
else
    wget -O "$FLATPAK_FILE" "$DOWNLOAD_URL"
fi
echo "[OK] Download complete"

echo
echo "Installing Hytale Launcher..."
flatpak install --user -y "$FLATPAK_FILE"

echo
echo "Cleaning up..."
rm -f "$FLATPAK_FILE"

echo
echo "=== Installation Complete ==="
echo "Run the launcher with: flatpak run com.hypixel.HytaleLauncher"
