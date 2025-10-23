#!/usr/bin/env bash
# Safe restore script for dotfiles backed up under ./src
# Usage:
#   ./restore_files.sh               # interactive restore: shows a summary and prompts once
#   ./restore_files.sh --dry-run     # preview actions without making changes
#   ./restore_files.sh --force       # proceed to overwrite files (legacy flag maintained)
#   ./restore_files.sh --noprompt    # skip the one-time confirmation and proceed (non-interactive)
#
# Options:
#   --dry-run   Preview all actions; no files are copied, moved, or modified.
#   --force     Legacy flag: treated as an instruction to overwrite files.
#   --noprompt  Skip the one-time summary confirmation and proceed immediately
#               (useful for automation/CI). The script still creates timestamped
#               backups of existing files before overwriting unless --dry-run.
#
# Behavior:
#   - Restores files from ./src into the user's home (and selected system files
#     such as /etc/pacman.conf when present). Existing files are backed up to
#     <path>.bak.TIMESTAMP before being overwritten.
#   - Directory restores use rsync without --delete (non-destructive).
#   - If rsync is missing the script will attempt to install it via pacman
#     unless --dry-run is set. Adjust the script if you run a different distro.

set -Eeuo pipefail
IFS=$'\n\t'

DRY_RUN=false
FORCE=false
NOPROMPT=false
for arg in "${@:-}"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --force) FORCE=true ;;
    --noprompt) NOPROMPT=true ;;
  esac
done

SRC_ROOT="$(pwd)/src"
LOG_DIR="$(pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/restore_$(date +%Y%m%d%H%M%S).log"

log() { printf '%s %s\n' "$(date +'%Y-%m-%d %T')" "$*" | tee -a "$LOG_FILE"; }

backup_target() {
  local target="$1"
  if [ -e "$target" ]; then
    local bak
    bak="$target.bak.$(date +%Y%m%d%H%M%S)"
    if [ "$DRY_RUN" = true ]; then
      log "[DRY-RUN] would backup existing $target -> $bak"
    else
      mkdir -p "$(dirname "$bak")"
      # Copy existing file to backup rather than moving it, to avoid deleting
      cp --preserve=mode,timestamps "$target" "$bak"
      log "BACKED UP (copied): $target -> $bak"
    fi
  fi
}

restore_file() {
  local src="$1"
  local dst="$2"
  [[ "$src" == ~* ]] && src="${src/#\~/$HOME}"
  if [ ! -e "$src" ]; then log "SKIP: source not found: $src"; return; fi
  # Non-interactive: always backup existing destination and overwrite
  backup_target "$dst"
  if [ "$DRY_RUN" = true ]; then
    log "[DRY-RUN] copy: $src -> $dst"
  else
    mkdir -p "$(dirname "$dst")"
    cp --preserve=mode,timestamps "$src" "$dst"
    log "RESTORED: $src -> $dst"
  fi
}

log "Starting restore. SRC_ROOT=$SRC_ROOT DRY_RUN=$DRY_RUN FORCE=$FORCE"

# Ensure rsync is available (some restore operations may use rsync in future)
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

ensure_rsync || log "Warning: rsync not available; some operations may fail"

# Define what this script will restore (mirror the backup script's targets)
# These need to be declared before the summary below so counts are accurate
declare -a FILES=(
  ".bashrc" ".bash_aliases" ".bash_functions" ".bash_logout"
  ".bash_profile" ".profile" ".dir_colors" ".gitconfig" ".nanorc"
  ".vimrc" ".Xresources" "Pictures/avatar.jpg"
)

# Special files copied by backup_files.sh
declare -a SPECIAL_FILES=(
  ".config/dolphinrc" ".config/katerc" ".config/starship.toml"
  ".config/atuin/config.toml" ".config/atuin/themes/nord.toml"
  ".config/openrazer/razer.conf" ".config/openrazer/persistence.conf"
  ".config/razergenie/RazerGenie.conf" ".config/yay/config.json"
)

# Directories synced by backup_files.sh (use rsync for directories)
declare -a DIRS=(
  ".local/bin"
  "Pictures/Wallpapers"
  ".config/autostart"
)

