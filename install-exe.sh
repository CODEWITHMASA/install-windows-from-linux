#!/bin/bash
# 🧩 Ultimate Auto Wine Setup Script
# Ubuntu 20.04.6 LTS
# Author: ChatGPT

set -e

echo "🔄 تحديث النظام وإضافة دعم 32 بت..."
sudo dpkg --add-architecture i386
sudo apt update -y
sudo apt upgrade -y

echo "🍷 تثبيت Wine والإضافات..."
sudo apt install -y wine64 wine32 wine-stable winbind winetricks cabextract wget unzip zenity

echo "⚙️ تهيئة Wine لأول مرة..."
wineboot --init
sleep 5

echo "🧰 تثبيت مكتبات أساسية (.NET + Visual C++ + خطوط)..."
winetricks -q corefonts vcrun6sp6 vcrun2010 vcrun2012 vcrun2013 vcrun2015 vcrun2019 dotnet40 dotnet45 dotnet472

echo "📦 إعداد مجلد التثبيت..."
mkdir -p ~/wine_setup
cd ~/wine_setup

echo "⬇️ تحميل أداة All in One Runtimes..."
wget -O aio-runtimes_v2.5.0.exe "https://allinoneruntimes.org/files/aio-runtimes_v2.5.0.exe"

echo "🚀 تشغيل الأداة داخل Wine..."
wine aio-runtimes_v2.5.0.exe || echo "⚠️ يمكنك تشغيلها يدويًا لاحقًا."

echo "🪟 تثبيت Bottles و PlayOnLinux..."
sudo apt install -y playonlinux bottles

echo ""
echo "📂 اختَر ملف exe اللي عايز تشغّله (هتظهر نافذة اختيار)..."
EXE_PATH=$(zenity --file-selection --title="اختَر ملف exe لتشغيله بـ Wine" --file-filter="*.exe")

if [[ -z "$EXE_PATH" ]]; then
  echo "❌ لم يتم اختيار أي ملف. الخروج..."
  exit 1
fi

echo "🚀 تشغيل البرنامج داخل Wine..."
wine "$EXE_PATH"

APP_NAME=$(basename "$EXE_PATH" .exe)
DESKTOP_DIR="$HOME/Desktop"

echo "🧩 إنشاء اختصار على سطح المكتب للبرنامج..."
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

echo "✅ تم إنشاء الاختصار على سطح المكتب باسم: ${APP_NAME}.desktop"
echo ""
echo "🎉 تم تشغيل البرنامج وتثبيت البيئة بالكامل بنجاح!"
echo "💡 يمكنك الآن فتح ${APP_NAME} مباشرة من سطح المكتب."
