#!/usr/bin/env bash
# install.sh — Install dependencies for the desktop widget
set -e

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Glancebar Installer                ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── System packages ──
if command -v dnf &> /dev/null; then
    echo "▶ Fedora/RedHat system detected (using dnf)"
    echo "▶ Installing system packages..."
    sudo dnf install -y \
        python3-gobject \
        python3-cairo \
        gtk3 \
        playerctl \
        redshift \
        NetworkManager \
        bluez \
        curl \
        gnome-calculator \
        python3-requests \
        xdg-utils

    # ── Fonts (optional but recommended) ──
    echo ""
    echo "▶ Installing fonts..."
    sudo dnf install -y jetbrains-mono-fonts 2>/dev/null || true

elif command -v pacman &> /dev/null; then
    echo "▶ Arch Linux system detected (using pacman)"
    echo "▶ Installing system packages..."
    echo "  (assumes 'sudo pacman -Syu' was run recently — using -S to avoid partial-upgrade risk)"
    sudo pacman -S --noconfirm --needed \
        python-gobject \
        python-cairo \
        gtk3 \
        playerctl \
        redshift \
        networkmanager \
        bluez \
        bluez-utils \
        curl \
        gnome-calculator \
        python-requests \
        xdg-utils \
        libpulse

    # ── Fonts (optional but recommended) ──
    echo ""
    echo "▶ Installing fonts..."
    sudo pacman -S --noconfirm --needed ttf-jetbrains-mono 2>/dev/null || true

    # ── Service activation (Arch doesn't auto-enable these) ──
    echo ""
    echo "▶ Enabling NetworkManager and Bluetooth services..."
    sudo systemctl enable --now NetworkManager.service 2>/dev/null || true
    sudo systemctl enable --now bluetooth.service 2>/dev/null || true

    # ── lp group (required for bluetoothctl on Arch) ──
    : "${USER:=$(id -un)}"
    if ! id -nG "$USER" | grep -qw lp; then
        echo ""
        echo "▶ Adding $USER to 'lp' group (required for Bluetooth toggle on Arch)..."
        if sudo gpasswd -a "$USER" lp; then
            echo "   ⚠️  You must log out and log back in before the Bluetooth toggle will work."
        else
            echo "   ⚠️  Couldn't add $USER to 'lp' group automatically — run 'sudo gpasswd -a $USER lp' manually."
        fi
    fi

elif command -v apt-get &> /dev/null; then
    echo "▶ Debian/Ubuntu system detected (using apt)"
    echo "▶ Updating package list..."
    sudo apt-get update -y -qq

    echo ""
    echo "▶ Installing system packages..."
    sudo apt-get install -y \
        python3-gi \
        python3-gi-cairo \
        gir1.2-gtk-3.0 \
        gir1.2-gdk-3.0 \
        playerctl \
        redshift \
        network-manager \
        bluetooth \
        bluez \
        curl \
        gnome-calculator \
        python3-requests \
        xdg-utils

    # ── Fonts (optional but recommended) ──
    echo ""
    echo "▶ Installing fonts..."
    sudo apt-get install -y fonts-jetbrains-mono 2>/dev/null || true

else
    echo "❌ Error: Package manager not supported (none of dnf, pacman, or apt-get found)."
    echo "   Please install dependencies manually."
    exit 1
fi

# ── Profile image placeholder ──
if [ ! -f "$HOME/Pictures/profile.jpg" ]; then
    echo ""
    echo "⚠️  No profile image found at ~/Pictures/profile.jpg"
    echo "   → Place your photo there and restart the widget."
fi

# ── Autostart entry ──
echo ""
echo "▶ Setting up autostart..."
mkdir -p "$HOME/.config/autostart"
WIDGET_PATH="$(realpath "$(dirname "$0")/widget.py")"

cat > "$HOME/.config/autostart/glancebar.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Glancebar
Comment=Glassmorphism desktop widget
Exec=python3 $WIDGET_PATH
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   ✅  Installation complete!         ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "  To start now:"
echo "    python3 widget.py"
echo ""
echo "  To customize, edit the USER CONFIG"
echo "  section at the top of widget.py:"
echo "    • DISPLAY_NAME  = your name"
echo "    • CITY          = your city (weather)"
echo "    • PROFILE_IMAGE = path to your photo"
echo ""
echo "  Optional – Outfit font for best look:"
echo "    Download from https://fonts.google.com/specimen/Outfit"
echo ""
