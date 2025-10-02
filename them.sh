#!/bin/bash

# -------------------------------------------
# MASA Windows 11 Theme Installer (Minimal)
# -------------------------------------------
sudo apt install -y lxappearance gtk2-engines-murrine gtk2-engines-pixbuf gtk3-engines-unico

# إنشاء مجلدات للثيمات والأيقونات والخلفيات
mkdir -p ~/.themes
mkdir -p ~/.icons
mkdir -p ~/Pictures

# تحميل الثيم (Win11 Light)
echo "Downloading Win11 Light theme..."
wget -O ~/Downloads/Win11-round-Light.tar.xz "https://ocs-dl.fra1.cdn.digitaloceanspaces.com/data/files/1744011723/Win11-round-Light.tar.xz?response-content-disposition=attachment%3B%2520Win11-round-Light.tar.xz&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=RWJAQUNCHT7V2NCLZ2AL%2F20251002%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251002T060720Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Signature=d344c6a76aede9db263af4cede439a31738001a3034d471996bbf50313b2b15f"
echo "Extracting theme..."
tar -xf ~/Downloads/Win11-round-Light.tar.xz -C ~/.themes

# تحميل الأيقونات (Win11 Blue)
echo "Downloading Win11 Blue icons..."
wget -O ~/Downloads/Win11-blue.tar.xz "https://ocs-dl.fra1.cdn.digitaloceanspaces.com/data/files/1624990003/Win11-blue.tar.xz?response-content-disposition=attachment%3B%2520Win11-blue.tar.xz&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=RWJAQUNCHT7V2NCLZ2AL%2F20251002%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251002T054726Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Signature=680ecccd25e95ededc090f953ec1b40101d49ddff95c2e91a9cc83d8202391f6"
echo "Extracting icons..."
tar -xf ~/Downloads/Win11-blue.tar.xz -C ~/.icons

# تحميل الخلفية
echo "Downloading wallpaper..."
wget -O ~/Pictures/win-background.jpg "https://l.top4top.io/p_3562wi1qn1.jpg"

# تطبيق الخلفية تلقائيًا (PCManFM / XFCE)
if command -v pcmanfm &> /dev/null; then
    pcmanfm --set-wallpaper=$HOME/Pictures/win-background.jpg --wallpaper-mode=stretch
elif command -v xfconf-query &> /dev/null; then
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s $HOME/Pictures/win-background.jpg --create
else
    echo "Cannot set wallpaper automatically. Please set it manually."
fi

echo "-----------------------------------"
echo "✅ Win11 Light theme and Win11 Blue icons downloaded."
echo "✅ Wallpaper applied (or ready to set)."
echo "⚡ Now open LXAppearance to apply the theme and icons manually."
echo "-----------------------------------"
