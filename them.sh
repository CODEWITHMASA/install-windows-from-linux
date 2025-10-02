#!/bin/bash
# -----------------------------
# Script: Install Win11 Theme on LXDE and open lxappearance
# -----------------------------

# إنشاء المجلدات
mkdir -p ~/.themes ~/.icons ~/.wallpapers

# تحميل الملفات
echo "Downloading theme, icons, and wallpaper..."
wget -q -O ~/.icons/Win11-blue.tar.xz https://github.com/CODEWITHMASA/them-windows-to-linux/raw/main/Win11-blue.tar.xz
wget -q -O ~/.themes/Win11-round-Dark-compact.tar.xz https://github.com/CODEWITHMASA/them-windows-to-linux/raw/main/Win11-round-Dark-compact.tar.xz
wget -q -O ~/.wallpapers/win11-background.jpg https://l.top4top.io/p_3562wi1qn1.jpg

# فك الضغط
echo "Extracting files..."
tar -xf ~/.icons/Win11-blue.tar.xz -C ~/.icons/
tar -xf ~/.themes/Win11-round-Dark-compact.tar.xz -C ~/.themes/

# تثبيت lxappearance إذا مش موجود
if ! command -v lxappearance &> /dev/null; then
    echo "Installing lxappearance..."
    sudo apt update && sudo apt install -y lxappearance
fi

# تطبيق الثيمات تلقائيًا (قد لا يغير كل الإعدادات تلقائيًا في LXDE، بس يعينها كخيار افتراضي)
gsettings set org.lxde.interface gtk-theme "Win11-round-Dark-compact" 2>/dev/null
gsettings set org.lxde.interface icon-theme "Win11-blue" 2>/dev/null

# تغيير الخلفية تلقائيًا
echo "Setting wallpaper..."
pcmanfm --set-wallpaper ~/.wallpapers/win11-background.jpg --wallpaper-mode=stretch

# فتح lxappearance عشان تشوف الثيمات وتعدل
echo "Opening lxappearance..."
lxappearance &

echo "✅ Win11 theme applied! You can tweak it in lxappearance now."
