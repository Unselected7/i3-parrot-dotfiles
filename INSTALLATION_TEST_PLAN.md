# Installation Test Plan - i3_parrot_design

## Ziel

Teste die Installation des i3_parrot_design Systems in einer **isolierten Umgebung**, um sicherzustellen, dass alle Abhängigkeiten und Installations-Schritte korrekt sind.

---

## Methode 1: Neuer Benutzer auf demselben System (EMPFOHLEN)

### Vorteile
- Schnell und einfach
- Gleiche System-Dependencies wie Produktivsystem
- Echter Test der Installation ohne User-spezifische Konfigurationen

### Vorbereitung

```bash
# 1. Neuen Test-Benutzer erstellen
sudo adduser i3test
# Passwort setzen: test123 (oder beliebig)

# 2. Benutzer zu sudo-Gruppe hinzufügen (optional, für Paket-Installation)
sudo usermod -aG sudo i3test

# 3. i3_parrot_dotfiles zum Test-User kopieren
sudo cp -r ~/i3_parrot_dotfiles /home/i3test/
sudo chown -R i3test:i3test /home/i3test/i3_parrot_dotfiles
```

### Test-Durchführung

#### Schritt 1: Login als Test-User

```bash
# Option A: Über TTY (Strg+Alt+F2)
# Login: i3test
# Password: test123

# Option B: su als Test-User (wenn auf Desktop)
su - i3test
```

#### Schritt 2: Installation ausführen

```bash
cd ~/i3_parrot_dotfiles

# Prüfe Dependencies
cat dependencies.txt
# Installiere falls nötig:
# sudo apt install <packages>

# Führe Installation aus
./install.sh

# Was install.sh machen sollte:
# 1. Kopiere .local/share/i3_parrot_design
# 2. Erstelle Symlinks in .local/bin
# 3. Kopiere .config Dateien
# 4. Erstelle Symlinks in .config
```

#### Schritt 3: Manuelle Nacharbeiten (falls install.sh nicht alles macht)

```bash
# .bashrc anpassen
echo "" >> ~/.bashrc
echo "# Source i3_parrot_design bash configuration" >> ~/.bashrc
echo "source \$HOME/.local/share/i3_parrot_design/default/bash/rc" >> ~/.bashrc

# .XCompose kopieren (optional)
cp ~/i3_parrot_dotfiles/.XCompose ~/

# i3 config kopieren
cp ~/i3_parrot_dotfiles/.config/i3/config ~/.config/i3/
```

#### Schritt 4: i3 starten / neu laden

```bash
# Falls i3 schon läuft:
i3-msg restart

# Falls noch nicht gestartet:
# Logout und bei Login i3 als WM wählen
```

#### Schritt 5: Funktionstest

**Test-Checklist:**

```bash
# 1. Scripts verfügbar?
which i3-theme-set
which i3-theme-list
which i3-menu

# 2. Theme-Liste anzeigen
i3-theme-list
# → Sollte 14 Themes zeigen

# 3. Theme setzen
i3-theme-set gruvbox
# → Sollte ohne Fehler durchlaufen

# 4. Aktuelles Theme anzeigen
i3-theme-current
# → Sollte "Gruvbox" ausgeben

# 5. Shell-Features testen (neues Terminal öffnen!)
ll
lsa
cd /tmp  # (sollte zoxide verwenden)
```

**Keybinding-Tests:**

Drücke nacheinander:
- **Win+Shift+Y** → Theme sollte wechseln
- **Win+Shift+W** → Wallpaper sollte wechseln
- **Super+M** → i3-menu sollte erscheinen
  - Wähle "Themes" → Liste sollte erscheinen
  - Wähle ein Theme → sollte wechseln

**App-Theming-Tests:**

```bash
# 1. Alacritty starten
alacritty &
# → Sollte Theme-Farben haben

# 2. Kitty starten (falls installiert)
kitty &
# → Sollte Theme-Farben haben

# 3. Neovim öffnen
nvim test.txt
# → Sollte Theme aktiv haben

# 4. eza colors
ll
# → Dateien sollten farbig sein (entsprechend dem Theme)
```

#### Schritt 6: Fehlerprotokoll

**Dokumentiere alle Probleme:**

