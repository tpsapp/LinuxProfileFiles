#!/usr/bin/env bash
# Safe dotfiles backup to ./src
# Usage:
#   ./backup_files.sh               # perform backup (non-destructive)
#   ./backup_files.sh --dry-run     # preview actions without writing files
#
# Options:
#   --dry-run   Preview actions only; do not create directories or copy files.
#
# Notes:
#   - The script copies selected files and directories into ./src and writes a
#     timestamped log to ./logs/backup_YYYYMMDDHHMMSS.log.
#   - By default the script avoids copying SSH private keys and other secret
#     material. See README.md for recommended secret handling.

set -Eeuo pipefail
IFS=$'\n\t'

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
	DRY_RUN=true
	echo "DRY-RUN: no files will be written"
fi

DEST_ROOT="$(pwd)/src"
LOG_DIR="$(pwd)/logs"
mkdir -p "$DEST_ROOT" "$LOG_DIR"
LOG_FILE="$LOG_DIR/backup_$(date +%Y%m%d%H%M%S).log"

log() {
	printf '%s %s\n' "$(date +'%Y-%m-%d %T')" "$*" | tee -a "$LOG_FILE"
}

copy_file() {
       local src="$1"
       [[ "$src" == ~* ]] && src="${src/#\~/$HOME}"
       if [ ! -e "$src" ]; then
	       log "SKIP: source not found: $src"
	       return
       fi
       local dst
       if [[ "$src" == "$HOME"* ]]; then
	       # Home files: preserve relative path under src
	       dst="$DEST_ROOT${src#$HOME}"
       elif [[ "$src" == "/etc/pacman.conf" ]]; then
	       # System file: put in src/etc/
	       dst="$DEST_ROOT/etc/pacman.conf"
       else
	       # Other absolute paths: preserve under src
	       dst="$DEST_ROOT${src}"
       fi
       local dstdir
       dstdir=$(dirname "$dst")
       if [ "$DRY_RUN" = true ]; then
	       log "[DRY-RUN] create-dir: $dstdir"
	       log "[DRY-RUN] copy: $src -> $dst"
       else
	       mkdir -p "$dstdir"
	       cp --preserve=mode,timestamps "$src" "$dst"
	       log "COPIED: $src -> $dst"
       fi
}

copy_tree() {
       local src="$1"
       [[ "$src" == ~* ]] && src="${src/#\~/$HOME}"
       if [ ! -e "$src" ]; then
	       log "SKIP: directory not found: $src"
	       return
       fi
       local dst_dir
       if [[ "$src" == "$HOME"* ]]; then
	       # Home directories: preserve path relative to $HOME
	       dst_dir="$DEST_ROOT${src#$HOME}"
       else
	       # Other absolute paths: preserve under src
	       dst_dir="$DEST_ROOT/${src#/}"
       fi
       if [ "$DRY_RUN" = true ]; then
	       log "[DRY-RUN] rsync -a \"$src/\" \"$dst_dir/\""
       else
	       mkdir -p "$dst_dir"
	       # Do not remove any files in the destination; avoid --delete
	       rsync -a --links --times --omit-dir-times "$src/" "$dst_dir/" >>"$LOG_FILE" 2>&1
	       log "RSYNCED: $src/ -> $dst_dir/"
       fi
}

# Single files to copy (expand ~)
FILES=(
	"$HOME/.bashrc"
	"$HOME/.bash_aliases"
	"$HOME/.bash_functions"
	"$HOME/.bash_logout"
	"$HOME/.bash_profile"
	"$HOME/.profile"
	"$HOME/.dir_colors"
	"$HOME/.gitconfig"
	"$HOME/.nanorc"
	"$HOME/.vimrc"
	"$HOME/.Xresources"
	"$HOME/Pictures/avatar.jpg"
	"/etc/pacman.conf"   # will be placed in src/etc/
)

# Directories to copy (rsync)
DIRS=(
	"$HOME/.local/bin"
	"$HOME/Pictures/Wallpapers"
)

# Special and ssh-safe patterns
SPECIAL_FILES=(
	"$HOME/.config/dolphinrc"
	"$HOME/.config/katerc"
	"$HOME/.config/starship.toml"
	"$HOME/.config/atuin/config.toml"
	"$HOME/.config/atuin/themes/nord.toml"
)

SSH_INCLUDES=(
	"$HOME/.ssh/*.pub"
	"$HOME/.ssh/config"
	"$HOME/.ssh/known_hosts"
)

log "Starting backup. DEST_ROOT=$DEST_ROOT DRY_RUN=$DRY_RUN"

# Ensure rsync is available (used by copy_tree)
ensure_rsync() {
	if command -v rsync >/dev/null 2>&1; then
		return 0
	fi
	if [ "$DRY_RUN" = true ]; then
		log "[DRY-RUN] rsync is not installed; would install via pacman"
		return 0
	fi
	if command -v pacman >/dev/null 2>&1; then
		log "rsync not found; installing with sudo pacman -S --noconfirm rsync"
		sudo pacman -S --noconfirm rsync
	else
		log "rsync not found and pacman is not available; please install rsync manually"
		return 1
	fi
}

ensure_rsync || log "Warning: rsync not available; directory syncing may fail"

for f in "${FILES[@]}"; do
	copy_file "$f" || true
done

for s in "${SPECIAL_FILES[@]}"; do
	copy_file "$s"
done

for d in "${DIRS[@]}"; do
	copy_tree "$d"
done

# SSH safe copy
shopt -s nullglob
for pattern in "${SSH_INCLUDES[@]}"; do
	# expand glob pattern into array safely
	mapfile -t matches < <(compgen -G "$pattern" || printf '')
	for match in "${matches[@]}"; do
		copy_file "$match"
	done
done
shopt -u nullglob

# Export installed package lists (official + AUR) into the repo's src/ directory
PKG_OFF_PATH="$DEST_ROOT/pkglist.txt"
PKG_AUR_PATH="$DEST_ROOT/aur_pkglist.txt"

if [ "$DRY_RUN" = true ]; then
	log "[DRY-RUN] would export installed package lists to $PKG_OFF_PATH and $PKG_AUR_PATH"
else
	log "Exporting installed package lists"
	# Official repo packages
	if command -v pacman >/dev/null 2>&1; then
		pacman -Qen > "$PKG_OFF_PATH" 2>>"$LOG_FILE" || log "Warning: pacman -Qen failed"
	else
		log "pacman not found; skipping official package export"
	fi
	# AUR packages (local/foreign)
	if command -v pacman >/dev/null 2>&1; then
		pacman -Qem > "$PKG_AUR_PATH" 2>>"$LOG_FILE" || log "Warning: pacman -Qem failed"
	else
		log "pacman not found; skipping AUR package export"
	fi
	log "Exported package lists: $PKG_OFF_PATH, $PKG_AUR_PATH"
fi

log "Backup finished. Log saved to $LOG_FILE"