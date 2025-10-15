#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# This is a script to install the base applications for Arch Linux for my personal use.
# Usage: ./install.sh [--dry-run]

# Basic tracing for failures
# initialize tracking variables so shellcheck doesn't warn about undefined vars (SC2154)
current_cmd=""
last_cmd=""
trap 'last_cmd=$current_cmd; current_cmd=$BASH_COMMAND' DEBUG
trap 'echo "ERROR: \"${last_cmd}\" command failed with exit code $?"' ERR

# Dry-run support
DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=true
    echo "Running in DRY-RUN mode; no destructive changes will be made"
fi

run() {
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] $*"
    else
        eval "$*"
    fi
}

run_sudo() {
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] sudo $*"
    else
        sudo "$@"
    fi
}

## Test if there is a network connection
echo "Checking network connection..."
if ! ping -c 1 archlinux.org > /dev/null 2>&1; then
    echo "No network connection. Please connect to the internet and try again."
    exit 1
fi

## Rank 10 fastest pacman mirrors (if rankmirrors available)
echo "Ranking 10 fastest pacman mirrors..."
if command -v rankmirrors > /dev/null 2>&1; then
    run_sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    # Some rankmirrors implementations accept -n for number; use -n 10
    if $DRY_RUN; then
        echo "[DRY-RUN] rankmirrors -n 10 /etc/pacman.d/mirrorlist.backup | sudo tee /etc/pacman.d/mirrorlist"
    else
        rankmirrors -n 10 /etc/pacman.d/mirrorlist.backup | sudo tee /etc/pacman.d/mirrorlist > /dev/null
    fi
else
    echo "rankmirrors not found; skipping mirror ranking"
fi

## Update system
echo "Updating system..."
run_sudo pacman -Syu --noconfirm

## Install necessary tools
echo "Installing necessary tools..."
run_sudo pacman -S --noconfirm --needed vim git go pacman-contrib

## Install yay from AUR (if missing)
if ! command -v yay > /dev/null 2>&1; then
    echo "yay not found; installing yay from AUR..."
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-git.git "$tmpdir/yay-git"
    (cd "$tmpdir/yay-git" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
else
    echo "yay already installed"
fi

## Install base applications
echo "Installing base applications..."
PKGS=(
    thunderbird firewalld cups hplip networkmanager-openvpn google-chrome openssh cups-filters cups-pdf systray-x-kde
    inetutils zip unzip p7zip unrar unarj exfatprogs ntfs-3g dosfstools packagekit-qt6 libreoffice-fresh
    plymouth intel-ucode pkgfile nerd-fonts starship bash-completion lesspipe nano plymouth-kcm
    adobe-source-code-pro-fonts github-cli nmap nikto hexchat steam system76-scheduler system76-firmware
    php gimp vlc system-config-printer docker docker-compose docker-rootless-extras docker-tray
    visual-studio-code-bin blesh 1password 1password-cli github-desktop firmware-manager vim-plug
    system76-dkms system76-driver system76-power reflector atuin openrazer-driver-dkms openrazer-daemon
    libopenrazer razergenie input-remapper-bin
)

if command -v yay > /dev/null 2>&1; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] yay -S --noconfirm --needed ${PKGS[*]}"
    else
        yay -S --noconfirm --needed "${PKGS[@]}"
    fi
else
    echo "yay not available; installing available packages via pacman (non-AUR)"
    # Attempt installing via pacman only; skip packages not in official repos
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] sudo pacman -S --noconfirm --needed ${PKGS[*]}"
    else
        run_sudo pacman -S --noconfirm --needed "${PKGS[@]}" || echo "Some packages may be AUR-only and were skipped"
    fi
fi

## Enable and start services
echo "Enabling and starting services..."
run_sudo systemctl enable firewalld cups docker bluetooth com.system76.PowerDaemon com.system76.Scheduler system76-firmware-daemon system76 pkgfile-update.timer reflector.service reflector.timer --now

## Add local systems to host file (idempotent)
echo "Adding local systems to /etc/hosts..."
add_host_if_missing() {
    local ip="$1" name="$2"
    if ! grep -qxF "$ip $name" /etc/hosts; then
        if [ "$DRY_RUN" = true ]; then
            echo "[DRY-RUN] would add: $ip $name to /etc/hosts"
        else
            echo "$ip $name" | sudo tee -a /etc/hosts >/dev/null
            echo "Added $ip $name to /etc/hosts"
        fi
    else
        echo "/etc/hosts already contains: $ip $name"
    fi
}

add_host_if_missing 192.168.0.7 white-dwarf
add_host_if_missing 192.168.0.88 red-dwarf
add_host_if_missing 192.168.0.134 sappnas

## Add only 'splash' and 'quiet' to the kernel command line for systemd-boot entries.
## Back up each entry first and add missing tokens individually.
filesChanged=false
if [ -d /boot/loader/entries ]; then
    echo "Configuring systemd-boot entries to include: splash quiet"
    tokens=(splash quiet)
    for f in /boot/loader/entries/*.conf; do
        [ -e "$f" ] || continue
        need_change=false
        for t in "${tokens[@]}"; do
            if ! grep -Eq "^options.*\b${t}\b" "$f"; then
                need_change=true
                break
            fi
        done
        if [ "$need_change" = false ]; then
            echo " - $f already contains splash/quiet; skipping"
            continue
        fi

        ts=$(date +%Y%m%d%H%M%S)
        run_sudo cp "$f" "$f.bak.$ts"

        # Append missing tokens individually
        if [ "$DRY_RUN" = true ]; then
            echo "[DRY-RUN] would update $f to add missing tokens: ${tokens[*]}"
        else
            sudo awk -v add="${tokens[*]}" '
                BEGIN { split(add, a, " ") }
                /^options/ {
                    for (i in a) if ($0 !~ "\\<" a[i] "\\>") $0 = $0 " " a[i]
                }
                { print }
            ' "$f" | sudo tee "$f" > /dev/null
            echo " - updated $f (backup: $f.bak.$ts)"
            filesChanged=true
        fi
    done
else
    echo "/boot/loader/entries not found; skipping systemd-boot splash/quiet configuration"
fi

if [ "$filesChanged" = true ]; then
    echo "Running mkinitcpio for updated initramfs images"
    run_sudo mkinitcpio -P
fi

## Optional: clone user's profile files (do not auto-run their install script)
if [ "${USER:-}" = "tpsapp" ]; then
    echo "Would you like to clone your profile files repository to /tmp for review? (y/n)"
    read -r response
    if [[ $response == "y" || $response == "Y" ]]; then
        echo "Cloning profile files repository to /tmp/LinuxProfileFiles"
        if [ "$DRY_RUN" = true ]; then
            echo "[DRY-RUN] git clone https://github.com/tpsapp/LinuxProfileFiles /tmp/LinuxProfileFiles"
        else
            git clone https://github.com/tpsapp/LinuxProfileFiles /tmp/LinuxProfileFiles
            echo "Cloned to /tmp/LinuxProfileFiles. I will not run the repository's install.sh automatically. Inspect and run it manually if desired."
        fi
    fi
fi