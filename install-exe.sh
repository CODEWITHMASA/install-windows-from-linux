#!/usr/bin/env bash
set -euo pipefail

# install-final-with-smart-exe.sh
# For Ubuntu 20.04.6 LTS
# Run as root: sudo bash install-final-with-smart-exe.sh
#
# Installs: Google Chrome, Telegram Desktop, WineHQ (wine32/wine64/winetricks),
# Vulkan libs, downloads AIO runtimes exe and runs it, creates a smart EXE runner
# that:
#  - creates per-exe WINEPREFIX under user's home (~/.wine-prefixes/<name>)
#  - detects exe architecture (32/64)
#  - installs common deps (corefonts, vcrun2015, dotnet48, d3dx9, dxvk) via winetricks
#  - launches exe in background and stores logs in ~/Downloads/wine-logs/
#  - creates a .desktop shortcut in user's ~/.local/share/applications for easy launch
#
# Security note: the runner executes as the invoking GUI user (not root).
# But initial installations below require root.

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use: sudo bash $0"
  exit 1
fi

AIO_URL="https://allinoneruntimes.org/files/aio-runtimes_v2.5.0.exe"
AIO_BASENAME="$(basename "$AIO_URL")"
ROOT_DOWNLOADS="/root/Downloads"
TMP_DEB="/tmp/google-chrome-stable_current_amd64.deb"

echo "=== 1) Update & basic tools ==="
apt-get update -y
apt-get upgrade -y || true
apt-get install -y wget curl ca-certificates gnupg2 software-properties-common apt-transport-https file

echo "=== 2) Remove old Chrome/Chromium if present ==="
OLD_PKGS=(google-chrome-stable google-chrome google-chrome-beta google-chrome-unstable chromium chromium-browser)
for p in "${OLD_PKGS[@]}"; do
  if dpkg -l 2>/dev/null | grep -q "^ii\s\+${p}\b"; then
    echo "Removing: $p"
    apt-get remove --purge -y "$p" || true
  fi
done
apt-get autoremove -y || true
rm -rf /root/.config/google-chrome || true

echo "=== 3) Install Google Chrome (official) ==="
if command -v wget >/dev/null 2>&1; then
  wget -O "$TMP_DEB" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
else
  curl -L -o "$TMP_DEB" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
fi
apt-get install -y "$TMP_DEB" || { apt-get -f install -y; apt-get install -y "$TMP_DEB"; }

echo "=== 4) Install Telegram Desktop ==="
if ! grep -E -h "^deb .+ universe" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null | grep -q .; then
  add-apt-repository -y universe || true
fi
apt-get update -y
apt-get install -y telegram-desktop || { apt-get update -y; apt-get install -y telegram-desktop; }

echo "=== 5) Install WineHQ (i386) and recommended packages ==="
dpkg --add-architecture i386 || true
mkdir -p /etc/apt/keyrings
if command -v wget >/dev/null 2>&1; then
  wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key || true
else
  curl -L -o /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key || true
fi
DISTRO_CODENAME="$(lsb_release -cs || echo focal)"
echo "deb [signed-by=/etc/apt/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ ${DISTRO_CODENAME} main" > /etc/apt/sources.list.d/winehq.list
apt-get update -y
apt-get install -y --install-recommends winehq-stable wine64 wine32 winetricks || {
  apt-get -f install -y || true
  apt-get install -y --install-recommends winehq-stable wine64 wine32 winetricks || true
}

echo "=== 6) Install Vulkan / DXVK host libs (mesa) ==="
# These packages help DXVK work on many Intel/AMD systems. NVIDIA users may need vendor drivers.
apt-get install -y libvulkan1 libvulkan1:i386 mesa-vulkan-drivers vulkan-utils || true

echo "=== 7) Download & run AIO Runtimes exe (background) ==="
mkdir -p "$ROOT_DOWNLOADS"
AIO_TARGET="$ROOT_DOWNLOADS/$AIO_BASENAME"
if command -v wget >/dev/null 2>&1; then
  wget -O "$AIO_TARGET" "$AIO_URL" || true
else
  curl -L -o "$AIO_TARGET" "$AIO_URL" || true
fi
chmod a+r "$AIO_TARGET" || true

if command -v wine >/dev/null 2>&1; then
  nohup bash -c "wine \"$AIO_TARGET\" >/root/Downloads/aio-run.out 2>/root/Downloads/aio-run.err" >/dev/null 2>&1 &
  echo "AIO started in background. Logs: /root/Downloads/aio-run.out /root/Downloads/aio-run.err"
else
  echo "wine not found, skipping AIO launch."
fi

echo "=== 8) Create Desktop shortcuts for root and local apps ==="
ROOT_DESKTOP="/root/Desktop"
LOCAL_APPS="/root/.local/share/applications"
mkdir -p "$ROOT_DESKTOP" "$LOCAL_APPS"

