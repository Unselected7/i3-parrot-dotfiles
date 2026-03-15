# i3 Parrot Design System - Systemübersicht

## Inhaltsverzeichnis
1. [Grundkonzept](#grundkonzept)
2. [Architektur](#architektur)
3. [Verzeichnisstruktur](#verzeichnisstruktur)
4. [Komponenten im Detail](#komponenten-im-detail)
5. [Ablauf: Theme-Wechsel](#ablauf-theme-wechsel)
6. [Integration von Applikationen](#integration-von-applikationen)
7. [Shell-Konfiguration](#shell-konfiguration)
8. [Keybindings](#keybindings)
9. [Entwicklungsphilosophie](#entwicklungsphilosophie)

---

## Grundkonzept

**i3_parrot_design** ist ein **XDG-konformes Theme-Management-System** für i3wm, das:
- Themes zentral verwaltet
- Applikationen automatisch themet
- Shell-Konfigurationen bereitstellt  
- Über Keybindings und ein Rofi-Menu gesteuert wird

### Design-Philosophie

Das System folgt der **XDG Base Directory Specification**:

```
~/.config/          → User-Konfiguration (was der User wählt)
~/.local/share/     → Application Data (wiederverwendbare Daten)
~/.local/bin/       → User Executables
```

**Warum Themes in .local/share?**
- Themes sind "Application Data" (wie Icon-Packs)
- Sie sind wiederverwendbare Templates, keine User-Konfiguration
- Die User-Konfiguration ist nur die *Wahl* des aktuellen Themes

---

## Architektur

```
┌─────────────────────────────────────────────────────────────┐
│                    USER INTERFACE                            │
│  • Keybindings (Win+Shift+Y, Win+Shift+W)                   │
│  • i3-menu (Super+M)                                         │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                 SCRIPTS (.local/bin)                         │
│  • i3-theme-set      (Hauptlogik)                           │
│  • i3-theme-next     (Theme cyclen)                         │
│  • i3-theme-list     (Themes auflisten)                     │
│  • i3-theme-bg-next  (Wallpaper cyclen)                     │
│  • i3-menu           (Rofi Control Center)                  │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│            THEME DATA (.local/share/i3_parrot_design)       │
│  themes/                                                     │
│  ├── catppuccin/                                            │
│  │   ├── alacritty.toml                                     │
│  │   ├── kitty.conf                                         │
│  │   ├── neovim.lua                                         │
│  │   ├── vscode.json                                        │
│  │   ├── btop.theme                                         │
│  │   ├── eza.yml                                            │
│  │   └── backgrounds/                                       │
│  ├── gruvbox/                                               │
│  └── ... (14 themes)                                        │
│                                                              │
│  default/                                                    │
│  ├── bash/ (Shell-Konfigurationen)                         │
│  │   ├── rc          (Master-Loader)                       │
│  │   ├── aliases     (lsa, ll, etc.)                       │
│  │   ├── functions   (Bash-Funktionen)                     │
│  │   ├── shell       (Prompt, History)                     │
│  │   └── init        (zoxide, fzf, etc.)                   │
│  ├── alacritty/ (App-Templates)                            │
│  └── kitty/                                                 │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│         USER CONFIG SYMLINKS (.config)                       │
│  i3-themes/current/theme → ../../.local/share/.../themes/X  │
│  eza/theme.yml → i3-themes/current/theme/eza.yml            │
└─────────────────────────────────────────────────────────────┘
```

---

## Verzeichnisstruktur

### Installierte Struktur

```
$HOME/
├── .config/
│   ├── i3/
│   │   └── config                    # Keybindings mit vollen Pfaden
│   ├── i3-themes/
│   │   └── current/
│   │       ├── theme → ../../.local/share/i3_parrot_design/themes/flexoki-light
│   │       └── background → theme/backgrounds/1.png
│   ├── eza/
│   │   └── theme.yml → ../i3-themes/current/theme/eza.yml
│   ├── alacritty.toml                # Import: current/theme/alacritty.toml
│   ├── kitty/kitty.conf              # Include: current/theme/kitty.conf
│   └── nvim/lua/user/i3_theme.lua    # Kopiert von theme/neovim.lua
│
├── .local/
│   ├── bin/
│   │   ├── i3-theme-set → ../share/i3_parrot_design/bin/i3-theme-set
│   │   ├── i3-theme-next → ../share/i3_parrot_design/bin/i3-theme-next
│   │   ├── i3-theme-list → ../share/i3_parrot_design/bin/i3-theme-list
│   │   ├── i3-theme-bg-next → ../share/i3_parrot_design/bin/i3-theme-bg-next
│   │   ├── i3-theme-current → ../share/i3_parrot_design/bin/i3-theme-current
│   │   └── i3-menu                    # Executable (kein Symlink)
│   │
│   └── share/
│       └── i3_parrot_design/
│           ├── bin/                   # Scripts (9 Dateien)
│           ├── themes/                # 14 Themes (83MB)
│           └── default/               # Shell & App Templates
│               ├── bash/
│               ├── alacritty/
│               └── kitty/
│
├── .bashrc                            # Source: i3_parrot_design/default/bash/rc
└── .XCompose                          # Tastatur-Compose-Sequences
```

---

## Komponenten im Detail

### 1. Scripts (.local/share/i3_parrot_design/bin)

#### **i3-theme-set** (Hauptscript)
```bash
THEMES_DIR="$HOME/.local/share/i3_parrot_design/themes"

# Funktion: Theme setzen
# 1. Symlink aktualisieren (.config/i3-themes/current/theme)
# 2. Apps theming:
#    - update_alacritty_theme()
#    - update_kitty_theme()
#    - update_neovim_theme()
#    - update_vscode_theme()
#    - update_btop_theme()
#    - update_eza_theme()
# 3. Wallpaper setzen (feh)
# 4. i3 reload
```

**WICHTIG:** Alle internen Aufrufe verwenden **volle Pfade**:
```bash
"$HOME/.local/bin/i3-theme-set" "$theme"
```

Grund: i3's `exec` Umgebung hat **kein ~/.local/bin im PATH**!

#### **i3-theme-next**
- Cyclet durch alle Themes (alphabetisch)
- Ruft `i3-theme-set` mit dem nächsten Theme auf
- Verwendet in Zeile 37: `"$HOME/.local/bin/i3-theme-set"`

#### **i3-theme-list**
- Listet alle Themes in `THEMES_DIR`
- Formatiert Namen (Groß-/Kleinschreibung, Leerzeichen)
- Wird von `i3-menu` verwendet

#### **i3-theme-bg-next**
- Cyclet durch Wallpaper im aktuellen Theme
- Verwendet `feh --bg-fill` (i3-spezifisch, nicht swaybg)

#### **i3-menu**
- Rofi-basiertes Control Center
- **Exportiert PATH:** `export PATH="$HOME/.local/bin:$PATH"`
  - Ohne das würde `i3-theme-list` nicht gefunden!
- Menüpunkte:
  - Themes → Theme-Auswahl
  - Config → i3/i3blocks/picom Config bearbeiten
  - System → Backup, Audio, Netzwerk, Updates
  - Keybindings → Übersicht aller Shortcuts

---

### 2. Themes (.local/share/i3_parrot_design/themes)

Jedes Theme ist ein Ordner mit:

```
gruvbox/
├── alacritty.toml        # Alacritty-Theme (import-basiert)
├── kitty.conf            # Kitty-Theme (include-basiert)
├── neovim.lua            # Neovim colorscheme (copy-basiert)
├── vscode.json           # VSCode Theme-Info (JSON-update)
├── btop.theme            # btop colors (copy-basiert)
├── eza.yml               # eza file colors (symlink-basiert)
├── chromium.theme        # Browser-Theme (optional)
├── icons.theme           # Icon-Theme Name (optional)
├── preview.png           # Theme-Vorschau
├── light.mode            # Flag-Datei für helle Themes (optional)
└── backgrounds/          # Wallpaper
    ├── 1-gruvbox.jpg
    └── 2-gruvbox-alt.jpg
```

#### **App-Theming Mechanismen:**

1. **Alacritty** (Import)
   ```toml
   # In ~/.config/alacritty.toml
   import = [
     "~/.config/i3-themes/current/theme/alacritty.toml"
   ]
   ```
   → Automatisch aktiv bei neuem Fenster

2. **Kitty** (Include + Reload)
   ```conf
   # In ~/.config/kitty/kitty.conf
   include ~/.config/i3-themes/current/theme/kitty.conf
   ```
   → Script sendet SIGUSR1 für Reload

3. **Neovim** (Copy)
   ```bash
   cp theme/neovim.lua ~/.config/nvim/lua/user/i3_theme.lua
   ```
   → Aktiv beim nächsten Start

4. **VSCode** (JSON Update)
   ```bash
   # Parse theme/vscode.json
   # Update ~/.config/Code/User/settings.json
   ```

5. **btop** (Copy)
   ```bash
   cp theme/btop.theme ~/.config/btop/themes/i3_current.theme
   # Update ~/.config/btop/btop.conf
   ```

6. **eza** (Symlink) **NEU!**
   ```bash
   ln -s ~/.config/i3-themes/current/theme/eza.yml \
         ~/.config/eza/theme.yml
   ```

---

### 3. Shell-Konfiguration (.local/share/i3_parrot_design/default/bash)

#### **Struktur:**
```
bash/
├── rc          # Master-Loader (wird von .bashrc gesourced)
├── aliases     # Command-Aliase (ll, la, lsa, etc.)
├── envs        # Environment Variables (EDITOR, etc.)
├── functions   # Bash-Funktionen
├── init        # Tool-Initialisierungen (zoxide, fzf)
├── inputrc     # Readline-Konfiguration
└── shell       # Prompt, History, Keybindings
```

#### **rc (Master-Loader):**
```bash
# Source alle Komponenten
source "$SCRIPT_DIR/shell"
source "$SCRIPT_DIR/aliases"
source "$SCRIPT_DIR/functions"
source "$SCRIPT_DIR/init"
source "$SCRIPT_DIR/envs"

# Bind inputrc
bind -f "$SCRIPT_DIR/inputrc"
```

#### **.bashrc Integration:**
```bash
# In ~/.bashrc
source $HOME/.local/share/i3_parrot_design/default/bash/rc
```

**Design-Prinzip:**
- `.bashrc` ist CONFIG (User-Entscheidung, in .config zu sourcen)
- `bash/` ist DATA (wiederverwendbare Templates, in .local/share)

#### **Wichtige Aliase:**
```bash
# eza-basiert (moderne ls-Alternative)
alias ls='eza --group-directories-first --icons'
alias ll='eza -l --group-directories-first --icons'
alias la='eza -la --group-directories-first --icons'
alias lsa='eza -la --group-directories-first --icons --tree --level=2'

# zoxide (smarter cd)
alias cd='z'
```

---

## Ablauf: Theme-Wechsel

### Szenario: User drückt **Win+Shift+Y**

```
1. i3 empfängt Keybinding
   └─ bindsym $mod+Shift+y exec /home/user2/.local/bin/i3-theme-next

2. i3-theme-next wird ausgeführt
   ├─ Liest aktuelles Theme: ~/.config/i3-themes/current/theme
   ├─ Findet nächstes Theme in THEMES_DIR
   └─ Ruft auf: "$HOME/.local/bin/i3-theme-set" "gruvbox"

3. i3-theme-set "gruvbox" wird ausgeführt
   ├─ Symlink Update:
   │  └─ ln -nsf ~/.local/share/i3_parrot_design/themes/gruvbox \
   │            ~/.config/i3-themes/current/theme
   │
   ├─ update_alacritty_theme()
   │  └─ Symlink zeigt jetzt auf gruvbox/alacritty.toml
   │     → Neue Alacritty-Fenster = gruvbox
   │
   ├─ update_kitty_theme()
   │  ├─ Symlink zeigt auf gruvbox/kitty.conf
   │  └─ Sendet SIGUSR1 an alle kitty-Prozesse
   │     → Sofortiger Reload in laufenden Fenstern
   │
   ├─ update_neovim_theme()
   │  └─ cp gruvbox/neovim.lua ~/.config/nvim/lua/user/i3_theme.lua
   │     → Nächster nvim-Start = gruvbox
   │
   ├─ update_vscode_theme()
   │  ├─ Parse gruvbox/vscode.json
   │  └─ Update ~/.config/Code/User/settings.json
   │     → VSCode Restart nötig
   │
   ├─ update_btop_theme()
   │  ├─ cp gruvbox/btop.theme ~/.config/btop/themes/i3_current.theme
   │  └─ Update ~/.config/btop/btop.conf
   │
   ├─ update_eza_theme()
   │  └─ Symlink ~/.config/eza/theme.yml zeigt auf gruvbox/eza.yml
   │     → Neue Shell-Fenster = gruvbox colors
   │
   ├─ Wallpaper setzen:
   │  ├─ ln -sf gruvbox/backgrounds/1-gruvbox.jpg current/background
   │  └─ feh --bg-fill current/background
   │
   └─ i3-msg reload
      └─ i3 lädt neue Farben (falls in theme/ definiert)

4. User sieht:
   ✓ Neues Wallpaper (sofort)
   ✓ Neue Alacritty-Fenster in gruvbox
   ✓ Kitty-Fenster reloaded (sofort)
   ✓ Neues eza-Colorscheme (neue Shells)
   ⚠ Neovim: Neustart nötig
   ⚠ VSCode: Neustart nötig
```

---

## Keybindings

### i3 Config Keybindings

**KRITISCH:** i3's `exec` Umgebung hat **NICHT** `~/.local/bin` im PATH!

**Deshalb: Volle Pfade verwenden!**

```bash
# ~/.config/i3/config

# Theme wechseln
bindsym $mod+Shift+y exec --no-startup-id /home/user2/.local/bin/i3-theme-next

# Wallpaper wechseln
bindsym $mod+Shift+w exec --no-startup-id /home/user2/.local/bin/i3-theme-bg-next

# i3 Control Center (Menu)
bindsym $mod+m exec --no-startup-id /home/user2/.local/bin/i3-menu
```

**FALSCH wäre:**
```bash
bindsym $mod+Shift+y exec --no-startup-id i3-theme-next  # ✗ Nicht gefunden!
```

### Script-interne Aufrufe

**Auch in Scripts: Volle Pfade!**

```bash
# i3-theme-next, Zeile 37:
"$HOME/.local/bin/i3-theme-set" "$NEXT_THEME_NAME"  # ✓

# i3-menu, show_theme_menu():
"$HOME/.local/bin/i3-theme-set" "$theme"  # ✓
```

**Aber: i3-menu exportiert PATH:**
```bash
# i3-menu, Zeile 5:
export PATH="$HOME/.local/bin:$PATH"
```
Grund: Damit `i3-theme-list` gefunden wird (wird nicht mit vollem Pfad aufgerufen).

---

## Integration von Applikationen

### Wie füge ich eine neue App hinzu?

**Beispiel: Füge tmux-Theming hinzu**

1. **Theme-Datei erstellen** (für jedes Theme):
   ```bash
   # In jedem Theme-Ordner:
   themes/gruvbox/tmux.conf
   themes/catppuccin/tmux.conf
   # etc.
   ```

2. **Update-Funktion in i3-theme-set** (nach Zeile 230):
   ```bash
   update_tmux_theme() {
     local theme_dir="$1"
     local tmux_theme="$theme_dir/tmux.conf"
     
     if [[ -f "$tmux_theme" ]]; then
       cp "$tmux_theme" "$HOME/.config/tmux/theme.conf"
       
       # Reload laufender tmux-Sessions
       if command -v tmux >/dev/null && tmux list-sessions >/dev/null 2>&1; then
         tmux source-file ~/.config/tmux/tmux.conf
       fi
       
       echo "  ✓ tmux: Theme aktiv"
     fi
   }
   ```

3. **Funktion aufrufen** (in i3-theme-set, nach Zeile 270):
   ```bash
   update_tmux_theme "$THEME_DIR"
   ```

4. **tmux.conf anpassen**:
   ```bash
   # ~/.config/tmux/tmux.conf
   source-file ~/.config/tmux/theme.conf
   ```

---

## Entwicklungsphilosophie

### XDG-Konformität

**Problem bei omarchy:**
- Alles in `~/.local/share/omarchy/` gemischt
- User-Config, Themes, Scripts → nicht klar getrennt

**Lösung i3_parrot_design:**
```
DATEN (wiederverwendbar)    → .local/share/i3_parrot_design/
CONFIG (User-Entscheidung)  → .config/
EXECUTABLES                 → .local/bin/
```

### Symlink-Philosophie

**Warum current/theme ein Symlink ist:**
- User's "aktuelle Wahl" = Config
- Theme-Daten selbst = Application Data
- Symlink verbindet beides

**Vorteil:**
- Atomic Updates (ln -nsf ist atomar)
- Keine Duplikate
- Apps können direkt auf theme/ verweisen

### PATH-Problem

**Warum Scripts volle Pfade brauchen:**

i3's `exec` Umgebung:
```bash
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
```

User's Shell:
```bash
PATH=/home/user2/.local/bin:...:/usr/bin:...
```

**Deshalb:**
- Keybindings: Volle Pfade
- Script-zu-Script-Aufrufe: Volle Pfade
- i3-menu: Exportiert PATH (damit i3-theme-list gefunden wird)

---

## Troubleshooting

### Keybindings funktionieren nicht

**Debug:**
```bash
# 1. Test Script direkt:
/home/user2/.local/bin/i3-theme-next
# → Funktioniert? Dann ist Script OK

# 2. Test via i3-msg:
i3-msg exec /home/user2/.local/bin/i3-theme-next
# → Funktioniert? Dann ist Keybinding das Problem

# 3. Prüfe i3 config:
i3-msg -t get_config | grep "Shift+y"
# → Sehe volle Pfade?

# 4. Prüfe i3 log:
tail -30 ~/.local/share/i3/log/current-i3.log
```

**Häufige Fehler:**
```bash
# ✗ FALSCH:
bindsym $mod+Shift+y exec i3-theme-next

# ✗ FALSCH (doppelter Pfad):
bindsym $mod+Shift+y exec $HOME/.local/bin/$HOME/.local/bin/i3-theme-next

# ✓ RICHTIG:
bindsym $mod+Shift+y exec --no-startup-id /home/user2/.local/bin/i3-theme-next
```

### Theme-Liste im Menu ist leer

**Ursache:** i3-menu findet `i3-theme-list` nicht.

**Fix:** i3-menu muss PATH exportieren (Zeile 5):
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### eza-Colors funktionieren nicht

**Check:**
```bash
# 1. Symlink vorhanden?
ls -la ~/.config/eza/theme.yml

# 2. Zeigt auf aktuelles Theme?
readlink ~/.config/eza/theme.yml
# → Sollte: ~/.config/i3-themes/current/theme/eza.yml

# 3. eza.yml existiert im Theme?
ls -la ~/.config/i3-themes/current/theme/eza.yml
```

---

## Installation auf neuem System

Siehe: `INSTALLATION_GUIDE.md`

**Kurzfassung:**
1. Repository klonen
2. `./install.sh` ausführen
3. `.bashrc` Source-Zeile hinzufügen
4. i3 restart
5. Theme wählen: `i3-theme-set gruvbox`

---

## Datei-Übersicht

### Kritische Dateien (ohne diese läuft nichts):
- `.local/share/i3_parrot_design/bin/i3-theme-set` (Kern-Logik)
- `.local/bin/i3-menu` (Control Center)
- `.config/i3/config` (Keybindings mit vollen Pfaden)
- `.bashrc` (Source-Zeile)

### Optionale Dateien:
- `.XCompose` (Keyboard Compose Sequences)
- `.local/share/i3_parrot_design/default/bash/*` (Shell Aliase)

---

**Erstellt:** 2026-03-14  
**Version:** 1.0  
**Autor:** i3_parrot_design Migration Project  
**Lizenz:** Siehe LICENSE
