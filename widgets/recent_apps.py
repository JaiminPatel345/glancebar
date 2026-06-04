"""
recent_apps.py – Resolve the N most-used apps from GNOME Shell's
                 ~/.local/share/gnome-shell/application_state XML file.

The file contains entries like:
  <application id="code.desktop" score="1064.9375" last-seen="1780504799"/>

We sort by score (descending) and resolve each .desktop file to extract
Name, Exec, and Icon so we can build a glancebar-compatible app dict.
"""

import os
import re

# ── Desktop-file search paths (ordered by priority) ──────────────────────────
_DESKTOP_SEARCH = [
    os.path.expanduser("~/.local/share/applications"),
    "/usr/share/applications",
    "/usr/local/share/applications",
]

# Skip internal / system apps that the user didn't explicitly open
_SKIP_IDS = {
    "gcr-prompter.desktop",
    "xdg-desktop-portal-gnome.desktop",
    "xdg-desktop-portal.desktop",
    "gnome-session-properties.desktop",
    "org.gnome.Shell.Extensions.desktop",
}

# Default color palette (cycled if a color can't be guessed from the icon name)
_COLORS = [
    [0.40, 0.85, 0.85, 1.0],   # cyan
    [1.00, 0.65, 0.30, 1.0],   # orange
    [0.35, 0.40, 0.90, 1.0],   # indigo
    [0.14, 0.53, 0.90, 1.0],   # blue
    [0.92, 0.42, 0.62, 1.0],   # pink
    [0.52, 0.75, 0.44, 1.0],   # green
]


def _parse_state_file(path):
    """Return list of (desktop_id, score, last_seen) sorted by score desc."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            text = f.read()
    except OSError:
        return []

    entries = []
    for m in re.finditer(
        r'application id="([^"]+)"\s+score="([^"]+)"\s+last-seen="([^"]+)"',
        text,
    ):
        did, score_s, last_s = m.groups()
        try:
            score = float(score_s)
        except ValueError:
            score = 0.0
        try:
            last = int(last_s)
        except ValueError:
            last = 0
        entries.append((did, score, last))

    # Sort: primarily by score, secondarily by recency
    entries.sort(key=lambda e: (e[1], e[2]), reverse=True)
    return entries


def _find_desktop_file(desktop_id):
    """Locate the .desktop file for *desktop_id* in standard directories."""
    for base in _DESKTOP_SEARCH:
        p = os.path.join(base, desktop_id)
        if os.path.isfile(p):
            return p
    return None


def _parse_desktop_file(path):
    """Return a dict with Name, Exec, Icon from a .desktop file."""
    info = {}
    try:
        with open(path, "r", encoding="utf-8") as f:
            in_entry = False
            for line in f:
                line = line.strip()
                if line == "[Desktop Entry]":
                    in_entry = True
                    continue
                if line.startswith("[") and in_entry:
                    break   # next section
                if in_entry and "=" in line:
                    key, _, val = line.partition("=")
                    k = key.strip()
                    if k in ("Name", "Exec", "Icon"):
                        info[k] = val.strip()
    except OSError:
        pass
    return info


def _clean_exec(exec_str):
    """Strip field codes (%U, %f …) from Exec and return a plain command."""
    cleaned = re.sub(r"%[a-zA-Z]", "", exec_str).strip()
    # Remove --profile-directory=Default noise but keep the app-id flag
    return cleaned


def get_recent_apps(n=6):
    """
    Return a list of up to *n* app dicts (matching glancebar's config format)
    for the most-used apps according to GNOME Shell's application_state file.

    Each dict has: name, icon, icon_path (None), cmd, color.
    Falls back to an empty list if the state file can't be read.
    """
    state_path = os.path.expanduser(
        "~/.local/share/gnome-shell/application_state"
    )
    entries = _parse_state_file(state_path)

    apps = []
    color_idx = 0

    for desktop_id, score, last in entries:
        if desktop_id in _SKIP_IDS:
            continue

        dfile = _find_desktop_file(desktop_id)
        if not dfile:
            continue

        info = _parse_desktop_file(dfile)
        name = info.get("Name", "")
        icon = info.get("Icon", "")
        exec_raw = info.get("Exec", "")

        if not name or not exec_raw:
            continue

        cmd = _clean_exec(exec_raw)
        color = _COLORS[color_idx % len(_COLORS)]
        color_idx += 1

        apps.append({
            "name": name,
            "icon": icon,
            "icon_path": None,
            "cmd": cmd,
            "color": color,
        })

        if len(apps) >= n:
            break

    return apps