```bash
# Log-Datei erstellen
cd ~/i3_parrot_dotfiles
cat > test_results.txt << EOF
=== INSTALLATION TEST REPORT ===
Datum: $(date)
User: $(whoami)
System: $(uname -a)

FEHLER:
- [Beschreibung]
- [Beschreibung]

ERFOLGE:
- [x] Theme-Wechsel funktioniert
- [x] Keybindings funktionieren
- [ ] etc.

NOTIZEN:
- [Was musste manuell nachgebessert werden?]
EOF
```

### Test abschließen

```bash
# 1. Als Test-User ausloggen
exit

# 2. Test-User löschen (als normaler User)
sudo deluser --remove-home i3test

# Falls Probleme gefunden: Erst beheben, dann erneut testen!
```

---

## Methode 2: VM oder Container (Vollständig isoliert)

### Mit QEMU/KVM VM

**Vorbereitung:**
1. ParrotOS ISO herunterladen
2. Neue VM erstellen (20GB, 4GB RAM)
3. ParrotOS installieren
4. i3_parrot_dotfiles rüberkopieren (via scp oder shared folder)

**Vorteil:** Komplett saubere Umgebung  
**Nachteil:** Ressourcen-intensiv, länger

### Mit Docker (Nur für Script-Tests, nicht GUI)

```dockerfile
FROM parrotsec/core:latest

RUN apt-get update && apt-get install -y \
    bash \
    git \
    # ... weitere Dependencies aus dependencies.txt

COPY i3_parrot_dotfiles /root/i3_parrot_dotfiles
WORKDIR /root/i3_parrot_dotfiles

CMD ["/bin/bash"]
```

**Limitation:** Keine GUI-Tests möglich (nur Script-Logik)

---

## Methode 3: Chroot-Umgebung (Fortgeschritten)

Für erfahrene User: Erstelle eine Chroot mit minimaler Parrot-Installation.

```bash
# Minimales Debian/Parrot Bootstrap
sudo debootstrap bullseye /mnt/chroot

# In Chroot wechseln
sudo chroot /mnt/chroot

# Installation testen
```

**Vorteil:** Schnell, wenig Overhead  
**Nachteil:** Komplex, keine GUI

---

## Was testen wir?

### Installations-Komponenten

- [ ] **Dependencies:** Alle benötigten Pakete installiert?
- [ ] **install.sh:** Läuft ohne Fehler durch?
- [ ] **Verzeichnisstruktur:** Alles am richtigen Ort?
- [ ] **Symlinks:** Alle korrekt gesetzt?
- [ ] **Permissions:** Alle Scripts ausführbar?

### Funktionale Tests

- [ ] **Theme-Wechsel:** `i3-theme-set` funktioniert
- [ ] **Theme-Cycling:** `i3-theme-next` funktioniert
- [ ] **Wallpaper-Cycling:** `i3-theme-bg-next` funktioniert
- [ ] **Menu:** `i3-menu` öffnet sich, Theme-Liste angezeigt
- [ ] **Keybindings:** Win+Shift+Y/W, Super+M funktionieren
- [ ] **Shell-Integration:** Aliase (ll, lsa) funktionieren
- [ ] **zoxide:** cd-Ersatz funktioniert
- [ ] **eza-Colors:** Farbige Dateilisten

### App-Integration

- [ ] **Alacritty:** Theme wird angewendet
- [ ] **Kitty:** Theme wird angewendet + Reload
- [ ] **Neovim:** Colorscheme aktiv
- [ ] **VSCode:** Theme wird gesetzt (falls installiert)
- [ ] **btop:** Theme aktiv (falls installiert)

### Edge Cases

- [ ] **Mehrfaches Theme-Switching:** Kein Fehler nach 10x wechseln
- [ ] **Theme mit Leerzeichen:** "Tokyo Night" funktioniert
- [ ] **Fehlende App:** Script gibt saubere Warnung wenn App fehlt
- [ ] **Leeres backgrounds/:** Graceful fallback
- [ ] **i3-Restart:** Theme bleibt nach i3-restart aktiv

---

## Häufige Probleme und Lösungen

### Problem: "i3-theme-set: command not found"

