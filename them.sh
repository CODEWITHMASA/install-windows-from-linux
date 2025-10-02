#!/bin/bash

echo "=============================================="
echo "  تثبيت وتطبيق ثيم Windows 10 على LXDE"
echo "=============================================="

# تحديث الباكجات
sudo apt-get update

# تثبيت الأدوات المطلوبة
sudo apt-get install -y git lxappearance wget

# تحميل الثيمات والأيقونات (لو مش متثبتة قبل كده)
if [ ! -d "/usr/share/themes/Windows-10" ]; then
    sudo git clone https://github.com/B00merang-Project/Windows-10.git /usr/share/themes/Windows-10
fi

if [ ! -d "/usr/share/icons/Windows-10-Icons" ]; then
    sudo git clone https://github.com/B00merang-Artwork/Windows-10-Icons.git /usr/share/icons/Windows-10-Icons
fi

# ضبط الثيم والأيقونات كإعداد افتراضي
mkdir -p ~/.config/gtk-3.0
cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Windows-10
gtk-icon-theme-name=Windows-10-Icons
EOF

# ضبط LXDE يطبّق الثيم أوتوماتيك عند تسجيل الدخول
mkdir -p ~/.config/lxsession/LXDE
echo '@lxappearance --command=apply' >> ~/.config/lxsession/LXDE/autostart

# تحميل الخلفية اللي انت عايزها
wget -O ~/wallpaper.jpg "https://c.top4top.io/p_3560n0o481.jpg"

# ضبط الخلفية كافتراضية
pcmanfm --set-wallpaper="$HOME/wallpaper.jpg"

echo "=============================================="
echo " ✔ تم التثبيت! "
echo " ✨ أعد تشغيل سطح المكتب أو الـ VNC لرؤية ثيم ويندوز + الخلفية"
echo "=============================================="
