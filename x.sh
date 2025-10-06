#!/bin/bash
# 🧩 Full Wine reinstall & environment setup (MASA Edition)
# What it does:
#  - Backup & remove old Wine packages and prefixes
#  - Remove Google Chrome repo (GPG issues)
#  - Add WineHQ repository for your Ubuntu codename
#  - Update system and install winehq (stable), winetricks, bottles, playonlinux
#  - Create a fresh 64-bit WINEPREFIX, install core runtimes
#  - Download All-in-One Runtimes and launch it at the END
#  - Create desktop shortcuts for Bottle/PlayOnLinux/Wine Programs
#  - Shows a colored MASA banner (3 seconds) at start
#
# Author: MASA (CODE WITH MASA)
# Version: 1.0

set -euo pipefail

# -------------------------
# Colors
# -------------------------
BLUE="\e[34m"
CYAN="\e[36m"
YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"
BOLD="\e[1m"

# -------------------------
# Banner / Credits (3 sec)
# -------------------------
clear
echo -e "${CYAN}====================================================${RESET}"
echo -e "${BOLD}${BLUE}             💻  MASA SETUP SCRIPT 💻${RESET}"
echo -e "${CYAN}====================================================${RESET}"
echo -e "${YELLOW}Author  :${RESET} MASA"
echo -e "${YELLOW}Channel :${RESET} CODE WITH MASA"
echo ""
echo -e "${GREEN}Facebook :${RESET}  https://www.facebook.com/CODEWITHMASA"
echo -e "${GREEN}Instagram:${RESET}  https://www.instagram.com/codewithmasa"
echo -e "${GREEN}Tiktok   :${RESET}  https://www.tiktok.com/@CODEWITHMASA"
echo -e "${GREEN}Youtube  :${RESET}  https://www.youtube.com/@CODEWITHMASA"
echo -e "${GREEN}Telegram Active :${RESET}  https://t.me/+_R91sWmKBacyZTc0"
echo -e "${GREEN}Telegram Page   :${RESET}  https://t.me/CODEWITHMASA"
echo -e "${GREEN}Github   :${RESET}  https://github.com/CODEWITHMASA"
echo -e "${GREEN}X (Twitter):${RESET}  https://x.com/CODEWITHMASA"
echo -e "${GREEN}Website  :${RESET}  https://codewithmasa.blogspot.com/"
echo -e "${GREEN}Telegram Group  :${RESET}  https://t.me/GROUPCODEWITHMASA"
echo -e "${GREEN}Telegram Contact:${RESET}  https://t.me/MrMasaOfficial"
echo -e "${CYAN}====================================================${RESET}"
sleep 3
clear

echo -e "${BLUE}Starting full Wine reinstall & environment setup...${RESET}"

# -------------------------
# Helper: timestamp
# -------------------------
TS=$(date +%Y%m%d-%H%M%S)

# -------------------------
# 0) Remove Google Chrome repo (GPG errors)
# -------------------------
echo -e "${CYAN}Removing Google Chrome apt source (to avoid GPG errors)...${RESET}"
sudo rm -f /etc/apt/sources.list.d/google-chrome.list || true

# -------------------------
# 1) Backup & remove old Wine packages & prefixes
# -------------------------
echo -e "${YELLOW}Backing up and removing old Wine packages & prefixes...${RESET}"

# Backup common wine prefixes (if exist)
if [ -d "$HOME/.wine" ]; then
  echo -e "${YELLOW}Backing up ~/.wine -> ~/.wine-backup-${TS}${RESET}"
  mv "$HOME/.wine" "$HOME/.wine-backup-${TS}"
fi

if [ -d "$HOME/.wine-torpedo" ]; then
  echo -e "${YELLOW}Backing up ~/.wine-torpedo -> ~/.wine-torpedo-backup-${TS}${RESET}"
  mv "$HOME/.wine-torpedo" "$HOME/.wine-torpedo-backup-${TS}"
fi

if [ -d "$HOME/.wine64" ]; then
  echo -e "${YELLOW}Backing up ~/.wine64 -> ~/.wine64-backup-${TS}${RESET}"
  mv "$HOME/.wine64" "$HOME/.wine64-backup-${TS}"