**Ursache:** Symlinks nicht erstellt oder PATH fehlt

**Lösung:**
```bash
# Prüfe Symlinks:
ls -la ~/.local/bin/i3-theme-*

# Erstelle falls fehlt:
cd ~/.local/bin
ln -s ../share/i3_parrot_design/bin/i3-theme-set i3-theme-set
# etc.

# PATH prüfen:
echo $PATH | grep .local/bin
# Falls fehlt, zu .bashrc hinzufügen:
export PATH="$HOME/.local/bin:$PATH"
```

### Problem: "Keybindings funktionieren nicht"

**Ursache:** i3 config hat keine vollen Pfade

**Lösung:**
```bash
# Prüfe i3 config:
grep "i3-theme-next" ~/.config/i3/config

# Sollte sein:
bindsym $mod+Shift+y exec --no-startup-id /home/USERNAME/.local/bin/i3-theme-next

# Korrigiere und reload:
i3-msg reload
```

### Problem: "Theme-Liste im Menu leer"

**Ursache:** i3-menu findet i3-theme-list nicht

**Lösung:**
```bash
# Prüfe i3-menu Zeile 5:
head -10 ~/.local/bin/i3-menu

# Sollte enthalten:
export PATH="$HOME/.local/bin:$PATH"
```

### Problem: "eza colors funktionieren nicht"

**Ursache:** Symlink fehlt oder eza.yml nicht im Theme

**Lösung:**
```bash
# 1. Symlink prüfen:
ls -la ~/.config/eza/theme.yml

# 2. Erstellen falls fehlt:
mkdir -p ~/.config/eza
ln -s ~/.config/i3-themes/current/theme/eza.yml ~/.config/eza/theme.yml

# 3. Prüfe ob eza.yml im Theme existiert:
ls ~/.local/share/i3_parrot_design/themes/*/eza.yml
# Sollte für alle 14 Themes vorhanden sein
```

---

## Test-Report Template

```markdown
# i3_parrot_design Installation Test Report

**Datum:** 2026-03-14  
**Tester:** [Name]  
**System:** ParrotOS 6.x / Debian Bookworm  
**Test-Methode:** Neuer Benutzer "i3test"

## Installation

- [ ] Repository geklont
- [ ] Dependencies installiert
- [ ] install.sh ausgeführt
- [ ] .bashrc angepasst
- [ ] i3 neugestartet

**Dauer:** XX Minuten

## Funktionstest Ergebnisse

| Feature | Status | Notizen |
|---------|--------|---------|
| i3-theme-set | ✅ / ❌ | |
| i3-theme-next | ✅ / ❌ | |
| i3-theme-list | ✅ / ❌ | |
| i3-menu | ✅ / ❌ | |
| Keybinding Win+Shift+Y | ✅ / ❌ | |
| Keybinding Win+Shift+W | ✅ / ❌ | |
| Keybinding Super+M | ✅ / ❌ | |
| Shell-Aliase (ll, lsa) | ✅ / ❌ | |
| zoxide | ✅ / ❌ | |
| eza colors | ✅ / ❌ | |
| Alacritty theming | ✅ / ❌ | |
| Kitty theming | ✅ / ❌ | |
| Neovim theming | ✅ / ❌ | |

## Gefundene Probleme

1. **[Problem-Beschreibung]**
   - Ursache: ...
   - Lösung: ...

2. **[Problem-Beschreibung]**
   - Ursache: ...
   - Lösung: ...

## Verbesserungsvorschläge

- ...
- ...

## Fazit

Installation: ✅ Erfolgreich / ❌ Fehlgeschlagen

**Zusammenfassung:**
[Kurze Bewertung der Installation]
```

---

## Nächste Schritte nach erfolgreichem Test

1. **install.sh verbessern** (basierend auf Testergebnissen)
2. **README.md aktualisieren** (mit genauen Installations-Schritten)
3. **KNOWN_ISSUES.md erstellen** (dokumentiere alle bekannten Probleme)
4. **Screenshots hinzufügen** (für README und Bewerbung)
5. **Repository auf GitHub pushen** (temporär public für Bewerbung)

---

**Erstellt:** 2026-03-14  
**Version:** 1.0  
**Für:** i3_parrot_design Installation Testing
