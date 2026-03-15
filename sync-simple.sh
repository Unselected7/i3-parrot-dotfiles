#!/bin/bash
# Sync: System → Repository
# Synchronisiert alle i3_parrot_design relevanten Dateien

REPO="$HOME/i3_parrot_dotfiles"

echo "📦 Synchronisiere i3_parrot_design System → Repository..."
echo ""

# 1. Theme Library & Scripts (.local/share/)
echo "1️⃣  Themes und Scripts syncing..."
rsync -av --delete \
  --exclude="*.backup" \
  --exclude="*.pre-migration" \
  ~/.local/share/i3_parrot_design/ \
  "$REPO/.local/share/i3_parrot_design/"

# 2. User Bin Symlinks (.local/bin/)
echo "2️⃣  Bin Symlinks syncing..."
rsync -av -l \
  ~/.local/bin/i3-* \
  "$REPO/.local/bin/"

# 3. i3 Konfiguration
echo "3️⃣  i3 Config syncing..."
rsync -av ~/.config/i3/config "$REPO/.config/i3/"

# 4. i3blocks Konfiguration
echo "4️⃣  i3blocks Config syncing..."
rsync -av ~/.config/i3blocks/config "$REPO/.config/i3blocks/"

# 5. Kitty Terminal Konfiguration
echo "5️⃣  Kitty Config syncing..."
rsync -av ~/.config/kitty/kitty.conf "$REPO/.config/kitty/"

# 6. Rofi Konfiguration
echo "6️⃣  Rofi Config syncing..."
rsync -av ~/.config/rofi/ "$REPO/.config/rofi/"

# 7. XCompose Tastaturlayout
echo "7️⃣  XCompose syncing..."
rsync -av ~/.XCompose "$REPO/"

# 8. i3-themes aktive Symlinks (current theme)
echo "8️⃣  Active theme symlinks syncing..."
rsync -av -l \
  ~/.config/i3-themes/current/ \
  "$REPO/.config/i3-themes/current/"

echo ""
echo "✅ Sync fertig!"
echo ""
echo "Nächste Schritte:"
echo "  cd $REPO"
echo "  git status"
echo "  git add ."
echo "  git commit -m 'Update: Synchronisiere mit aktuellem System'"
