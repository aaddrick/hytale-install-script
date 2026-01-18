#!/bin/sh
set -e

DOWNLOAD_URL="https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak"
FLATPAK_FILE="/tmp/hytale-launcher-latest.flatpak"
REQUIRED_SPACE_MB=500

echo "=== Hytale Launcher Installer ==="
echo

# Cleanup function for trap
cleanup() {
    rm -f "$FLATPAK_FILE"
}
trap cleanup EXIT

# Check if running as root
if [ "$(id -u)" = "0" ]; then
    echo "Error: Do not run this script as root or with sudo."
    echo "The installer uses --user flag to install to your home directory."
    echo "Please run again as a normal user: curl -fsSL <url> | bash"
    exit 1
fi
echo "[OK] Running as normal user"

# Check for flatpak
if ! command -v flatpak >/dev/null 2>&1; then
    echo "Error: flatpak is not installed."
    echo "Please install flatpak for your distribution:"
    echo "  Fedora/RHEL: sudo dnf install flatpak"
    echo "  Ubuntu/Debian: sudo apt install flatpak"
    echo "  Arch: sudo pacman -S flatpak"
    echo "  openSUSE: sudo zypper install flatpak"
    exit 1
fi
echo "[OK] flatpak is installed"

# Check flatpak version for --noninteractive support (added in 1.2.0)
FLATPAK_VERSION=$(flatpak --version | awk '{print $2}')
FLATPAK_MAJOR=$(echo "$FLATPAK_VERSION" | cut -d. -f1)
FLATPAK_MINOR=$(echo "$FLATPAK_VERSION" | cut -d. -f2)
USE_NONINTERACTIVE=true
if [ "$FLATPAK_MAJOR" -lt 1 ] || { [ "$FLATPAK_MAJOR" -eq 1 ] && [ "$FLATPAK_MINOR" -lt 2 ]; }; then
    USE_NONINTERACTIVE=false
    echo "[WARN] Older flatpak version ($FLATPAK_VERSION), some prompts may appear"
fi
echo "[OK] flatpak version $FLATPAK_VERSION"

# Check for user-level flathub remote
if ! flatpak remotes --user 2>/dev/null | grep -q flathub; then
    echo "Adding flathub remote for user..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi
echo "[OK] flathub remote configured"

# Check for curl or wget
if command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget"
else
    echo "Error: curl or wget is required to download the launcher."
    echo "Please install one for your distribution:"
    echo "  Fedora/RHEL: sudo dnf install curl"
    echo "  Ubuntu/Debian: sudo apt install curl"
    echo "  Arch: sudo pacman -S curl"
    echo "  openSUSE: sudo zypper install curl"
    exit 1
fi
echo "[OK] $DOWNLOADER available for download"

# Check available disk space in home directory
AVAILABLE_SPACE_KB=$(df "$HOME" | awk 'NR==2 {print $4}')
AVAILABLE_SPACE_MB=$((AVAILABLE_SPACE_KB / 1024))
if [ "$AVAILABLE_SPACE_MB" -lt "$REQUIRED_SPACE_MB" ]; then
    echo "Error: Insufficient disk space."
    echo "Required: ${REQUIRED_SPACE_MB}MB, Available: ${AVAILABLE_SPACE_MB}MB"
    echo "The GNOME Platform runtime requires significant space."
    exit 1
fi
echo "[OK] Sufficient disk space (${AVAILABLE_SPACE_MB}MB available)"

echo
echo "Downloading Hytale Launcher..."
if [ "$DOWNLOADER" = "curl" ]; then
    curl -fSL -o "$FLATPAK_FILE" "$DOWNLOAD_URL"
else
    wget -O "$FLATPAK_FILE" "$DOWNLOAD_URL"
fi
echo "[OK] Download complete"

echo
# Check if already installed
if flatpak info com.hypixel.HytaleLauncher >/dev/null 2>&1; then
    echo "Hytale Launcher is already installed, reinstalling to update..."
    if [ "$USE_NONINTERACTIVE" = true ]; then
        flatpak uninstall --user -y --noninteractive com.hypixel.HytaleLauncher
    else
        flatpak uninstall --user -y com.hypixel.HytaleLauncher
    fi
fi

echo "Installing Hytale Launcher (including GNOME Platform runtime if needed)..."
if [ "$USE_NONINTERACTIVE" = true ]; then
    flatpak install --user -y --noninteractive "$FLATPAK_FILE"
else
    flatpak install --user -y "$FLATPAK_FILE"
fi

echo
echo "=== Installation Complete ==="
echo "Run the launcher with: flatpak run com.hypixel.HytaleLauncher"
