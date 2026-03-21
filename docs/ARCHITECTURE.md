# Architecture

## Overview

**i3_parrot_design** is a theme management system for i3wm that synchronizes a single theme definition across multiple applications (terminals, editors, system tools) through a central symlink-based control point.

### Core Design Principle: Symlink-Based Theme Switching

Instead of duplicating theme configurations across applications, a single active theme symlink serves as the source of truth:

```
~/.config/i3-themes/current/theme → ~/.local/share/i3_parrot_design/themes/[ACTIVE_THEME]
```

All applications read their theme configuration from this central location, ensuring **atomic, consistent theme updates** without partial states.

## System Architecture

### Three Core Components

#### 1. Theme Management System

**Responsibility:** Central theme storage, selection, and application synchronization.

**Key Scripts:**
- `i3-theme-set <THEME>` – Activate a theme
- `i3-theme-next` – Cycle to next theme
- `i3-theme-current` – Query active theme
- `i3-theme-list` – Enumerate available themes
- `i3-theme-bg-next` – Cycle wallpaper within current theme

**Supported Applications:**
- Terminals: Alacritty, Kitty
- Editors: Neovim, VSCode
- Utilities: btop (monitor), eza (file lister)

#### 2. Rofi-Based Control Center

**Responsibility:** User-friendly menu interface for theme selection and system actions.

**Entry Point:** `Win+M` keybinding

**Capabilities:**
- Navigate and select from all 14 themes
- Access configuration editors
- Trigger system actions (backup, volume, etc.)
- Display keybindings reference

#### 3. i3 Window Manager Configuration

**Responsibility:** Keybindings, application launchers, system integration.

**Coverage:**
- Window navigation and layout management
- Application launchers (browser, terminal, editor, file manager)
- Hardware controls (volume, brightness, display)
- System actions (lock, sleep, reload i3)
- Theme-specific keybindings (Win+Shift+Y for theme cycle)

---

## Data Flow

```
User Input
    │
    ├─ Win+Shift+Y → i3-theme-next → i3-theme-set
    ├─ Win+M → Rofi menu → (Theme selection) → i3-theme-set
    └─ Win+Shift+W → i3-theme-bg-next

i3-theme-set execution:
    ├─ Update symlink: ~/.config/i3-themes/current/theme
    ├─ Set wallpaper (or trigger i3-theme-bg-next)
    ├─ Notify applications of theme change
    └─ Return status to user

Application detection:
    └─ All apps read from ~/.config/i3-themes/current/theme/
       (Alacritty, Kitty, Neovim, VSCode, btop, eza)
    └─ Apps either reload configs or apply changes on next launch
```



---

## Directory Structure

### Installation Layout

```
~/.config/
├── i3-themes/
│   └── current/theme → ~/.local/share/i3_parrot_design/themes/[ACTIVE]
├── i3/
├── i3blocks/
├── rofi/
├── alacritty/
├── kitty/
└── nvim/

~/.local/bin/
├── i3-theme-set → ~/.local/share/i3_parrot_design/bin/i3-theme-set
├── i3-theme-next → ~/.local/share/i3_parrot_design/bin/i3-theme-next
├── i3-theme-list → ~/.local/share/i3_parrot_design/bin/i3-theme-list
├── i3-theme-bg-next → ~/.local/share/i3_parrot_design/bin/i3-theme-bg-next
├── i3-theme-current → ~/.local/share/i3_parrot_design/bin/i3-theme-current
└── i3-menu

~/.local/share/i3_parrot_design/
├── bin/ (core scripts)
├── themes/ (14 theme directories)
│   ├── catppuccin/
│   ├── gruvbox/
│   └── ...
└── default/ (shell and app config templates)
```

---

## Integration Points

| Component | Integration Method | Notes |
|-----------|-------------------|-------|
| **Alacritty** | `import` directive | References `~/.config/i3-themes/current/theme/alacritty.toml` |
| **Kitty** | `include` directive | References `~/.config/i3-themes/current/theme/kitty.conf` |
| **Neovim** | Lua configuration | Loads colorscheme from theme directory |
| **VSCode** | JSON settings | References external color preferences |
| **btop** | Theme file path | Points to active theme's btop configuration |
| **eza** | YAML color mapping | Uses active theme's color definitions |

---

## Extension Points

### Adding a New Theme

1. Create a new directory in `~/.local/share/i3_parrot_design/themes/[THEME_NAME]/`
2. Populate with application config files (alacritty.toml, kitty.conf, etc.)
3. Add backgrounds/ subdirectory with wallpaper images
4. Regenerate theme enumeration (i3-theme-list detects automatically)

### Adding a New Application

1. Create config file in each theme directory
2. Update i3-theme-set to handle the new application's config reload mechanism

### Custom Keybindings

Modify `~/.config/i3/config` directly; keybindings are independent of the theme system.

---

## Technology Stack

- **Shell:** Bash 4.0+ for portability and minimal dependencies
- **File System:** XDG Base Directory Specification for standard layout
- **Menu:** Rofi for desktop-integrated, keyboard-driven application selection
- **Window Manager:** i3 (stable branch)
- **Theme Format:** Application-native config formats (TOML, YAML, JSON, Lua)

---

## See Also

- [MENU_SYSTEM.md](MENU_SYSTEM.md) – Rofi control center design
- [I3_CONFIG.md](I3_CONFIG.md) – Keybindings reference
- [README.md](../README.md) – Quick start and feature overview
