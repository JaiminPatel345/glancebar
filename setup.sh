#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  Glancebar - One-time Setup Script
#  Run once: bash setup.sh
# ─────────────────────────────────────────────────────────────

set -e

echo "📦 Installing dependencies..."
if command -v dnf &> /dev/null; then
  echo "▶ Fedora/RedHat system detected (using dnf)"
  sudo dnf install -y \
    python3-gobject \
    python3-cairo \
    gtk3 \
    gdk-pixbuf2 \
    redshift \
    brightnessctl \
    NetworkManager \
    bluez
elif command -v pacman &> /dev/null; then
  echo "▶ Arch Linux system detected (using pacman)"
  sudo pacman -Sy --noconfirm --needed \
    python-gobject \
    python-cairo \
    gtk3 \
    gdk-pixbuf2 \
    redshift \
    brightnessctl \
    networkmanager \
    bluez \
    bluez-utils
elif command -v apt &> /dev/null; then
  echo "▶ Debian/Ubuntu system detected (using apt)"
  sudo apt update -qq
  sudo apt install -y \
    python3-gi \
    python3-gi-cairo \
    gir1.2-gtk-3.0 \
    gir1.2-gdkpixbuf-2.0 \
    python3-cairo \
    redshift \
    brightnessctl \
    network-manager \
    bluez
else
  echo "❌ Error: Package manager not supported (none of dnf, pacman, or apt found)."
  echo "   Please install dependencies manually."
  exit 1
fi

echo ""
echo "📁 Creating config directory..."
mkdir -p ~/.config/glancebar

echo ""
echo "✅ Setup complete!"
echo ""
echo "─────────────────────────────────────────────────────"
echo "  BEFORE RUNNING — edit widget.py and change:"
echo ""
echo "  USER_NAME = 'Your Name'     ← your name"
echo "  CITY      = 'New York'      ← your city (for weather)"
echo ""
echo "  Profile photo (optional):"
echo "  Copy your photo to:  ~/.config/glancebar/profile.jpg"
echo "─────────────────────────────────────────────────────"
echo ""
echo "▶  Run the widget:"
echo "   python3 widget.py"
echo ""
echo "▶  Auto-start on login:"
echo "   bash autostart.sh"
echo ""
