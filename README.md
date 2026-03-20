# i3_parrot_design

i3 window manager theme management system with 14 pre-configured themes and integrated keybindings for Debian/Ubuntu/Parrot OS.

This project demonstrates:

- Architecture following XDG Base Directory Specification
- Automatic theme synchronization across multiple applications
- Efficient bash scripting for system automation
- Rofi-based control center for centralized system management

## Overview

i3_parrot_design provides a symlink-based theme management system
that applies a single theme definition across multiple applications
(i3, terminals, editors, system tools) in a consistent and atomic way.

## Features

| Feature | Description |
|---------|-------------|
| **14 Professional Themes** | Catppuccin, Gruvbox, Nord, Tokyo Night, Kanagawa, and more |
| **Automatic App Syncing** | Change theme once, applies to 6+ applications simultaneously |
| **Instant Theme Switching** | Win+Shift+Y to cycle through themes |
| **Wallpaper Management** | Per-theme background images included |
| **i3 Integration** | 50+ documented keybindings organized by function |
| **Control Center** | Win+M launches rofi-based system menu |
| **Installation Automation** | Single command install with dependency checking |
| **Modular Design** | XDG-compliant, easy to extend or customize |

## Keybindings

Core theme and system controls:

| Keybinding | Action |
|-----------|--------|
| Win+Shift+Y | Cycle to next theme |
| Win+Shift+W | Cycle to next wallpaper |
| Win+M | Open control center menu |
| Win+Enter | Launch terminal |
| Win+D | Launch app launcher (Rofi) |
| Win+Q | Close focused window |
| Win+F | Toggle fullscreen |

Full keybinding documentation available in KEYBINDINGS.md

## Quick Start

```bash
git clone https://github.com/Unslected7/i3_parrot_dotfiles.git
cd i3_parrot_dotfiles
./install.sh
```

Installation takes about 2-3 minutes and includes:

- Dependency installation (i3, rofi, alacritty, etc.)
- Configuration file deployment
- Theme library setup
- Symlink creation for instant theme switching

## Project Structure

```
i3_parrot_dotfiles/
├── .config/
│   ├── i3/                    # i3wm configuration
│   ├── i3blocks/              # Status bar config
│   ├── i3-themes/             # Theme metadata
│   ├── alacritty/             # Terminal defaults
│   ├── kitty/                 # Terminal defaults
│   └── rofi/                  # Application launcher
├── .local/
│   ├── bin/                   # Scripts (symlinks)
│   └── share/i3_parrot_design/
│       ├── bin/               # Actual scripts
│       └── themes/            # 14 theme directories

├── install.sh                 # Installation script
├── sync-simple.sh             # System sync utility
├── dependencies.txt           # APT packages required
└── README.md (this file)
```

## Design Decisions

- Symlink-based switching → ensures atomic updates without partial states
- XDG directory layout → clean separation of config and data
- Bash scripting → minimal dependencies, high portability

## How It Works

1. **Theme Selection**: Win+Shift+Y triggers theme cycle
2. **Script Execution**: i3-theme-next determines next theme
3. **Configuration Update**: i3-theme-set updates app configs
4. **Symlink Update**: ~/.config/i3-themes/current/theme → ~/.local/share/.../themes/<theme>
5. **App Reload**: Applications reload settings (or restart on next launch)

**See:** [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for technical deep-dive, [docs/THEME_SYSTEM.md](docs/THEME_SYSTEM.md) for theme details.

## Installation

### Prerequisites

- Linux (Debian, Ubuntu, Parrot OS)
- i3wm installed
- Git
- bash 4.0+

### Full Installation

```bash
git clone https://github.com/Unslected7/i3_parrot_dotfiles.git
cd i3_parrot_dotfiles
./install.sh
```

The installer will:

1. Check dependencies
2. Create backups of existing configs
3. Install theme library to ~/.local/share/
4. Create symlinks in ~/.local/bin/
5. Configure i3, rofi, terminals, editors
6. Initialize active theme

## Customization

The system is designed to be **extended without modifying core code**. Five ways to customize:

### Aditional Wallpapers

```bash
# Adding Wallpaper to current theme 
cp your-wallpaper.jpg ~/.config/i3-themes/current/theme/backgrounds/
```

### Additional Keybindings

Ad key to `~/.config/i3/config`:

```bash
bindsym $mod+x exec --no-startup-id your-command
```

## Optional Shell Configuration

Optional but recommended: add shell aliases, zoxide and fuzzy_find patterns for enhanced productivity.

You can use preconfigured shell configurations by souring `~/.local/share/i3_parrot_design/default/bash/rc` in your `~/.bashrc`:

```bash
# Sourcing i3_parrot_design bash configurations 
source ~/.local/share/i3_parrot_design/default/bash/rc
```

## License

MIT License - See LICENSE file

## Author

Developed by Unslected7 as part of his Linux-Learning-Journey.

## 🤝 Credits

- **Theme-System** - Adaptiert von [Omarchy](https://github.com/ohmarch/omarchy)
- **i3 Community** - Inspiration und Tutorials
- **Parrot OS** - Exzellente Debian-Distribution

## 📝 Lizenz

MIT License - Siehe [LICENSE](LICENSE)
