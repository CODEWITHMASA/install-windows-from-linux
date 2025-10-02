#!/bin/bash

# ============================================
# Interactive Theme Installer: Win11 + Catppuccin LXTerminal
# ============================================

# ------------------------------
# Print your social links professionally (before applying themes)
# ------------------------------
echo ""
echo "============================================"
echo "           🌐 My Social Links 🌐           "
echo "============================================"
echo -e "📘 Facebook        : \033[1;34mhttps://www.facebook.com/CODEWITHMASA\033[0m"
echo -e "📸 Instagram       : \033[1;35mhttps://www.instagram.com/codewithmasa\033[0m"
echo -e "🎵 TikTok          : \033[1;36mhttps://www.tiktok.com/@CODEWITHMASA\033[0m"
echo -e "▶️ Youtube         : \033[1;31mhttps://www.youtube.com/@CODEWITHMASA\033[0m"
echo -e "💬 Telegram Active : \033[1;34mhttps://t.me/+_R91sWmKBacyZTc0\033[0m"
echo -e "📢 Telegram Page   : \033[1;36mhttps://t.me/CODEWITHMASA\033[0m"
echo -e "🐱 Github          : \033[1;30mhttps://github.com/CODEWITHMASA\033[0m"
echo -e "🐦 X (Twitter)     : \033[1;34mhttps://x.com/CODEWITHMASA\033[0m"
echo -e "🌐 Website         : \033[1;32mhttps://codewithmasa.blogspot.com/\033[0m"
echo -e "👥 Group Telegram  : \033[1;36mhttps://t.me/GROUPCODEWITHMASA\033[0m"
echo -e "📞 Telegram Contact: \033[1;35mhttps://t.me/MrMasaOfficial\033[0m"
echo "============================================"
echo ""

# ------------------------------
# Ask for Win11 theme
echo "Choose Win11 theme:"
echo "1) Win11 Dark"
echo "2) Win11 Light"
read -p "Enter choice [1-2]: " win11_choice

if [ "$win11_choice" == "1" ]; then
    WIN11_THEME="Win11-round-Dark"
    WIN11_THEME_URL="https://ocs-dl.fra1.cdn.digitaloceanspaces.com/data/files/1744011723/Win11-round-Dark.tar.xz"
else
    WIN11_THEME="Win11-round-Light"
    WIN11_THEME_URL="https://ocs-dl.fra1.cdn.digitaloceanspaces.com/data/files/1744011723/Win11-round-Light.tar.xz"
fi

# ------------------------------
# Ask for Catppuccin flavor
echo "Choose Catppuccin flavor for LXTerminal:"
echo "1) Latte"
echo "2) Frappe"
echo "3) Macchiato"
echo "4) Mocha"
read -p "Enter choice [1-4]: " cat_flavor_choice

case $cat_flavor_choice in
    1) CAT_FLAVOR="Latte" ;;
    2) CAT_FLAVOR="Frappe" ;;
    3) CAT_FLAVOR="Macchiato" ;;
    4) CAT_FLAVOR="Mocha" ;;
    *) CAT_FLAVOR="Mocha" ;; # default
esac

# ------------------------------
# Paths
ICON_URL="https://ocs-dl.fra1.cdn.digitaloceanspaces.com/data/files/1624990003/Win11-blue.tar.xz"
BG_URL="https://l.top4top.io/p_3562wi1qn1.jpg"

THEME_DIR="$HOME/.themes"
ICON_DIR="$HOME/.icons"
PICTURES_DIR="$HOME/Pictures"
GTK3_CONF_DIR="$HOME/.config/gtk-3.0"
GTK2_RC="$HOME/.gtkrc-2.0"

LXTERMINAL_CONFIG="$HOME/.config/lxterminal"
LXTERMINAL_PROFILE="$LXTERMINAL_CONFIG/Default"

# ------------------------------
# Install packages
echo "🚀 Installing necessary packages..."
sudo apt update
sudo apt install -y wget git lxappearance gtk2-engines-murrine gtk2-engines-pixbuf gtk3-engines-unico xfconf

mkdir -p $THEME_DIR $ICON_DIR $PICTURES_DIR $GTK3_CONF_DIR $LXTERMINAL_CONFIG

# ------------------------------
# Download and extract Win11 theme and icons
echo "Downloading and applying Win11 theme..."
wget -O ~/Win11-theme.tar.xz "$WIN11_THEME_URL"
tar -xf ~/Win11-theme.tar.xz -C $THEME_DIR

wget -O ~/Win11-icons.tar.xz "$ICON_URL"
tar -xf ~/Win11-icons.tar.xz -C $ICON_DIR

# ------------------------------
# Download background
wget -O $PICTURES_DIR/win-background.jpg "$BG_URL"

# ------------------------------
# Configure GTK3
cat > $GTK3_CONF_DIR/settings.ini <<EOL
[Settings]
gtk-theme-name = $WIN11_THEME
gtk-icon-theme-name = Win11-blue
gtk-font-name = Sans 10
gtk-cursor-theme-name = DMZ-White
EOL

# Configure GTK2
echo "gtk-theme-name=\"$WIN11_THEME\"" > $GTK2_RC
echo "gtk-icon-theme-name=\"Win11-blue\"" >> $GTK2_RC
echo "gtk-font-name=\"Sans 10\"" >> $GTK2_RC

# ------------------------------
# Apply background (LXDE)
if command -v pcmanfm &> /dev/null; then
    pcmanfm --set-wallpaper=$PICTURES_DIR/win-background.jpg --wallpaper-mode=stretch
    pcmanfm --quit
    pcmanfm &
fi

# Apply background (XFCE)
if command -v xfconf-query &> /dev/null; then
    PROP="/backdrop/screen0/monitor0/image-path"
    if xfconf-query -c xfce4-desktop -p $PROP &> /dev/null; then
        xfconf-query -c xfce4-desktop -p $PROP -s $PICTURES_DIR/win-background.jpg
    else
        xfconf-query -c xfce4-desktop -n -t string -p $PROP -s $PICTURES_DIR/win-background.jpg
    fi
    xfdesktop --reload
fi

# ------------------------------
# Install Catppuccin LXTerminal
echo "Installing Catppuccin theme ($CAT_FLAVOR) for LXTerminal..."
git clone https://github.com/catppuccin/lxterminal.git /tmp/lxterminal-theme
cp /tmp/lxterminal-theme/Default "$LXTERMINAL_PROFILE"

# Apply selected flavor and font
sed -i "s/^FontName=.*/FontName=Fira Code 11/" "$LXTERMINAL_PROFILE"
sed -i "s/^ColorScheme=.*/ColorScheme=$CAT_FLAVOR/" "$LXTERMINAL_PROFILE"
rm -rf /tmp/lxterminal-theme

echo "✅ Installation completed! Restart LXTerminal to see changes."
