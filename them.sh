#!/bin/bash

apt-get update
apt-get install -y wget unzip

cd /tmp

# تحميل الثيم
wget -O win10-theme.zip https://github.com/B00merang-Project/Windows-10/archive/refs/heads/master.zip
unzip -o win10-theme.zip
cp -r Windows-10-* /usr/share/themes/Windows-10

# تحميل الأيقونات
wget -O win10-icons.zip https://github.com/B00merang-Project/Windows-10-Icons/archive/refs/heads/master.zip
unzip -o win10-icons.zip
cp -r Windows-10-Icons-* /usr/share/icons/Windows-10-Icons

# إعدادات GTK
mkdir -p /root/.config/gtk-3.0
cat <<EOF > /root/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Windows-10
gtk-icon-theme-name=Windows-10-Icons
gtk-font-name=Sans 10
EOF

# إعدادات Openbox
mkdir -p /root/.config/openbox
cat <<EOF > /root/.config/openbox/lxde-rc.xml
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <theme>
    <name>Windows-10</name>
    <titleLayout>NLIMC</titleLayout>
    <keepBorder>yes</keepBorder>
    <animateIconify>yes</animateIconify>
  </theme>
</openbox_config>
EOF

# إعادة تحميل Openbox
openbox --reconfigure

echo "✅ تم تثبيت ثيم Windows 10 + الأيقونات!"
