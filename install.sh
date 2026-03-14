#!/bin/bash

# Installation Script für i3 Parrot Dotfiles
# Autor: [Dein Name]
# Getestet auf: Parrot OS Security Edition

set -e  # Exit bei Fehler

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔═══════════════════════════════════════╗"
echo "║   i3 Parrot Dotfiles Installation    ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Prüfe ob auf Debian/Parrot
if ! command -v apt &> /dev/null; then
    echo "❌ Fehler: Dieses Script ist für Debian/Ubuntu/Parrot"
    exit 1
fi

echo "📦 Phase 1: Dependencies installieren"
echo "────────────────────────────────────────"

# Lese Dependencies aus Datei
PACKAGES=$(cat "$DOTFILES_DIR/dependencies.txt" | grep -v "^#" | grep -v "^$" | tr '\n' ' ')

echo "Zu installierende Pakete:"
echo "$PACKAGES"
echo ""

read -p "Fortfahren? (j/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[JjYy]$ ]]; then
    echo "❌ Installation abgebrochen"
    exit 1
fi

sudo apt update
sudo apt install -y $PACKAGES

echo "✅ Dependencies installiert"
echo ""

echo "📁 Phase 2: Backup ersteller"
echo "────────────────────────────────────────"

BACKUP_DIR="$HOME/.config-backup/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup existierender Configs
for dir in i3 i3blocks i3-themes alacritty kitty rofi picom dunst; do
    if [ -d "$HOME/.config/$dir" ]; then
        echo "Backup: $dir"
        cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done

# Backup existierender Skripte
if [ -d "$HOME/.local/bin" ]; then
    mkdir -p "$BACKUP_DIR/.local"
    for script in i3-menu i3-theme-next i3blocks-updates update-checker; do
        if [ -f "$HOME/.local/bin/$script" ]; then
            echo "Backup: $script"
            cp "$HOME/.local/bin/$script" "$BACKUP_DIR/.local/"
        fi
    done
fi

echo "✅ Backup erstellt in: $BACKUP_DIR"
echo ""

echo "📋 Phase 3: Dotfiles kopieren"
echo "────────────────────────────────────────"

# Erstelle Zielverzeichnisse
mkdir -p ~/.config
mkdir -p ~/.local/bin

# Kopiere Configs
echo "Kopiere .config/*"
cp -rv "$DOTFILES_DIR/.config/"* ~/.config/

# Kopiere bin Skripte
echo "Kopiere .local/bin/*"
cp -rv "$DOTFILES_DIR/.local/bin/"* ~/.local/bin/

# Mache Skripte ausführbar
echo "Setze Berechtigungen"
chmod +x ~/.local/bin/i3-menu
chmod +x ~/.local/bin/i3-theme-next
chmod +x ~/.local/bin/i3blocks-updates
chmod +x ~/.local/bin/update-checker
find ~/.local/bin/i3-theme/ -type f -exec chmod +x {} \;

echo "✅ Dotfiles installiert"
echo ""

echo "🎨 Phase 4: Theme-System initialisieren"
echo "────────────────────────────────────────"

# Setze Standard-Theme falls noch nicht gesetzt
if [ ! -L "$HOME/.config/i3-themes/current/theme" ]; then
    echo "Setze Standard-Theme: tokyo-night"
    ln -sf "$HOME/.config/i3-themes/themes/tokyo-night" "$HOME/.config/i3-themes/current/theme"
fi

# Setze Standard-Wallpaper
if [ ! -L "$HOME/.config/i3-themes/current/background" ]; then
    FIRST_BG=$(find "$HOME/.config/i3-themes/current/theme/backgrounds/" -type f | head -1)
    if [ -n "$FIRST_BG" ]; then
        echo "Setze Standard-Wallpaper"
        ln -sf "$FIRST_BG" "$HOME/.config/i3-themes/current/background"
    fi
fi

echo "✅ Theme-System initialisiert"
echo ""

echo "🔤 Phase 5: Nerd Fonts (optional)"
echo "────────────────────────────────────────"

if fc-list | grep -qi "nerd"; then
    echo "✅ Nerd Font bereits installiert"
else
    echo "⚠️  Keine Nerd Font gefunden"
    echo "Für Icons in i3blocks und Terminal wird eine Nerd Font empfohlen."
    echo ""
    read -p "Nerd Font jetzt installieren? (j/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[JjYy]$ ]]; then
        mkdir -p ~/.local/share/fonts
        cd ~/.local/share/fonts
        echo "Downloading CascadiaCode Nerd Font..."
        wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/CascadiaCode.zip
        unzip -q CascadiaCode.zip
        rm CascadiaCode.zip
        fc-cache -fv
        echo "✅ Nerd Font installiert"
    else
        echo "⏭️  Übersprungen - kann später manuell installiert werden"
    fi
fi

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║         Installation abgeschlossen!   ║"
echo "╚═══════════════════════════════════════╝"
echo ""
echo "📝 Nächste Schritte:"
echo ""
echo "1. Log out und wieder ein (oder: i3-msg restart)"
echo "2. Teste Theme-Wechsel: Super+Shift+Y"
echo "3. Öffne Control Center: Super+M"
echo "4. Prüfe Keybindings: Super+M → Keybindings"
echo ""
echo "📚 Dokumentation: README.md"
echo "🐛 Probleme? Siehe: TROUBLESHOOTING.md"
echo ""
echo "Backup gespeichert in:"
echo "  $BACKUP_DIR"
echo ""
