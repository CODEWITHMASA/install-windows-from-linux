#!/bin/bash

# =========================================
# MASA Windows 11 Theme Installer (Auto)
# Works on minimal LXDE/XFCE (Docker, Cloud Shell)
# =========================================

# ===== CONFIG =====
THEME="Win11-round-Light"   # options: Win11-round-Light, Win11-round-Dark
ICON="Win11-blue"
WALLPAPER_URL="https://l.top4top.io/p_3562wi1qn1.jpg"
CATPPUCCIN_FLAVOR="Mocha"   # options: Latte, Frappe, Macchiato, Mocha

# ===== DIRECTORIES =====
mkdir -p ~/.themes
mkdir -p ~/.icons
mkdir -p ~/Pictures
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/lxterminal

# ===== DOWNLOAD & EXTRACT THEME =====
echo "Downloading $THEME theme..."
wget -O ~/Downloads/$THEME.tar.xz "https://ocs-dl.fra1.cdn.digitaloceanspaces.com/data/files/1744011723/$THEME.tar.xz?response-content-disposition=attachment"
echo "Extracting theme..."
tar -xf ~/Downloads/$THEME.tar.xz -C ~/.themes

# ===== DOWNLOAD & EXTRACT ICONS =====
echo "Downloading $ICON icons..."
wget -O ~/Downloads/$ICON.tar.xz "https://ocs-dl.fra1.cdn.digitaloceanspaces.com/data/files/1624990003/Win11-blue.tar.xz?response-content-disposition=attachment"
echo "Extracting icons..."
tar -xf ~/Downloads/$ICON.tar.xz -C ~/.icons

# ===== DOWNLOAD WALLPAPER =====
echo "Downloading wallpaper..."
wget -O ~/Pictures/win-background.jpg "$WALLPAPER_URL"

# ===== APPLY WALLPAPER =====
if command -v pcmanfm &> /dev/null; then
    pcmanfm --set-wallpaper=$HOME/Pictures/win-background.jpg --wallpaper-mode=stretch
elif command -v xfconf-query &> /dev/null; then
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s $HOME/Pictures/win-background.jpg --create
else
    echo "Cannot set wallpaper automatically. Please set it manually."
fi

# ===== APPLY GTK3 SETTINGS =====
cat > ~/.config/gtk-3.0/settings.ini <<EOL
[Settings]
gtk-theme-name = $THEME
gtk-icon-theme-name = $ICON
gtk-font-name = Sans 10
gtk-cursor-theme-name = DMZ-White
EOL

# ===== APPLY GTK2 SETTINGS =====
echo "gtk-theme-name=\"$THEME\"" > ~/.gtkrc-2.0
echo "gtk-icon-theme-name=\"$ICON\"" >> ~/.gtkrc-2.0
echo "gtk-font-name=\"Sans 10\"" >> ~/.gtkrc-2.0

# ===== APPLY LXTerminal Catppuccin Theme =====
LXTERMINAL_CONF="$HOME/.config/lxterminal/Default"
cat > $LXTERMINAL_CONF <<EOL
[general]
fontname=Monospace 12
color_scheme=$CATPPUCCIN_FLAVOR
EOL

# ===== COMPLETE =====
echo "-----------------------------------"
echo "✅ Theme: $THEME applied"
echo "✅ Icons: $ICON applied"
echo "✅ Wallpaper applied (or ready to set)"
echo "✅ LXTerminal Catppuccin flavor: $CATPPUCCIN_FLAVOR"
echo "⚡ If LXTerminal does not refresh, close and reopen it."
echo "-----------------------------------"
