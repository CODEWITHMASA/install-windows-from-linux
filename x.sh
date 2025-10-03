#!/bin/bash
# system_info.sh
# Produce a tidy system + hardware report for Ubuntu systems.
# Usage: chmod +x system_info.sh && ./system_info.sh
set -euo pipefail

OUT="/tmp/system_report.txt"
echo "Generating system report -> $OUT"
echo "==========================================" > "$OUT"
echo "System & OS" >> "$OUT"
echo "==========================================" >> "$OUT"

# Basic OS info
echo "lsb_release -a:" >> "$OUT"
if command -v lsb_release >/dev/null 2>&1; then
  lsb_release -a >> "$OUT" 2>/dev/null
else
  cat /etc/os-release >> "$OUT" 2>/dev/null
fi
echo "" >> "$OUT"

# Kernel & arch
echo "Kernel & Architecture" >> "$OUT"
echo "---------------------" >> "$OUT"
uname -srmo >> "$OUT" 2>/dev/null || uname -a >> "$OUT"
echo "" >> "$OUT"

# Installed packages count (dpkg)
if command -v dpkg >/dev/null 2>&1; then
  echo "Installed packages (dpkg): $(dpkg -l 2>/dev/null | wc -l)" >> "$OUT"
fi
echo "" >> "$OUT"

echo "==========================================" >> "$OUT"
echo "CPU" >> "$OUT"
echo "==========================================" >> "$OUT"
if command -v lscpu >/dev/null 2>&1; then
  lscpu >> "$OUT"
else
  cat /proc/cpuinfo >> "$OUT"
fi
echo "" >> "$OUT"

echo "==========================================" >> "$OUT"
echo "Memory (RAM)" >> "$OUT"
echo "==========================================" >> "$OUT"
free -h >> "$OUT"
echo "" >> "$OUT"

echo "==========================================" >> "$OUT"
echo "Disks & Filesystems" >> "$OUT"
echo "==========================================" >> "$OUT"
if command -v lsblk >/dev/null 2>&1; then
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL -r >> "$OUT"
fi
echo "" >> "$OUT"
echo "Mounted filesystems (df -h --total):" >> "$OUT"
df -h --total >> "$OUT" 2>/dev/null || df -h >> "$OUT"
echo "" >> "$OUT"

echo "==========================================" >> "$OUT"
echo "PCI / GPU / Network / USB" >> "$OUT"
echo "==========================================" >> "$OUT"
if command -v lspci >/dev/null 2>&1; then
  echo "lspci (short):" >> "$OUT"
  lspci -nnk >> "$OUT"
else
  echo "lspci not installed." >> "$OUT"
fi
echo "" >> "$OUT"
if command -v lsusb >/dev/null 2>&1; then
  echo "lsusb (short):" >> "$OUT"
  lsusb >> "$OUT"
fi
echo "" >> "$OUT"

echo "==========================================" >> "$OUT"
echo "Hardware summary (lshw short) — requires sudo for full info" >> "$OUT"
echo "==========================================" >> "$OUT"
if command -v lshw >/dev/null 2>&1; then
  if [ "$(id -u)" -eq 0 ]; then
    lshw -short >> "$OUT"
  else
    echo "Note: running lshw -short with sudo for more details..." >> "$OUT"
    sudo lshw -short >> "$OUT" 2>/dev/null || echo "lshw needs to be installed or you cancelled sudo." >> "$OUT"
  fi
else
  echo "lshw not installed. Install with: sudo apt install lshw" >> "$OUT"
fi
echo "" >> "$OUT"

echo "==========================================" >> "$OUT"
echo "Optional: dmidecode (requires sudo) — BIOS / board / serials" >> "$OUT"
echo "==========================================" >> "$OUT"
if command -v dmidecode >/dev/null 2>&1; then
  if [ "$(id -u)" -eq 0 ]; then
    dmidecode -t system >> "$OUT" 2>/dev/null || true
  else
    echo "You can run: sudo dmidecode -t system  (for vendor/serial/model info)" >> "$OUT"
  fi
else
  echo "dmidecode not installed. Install with: sudo apt install dmidecode" >> "$OUT"
fi

echo "" >> "$OUT"
echo "==========================================" >> "$OUT"
echo "Notes:" >> "$OUT"
echo "- Wine prefix (if exists):" >> "$OUT"
echo "  $( [ -d \"$HOME/.wine\" ] && echo '~/.wine exists' || echo '~/.wine not found' )" >> "$OUT"
echo "" >> "$OUT"
echo "Report generated at: $OUT" >> "$OUT"
echo "==========================================" >> "$OUT"

# Print summary to stdout
echo ""
echo "System report saved to: $OUT"
echo "Quick summary:"
echo "--------------"
# extract short summary
echo -n "OS: " && (lsb_release -d 2>/dev/null | cut -f2- -d: || grep PRETTY_NAME /etc/os-release | cut -f2 -d=)
echo -n "Kernel: " && uname -r
echo -n "Arch: " && uname -m
if command -v lscpu >/dev/null 2>&1; then
  echo -n " | CPU: " && lscpu | awk -F: '/Model name/ {print $2; exit}' | sed 's/^[ \t]*//'
fi
echo -n "RAM: " && free -h | awk '/Mem:/ {print $2 " total"}'
echo -n "Disk Root: " && df -h / | awk 'NR==2 {print $2 " total, " $3 " used, " $5 " used%"}'
echo ""
echo ""
echo "If you want, send me the file $OUT (or paste its content) and I'll help you interpret the results."
