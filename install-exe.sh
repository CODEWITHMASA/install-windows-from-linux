#!/bin/bash
set -euo pipefail

# -----------------------------
# Ultimate setup script (Ubuntu 20.04)
# - Remove old Chrome
# - Install Google Chrome (stable)
# - Create Desktop shortcut that runs Chrome with --no-sandbox
# - Install Wine Staging + winetricks + essential libs
# - Initialize Wine and install common runtimes via winetricks
# NOTE: Running Chrome with --no-sandbox is insecure. Use only if you accept the risk.
# -----------------------------

# Detect whether we need sudo for package commands
if [[ $EUID -ne 0 ]]; then
  SUDO='sudo'
else
  SUDO=''
fi

HOME_DIR="${HOME:-/root}"
DESKTOP_DIR="$HOME_DIR/Desktop"
TMP_DEB="/tmp/google-chrome-stable_current_amd64.deb"

echo "===== START: Ultimate setup ====="

echo
echo ">>> Step 1: Remove existing Google Chrome (if any)"
$SUDO apt remove --purge google-chrome-stable -y || true
$SUDO apt autoremove -y || true
# remove user config (this deletes bookmarks/settings)
if [[ -d "$HOME_DIR/.config/google-chrome" ]]; then
  echo "Removing user Chrome config at $HOME_DIR/.config/google-chrome"
  rm -rf "$HOME_DIR/.config/google-chrome"
fi

echo
echo ">>> Step 2: Download & install Google Chrome (stable)"
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O "$TMP_DEB"
$SUDO apt update
$SUDO apt install -y "$TMP_DEB"
rm -f "$TMP_DEB"

echo
echo ">>> Step 3: Create Desktop shortcut that runs Chrome with --no-sandbox"
# Ensure desktop directory exists
mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_DIR/google-chrome-no-sandbox.desktop" <<'EOF'
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

# Try to update desktop DB if available (no harm if command not present)
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database ~/.local/share/applications >/dev/null 2>&1 || true
fi

echo
echo ">>> Shortcut created at: $DESKTOP_DIR/google-chrome-no-sandbox.desktop"
echo "IMPORTANT: This shortcut launches Chrome with --no-sandbox (insecure)."

echo
echo ">>> Step 4: Install Wine Staging repository & packages"
$SUDO dpkg --add-architecture i386 || true
$SUDO mkdir -pm755 /etc/apt/keyrings
$SUDO wget -q -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
$SUDO wget -q -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources
$SUDO apt update

# Install Wine Staging + helpers
$SUDO apt install --install-recommends -y winehq-staging winetricks cabextract p7zip-full libfaudio0 || {
  echo "Failed to install some Wine packages via apt. Please check apt output."
  exit 1
}

echo
echo ">>> Step 5: Initialize Wine environment for current user ($HOME_DIR)"
# Use the current user's HOME (if running with sudo from another user, this script uses $HOME of the runner)
export WINEPREFIX="$HOME_DIR/.wine"
# Ensure env points to a writable HOME for wine
mkdir -p "$HOME_DIR"
# Initialize wine (non-sudo, use the same user running the script)
wineboot --init || true

echo
echo ">>> Step 6: Install common runtimes via winetricks (may take long)"
echo "Winetricks will try to run non-interactively (-q). Some installers may still prompt or fail silently."
# We run winetricks as the current user (do NOT use sudo with winetricks unless you know what you're doing)
# List of items: adjust if you want more/less
winetricks -q corefonts vcrun6 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015 vcrun2017 vcrun2019 d3dx9 dxvk msxml6 gdiplus windowscodecs fontsmooth=rgb dotnet20 dotnet35 dotnet40 dotnet45 dotnet48 jre8 || {
  echo "Note: some winetricks installs may have failed or required manual input. Check output above."
}

echo
echo ">>> Step 7: Launch winecfg for final configuration (this will open a window)"
winecfg || echo "winecfg returned non-zero (this may be fine)."

echo
echo "===== DONE: Ultimate setup finished ====="
echo " - Google Chrome installed and shortcut created (runs with --no-sandbox)."
echo " - Wine Staging + winetricks + common runtimes attempted to install."
echo
echo "Security reminder: Running Chrome with --no-sandbox is insecure. Prefer running a non-root user for browsing."
