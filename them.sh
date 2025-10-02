#!/bin/bash

echo "=============================================="
echo "   تثبيت ثيم Windows 10 + أيقونات على LXDE"
echo "=============================================="

# تحديث الباكجات
sudo apt-get update

# تثبيت الأدوات المطلوبة
sudo apt-get install -y git lxappearance

# تحميل الثيمات والأيقونات
sudo git clone https://github.com/B00merang-Project/Windows-10.git /usr/share/themes/Windows-10
sudo git clone https://github.com/B00merang-Artwork/Windows-10-Icons.git /usr/share/icons/Windows-10-Icons

# ضبط الثيم كإفتراضي (GTK + أيقونات)
mkdir -p ~/.config/gtk-3.0
cat <<EOF > ~/