fi

# Remove old wine packages
echo -e "${CYAN}Removing existing wine packages (if any)...${RESET}"
sudo apt remove --purge -y 'wine*' || true
sudo apt autoremove -y || true

# Remove old WineHQ sources if present
sudo rm -f /etc/apt/sources.list.d/winehq*.sources /etc/apt/sources.list.d/winehq*.list || true

# -------------------------
# 2) Add WineHQ repository (appropriate codename)
# -------------------------
CODENAME=$(lsb_release -sc || echo "focal")
echo -e "${BLUE}Detected Ubuntu codename: ${CODENAME}${RESET}"
echo -e "${CYAN}Adding WineHQ repository for ${CODENAME}...${RESET}"

sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings

# get winehq key
sudo wget -q -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

# try to download the appropriate .sources file; fallback to focal if not found
SRC_URL="https://dl.winehq.org/wine-builds/ubuntu/dists/${CODENAME}/winehq-${CODENAME}.sources"
if sudo wget -q --spider "$SRC_URL"; then
  sudo wget -NP /etc/apt/sources.list.d/ "$SRC_URL"
else
  echo -e "${YELLOW}No WineHQ sources for ${CODENAME}, falling back to focal (20.04)...${RESET}"
  sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources
fi

# -------------------------
# 3) Update system
# -------------------------
echo -e "${CYAN}Updating apt lists and upgrading system...${RESET}"
sudo apt update -y
sudo apt upgrade -y

# -------------------------
# 4) Install WineHQ stable, winetricks, and helper tools
# -------------------------
echo -e "${YELLOW}Installing WineHQ (stable), winetricks and helper packages...${RESET}"
sudo apt install --install-recommends -y winehq-stable winetricks cabextract wget unzip zenity

# Also install bottles and playonlinux (optional GUIs)
echo -e "${CYAN}Installing Bottles and PlayOnLinux (optional GUI tools)...${RESET}"
sudo apt install -y bottles playonlinux || true

# -------------------------
# 5) Initialize Wine and create fresh 64-bit prefix
# -------------------------
WINEPREFIX="$HOME/.wine64"
export WINEPREFIX
export WINEARCH=win64

echo -e "${BLUE}Initializing fresh 64-bit Wine prefix at ${WINEPREFIX} ...${RESET}"
wineboot --init || true
sleep 3

# Set Windows version to Windows10 using winecfg in background (it will open GUI if not available)
# but we can set registry keys to prefer Windows 10; safer to run winecfg once:
echo -e "${CYAN}Running winecfg (will open a window briefly if GUI available) to finalize prefix...${RESET}"
WINEPREFIX="$WINEPREFIX" winecfg >/dev/null 2>&1 || true

# -------------------------
# 6) Install common runtimes with winetricks (non-fatal)
# -------------------------
echo -e "${YELLOW}Installing common runtimes via winetricks (corefonts, vcrun2019, dotnet48)...${RESET}"

# Make sure winetricks is up-to-date
winetricks --self-update || true

# Install core runtimes (non-fatal failures handled)
WINEPREFIX="$WINEPREFIX" winetricks -q corefonts vcrun2019 || echo -e "${RED}Warning: vcrun2019 may have failed; continue.${RESET}"

# dotnet48 tends to show dialogs and may fail silently; try and continue on error
echo -e "${CYAN}Attempting to install dotnet48 (may require manual interaction)...${RESET}"
WINEPREFIX="$WINEPREFIX" winetricks dotnet48 || echo -e "${YELLOW}dotnet48 installation failed or requested manual steps. You can run: WINEPREFIX=\"$WINEPREFIX\" winetricks dotnet48${RESET}"

# Try dotnet6 (if winetricks supports it) - do not fail the script if unavailable
echo -e "${CYAN}Attempting to install dotnet6 (if available)...${RESET}"
WINEPREFIX="$WINEPREFIX" winetricks dotnet6 2>/dev/null || echo -e "${YELLOW}dotnet6 not available via winetricks or failed; that's OK.${RESET}"

