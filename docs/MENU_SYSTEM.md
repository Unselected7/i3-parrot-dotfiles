# Menu System

## Overview

**i3-menu** is a Rofi-based control center for theme selection and system actions. Launched via `Win+M`, it provides a keyboard-driven interface to:

- Select and switch themes
- Open configuration editors
- Trigger system actions (reload i3, manage audio, etc.)
- Display keybindings reference

```
Win+M → i3-menu → Main Menu
                   ├─ Themes
                   ├─ Config
                   ├─ System
                   ├─ Keybindings
                   └─ i3 Actions
```

---

## How It Works

**Architecture:** Bash script using Rofi for menu rendering + system commands for actions.

**Core Pattern:**

```bash
# 1. Define a menu helper
menu() {
  echo -e "$options" | rofi -dmenu -i -p "$prompt"
}

# 2. Define menu functions
show_main_menu() {
  case $(menu "i3 Control Center" "🎨 Themes\n⚙️ Config\n...") in
    *Themes*) show_theme_menu ;;
    *Config*) show_config_menu ;;
    *) exit ;;
  esac
}

# 3. Each submenu calls an action or another menu
show_theme_menu() {
  case $(menu "Select Theme" "$(i3-theme-list)") in
    *) i3-theme-set "$selection" ;;
  esac
}
```

**Execution Flow:**

1. User presses `Win+M`
2. i3 calls `i3-menu` (from keybinding in `~/.config/i3/config`)
3. `show_main_menu()` displays top-level options via Rofi
4. User selects an option → corresponding function is called
5. Function either:
   - Displays a submenu (another Rofi dialog)
   - Executes an action (e.g., `i3-theme-set gruvbox`)
   - Opens an editor or external program
6. Control returns to main menu or exits

---

## Menu Structure

| Menu | Purpose | Entry Point | Actions |
|------|---------|-------------|---------|
| **Themes** | Select and activate themes | Main menu | Calls `i3-theme-set <theme>` |
| **Config** | Edit configuration files | Main menu | Opens editor (nvim in alacritty) |
| **System** | System controls (audio, backup, updates) | Main menu | Calls external scripts or system commands |
| **i3 Actions** | Reload, restart, or exit i3 | Main menu | Calls `i3-msg reload/restart/exit` |
| **Keybindings** | Reference (optional) | Main menu | Displays static help text or opens docs |

---

## How to Extend

### Add a New Submenu

**Example:** Add a "Games" menu to launch games.

1. Create the function in `~/.local/bin/i3-menu`:

```bash
show_games_menu() {
  case $(menu "Games" "🎮 Steam\n🎮 Lutris\n🎮 Minecraft") in
    *Steam*) steam & ;;
    *Lutris*) lutris & ;;
    *Minecraft*) ~/.local/bin/launch-minecraft & ;;
    *) show_main_menu ;;
  esac
}
```

2. Add entry to `show_main_menu()`:

```bash
show_main_menu() {
  case $(menu "i3 Control Center" "🎨 Themes\n⚙️ Config\n...\n🎮 Games") in
    # ... existing cases ...
    *Games*) show_games_menu ;;
  esac
}
```

3. Test: `i3-menu` → navigate to "Games"

### Integrate an External Script

**Example:** Add weather status to the System menu.

1. Create a simple script (not in repo, system-specific):

```bash
# ~/.local/bin/get-weather
#!/bin/bash
curl -s "https://wttr.in/Berlin?format=3" 2>/dev/null || echo "N/A"
```

2. Update the menu to call it:

```bash
show_system_menu() {
  local weather=$(timeout 2 ~/.local/bin/get-weather || echo "Offline")
  case $(menu "System" "🌤️ Weather: $weather\n🔊 Audio\n💾 Backup") in
    *Audio*) show_audio_menu ;;
    *Backup*) ~/.local/bin/backup-system & ;;
    *) show_main_menu ;;
  esac
}
```

### External vs. Built-in Scripts

**Built-in (in repo):**
- `i3-theme-set`, `i3-theme-list` – theme management
- Theme configuration files

**External (system-specific, not in repo):**
- `~/.local/bin/custom-backup` – personal backup script
- `~/.local/bin/get-weather` – weather API client
- System commands: `pactl` (audio), `systemctl` (power), `i3-msg` (i3 control)

**Why separate?** External scripts are personal automation and may depend on system-specific tools or configurations not universally applicable.

---

## Best Practices

1. **Always provide an exit option** in submenus to prevent getting trapped:
   ```bash
   *) show_parent_menu ;;  # Fallback case
   ```

2. **Use background execution** for long-running processes:
   ```bash
   steam &        # Background
   # NOT: steam   # Blocks menu
   ```

3. **Add error handling** for optional scripts:
   ```bash
   if command -v ~/.local/bin/script >/dev/null 2>&1; then
     ~/.local/bin/script
   else
     notify-send "Error" "Script not found"
   fi
   ```

4. **Keep menus short** – 10 items max. Use submenus for organization.

5. **Use visual indicators** (emojis) for quick scanning.

6. **Export PATH** so helper scripts are found:
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```


