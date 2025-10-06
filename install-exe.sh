#!/bin/bash
# 🧩 Ultimate Auto Wine Setup Script (MASA Edition)
# Ubuntu 20.04.6 LTS
# Author: MASA
# Youtube: CODE WITH MASA

set -e

# 💬 Show MASA credits
clear
echo "===================================================="
echo "                💻  MASA SETUP SCRIPT 💻"
echo "===================================================="
echo "Author  : MASA"
echo "Channel : CODE WITH MASA"
echo ""
echo "Facebook :  https://www.facebook.com/CODEWITHMASA"
echo "Instagram:  https://www.instagram.com/codewithmasa"
echo "Tiktok   :  https://www.tiktok.com/@CODEWITHMASA"
echo "Youtube  :  https://www.youtube.com/@CODEWITHMASA"
echo "Telegram Active :  https://t.me/+_R91sWmKBacyZTc0"
echo "Telegram Page   :  https://t.me/CODEWITHMASA"
echo "Github   :  https://github.com/CODEWITHMASA"
echo "X (Twitter):  https://x.com/CODEWITHMASA"
echo "Website  :  https://codewithmasa.blogspot.com/"
echo "Telegram Group  :  https://t.me/GROUPCODEWITHMASA"
echo "Telegram Contact: https://t.me/MrMasaOfficial"
echo "===================================================="
sleep 3
clear

echo "🧹 Removing Google Chrome repo to avoid GPG errors..."
sudo rm -f /etc/apt/sources.list.d/google-chrome.list

echo "🔄 Updating system and adding 32-bit architecture..."
sudo dpkg --add-architecture i386
sudo apt update -y
sudo apt upgrade -y

echo "🍷 Installing Wine and dependencies..."
sudo apt install -y wine64 wine32 wine-stable winbind winetricks cabextract wget unzip zenity

echo "⚙️ Initializing Wine environment..."
wineboot --init
sleep 5

echo "🧰 Installing core runtimes (.NET, Visual C++, Fonts)..."
winetricks -q corefonts vcrun6sp6 vcrun2010 vcrun2012 vcrun2013 vcrun2015 vcrun2019 dotnet40 dotnet45 dotnet472

echo "📦 Creating setup directory..."
mkdir -p ~/wine_setup
cd ~/wine_setup

echo "⬇️ Downloading All in One Runtimes..."
wget -O aio-runtimes_v2.5.0.exe "https://allinoneruntimes.org/files/aio-runtimes_v2.5.0.exe"

echo "🚀 Running All in One Runtimes inside Wine..."
wine aio-runtimes_v2.5.0.exe || echo "⚠️ You can run it manually later."

echo "🪟 Installing GUI tools (Bottles & PlayOnLinux)..."
sudo apt install -y playonlinux bottles

echo ""
echo "📂 Please select the .exe file you want to run (GUI window will open)..."
EXE_PATH=$(zenity --file-selection --title="Select .exe file to run with Wine" --file-filter="*.exe")

if [[ -z "$EXE_PATH" ]]; then
  echo "❌ No file selected. Exiting..."
  exit 1
fi

echo "🚀 Running the selected program with Wine..."
wine "$EXE_PATH"

APP_NAME=$(basename "$EXE_PATH" .exe)
DESKTOP_DIR="$HOME/Desktop"

echo "🧩 Creating desktop shortcut for the program..."
cat <<EOF > "$DESKTOP_DIR/${APP_NAME}.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_NAME}
Comment=Run ${APP_NAME} with Wine
Exec=wine "$EXE_PATH"
Icon=wine
Terminal=false
Categories=Utility;Wine;
EOF

chmod +x "$DESKTOP_DIR/${APP_NAME}.desktop"

echo "✅ Shortcut created on Desktop: ${APP_NAME}.desktop"
echo ""
echo "🎉 Environment ready!"
echo "💡 You can now open ${APP_NAME} directly from your desktop."
echo "===================================================="
echo "Setup completed by: MASA (CODE WITH MASA)"
echo "Visit: https://www.youtube.com/@CODEWITHMASA"
echo "===================================================="
