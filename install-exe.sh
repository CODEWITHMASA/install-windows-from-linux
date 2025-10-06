#!/bin/bash
# 🧩 Ultimate Auto Wine Setup Script (MASA Edition)
# Ubuntu 20.04.6 LTS
# Author: MASA
# Youtube: CODE WITH MASA
# Version: 1.3 — Opens All-in-One Runtimes after setup completion

set -e

# 🎨 Define Colors
BLUE="\e[34m"
CYAN="\e[36m"
YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"
BOLD="\e[1m"

# 💬 Show MASA credits
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

# 🧹 Fix Chrome repo error
echo -e "${BLUE}🧹 Removing Google Chrome repo to avoid GPG errors...${RESET}"
sudo rm -f /etc/apt/sources.list.d/google-chrome.list

# 🔄 Update & architecture
echo -e "${CYAN}🔄 Updating system and adding 32-bit architecture...${RESET}"
sudo dpkg --add-architecture i386
sudo apt update -y
sudo apt upgrade -y

# 🍷 Install Wine
echo -e "${YELLOW}🍷 Installing Wine and dependencies...${RESET}"
sudo apt install -y wine64 wine32 wine-stable winbind winetricks cabextract wget unzip zenity

# ⚙️ Init Wine
echo -e "${BLUE}⚙️ Initializing Wine environment...${RESET}"
wineboot --init
sleep 5

# 🧰 Winetricks runtimes
echo -e "${CYAN}🧰 Installing core runtimes (.NET, Visual C++, Fonts)...${RESET}"
winetricks -q corefonts vcrun6sp6 vcrun2010 vcrun2012 vcrun2013 vcrun2015 vcrun2019 dotnet40 dotnet45 dotnet472

# 🧩 Create setup folder
echo -e "${BLUE}📦 Creating setup directory...${RESET}"
mkdir -p ~/wine_setup
cd ~/wine_setup

# ⬇️ Download All-in-One Runtimes if missing
AIO_PATH="$HOME/wine_setup/aio-runtimes_v2.5.0.exe"
if [ ! -f "$AIO_PATH" ]; then
  echo -e "${YELLOW}⬇️ Downloading All-in-One Runtimes...${RESET}"
  wget -O "$AIO_PATH" "https://allinoneruntimes.org/files/aio-runtimes_v2.5.0.exe"
else
  echo -e "${GREEN}✅ All-in-One Runtimes already downloaded.${RESET}"
fi

# 🪟 GUI Tools
echo -e "${CYAN}🪟 Installing GUI tools (Bottles & PlayOnLinux)...${RESET}"
sudo apt install -y playonlinux bottles

# 🧩 Auto-run any EXE beside script
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
EXE_FILES=("$SCRIPT_DIR"/*.exe)

if [ -e "${EXE_FILES[0]}" ]; then
  echo -e "${GREEN}🚀 Found ${#EXE_FILES[@]} EXE file(s). Running them automatically...${RESET}"
  for EXE in "${EXE_FILES[@]}"; do
    if [ "$(realpath "$EXE")" = "$(realpath "$AIO_PATH")" ]; then
      continue
    fi

    echo -e "${CYAN}➡️ Launching: ${EXE}${RESET}"
    wine "$EXE" || echo -e "${RED}⚠️ Failed to launch ${EXE}.${RESET}"

    APP_NAME=$(basename "$EXE" .exe)
    DESKTOP_DIR="$HOME/Desktop"
    echo -e "${YELLOW}🧩 Creating desktop shortcut for ${APP_NAME}...${RESET}"

    cat <<EOF > "$DESKTOP_DIR/${APP_NAME}.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_NAME}
Comment=Run ${APP_NAME} with Wine
Exec=wine "${EXE}"
Icon=wine
Terminal=false
Categories=Utility;Wine;
EOF

    chmod +x "$DESKTOP_DIR/${APP_NAME}.desktop"
    echo -e "${GREEN}✅ Shortcut created: ${DESKTOP_DIR}/${APP_NAME}.desktop${RESET}"
  done
else
  echo -e "${RED}❌ No .exe files found beside this script.${RESET}"
fi

# ✅ All setup done — now open All-in-One Runtimes
if [ -f "$AIO_PATH" ]; then
  echo ""
  echo -e "${BOLD}${BLUE}🚀 Opening All-in-One Runtimes now to complete setup...${RESET}"
  wine "$AIO_PATH"
  echo -e "${GREEN}✅ All-in-One Runtimes installer launched successfully.${RESET}"
else
  echo -e "${RED}❌ aio-runtimes_v2.5.0.exe not found at ${AIO_PATH}.${RESET}"
fi

# ✅ Finish
echo ""
echo -e "${GREEN}🎉 All setup steps are complete!${RESET}"
echo -e "${YELLOW}💡 You can now launch your installed programs from Desktop shortcuts.${RESET}"
echo -e "${CYAN}====================================================${RESET}"
echo -e "${BOLD}${BLUE}Setup completed by: MASA (CODE WITH MASA)${RESET}"
echo -e "${BOLD}${YELLOW}Visit: https://www.youtube.com/@CODEWITHMASA${RESET}"
echo -e "${CYAN}====================================================${RESET}"