cat > "$ROOT_DESKTOP/Google-Chrome-Root.desktop" <<'EOF'
[Desktop Entry]
Name=Google Chrome (Root)
Comment=Google Chrome (run as root)
Exec=/usr/bin/google-chrome-stable --no-sandbox %U
Icon=google-chrome
Terminal=false
Type=Application
Categories=Network;WebBrowser;
StartupNotify=true
EOF
chmod +x "$ROOT_DESKTOP/Google-Chrome-Root.desktop"
cp -f "$ROOT_DESKTOP/Google-Chrome-Root.desktop" "$LOCAL_APPS/google-chrome-root.desktop"

cat > "$ROOT_DESKTOP/Telegram-Desktop.desktop" <<'EOF'
[Desktop Entry]
Name=Telegram Desktop
Comment=Telegram Desktop
Exec=telegram-desktop %U
Icon=telegram
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupNotify=true
EOF
chmod +x "$ROOT_DESKTOP/Telegram-Desktop.desktop"
cp -f "$ROOT_DESKTOP/Telegram-Desktop.desktop" "$LOCAL_APPS/telegram-desktop.desktop"

cat > "$ROOT_DESKTOP/Wine-Config.desktop" <<'EOF'
[Desktop Entry]
Name=Wine Configuration
Comment=Open Wine configuration (winecfg)
Exec=winecfg
Icon=wine
Terminal=false
Type=Application
Categories=Utility;
StartupNotify=true
EOF
chmod +x "$ROOT_DESKTOP/Wine-Config.desktop"
cp -f "$ROOT_DESKTOP/Wine-Config.desktop" "$LOCAL_APPS/wine-config.desktop"

cat > "$ROOT_DESKTOP/AIO-Runtimes.desktop" <<EOF
[Desktop Entry]
Name=AIO Runtimes (Run via Wine)
Comment=Run aio-runtimes_v2.5.0.exe using Wine
Exec=wine "$AIO_TARGET"
Icon=application-x-ms-dos-executable
Terminal=false
Type=Application
Categories=Utility;
StartupNotify=true
EOF
chmod +x "$ROOT_DESKTOP/AIO-Runtimes.desktop"
cp -f "$ROOT_DESKTOP/AIO-Runtimes.desktop" "$LOCAL_APPS/aio-runtimes.desktop"

echo "=== 9) Install smart EXE runner and .desktop association ==="
RUNNER="/usr/local/bin/wine-exe-runner.sh"
cat > "$RUNNER" <<'EOF'
#!/usr/bin/env bash
# wine-exe-runner.sh
# Invoked by file manager: /usr/local/bin/wine-exe-runner.sh "%f"
# Runs as the GUI user. Creates a per-exe WINEPREFIX, installs common deps (quiet),
# enables dxvk if possible, launches exe in background, logs output, and creates a .desktop shortcut.

set -euo pipefail

FILE="${1:-}"
if [ -z "$FILE" ]; then
  echo "Usage: $0 /path/to/file.exe" >&2
  exit 1
fi

# resolve absolute path
if [ ! -f "$FILE" ]; then
  zenity --error --text="File not found: $FILE" 2>/dev/null || echo "File not found: $FILE" >&2
  exit 2
fi

# Determine invoking user and HOME (some file managers run as root for root user)
INV_USER="$(ps -o user= -p "$(pgrep -u $(id -u) -n $PPID || echo "")" 2>/dev/null || true)"
# Fallback to environment
INV_USER="${SUDO_USER:-${USER:-$(id -un)}}"
USER_HOME="$(getent passwd "$INV_USER" | cut -d: -f6 2>/dev/null || echo "$HOME")"

# If USER_HOME still empty, fallback to HOME
USER_HOME="${USER_HOME:-$HOME}"

# Create log dir
LOGDIR="$USER_HOME/Downloads/wine-logs"
mkdir -p "$LOGDIR"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
OUTLOG="$LOGDIR/wine-run-$TIMESTAMP.out"
ERRLOG="$LOGDIR/wine-run-$TIMESTAMP.err"

# Prepare prefix name (safe)
BNAME="$(basename "$FILE")"
SAFE_NAME="$(echo "$BNAME" | tr '/\\:*?\"<>| ' '_' | tr -cd '[:alnum:]._-' )"
PREFIX_BASE="$USER_HOME/.wine-prefixes"
PREFIX_DIR="$PREFIX_BASE/${SAFE_NAME%.*}"
mkdir -p "$PREFIX_DIR"

# detect exe architecture using `file`
ARCH="win32"
if command -v file >/dev/null 2>&1; then
  FILEOUT="$(file -b --mime-encoding "$FILE" 2>/dev/null || true)"
  # easier: use 'file' output matching PE32/PE32+
  FOUT="$(file "$FILE" 2>/dev/null || true)"
  if echo "$FOUT" | grep -q "PE32+"; then
    ARCH="win64"
  else
    ARCH="win32"
  fi
fi

