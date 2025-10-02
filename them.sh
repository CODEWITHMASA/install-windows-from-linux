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

# إعدادات GTK (للقوائم والنوافذ)
mkdir -p ~/.config/gtk-3.0
cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Windows-10
gtk-icon-theme-name=Windows-10-Icons
gtk-font-name=Sans 10
EOF

# إعدادات openbox (مدير النوافذ في LXDE)
mkdir -p ~/.config/openbox
cat <<EOF > ~/.config/openbox/lxde-rc.xml
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc" xmlns:xi="http://www.w3.org/2001/XInclude">
  <theme>
    <name>Windows-10</name>
    <titleLayout>NLIMC</titleLayout>
    <keepBorder>yes</keepBorder>
    <animateIconify>yes</animateIconify>
  </theme>
</openbox_config>
EOF

# إعادة تحميل إعدادات openbox
openbox --reconfigure

# تحميل الخلفية اللي انت عايزها
wget -O ~/wallpaper.jpg "https://c.top4top.io/p_3560n0o481.jpg"

# ضبط الخلفية كافتراضية
pcmanfm --set-wallpaper="$HOME/wallpaper.jpg"

echo "=============================================="
echo " ✔ تم التثبيت والتطبيق!"
echo " ✨ لو ما ظهرش التغيير، اعمل Logout/Login أو اكتب: openbox --restart"
echo "=============================================="
