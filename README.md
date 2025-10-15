# Linux Profile Files

These are a collection of documents that I use on my Linux distributions.

## Backup / Restore

This repository contains helper scripts to collect and restore local profile files.

- `backup_files.sh` - safe backup script that copies selected files into `src/`.

  - Supports the following options:
    - `--dry-run` : Preview actions only; do not write files or create dirs.
  - Writes a timestamped log to `logs/backup_YYYYMMDDHHMMSS.log`.
  - By default, it does NOT copy SSH private keys or GPG private material.

- `restore_files.sh` - interactive restore script that prompts before overwriting and backs up any existing files to `*.bak.TIMESTAMP`.
  - Supports the following options:
    - `--dry-run` : Preview actions only; no changes are made.
    - `--force` : Legacy flag; proceed to overwrite files (behavior maintained).
    - `--noprompt` : Skip the one-time confirmation prompt and proceed immediately (useful for automation/CI). The script still creates timestamped backups before overwriting unless `--dry-run` is set.
  - The script backs up existing files to `*.bak.TIMESTAMP` before restoring.

Security notes:

- Do NOT commit private keys, secrets, or other sensitive material to this repository. The scripts intentionally avoid copying SSH private keys.
- If you must back up secrets, use an encrypted archive (GPG) and store it outside the repo or use `git-crypt`/private storage.