export WINEPREFIX="$PREFIX_DIR"
export WINEARCH="${ARCH}"
# initialize prefix if empty
if [ ! -d "$WINEPREFIX/drive_c" ] || [ ! -f "$WINEPREFIX/system.reg" ]; then
  mkdir -p "$WINEPREFIX"
  # initialize wineprefix; allow wineboot to complete
  wineboot -u >/dev/null 2>&1 || true
  # install common dependencies quietly (best-effort)
  if command -v winetricks >/dev/null 2>&1; then
    # install core fonts and vcrun2015; dotnet48 may require GUI or fail — try anyway
    winetricks -q corefonts vcrun2015 d3dx9 || true
    # try dotnet48 (this often needs interactive steps; we attempt but don't fail if it doesn't)
    winetricks -q dotnet48 || true
    # try dxvk (requires vulkan host libs installed)
    winetricks -q dxvk || true
  fi
fi

# Launch the exe (detached)
# Keep user's env for GUI: DISPLAY and XDG_RUNTIME_DIR
export DISPLAY="${DISPLAY:-:0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Run in background using setsid; redirect logs
( setsid wine "$FILE" >"$OUTLOG" 2>"$ERRLOG" < /dev/null ) &

# Create a .desktop shortcut for convenience (if not exists)
DESKTOP_DIR="$USER_HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"
SHORTCUT_NAME="$(echo "$SAFE_NAME" | tr ' ' '_' ).desktop"
SHORTCUT_PATH="$DESKTOP_DIR/$SHORTCUT_NAME"

if [ ! -f "$SHORTCUT_PATH" ]; then
  cat > "$SHORTCUT_PATH" <<DESK
[Desktop Entry]
Name=$SAFE_NAME
Exec=env WINEPREFIX="$WINEPREFIX" wine "$FILE"
Icon=application-x-ms-dos-executable
Type=Application
Terminal=false
Categories=Utility;Application;
DESK
  chown "${INV_USER}:$(id -gn "$INV_USER" 2>/dev/null || echo $INV_USER)" "$SHORTCUT_PATH" 2>/dev/null || true
  chmod 644 "$SHORTCUT_PATH"
fi

# notify user (graphical) if zenity exists
if command -v zenity >/dev/null 2>&1; then
  su - "$INV_USER" -c "zenity --notification --text='Launched $BNAME via Wine (logs: $LOGDIR)'" >/dev/null 2>&1 || true
fi

exit 0
EOF

chmod +x "$RUNNER"
echo "Created runner: $RUNNER"

# Create system .desktop to register Wine EXE Runner
WINE_EXE_DESKTOP="/usr/share/applications/wine-exe-runner.desktop"
cat > "$WINE_EXE_DESKTOP" <<'EOF'
[Desktop Entry]
Name=Wine EXE Runner (Isolated Prefix)
Comment=Run Windows executables with Wine (per-exe isolated prefixes)
Exec=/usr/local/bin/wine-exe-runner.sh %f
Terminal=false
Type=Application
MimeType=application/x-ms-dos-executable;application/x-msdos-program;application/vnd.microsoft.portable-executable;application/x-executable;
NoDisplay=false
Categories=Utility;Application;
EOF
chmod 644 "$WINE_EXE_DESKTOP"

# Update desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database /usr/share/applications || true
fi

# Note: xdg-mime sets default per-user; setting for root only here.
if command -v xdg-mime >/dev/null 2>&1; then
  xdg-mime default "wine-exe-runner.desktop" application/x-ms-dos-executable || true
  xdg-mime default "wine-exe-runner.desktop" application/x-msdos-program || true
  xdg-mime default "wine-exe-runner.desktop" application/vnd.microsoft.portable-executable || true
fi

echo ""
echo "=== All done ==="
echo "What I installed/configured:"
echo " - Google Chrome (official)"
echo " - Telegram Desktop"
echo " - WineHQ (wine32/wine64/winetricks)"
echo " - Vulkan host libs: libvulkan1, libvulkan1:i386, mesa-vulkan-drivers, vulkan-utils"
echo " - AIO runtimes exe downloaded and launched in background"
echo " - EXE runner created at: $RUNNER"
echo " - System .desktop for runner: $WINE_EXE_DESKTOP"
echo ""
echo "Usage notes:"
echo " - Double-click any .exe in the file manager. Choose 'Wine EXE Runner' and set as default if prompted."
echo " - On first run for a given exe a per-exe WINEPREFIX is created at: ~/.wine-prefixes/<exe-name>/"
echo " - Logs are stored in: ~/Downloads/wine-logs/"
echo " - Shortcuts for launched exes are created in: ~/.local/share/applications/"
echo ""
echo "Caveats:"
echo " - dotnet48 installation via winetricks can be interactive or fail silently; if an exe needs dotnet and fails, run winetricks dotnet48 manually inside the prefix."
echo " - DXVK requires functioning Vulkan drivers on the host. If the app needs DXVK and you have NVIDIA/AMD, install vendor drivers if needed."
echo " - For best security, run Windows apps as non-root users (the runner uses the invoking user)."
