#!/usr/bin/env bash
# install.sh
# Run as your regular user (not root). sudo is called internally where needed.
# Usage: ./install.sh [--repo-dir /path/to/manual-sync-dotfiles]

set -euo pipefail

REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
BOOT_MOUNT="/boot"

# ── Colours ────────────────────────────────────────────────────────────────
log()  { echo -e "\n\033[1;34m▶ $*\033[0m"; }
ok()   { echo -e "  \033[1;32m✓\033[0m  $*"; }
warn() { echo -e "  \033[1;33m!\033[0m  $*"; }
die()  { echo -e "\n  \033[1;31m✗  $*\033[0m\n" >&2; exit 1; }

# ── Helpers ────────────────────────────────────────────────────────────────

# Back up a file if it already exists and isn't one of our own symlinks
backup() {
  local f="$1"
  if [[ -e "$f" && ! -L "$f" ]]; then
    local bak="${f}.bak.$(date +%Y%m%d-%H%M%S)"
    warn "Existing file backed up: $bak"
    sudo mv "$f" "$bak" 2>/dev/null || mv "$f" "$bak"
  fi
}

# Create a symlink, backing up any existing target first
symlink() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  backup "$dest"
  ln -sf "$src" "$dest"
  ok "$dest  →  $src"
}

# ── Pre-flight ─────────────────────────────────────────────────────────────

[[ -d "$REPO_DIR" ]] || die "Repo not found at $REPO_DIR"
[[ $EUID -ne 0 ]]   || die "Run as your regular user, not root. sudo is called internally."

log "Repo: $REPO_DIR"
sudo -v   # cache sudo credentials upfront

# ── 1. Boot entry (arch.conf) ──────────────────────────────────────────────

log "Installing systemd-boot entry"

TEMPLATE="$REPO_DIR/bootfiles/arch.conf.template"
[[ -f "$TEMPLATE" ]] || die "Missing: $TEMPLATE"

ROOT_UUID=$(blkid -s UUID -o value "$(findmnt -n -o SOURCE /)") \
  || die "Could not detect root UUID. Is / mounted?"

sudo mkdir -p "$BOOT_MOUNT/loader/entries"
backup "$BOOT_MOUNT/loader/entries/arch.conf"
sed "s/%%ROOT_UUID%%/$ROOT_UUID/g" "$TEMPLATE" \
  | sudo tee "$BOOT_MOUNT/loader/entries/arch.conf" > /dev/null
ok "$BOOT_MOUNT/loader/entries/arch.conf  (UUID: $ROOT_UUID)"

# ── 2. loader.conf ─────────────────────────────────────────────────────────

log "Installing loader.conf"

backup "$BOOT_MOUNT/loader/loader.conf"
sudo cp "$REPO_DIR/bootfiles/loader.conf" "$BOOT_MOUNT/loader/loader.conf"
ok "$BOOT_MOUNT/loader/loader.conf"

# ── 3. Plymouth theme ──────────────────────────────────────────────────────

log "Installing Plymouth theme (archlogo)"

THEME_SRC="$REPO_DIR/bootfiles/archlogo"
THEME_DEST="/usr/share/plymouth/themes/archlogo"

[[ -d "$THEME_SRC" ]] || die "Missing theme folder: $THEME_SRC"
sudo mkdir -p "$THEME_DEST"
sudo cp -r "$THEME_SRC/." "$THEME_DEST/"
ok "$THEME_DEST"

# ── 4. plymouthd.conf ──────────────────────────────────────────────────────

log "Installing plymouthd.conf"

sudo mkdir -p /etc/plymouth
backup /etc/plymouth/plymouthd.conf
sudo cp "$REPO_DIR/bootfiles/plymouthd.conf" /etc/plymouth/plymouthd.conf
ok "/etc/plymouth/plymouthd.conf"

# ── 5. mkinitcpio.conf ─────────────────────────────────────────────────────

log "Installing mkinitcpio.conf"

backup /etc/mkinitcpio.conf
sudo cp "$REPO_DIR/bootfiles/mkinitcpio.conf" /etc/mkinitcpio.conf
ok "/etc/mkinitcpio.conf"

# ── 6. Home dotfiles (symlinks) ────────────────────────────────────────────

log "Symlinking home dotfiles"

symlink "$REPO_DIR/bashrc"           "$HOME/.bashrc"
symlink "$REPO_DIR/bash_aliases"     "$HOME/.bash_aliases"
symlink "$REPO_DIR/tmux.conf"        "$HOME/.tmux.conf"
symlink "$REPO_DIR/tmux.dotbar"      "$HOME/.tmux.dotbar"
symlink "$REPO_DIR/mpv.conf"         "$HOME/.config/mpv/mpv.conf"
symlink "$REPO_DIR/nvim-init.lua"    "$HOME/.config/nvim/init.lua"
symlink "$REPO_DIR/hypr"             "$HOME/.config/hypr"
symlink "$REPO_DIR/ghostty-config"   "$HOME/.config/ghostty/config"
symlink "$REPO_DIR/kitty-conf"       "$HOME/.config/kitty/kitty.conf"
symlink "$REPO_DIR/powerline-shell.config.json" \
                                     "$HOME/.config/powerline-shell/config.json"

# lessfilter must be executable
symlink "$REPO_DIR/lessfilter"       "$HOME/.lessfilter"
chmod +x "$REPO_DIR/lessfilter"

# Colour schemes — symlink into their theme dirs so apps can find them
mkdir -p "$HOME/.config/ghostty/themes" "$HOME/.config/kitty/themes"
symlink "$REPO_DIR/onehalf-dark-ghostty-zach" \
        "$HOME/.config/ghostty/themes/onehalf-dark-ghostty-zach"
symlink "$REPO_DIR/onehalf-dark-kitty-zach" \
        "$HOME/.config/kitty/themes/onehalf-dark-kitty-zach"

# ── 7. keyd (needs sudo for /etc) ─────────────────────────────────────────

if [[ -f "$REPO_DIR/keyd.default.conf" ]]; then
  log "Installing keyd config"
  sudo mkdir -p /etc/keyd
  backup /etc/keyd/default.conf
  sudo cp "$REPO_DIR/keyd.default.conf" /etc/keyd/default.conf
  ok "/etc/keyd/default.conf"
  warn "Remember: sudo systemctl enable --now keyd"
fi

# ── 8. Rebuild initramfs ───────────────────────────────────────────────────

log "Rebuilding initramfs (mkinitcpio -P)"
sudo mkinitcpio -P && ok "Initramfs rebuilt." || die "mkinitcpio failed — check output above."

# ── Done ───────────────────────────────────────────────────────────────────

echo ""
echo "  ┌─────────────────────────────────────────────┐"
echo "  │  All done. Reboot when you're ready.         │"
echo "  │                                              │"
echo "  │  Skipped (Mac-only):                         │"
echo "  │    hammerspoon-init.lua                      │"
echo "  │    karabiner/                                │"
echo "  └─────────────────────────────────────────────┘"
echo ""
