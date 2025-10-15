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

# Search locations
declare -a SEARCH_PATHS=("$HOME")
if [ "$INCLUDE_SYSTEM" = true ]; then
  SEARCH_PATHS+=("/etc")
fi

log "Starting cleanup. DRY_RUN=$DRY_RUN INCLUDE_SYSTEM=$INCLUDE_SYSTEM"

# Find .bak.* files under the given paths
mapfile -t FOUND < <(find "${SEARCH_PATHS[@]}" -type f -name "*.bak.*" 2>/dev/null || true)

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
  if [ -e "$f" ]; then
    rm -f "$f"
    log "REMOVED: $f"
  else
    log "SKIP (missing): $f"
  fi
done

log "Cleanup finished. Log: $LOG_FILE"
