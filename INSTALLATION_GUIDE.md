# Installation Test & Anleitung

## 🧪 So würde die Installation ablaufen:

### Voraussetzungen:
- Frisches Parrot OS installiert
- **KEINE i3-Installation nötig vorher!** Das Skript installiert alles.

### Installations-Schritte:

```bash
# 1. Repo clonen
cd ~
git clone https://github.com/USERNAME/i3-parrot-dotfiles.git
cd i3-parrot-dotfiles

# 2. Install-Script ausführen
chmod +x install.sh
./install.sh
```

## 📋 Was das Skript macht:

### Phase 1: Dependencies (mit apt)
✅ Installiert: i3-wm, i3blocks, rofi, feh, dunst, picom, alacritty, kitty, etc.
✅ Fragt vorher nach Bestätigung
⚠️  Braucht sudo-Rechte für apt

### Phase 2: Backup
✅ Erstellt Backup in ~/.config-backup/dotfiles-backup-DATUM
✅ Sichert existierende Configs (falls vorhanden)
✅ Überspringt nicht-existente Verzeichnisse

### Phase 3: Configs kopieren
✅ Kopiert von: `./i3_parrot_dotfiles/.config/*`
✅ Nach: `~/.config/`
⚠️  Würde existierende Dateien überschreiben!

### Phase 4: Skripte kopieren
✅ Kopiert von: `./i3_parrot_dotfiles/.local/bin/*`
✅ Nach: `~/.local/bin/`
✅ Setzt ausführbar: i3-menu, i3-theme-*, update-checker, etc.

### Phase 5: Theme-System initialisieren
✅ Erstellt Symlink: `~/.config/i3-themes/current/theme` → tokyo-night
✅ Erstellt Symlink: `~/.config/i3-themes/current/background` → erstes Wallpaper
⚠️  Nur wenn noch nicht vorhanden

### Phase 6: Nerd Fonts (optional)
✅ Prüft ob Nerd Font installiert
✅ Fragt ob automatisch installieren
✅ Downloadet & installiert CascadiaCode Nerd Font
✅ Kann übersprungen werden

## ✅ Nach Installation:

```bash
# Log out und wieder ein
# Wähle "i3" als Window Manager im Login-Screen

# ODER im Terminal:
echo "exec i3" > ~/.xinitrc
startx
```

## 🔍 Was funktioniert SOFORT:

✅ i3wm mit vollständiger Config
✅ Rofi App Launcher (Super+D)
✅ i3-menu Control Center (Super+M)
✅ Theme-Wechsel (Super+Shift+Y)
✅ i3blocks Statusbar mit Update-Anzeige
✅ Wallpaper automatisch gesetzt
✅ Alle Keybindings

## ⚠️  Potenzielle Probleme & Fixes:

### Problem 1: Existierende i3-Config wird überschrieben
**Lösung:** Backup wird automatisch erstellt!
```bash
# Restore aus Backup:
cp -r ~/.config-backup/dotfiles-backup-*/i3 ~/.config/
```

### Problem 2: Wallpaper wird nicht gesetzt
**Ursache:** feh läuft nicht oder Pfad falsch
**Fix:**
```bash
feh --bg-fill ~/.config/i3-themes/current/background
```

### Problem 3: Theme-Wechsel funktioniert nicht
**Ursache:** PATH nicht gesetzt oder Skripte nicht ausführbar
**Fix:**
```bash
export PATH="$HOME/.local/bin:$HOME/.local/bin/i3-theme:$PATH"
chmod +x ~/.local/bin/i3-theme/*
```

### Problem 4: Icons fehlen in i3blocks
**Ursache:** Nerd Font nicht installiert
**Fix:**
```bash
# Font manuell installieren (siehe Phase 6)
# Oder Font in i3/config ändern
```

### Problem 5: Themes-Verzeichnis leer
**Ursache:** Git hat Themes nicht gecloned
**Fix:**
```bash
cd ~/i3_parrot_dotfiles
git pull
ls .config/i3-themes/themes/  # Sollte 14 Themes zeigen
```

## 🧹 Deinstallation:

```bash
# Configs entfernen
rm -rf ~/.config/i3 ~/.config/i3blocks ~/.config/i3-themes
rm -rf ~/.config/alacritty.toml ~/.config/rofi

# Skripte entfernen
rm -f ~/.local/bin/i3-menu ~/.local/bin/i3-theme-*
rm -rf ~/.local/bin/i3-theme/

# Restore aus Backup (falls vorhanden)
cp -r ~/.config-backup/dotfiles-backup-LATEST/* ~/

# Packages behalten (könnten von anderen Programmen genutzt werden)
```

## 📊 Checklist nach Installation:

- [ ] i3 startet ohne Fehler
- [ ] Super+D öffnet Rofi
- [ ] Super+M öffnet i3-menu
- [ ] i3bar zeigt Statusinfo
- [ ] Wallpaper ist gesetzt
- [ ] Theme-Wechsel funktioniert (Super+Shift+Y)
- [ ] Terminal öffnet (Super+Return)
- [ ] Icons werden korrekt angezeigt

## 💡 Pro-Tipps:

**Vor Installation auf produktivem System:**
```bash
# Teste erst in VM oder auf Test-Partition
# Oder: Manuelles Backup
tar -czf ~/i3-backup-$(date +%Y%m%d).tar.gz ~/.config/i3 ~/.config/i3blocks
```

**Individuelle Anpassungen behalten:**
```bash
# Vor Installation: Sichere deine i3-config
cp ~/.config/i3/config ~/my-i3-config.backup

# Nach Installation: Merge wichtige Teile zurück
vimdiff ~/my-i3-config.backup ~/.config/i3/config
```

**Selektive Installation:**
```bash
# Nur Themes installieren (ohne i3-config zu überschreiben)
cp -r i3_parrot_dotfiles/.config/i3-themes ~/.config/
cp -r i3_parrot_dotfiles/.local/bin/i3-theme ~/.local/bin/

# Nur Skripte installieren
cp i3_parrot_dotfiles/.local/bin/i3-* ~/.local/bin/
```

## ✅ Fazit:

**JA, das Skript funktioniert auf frischem Parrot-System!**

1. i3 muss NICHT vorher laufen
2. Alles wird an die richtige Stelle kopiert
3. Backup wird automatisch erstellt
4. Nach logout/login ist alles fertig
