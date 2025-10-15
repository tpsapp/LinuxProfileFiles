#!/usr/bin/env bash
# Safe cleanup script to remove backup files created by restore_files.sh
# Usage:
#   ./cleanup_baks.sh                # interactive: shows summary and prompts
#   ./cleanup_baks.sh --dry-run      # preview actions
#   ./cleanup_baks.sh --noprompt     # remove without prompting
#   ./cleanup_baks.sh --include-system  # include system paths like /etc

set -Eeuo pipefail
IFS=$'\n\t'

DRY_RUN=false
NOPROMPT=false
INCLUDE_SYSTEM=false
for arg in "${@:-}"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --noprompt) NOPROMPT=true ;;
    --include-system) INCLUDE_SYSTEM=true ;;
  esac
done

LOG_DIR="$(pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/cleanup_$(date +%Y%m%d%H%M%S).log"
log() { printf '%s %s\n' "$(date +'%Y-%m-%d %T')" "$*" | tee -a "$LOG_FILE"; }

declare -a SEARCH_PATHS=("$HOME")

# Build the list of locations to scan for .bak.* files based on what
# the restore script writes: files, special files, and directories.
declare -a FILES=(
  ".bashrc" ".bash_aliases" ".bash_functions" ".bash_logout"
  ".bash_profile" ".profile" ".dir_colors" ".gitconfig" ".nanorc"
  ".vimrc" ".Xresources" "Pictures/avatar.jpg"
)

declare -a SPECIAL_FILES=(
  ".config/dolphinrc" ".config/katerc" ".config/starship.toml"
  ".config/atuin/config.toml" ".config/atuin/themes/nord.toml"
)

declare -a DIRS=(
  ".local/bin"
  "Pictures/Wallpapers"
)

declare -a SEARCH_PATHS=("$HOME")

# Add parent directories for the individual files
for rel in "${FILES[@]}"; do
  SEARCH_PATHS+=("$HOME/$(dirname "$rel")")
done
for rel in "${SPECIAL_FILES[@]}"; do
  SEARCH_PATHS+=("$HOME/$(dirname "$rel")")
done
# Add the directories that were synced
for rel in "${DIRS[@]}"; do
  SEARCH_PATHS+=("$HOME/$rel")
done

if [ "$INCLUDE_SYSTEM" = true ]; then
  SEARCH_PATHS+=("/etc")
fi

log "Starting cleanup. DRY_RUN=$DRY_RUN INCLUDE_SYSTEM=$INCLUDE_SYSTEM"

# Deduplicate and keep only existing directories
declare -A _seen
declare -a _unique
for p in "${SEARCH_PATHS[@]}"; do
  # skip empty
  [ -z "$p" ] && continue
  # normalize path (avoid trailing slash differences)
  p="${p%/}"
  if [ -d "$p" ] && [ -z "${_seen[$p]:-}" ]; then
    _unique+=("$p")
    _seen[$p]=1
  fi
done

# Find .bak.* files under the computed locations
mapfile -t FOUND < <(find "${_unique[@]}" -type f -name "*.bak.*" 2>/dev/null || true)

if [ ${#FOUND[@]} -eq 0 ]; then
  log "No backup files (\*.bak.*) found under: ${SEARCH_PATHS[*]}"
  exit 0
fi

log "Found ${#FOUND[@]} backup files to remove"
if [ "$DRY_RUN" = true ]; then
  for f in "${FOUND[@]}"; do
    log "[DRY-RUN] would remove: $f"
  done
  exit 0
fi

if [ "$NOPROMPT" = false ]; then
  echo "The following backup files will be removed:"
  for f in "${FOUND[@]}"; do
    echo "  $f"
  done
  read -r -p "Proceed and remove these files? [y/N] " CONF
  case "$CONF" in
    [Yy]*) log "User confirmed; removing files" ;;
    *) log "Cancelled by user"; exit 0 ;;
  esac
else
  log "--noprompt set; removing files without confirmation"
fi

# Remove files
for f in "${FOUND[@]}"; do
  if [ ! -e "$f" ]; then
    log "SKIP (missing): $f"
    continue
  fi

  if [[ "$f" == /etc/* ]]; then
    if [ "$DRY_RUN" = true ]; then
      log "[DRY-RUN] would sudo rm -f $f"
    else
      sudo rm -f "$f"
      log "REMOVED (sudo): $f"
    fi
  else
    if [ "$DRY_RUN" = true ]; then
      log "[DRY-RUN] would rm -f $f"
    else
      rm -f "$f"
      log "REMOVED: $f"
    fi
  fi
done

log "Cleanup finished. Log: $LOG_FILE"
