#!/bin/bash

# Installation Script für i3_parrot_design
# Installiert i3wm Theme Manager mit vordefinierten Themes und Keybindings
# Getestet auf: Debian, Ubuntu, Parrot OS

# Fehlerbehandlung: Nur kritische Fehler brechen ab
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fehlerzähler für nicht-kritische Fehler
WARNINGS=0
FAILED_PACKAGES=()

echo "╔═══════════════════════════════════════════════╗"
echo "║      i3_parrot_design Installation          ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# Prüfe ob auf Debian/Parrot
if ! command -v apt &>/dev/null; then
  echo "❌ Fehler: Dieses Script ist für Debian/Ubuntu/Parrot"
  exit 1
fi

echo "📦 Phase 1: Dependencies installieren"
echo "─────────────────────────────────────────"

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

# apt update mit Fehlertoleranz (Repository-Fehler sind nicht kritisch)
echo "  Aktualisiere Paketlisten..."
if ! sudo apt update 2>&1 | tee /tmp/apt-update.log; then
  echo "⚠️  Warnung: apt update hatte Probleme (oft Repository-Signaturen)"
  echo "  Fahre trotzdem fort..."
  ((WARNINGS++))
fi

echo ""
echo "  Installiere Pakete..."

# Installiere Pakete einzeln mit Fehlertoleranz
INSTALLED=()
for pkg in $PACKAGES; do
  echo -n "  - $pkg ... "
  if sudo apt install -y "$pkg" >/dev/null 2>&1; then
    echo "✅"
    INSTALLED+=("$pkg")
  else
    echo "❌ (nicht verfügbar)"
    FAILED_PACKAGES+=("$pkg")
    ((WARNINGS++))
  fi
done

echo ""
if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
  echo "⚠️  Folgende Pakete konnten nicht installiert werden:"
  for pkg in "${FAILED_PACKAGES[@]}"; do
    echo "     - $pkg"
  done
  echo ""
  echo "  Installierte Pakete: ${#INSTALLED[@]}/${#PACKAGES[@]}"
  echo ""
  read -p "Trotzdem fortfahren? (j/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[JjYy]$ ]]; then
    echo "❌ Installation abgebrochen"
    exit 1
  fi
else
  echo "✅ Alle Dependencies installiert"
fi
echo ""

echo "📁 Phase 2: Backup existierender Configs"
echo "─────────────────────────────────────────"

BACKUP_DIR="$HOME/.config-backup/i3_parrot-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup existierender Configs
for dir in i3 i3blocks i3-themes alacritty kitty rofi picom dunst; do
  if [ -d "$HOME/.config/$dir" ]; then
    echo "  Backup: $dir"
    cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
  fi
done

# Backup existierender Scripts
if [ -d "$HOME/.local/bin" ]; then
  mkdir -p "$BACKUP_DIR/.local/bin"
  for script in i3-menu i3-theme-* i3blocks-updates update-checker; do
    if [ -f "$HOME/.local/bin/$script" ] 2>/dev/null; then
      echo "  Backup: $script"
      cp "$HOME/.local/bin/$script" "$BACKUP_DIR/.local/bin/" 2>/dev/null || true
    fi
  done
fi

echo "✅ Backup erstellt: $BACKUP_DIR"
echo ""

echo "🔗 Phase 3: Theme Library installieren (.local/share/)"
echo "─────────────────────────────────────────────────────"

mkdir -p ~/.local/share
cp -rv "$DOTFILES_DIR/.local/share/i3_parrot_design" ~/.local/share/

echo "✅ Theme Library installiert"
echo ""

echo "📋 Phase 4: Symlinks und Scripts (.local/bin/)"
echo "──────────────────────────────────────────────"

mkdir -p ~/.local/bin

# Kopiere Symlinks aus Repo (mit -P um Symlinks zu bewahren)
cp -Pv "$DOTFILES_DIR/.local/bin/i3-"* ~/.local/bin/ 2>/dev/null || true

# Falls normale Dateien statt Symlinks: erstelle Symlinks neu
for script in i3-menu i3-theme-set i3-theme-next i3-theme-list i3-theme-bg-next i3-theme-current; do
  if [ -f "$HOME/.local/bin/$script" ] && [ ! -L "$HOME/.local/bin/$script" ]; then
    echo "  Converting $script to symlink..."
    rm "$HOME/.local/bin/$script"
    ln -s "$HOME/.local/share/i3_parrot_design/bin/$script" "$HOME/.local/bin/$script"
  elif [ ! -e "$HOME/.local/bin/$script" ]; then
    ln -s "$HOME/.local/share/i3_parrot_design/bin/$script" "$HOME/.local/bin/$script"
  fi
done

# Mache aktuelle Scripts ausführbar (falls sie normale Dateien sind)
chmod +x ~/.local/share/i3_parrot_design/bin/i3-* 2>/dev/null || true

echo "✅ Scripts und Symlinks installiert"
echo ""

echo "🎨 Phase 5: i3 und Anwendungs-Konfigurationen"
echo "────────────────────────────────────────────"

# Kopiere Config-Dateien
mkdir -p ~/.config/i3
mkdir -p ~/.config/i3blocks
mkdir -p ~/.config/i3-themes/current

