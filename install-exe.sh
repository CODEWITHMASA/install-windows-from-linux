#!/bin/bash
set -euo pipefail

HOME_DIR="${HOME:-/root}"
DESKTOP_DIR="$HOME_DIR/Desktop"
TMP_CHROME_DEB="/tmp/google-chrome-stable_current_amd64.deb"
TMP_AIO_EXE="/tmp/aio-runtimes_v2.5.0.exe"

echo "===== Full Wine + Chrome + AIO Setup for Ubuntu 20.04.6 ====="

# ---------------------------
# Step 0: Install full Wine (Stable + Staging)
# ---------------------------
echo "Installing full Wine (Stable + Staging) ..."

# Add 32-bit architecture support
sudo dpkg --add-architecture i386

# Install required tools for Wine
sudo apt update
sudo apt install -y wget gnupg2 software-properties-common apt-transport-https

# Add WineHQ key and repository
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -q -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -q -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources
sudo apt update

# Install Wine (Stable + Staging) and tools
sudo apt install --install-recommends -y winehq-stable winehq-staging winetricks cabextract p7zip-full libfaudio0 fonts-wine

echo "✅ Wine installation completed."

# ---------------------------
# Step 1: Remove old Chrome
# ---------------------------
echo "Removing old Google Chrome (if exists)..."
sudo apt remove --purge google-chrome-stable -y || true
sudo apt autoremove -y || true
rm -rf "$HOME_DIR/.config/google-chrome"

# ---------------------------
# Step 2: Download & install Chrome
# ---------------------------
echo "Downloading Google Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O "$TMP_CHROME_DEB"

echo "Installing Google Chrome..."
sudo apt install -y "$TMP_CHROME_DEB"
rm -f "$TMP_CHROME_DEB"

# ---------------------------
# Step 3: Create Desktop shortcut for Chrome (no-sandbox)
# ---------------------------
echo "Creating Desktop shortcut for Chrome..."
mkdir -p "$DESKTOP_DIR"
cat > "$DESKTOP_DIR/google-chrome-no-sandbox.desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=Google Chrome (no-sandbox)
Comment=Google Chrome (launched with --no-sandbox)
Exec=google-chrome --no-sandbox %U
Terminal=false
Type=Application
Icon=google-chrome
Categories=Network;WebBrowser;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/google-chrome-no-sandbox.desktop"

# ---------------------------
# Step 4: Initialize Wine environment
# ---------------------------
echo "Initializing Wine..."
export WINEPREFIX="$HOME_DIR/.wine"
wineboot --init || true

# ---------------------------
# Step 5: Install core Windows libraries via Winetricks
# ---------------------------
echo "Installing core Windows libraries..."
winetricks -q corefonts vcrun6 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015 vcrun2017 vcrun2019 d3dx9 dxvk msxml6 gdiplus windowscodecs fontsmooth=rgb dotnet20 dotnet35 dotnet40 dotnet45 dotnet48 jre8 || echo "Some winetricks installs failed or require input."

# ---------------------------
# Step 6: Download & run AIO Runtimes
# ---------------------------
echo "Downloading AIO Runtimes..."
wget -O "$TMP_AIO_EXE" "https://allinoneruntimes.org/files/aio-runtimes_v2.5.0.exe"

echo "Launching AIO Runtimes..."
wine "$TMP_AIO_EXE"
rm -f "$TMP_AIO_EXE"

# ---------------------------
# Step 7: Launch winecfg
# ---------------------------
echo "Launching Wine configuration window..."
winecfg || true

echo "===== Setup completed! ====="
echo "✅ Chrome shortcut: $DESKTOP_DIR/google-chrome-no-sandbox.desktop"
echo "✅ Full Wine installed with core Windows libraries"
echo "✅ AIO Runtimes launched via Wine"