# If not a dry run, show a summary of actions and ask for one confirmation to proceed
if [ "$DRY_RUN" != true ]; then
  declare -a SUMMARY_FILES=()
  declare -a SUMMARY_SPECIAL=()
  declare -a SUMMARY_DIRS=()
  declare -a SUMMARY_SSH=()
  PACMAN_PRESENT=false

  for rel in "${FILES[@]}"; do
    if [ -f "$SRC_ROOT/$rel" ]; then
      SUMMARY_FILES+=("$rel")
    fi
  done

  for rel in "${SPECIAL_FILES[@]}"; do
    if [ -f "$SRC_ROOT/$rel" ]; then
      SUMMARY_SPECIAL+=("$rel")
    fi
  done

  for rel in "${DIRS[@]}"; do
    if [ -d "$SRC_ROOT/$rel" ]; then
      SUMMARY_DIRS+=("$rel")
    fi
  done

  # SSH matches
  mapfile -t SUMMARY_SSH < <(compgen -G "$SRC_ROOT/.ssh/*.pub" || printf '')

  if [ -f "$SRC_ROOT/etc/pacman.conf" ]; then
    PACMAN_PRESENT=true
  fi

  log "Restore summary (non-dry-run):"
  log " - files: ${#SUMMARY_FILES[@]} to restore"
  for f in "${SUMMARY_FILES[@]}"; do log "     $f"; done
  log " - special files: ${#SUMMARY_SPECIAL[@]} to restore"
  for f in "${SUMMARY_SPECIAL[@]}"; do log "     $f"; done
  log " - directories: ${#SUMMARY_DIRS[@]} to sync"
  for d in "${SUMMARY_DIRS[@]}"; do log "     $d"; done
  log " - ssh public keys: ${#SUMMARY_SSH[@]} to restore"
  if [ "$PACMAN_PRESENT" = true ]; then
    log " - system file: /etc/pacman.conf will be restored"
  fi

  if [ "$NOPROMPT" = true ]; then
    log "--noprompt set; skipping interactive confirmation and proceeding"
  else
    read -r -p "Proceed with restore? This will overwrite files and may require sudo. [y/N] " CONFIRM
    case "$CONFIRM" in
      [Yy]*) log "User confirmed; proceeding with restore" ;;
      *) log "Restore cancelled by user"; exit 0 ;;
    esac
  fi
      fi
    for rel in "${FILES[@]}"; do
  src="$SRC_ROOT/$rel"
  dst="$HOME/$rel"
  restore_file "$src" "$dst"
done

for rel in "${SPECIAL_FILES[@]}"; do
  src="$SRC_ROOT/$rel"
  dst="$HOME/$rel"
  restore_file "$src" "$dst"
done

for rel in "${DIRS[@]}"; do
  srcdir="$SRC_ROOT/$rel"
  dstdir="$HOME/$rel"
  if [ ! -d "$srcdir" ]; then
    log "SKIP: directory not found in backup: $srcdir"
    continue
  fi
  if [ "$DRY_RUN" = true ]; then
    log "[DRY-RUN] rsync -a \"$srcdir/\" \"$dstdir/\""
  else
    mkdir -p "$dstdir"
    # Do not delete files in destination; avoid --delete
    rsync -a --links --times --omit-dir-times "$srcdir/" "$dstdir/" >>"$LOG_FILE" 2>&1
    log "RSYNCED: $srcdir/ -> $dstdir/"
  fi
done

# Restore SSH safe items
shopt -s nullglob
for pattern in "$SRC_ROOT"/.ssh/*.pub "$SRC_ROOT"/.ssh/config "$SRC_ROOT"/.ssh/known_hosts; do
  mapfile -t matches < <(compgen -G "$pattern" || printf '')
  for match in "${matches[@]}"; do
    dst="$HOME/.ssh/$(basename "$match")"
    restore_file "$match" "$dst"
  done
done
shopt -u nullglob

## Restore system pacman.conf from backup if present
PACMAN_SRC="$SRC_ROOT/etc/pacman.conf"
if [ -f "$PACMAN_SRC" ]; then
  DST_SYS="/etc/pacman.conf"
  ts=$(date +%Y%m%d%H%M%S)
  if [ "$DRY_RUN" = true ]; then
    log "[DRY-RUN] would backup existing $DST_SYS -> $DST_SYS.bak.$ts (with sudo) and copy $PACMAN_SRC -> $DST_SYS"
  else
    # Non-interactive system restore: backup existing and overwrite
    sudo cp "$DST_SYS" "$DST_SYS.bak.$ts" 2>/dev/null || true
    sudo cp --preserve=mode,timestamps "$PACMAN_SRC" "$DST_SYS"
    sudo chown root:root "$DST_SYS" || true
    sudo chmod 644 "$DST_SYS" || true
    log "RESTORED SYSTEM: $PACMAN_SRC -> $DST_SYS (backup: $DST_SYS.bak.$ts)"
  fi
fi

log "Restore finished. Log: $LOG_FILE"
