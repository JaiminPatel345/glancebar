<h1 align="center">Glancebar</h1>

<p align="center">
  <b>A beautiful glassmorphism desktop widget for Ubuntu.</b><br/>
  Clock · Weather · Music · App Launcher · System Controls · File Shortcuts<br/>
  <i>All in one always-on panel that lives on your desktop.</i>
</p>

<p align="center">
  <img src="Images/full_preview.png" alt="Glancebar Preview" width="900"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Python-3.8+-3776AB?logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/GTK-3-4A90D9?logo=gnome&logoColor=white" />
  <img src="https://img.shields.io/badge/Cairo-vector_graphics-CC3333" />
  <img src="https://img.shields.io/badge/platform-Ubuntu%20%7C%20Fedora%20%7C%20Arch-blue?logo=linux&logoColor=white" />
  <img src="https://img.shields.io/badge/license-MIT-green" />
</p>

---

## Table of Contents

1. [Why Glancebar?](#why-glancebar)
2. [Features](#features)
3. [Before You Start](#before-you-start)
4. [Try It First (quick preview)](#try-it-first-quick-preview)
5. [Install Permanently (auto-start on login)](#install-permanently-auto-start-on-login)
6. [Frosted-glass blur (optional)](#frosted-glass-blur-optional)
7. [Make It Yours — Full config.json guide](#make-it-yours--the-easy-bit)
8. [How to stop / restart / uninstall](#how-to-stop--restart--uninstall)
9. [Architecture](#architecture)
10. [Troubleshooting](#troubleshooting)
11. [Contributing & License](#contributing)

---

## Why Glancebar?

Tired of having ten tiny widgets scattered across your desktop? Glancebar gives you **one elegant panel** that sits quietly behind your windows and surfaces everything you actually use — time, weather, music, your favorite apps, Wi-Fi/Bluetooth toggles, quick folders, and a web search — all in a frosted-glass card that looks like it belongs in a 2030 concept video.

Built with **Python 3 + GTK3 + Cairo**. No Electron. No bloat. No Qt. Just ~1000 lines of clean, hackable Python you can read in one sitting.

---

## Features

- **Live clock** with analog face + full month calendar
- **Current weather** for your city (via [wttr.in](https://wttr.in))
- **Music player** with album art, progress bar, play/prev/next — works with Spotify, YouTube, VLC, anything that speaks MPRIS
- **App launcher** for your most-used apps with real icons
- **System toggles** — Wi-Fi, Bluetooth, Night Light, Mute — one-click from the desktop
- **System actions** — Shutdown, Restart, Lock, Logout with confirmation
- **File shortcuts** to your favorite folders
- **Web search bar** that opens results in your default browser
- **Rotating quote** of the day
- **100% configurable** via one `config.json` — add apps, change colors, rename toggles, point to your own icons

---

## Before You Start

This widget targets **Ubuntu / Debian, Fedora / RedHat, or Arch-based distros with GNOME or similar**. Make sure you have:

- **Ubuntu 20.04+**, **Fedora 38+**, or **Arch Linux** (or compatible distros)
- **Python 3.8 or newer** — check with `python3 --version`
- **Sudo access** (needed once, for the package installs)
- **An internet connection** (for downloading packages and live weather)
- **A compositor with blur support** *(optional, for the frosted-glass effect — see [blur section](#frosted-glass-blur-optional))*

You do **not** need to install anything manually — `install.sh` handles GTK3, Cairo, playerctl, redshift, and all other system packages for you.

> **⚠️ Note:** Some features depend on system services being enabled — Bluetooth toggle won't work if the `bluetooth` service is disabled, Wi-Fi toggle needs NetworkManager, etc. If your distro uses something different (e.g. `iwd` instead of NetworkManager), edit the commands in `config.json` (see the [config guide](#3-system-toggles-wi-fi--bluetooth--night--mute) below).

### Arch Linux notes

A few extra things to know if you're on Arch:

- **Run `sudo pacman -Syu` first.** `install.sh` uses `pacman -S` (not `-Sy`) to avoid the [partial-upgrade footgun](https://wiki.archlinux.org/title/System_maintenance#Partial_upgrades_are_unsupported). Make sure your system is up to date before running it.
- **Night-mode toggle (`redshift`) does not work on Wayland.** GNOME on Arch defaults to a Wayland session, and `redshift` is X11-only and long unmaintained upstream. Three options:
  1. Pick the **"GNOME on Xorg"** session at login if you want `redshift` to work as-is.
  2. On Wayland, switch the night toggle to GNOME's built-in Night Light by editing `config.json`:
     ```json
     { "label": "Night",
       "icon": "moon",
       "cmd_on":  ["gsettings", "set", "org.gnome.settings-daemon.plugins.color", "night-light-enabled", "true"],
       "cmd_off": ["gsettings", "set", "org.gnome.settings-daemon.plugins.color", "night-light-enabled", "false"] }
     ```
  3. On non-GNOME Wayland compositors (Hyprland, Sway), install `gammastep` (`sudo pacman -S gammastep`) and replace `redshift` with `gammastep` in the toggle commands.
- **Bluetooth needs `lp` group membership.** `install.sh` adds your user to the `lp` group automatically; **log out and back in** for it to take effect, otherwise the Bluetooth toggle will silently fail.
- **NetworkManager and Bluetooth services** are enabled by `install.sh` (Arch does not auto-enable them like Ubuntu/Fedora do).

---

## Try It First (quick preview)

Want to see it running before committing to the autostart setup? Takes **2 minutes**.

### 1. Clone the repo
```bash
git clone https://github.com/JaiminPatel345/glancebar.git
cd glancebar
```

### 2. Install dependencies
```bash
bash install.sh
```
This installs every system package you need (GTK3, Cairo, playerctl, redshift, network-manager, bluez, python3-requests, etc.). It will ask for your sudo password once.

### 3. (Optional) Drop in a profile photo
```bash
cp /path/to/your/photo.jpg ~/Pictures/profile.jpg
```
If you skip this, Glancebar shows a nice gradient circle instead.

### 4. Launch it
```bash
python3 widget.py
```

The widget appears centered on your desktop. **Leave the terminal open** — closing the terminal stops the widget. To stop manually, press `Ctrl+C` in that terminal.

> **💡 Try this first before step "install permanently"** — it lets you edit `config.json`, restart, and iterate fast without touching system autostart.

---

## Install Permanently (auto-start on login)

Once you're happy with how it looks, make it launch automatically every time you log in.

### 1. From the project directory:
```bash
bash autostart.sh
```

This creates `~/.config/autostart/glancebar.desktop`, which your desktop environment reads at login.

### 2. Log out and log back in (or reboot)

> **🔁 Important:** The widget will **not** appear until you log out and log back in (or reboot). Autostart entries are only processed on login — not immediately.

```bash
# Fastest way:
gnome-session-quit --logout --no-prompt
```

After logging back in, Glancebar will be running on your desktop. You won't see a terminal window — it runs silently in the background.

### 3. Verify it's running
```bash
pgrep -af "python3.*widget.py"
```
You should see one line showing the running process.

---

## Frosted-glass blur (optional)

Without a blur-capable compositor, the widget still works — you just get a semi-transparent dark card instead of the blurred-wallpaper effect. To get the full glass look:

### 1. Install picom
```bash
# On Debian/Ubuntu:
sudo apt install picom

# On Fedora:
sudo dnf install picom

# On Arch:
sudo pacman -S picom
```

### 2. Enable blur in `~/.config/picom.conf`
Create the file if it doesn't exist, and add:
```ini
blur-method = "dual_kawase";
blur-strength = 8;
blur-background = true;
```

### 3. Start picom
```bash
picom --daemon
```

### 4. Make picom auto-start on login
```bash
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/picom.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Picom
Exec=picom --daemon
X-GNOME-Autostart-enabled=true
EOF
```
Log out + log back in for picom to start automatically.

---

## Make It Yours — the easy bit

**Everything user-facing lives in one file: [`config.json`](config.json).** No Python editing required. Open it in any text editor, change what you want, save, and restart the widget.

> **🔄 To see your changes:** stop the widget (`Ctrl+C` in the terminal, or `pkill -f "python3.*widget.py"`) and start it again (`python3 widget.py`). If it's running via autostart, you can just kill and relaunch — no logout needed.

Here's a tour of every section of `config.json`:

### 1. Your profile
```json
{
  "display_name": "Your Name",
  "subtitle": "Your Title",
  "profile_image": "~/Pictures/profile.jpg",
  "city": "Vadodara"
}
```
- `display_name` — shown under your profile photo
- `subtitle` — a short tagline ("Frontend Dev", "Coffee Addict", whatever fits)
- `profile_image` — path to a square photo (`~` expands to your home directory). Use `null` to get the gradient fallback.
- `city` — used for the weather lookup (e.g. `"London"`, `"New York"`, `"Tokyo"`)

### 2. Your apps (app launcher)
```json
"apps": [
  {
    "name": "Chrome",
    "icon": "google-chrome",
    "icon_path": null,
    "cmd": "google-chrome",
    "color": [0.40, 0.85, 0.85, 1.0]
  }
]
```
- `name` — label shown in the widget
- `icon` — icon theme name (try the binary name first: `code`, `discord`, `firefox`)
- `icon_path` — **optional** absolute path to a PNG/SVG if the theme lookup fails. Set to `null` for auto-detect.
- `cmd` — the shell command to launch the app
- `color` — accent color as `[R, G, B, A]` with each value between `0.0` and `1.0`

**Add a new app:** copy-paste a block and change the four fields. Remove one: delete its block.

> **💡 Finding the right icon name:** run
> ```bash
> ls /usr/share/icons/hicolor/scalable/apps /usr/share/pixmaps 2>/dev/null | grep -i <appname>
> ```
> If nothing matches, set `icon_path` to an absolute path to any PNG/SVG.

### 3. System toggles (Wi-Fi / Bluetooth / Night / Mute)
```json
"system_toggles": [
  {
    "label": "Wi-Fi",
    "icon": "wifi",
    "cmd_on":  ["nmcli", "radio", "wifi", "on"],
    "cmd_off": ["nmcli", "radio", "wifi", "off"]
  }
]
```
Each toggle runs `cmd_on` or `cmd_off` depending on its current state.

Built-in icons: `wifi`, `bluetooth`, `moon`, `speaker`.

You can add your own — e.g. a "Do Not Disturb" toggle that calls `gsettings set org.gnome.desktop.notifications show-banners`.

### 4. System actions (Shutdown / Restart / Lock / Logout)
```json
"system_actions": [
  {
    "label": "Shutdown",
    "icon": "power",
    "cmd": ["systemctl", "poweroff"],
    "color": [0.85, 0.45, 0.45, 1.0],
    "confirm": true
  }
]
```
- `confirm: true` pops up a yes/no dialog before running
- Built-in icons: `power`, `restart`, `lock`, `logout`

### 5. Quick folders
```json
"files": [
  { "label": "Home",      "path": "~",             "icon": "home"      },
  { "label": "Downloads", "path": "~/Downloads",   "icon": "downloads" },
  { "label": "Projects",  "path": "~/Dev/Projects","icon": "folder"    }
]
```
Clicking opens the folder in your default file manager.

Built-in icons: `home`, `folder`, `downloads`.

### 6. Quotes (rotating)
```json
"quotes": [
  { "text": "Stay hungry, stay foolish.", "author": "Steve Jobs" },
  { "text": "Code is poetry.",            "author": "WordPress"  }
]
```
Add as many as you like — one shows at a time.

### 7. Theme colors
```json
"colors": {
  "bg":    [0.16, 0.17, 0.22, 0.96],
  "card":  [0.20, 0.21, 0.27, 1.00],
  "pink":  [0.42, 0.68, 0.88, 1.00],
  "cyan":  [0.38, 0.80, 0.80, 1.00]
}
```
All colors are `[R, G, B, A]` in the `0.0`–`1.0` range. Want a warm orange theme? Change `pink` and `cyan`, restart the widget, done.

---

## How to stop / restart / uninstall

### Stop it now
```bash
pkill -f "python3.*widget.py"
```

### Restart after editing config.json
```bash
pkill -f "python3.*widget.py"
python3 widget.py &
```

### Disable auto-start (keep the files)
```bash
rm ~/.config/autostart/glancebar.desktop
```
> **Note:** The widget keeps running until you kill it or reboot.

### Uninstall completely
```bash
pkill -f "python3.*widget.py"                           # stop it
rm ~/.config/autostart/glancebar.desktop                # remove autostart
cd .. && rm -rf glancebar                               # remove the folder
```
If you want to also uninstall the system packages `install.sh` added, run `sudo apt remove playerctl redshift` (or `sudo dnf remove playerctl redshift` on Fedora, or `sudo pacman -R playerctl redshift` on Arch) — though you might want to keep them, they're harmless.

---

## Architecture

```
widget.py              # entry point, window setup
config.json            # ALL user config (edit this!)
widgets/
  config.py            # config loader + theme constants
  helpers.py           # cairo drawing helpers (rounded rects, icons)
  icons.py             # cairo vector icon library
  left_panel.py        # profile, weather, toggles
  center_panel.py      # clock, calendar, music, search
  right_panel.py       # apps + system actions
  files_panel.py       # folder shortcuts
assets/icons/          # SVG assets for a few symbolic icons
```

Each panel is a `Gtk.DrawingArea` that paints itself with Cairo. No themes to fight, no CSS to debug — if you can read the drawing code, you can change anything.

---

## Troubleshooting

<details>
<summary><b>Widget shows a dark rectangle, no blur.</b></summary>
<br/>
You need a compositor with blur support. Install <code>picom</code> and enable <code>blur-background = true</code> — see the <a href="#frosted-glass-blur-optional">blur section</a>.
</details>

<details>
<summary><b>App icons missing / showing colored circles with initials.</b></summary>
<br/>
Either the <code>icon</code> name in <code>config.json</code> doesn't match a theme icon, or the app isn't installed. Set <code>icon_path</code> to the absolute path of any PNG/SVG as an override.
</details>

<details>
<summary><b>Weather says "Unavailable".</b></summary>
<br/>
Check that <code>python3-requests</code> is installed (<code>sudo apt install python3-requests</code>, <code>sudo dnf install python3-requests</code>, or <code>sudo pacman -S python-requests</code>) and that you have an internet connection. Also verify your <code>city</code> field is spelled correctly — try the English name.
</details>

<details>
<summary><b>Music shows "YouTube / Open in Browser" by default.</b></summary>
<br/>
That's the placeholder when no player is running. Start Spotify, VLC, or play something in a browser that supports MPRIS and it'll pick up the metadata.
</details>

<details>
<summary><b>Toggles don't do anything.</b></summary>
<br/>
Some commands need sudo-free access (e.g. <code>nmcli</code>). On Ubuntu this works out of the box, but if your distro requires elevated permissions, adjust the commands in <code>system_toggles</code> accordingly.
</details>

<details>
<summary><b>Widget didn't appear after reboot.</b></summary>
<br/>
Check the autostart file exists: <code>ls ~/.config/autostart/glancebar.desktop</code><br/>
Check the process is running: <code>pgrep -af "python3.*widget.py"</code><br/>
If the process is not running, try launching manually: <code>python3 ~/glancebar/widget.py</code> — any errors will be printed to the terminal.
</details>

<details>
<summary><b>It's on the wrong monitor / wrong position.</b></summary>
<br/>
Glancebar centers itself on the primary screen. If you have multiple monitors and want to move it, edit <code>widget.py</code> around line 56 (<code>self.move(...)</code>).
</details>

<details>
<summary><b>I changed <code>config.json</code> but nothing happened.</b></summary>
<br/>
You need to restart the widget to pick up config changes:<br/>
<code>pkill -f "python3.*widget.py" && python3 widget.py &</code>
</details>

---

## Dependencies (for reference)

**System packages** (installed by `install.sh`):
- **Debian/Ubuntu**: `python3-gi`, `python3-gi-cairo`, `gir1.2-gtk-3.0`, `gir1.2-gdk-3.0`, `fonts-jetbrains-mono`
- **Fedora**: `python3-gobject`, `python3-cairo`, `gtk3`, `jetbrains-mono-fonts`
- **Arch**: `python-gobject`, `python-cairo`, `gtk3`, `libpulse`, `ttf-jetbrains-mono`
- **Common**:
  - `playerctl` — music metadata
  - `redshift` — night mode toggle (X11 only — see [Arch Linux notes](#arch-linux-notes) for Wayland)
  - `network-manager` / `NetworkManager` / `networkmanager` — Wi-Fi toggle
  - `bluez` (+ `bluetooth` on Debian, `bluez-utils` on Arch) — Bluetooth toggle
  - `pactl` — audio mute (in `libpulse` on Arch; usually pre-installed elsewhere)
  - `xdg-utils` — opens folders and links via `xdg-open`
  - `python3-requests` / `python-requests` — live weather

**Optional:**
- `picom` — frosted-glass blur

---

## Contributing

Pull requests welcome — especially for:
- More weather icons (see `_draw_weather_icon` in `widgets/left_panel.py`)
- Additional system toggles
- Color palette presets
- Ports to other distros (openSUSE, Alpine, NixOS — Ubuntu, Fedora, and Arch are now supported!)

If you build something cool with this, tag me — I'd love to see it.

---

## License

MIT — do anything, just don't blame me if your desktop gets too pretty to work on.

---

<p align="center">
  <b>Made with too much coffee ☕ and a love for clean desktops.</b><br/>
  If you find this useful, a ⭐ on GitHub makes my day.
</p>