# -------------------------
# 7) Prepare directories and download All-in-One Runtimes
# -------------------------
SETUP_DIR="$HOME/wine_setup"
AIO_FILE="aio-runtimes_v2.5.0.exe"
AIO_PATH="$SETUP_DIR/$AIO_FILE"

mkdir -p "$SETUP_DIR"
cd "$SETUP_DIR"

if [ -f "$AIO_PATH" ]; then
  echo -e "${GREEN}All-in-One Runtimes already downloaded at ${AIO_PATH}${RESET}"
else
  echo -e "${CYAN}Downloading All-in-One Runtimes to ${AIO_PATH} ...${RESET}"
  wget -O "$AIO_PATH" "https://allinoneruntimes.org/files/$AIO_FILE"
fi

# -------------------------
# 8) Create Desktop shortcuts for Bottles / PlayOnLinux / Wine Programs
# -------------------------
DESKTOP_DIR="$HOME/Desktop"
mkdir -p "$DESKTOP_DIR"

echo -e "${CYAN}Creating desktop shortcuts...${RESET}"

cat > "$DESKTOP_DIR/Bottles.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Bottles
Comment=Manage Windows applications easily
Exec=bottles
Icon=bottles
Terminal=false
Categories=Utility;Wine;
EOF

cat > "$DESKTOP_DIR/PlayOnLinux.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=PlayOnLinux
Comment=Run Windows applications with ease
Exec=playonlinux
Icon=playonlinux
Terminal=false
Categories=Utility;Wine;
EOF

cat > "$DESKTOP_DIR/Wine_Programs.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Wine Programs Folder
Comment=Open installed Wine programs
Exec=xdg-open ~/.wine/drive_c/Program\ Files
Icon=folder
Terminal=false
Categories=Utility;Wine;
EOF

chmod +x "$DESKTOP_DIR"/*.desktop || true
echo -e "${GREEN}Desktop shortcuts created.${RESET}"

# -------------------------
# 9) Optional: backup old apt keys and sources (already attempted earlier)
# -------------------------

# -------------------------
# 10) Final message and run All-in-One Runtimes
# -------------------------
echo ""
echo -e "${BLUE}All setup steps completed.${RESET}"
echo -e "${CYAN}Now launching All-in-One Runtimes installer inside the fresh Wine prefix...${RESET}"

# Launch AIO in foreground so user can follow installation (this is intentional per request)
if [ -f "$AIO_PATH" ]; then
  echo -e "${YELLOW}Note: The All-in-One installer may open multiple dialogs. Please follow its UI to completion.${RESET}"
  WINEPREFIX="$WINEPREFIX" wine "$AIO_PATH"
  echo -e "${GREEN}All-in-One Runtimes installer finished (or was closed).${RESET}"
else
  echo -e "${RED}ERROR: All-in-One Runtimes not found at ${AIO_PATH}${RESET}"
fi

# -------------------------
# 11) Finish
# -------------------------
echo ""
echo -e "${GREEN}🎉 Full Wine reinstall & setup finished.${RESET}"
echo -e "${YELLOW}Shortcuts on Desktop: Bottles, PlayOnLinux, Wine Programs Folder${RESET}"
echo -e "${CYAN}If you need a dedicated prefix for Torpedo, run:${RESET}"
echo -e "${CYAN}  export WINEPREFIX=\"$HOME/.wine-torpedo\"; export WINEARCH=win64; wineboot --init${RESET}"
echo -e "${CYAN}To run a program with the new prefix:${RESET}"
echo -e "${CYAN}  WINEPREFIX=\"$WINEPREFIX\" wine \"/path/to/YourProgram.exe\"${RESET}"
echo -e "${CYAN}====================================================${RESET}"
echo -e "${BOLD}${BLUE}Setup completed by: MASA (CODE WITH MASA)${RESET}"
echo -e "${BOLD}${YELLOW}Visit: https://www.youtube.com/@CODEWITHMASA${RESET}"
echo -e "${CYAN}====================================================${RESET}"