echo "  Kopiere i3 config..."
cp -v "$DOTFILES_DIR/.config/i3/config" ~/.config/i3/

echo "  Kopiere i3blocks config..."
cp -v "$DOTFILES_DIR/.config/i3blocks/config" ~/.config/i3blocks/

echo "  Kopiere App-Defaults (alacritty, kitty, rofi)..."
cp -rv "$DOTFILES_DIR/.config/alacritty" ~/.config/ 2>/dev/null || true
cp -rv "$DOTFILES_DIR/.config/kitty" ~/.config/ 2>/dev/null || true
cp -rv "$DOTFILES_DIR/.config/rofi" ~/.config/ 2>/dev/null || true

echo "✅ Konfigurationen installiert"
echo ""

echo "⚙️  Phase 6: Theme-System initialisieren"
echo "──────────────────────────────────────"

# Setze Standard-Theme falls noch nicht gesetzt
if [ ! -L "$HOME/.config/i3-themes/current/theme" ]; then
  # Wähle erstes verfügbares Theme
  FIRST_THEME=$(ls -d "$HOME/.local/share/i3_parrot_design/themes/"* 2>/dev/null | head -1 | xargs basename)
  if [ -n "$FIRST_THEME" ]; then
    echo "  Setze Standard-Theme: $FIRST_THEME"
    ln -sf "$HOME/.local/share/i3_parrot_design/themes/$FIRST_THEME" \
      "$HOME/.config/i3-themes/current/theme"
  fi
fi

# Setze Standard-Wallpaper
if [ ! -L "$HOME/.config/i3-themes/current/background" ]; then
  THEME_PATH="$HOME/.config/i3-themes/current/theme"
  if [ -L "$THEME_PATH" ]; then
    THEME_REAL="$(readlink -f "$THEME_PATH")"
    FIRST_BG=$(find "$THEME_REAL/backgrounds/" -type f 2>/dev/null | head -1)
    if [ -n "$FIRST_BG" ]; then
      echo "  Setze Standard-Wallpaper"
      ln -sf "$FIRST_BG" "$HOME/.config/i3-themes/current/background"
    fi
  fi
fi

echo "✅ Theme-System initialisiert"
echo ""

echo "🔤 Phase 7: Nerd Fonts (optional)"
echo "────────────────────────────────"

if fc-list | grep -qi "nerd"; then
  echo "✅ Nerd Font bereits installiert"
else
  echo "⚠️  Keine Nerd Font gefunden"
  echo "Für Icons in i3blocks wird eine Nerd Font empfohlen."
  echo ""
  read -p "Nerd Font jetzt installieren? (j/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[JjYy]$ ]]; then
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    echo "  Downloading CascadiaCode Nerd Font..."
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
echo "⚙️  Phase 8: PATH-Konfiguration"
echo "──────────────────────────────"

# Prüfe ob ~/.local/bin bereits im PATH ist
if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
  echo "✅ ~/.local/bin ist bereits im PATH"
else
  echo "Die i3-Keybindings (Mod+Shift+Y, Mod+Shift+W) benötigen"
  echo "~/.local/bin im PATH."
  echo ""
  read -p "~/.profile automatisch ergänzen? (j/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[JjYy]$ ]]; then
    # Prüfe ob Zeile schon in .profile existiert
    if grep -q "\.local/bin" ~/.profile 2>/dev/null; then
      echo "✅ ~/.profile enthält bereits .local/bin Konfiguration"
    else
      # Erstelle .profile falls nicht vorhanden und füge PATH hinzu
      touch ~/.profile
      echo "" >> ~/.profile
      echo "# Added by i3_parrot_design installer" >> ~/.profile
      echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
      echo "✅ ~/.profile aktualisiert"
      echo ""
      echo "ℹ️  Für aktuelle Shell: source ~/.profile"
    fi
  else
    echo "⏭️  Übersprungen"
    echo ""
    echo "ℹ️  Keybindings funktionieren erst nach manuellem Hinzufügen:"
    echo "   echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.profile"
    ((WARNINGS++))
  fi
fi

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║      Installation erfolgreich! 🎉            ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# Zeige Zusammenfassung bei Warnungen
if [ $WARNINGS -gt 0 ]; then
  echo "⚠️  Installation abgeschlossen mit $WARNINGS Warnung(en)"
  if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
    echo "   Fehlende Pakete:"
    for pkg in "${FAILED_PACKAGES[@]}"; do
      echo "     - $pkg"
    done
    echo ""
    echo "   Diese können später manuell nachinstalliert werden:"
    echo "   sudo apt install ${FAILED_PACKAGES[*]}"
    echo ""
  fi
fi

echo "📝 Nächste Schritte:"
echo ""
echo "1. Log out und wieder ein (oder: i3-msg restart)"
echo "2. Teste Theme-Wechsel:    Win+Shift+Y"
echo "3. Öffne Control Center:   Win+M"
echo "4. Wallpaper ändern:       Win+Shift+W"
echo ""
echo "📚 Dokumentation:"
echo "   README.md              – Features und Übersicht"
echo "   SYSTEM_OVERVIEW.md     – Technische Architektur"
echo "   KEYBINDINGS.md         – Alle Tastenkombinationen"
echo ""
echo "💾 Backup gespeichert in:"
echo "   $BACKUP_DIR"
echo ""
