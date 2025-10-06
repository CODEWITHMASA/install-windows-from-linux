#!/bin/bash
# 🧩 Windows 11 Theme Installer for LXDE
# Author : MASA
# Channel: CODE WITH MASA
# Website: https://codewithmasa.blogspot.com/
# Github : https://github.com/CODEWITHMASA
# Version: 1.1

set -e

# 🎨 Define Colors
BLUE="\e[34m"
CYAN="\e[36m"
YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"
BOLD="\e[1m"

# 💬 MASA Banner
clear
echo -e "${CYAN}====================================================${RESET}"
echo -e "${BOLD}${BLUE}            💻  MASA THEME INSTALLER 💻${RESET}"
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

# Simple animation effect
for i in 3 2 1; do
  echo -e "${YELLOW}Starting installation in ${i}...${RESET}"
  sleep 1
done

clear

echo -e "${BLUE}🎨 Installing Windows 11 Theme for LXDE...${RESET}"
echo "--------------------------------------------"

# Create directories
mkdir -p ~/.themes ~/.icons ~/.wallpapers

# Download theme, icons, and wallpaper
echo -e "${CYAN}⬇️  Downloading theme, icons, and wallpaper...${RESET}"
wget -q -O ~/.icons/Win11-blue.tar.xz "https://github.com/CODEWITHMASA/them-windows-to-linux/raw/main/Win11-blue.tar.xz"
wget -q -O ~/.themes/Win11-round-Dark-compact.tar.xz "https://github.com/CODEWITHMASA/them-windows-to-linux/raw/main/Win11-round-Dark-compact.tar.xz"
wget -q -O ~/.wallpapers/win11-background.jpg "https://l.top4top.io/p_3562wi1qn1.jpg"

# Extract files
echo -e "${YELLOW}📦 Extracting theme and icons...${RESET}"
tar -xf ~/.icons/Win11-blue.tar.xz -C ~/.icons/
tar -xf ~/.themes/Win11-round-Dark-compact.tar.xz -C ~/.themes/

# Install lxappearance if not installed
if ! command -v lxappearance &> /dev/null; then
    echo -e "${RED}🛠️  lxappearance not found. Installing...${RESET}"
    sudo apt update -y && sudo apt install -y lxappearance
else
    echo -e "${GREEN}✅ lxappearance is already installed.${RESET}"
fi

# Apply theme automatically
echo -e "${CYAN}🧩 Applying theme and icons...${RESET}"
gsettings set org.lxde.interface gtk-theme "Win11-round-Dark-compact" 2>/dev/null || true
gsettings set org.lxde.interface icon-theme "Win11-blue" 2>/dev/null || true

# Set wallpaper
echo -e "${BLUE}🖼️  Setting wallpaper...${RESET}"
pcmanfm --set-wallpaper ~/.wallpapers/win11-background.jpg --wallpaper-mode=stretch

# Open lxappearance
echo -e "${YELLOW}🚀 Opening lxappearance...${RESET}"
lxappearance &

echo ""
echo -e "${GREEN}✅ Windows 11 Theme applied successfully!${RESET}"
echo -e "${CYAN}🎨 You can tweak settings in lxappearance if needed.${RESET}"
echo ""
echo -e "${CYAN}====================================================${RESET}"
echo -e "${BOLD}${BLUE} Script by: MASA (CODE WITH MASA)${RESET}"
echo -e "${BOLD}${YELLOW} Visit: https://www.youtube.com/@CODEWITHMASA${RESET}"
echo -e "${CYAN}====================================================${RESET}"
