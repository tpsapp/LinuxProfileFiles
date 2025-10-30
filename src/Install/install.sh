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
echo "**** Checking network connection..."
if ! ping -c 1 archlinux.org > /dev/null 2>&1; then
    echo "No network connection. Please connect to the internet and try again."
    exit 1
fi

## Update system
echo "**** Updating system..."
run_sudo pacman -Syu --noconfirm

## Install necessary tools
echo "**** Installing necessary tools..."
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

## Rank 20 fastest pacman mirrors (if rankmirrors available)
echo "**** Ranking 20 fastest pacman mirrors..."
if command -v rankmirrors > /dev/null 2>&1; then
    run_sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    # Some rankmirrors implementations accept -n for number; use -n 20
    if $DRY_RUN; then
        echo "[DRY-RUN] rankmirrors -n 20 /etc/pacman.d/mirrorlist.backup | sudo tee /etc/pacman.d/mirrorlist"
    else
        rankmirrors -n 20 /etc/pacman.d/mirrorlist.backup | sudo tee /etc/pacman.d/mirrorlist > /dev/null
    fi
else
    echo "rankmirrors not found; skipping mirror ranking"
fi

## Install base applications
echo "**** Installing base applications..."
ALL_INSTALLED=false
PKGS=(
    adobe-source-code-pro-fonts
    ark
    atuin
    bash-completion
    colord-kde
    cups
    cups-filters
    cups-pdf
    docker
    docker-compose
    dolphin-plugins
    dosfstools
    exfatprogs
    ffmpegthumbs
    filelight
    filezilla
    firefox
    firewalld
    gameconqueror
    gamemode
    gimp
    git
    github-cli
    go
    gwenview
    gwenview
    hplip
    hunspell-en_us
    inetutils
    intel-media-driver
    isoimagewriter
    kalk
    kamera
    kapptemplate
    kate
    kbackup
    kcachegrind
    kcharselect
    kclock
    kcolorchooser
    kde-dev-scripts
    kde-dev-utils
    kde-sdk-meta
    kdebugsettings
    kdeconnect
    kdegraphics-thumbnailers
    kdenetwork-filesharing
    kdesdk-kio
    kdesdk-thumbnailers
    kdf
    kdialog
    keditbookmarks
    keysmith
    kfind
    kgpg
    kimageformats
    kio-extras
    kio-gdrive
    kio-zeroconf
    kirigami-gallery
    koko
    kompare
    konsole
    krdc
    krecorder
    krfb
    ktimer
    ktorrent
    kwalletmanager
    kweather
    lesspipe
    lib32-gamemode
    lib32-vulkan-intel
    libreoffice-fresh
    libva-intel-driver
    lokalize
    markdownpart
    ncdu
    networkmanager-openvpn
    nikto
    nmap
    noto-fonts-cjk
    ntfs-3g
    nvidia-settings
    okteta
    okular
    ollama-cuda
    openrazer-daemon
    openrazer-driver-dkms
    openssh
    p7zip
    packagekit-qt6
    pacman-contrib
    php
    pkgfile
    plymouth
    plymouth-kcm
    poxml
    qrca
    reflector
    rsync
    shellcheck
    signon-kwallet-extension
    skanlite
    skanpage
    sshfs
    starship
    steam
    svgpart
    sweeper
    system-config-printer
    system76-firmware
    system76-scheduler
    systray-x-kde
    thunderbird
    ttf-3270-nerd
    ttf-firacode-nerd
    unarj
    unrar
    unzip
    virt-manager
    vlc
    vulkan-intel
    zip
)

AURPKGS=(
    1password
    1password-cli
    blesh-git
    docker-rootless-extras
    docker-tray
    firmware-manager
    github-desktop
    google-chrome
    hexchat
    input-remapper-bin
    libopenrazer
    ocs-url
    razergenie
    system76-dkms
    system76-driver
    system76-power
    vim-plug
    visual-studio-code-bin
)

if command -v pacman > /dev/null 2>&1; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] pacman -S --noconfirm --needed ${PKGS[*]}"
    else
        sudo pacman -S --noconfirm --needed "${PKGS[@]}"
        ALL_INSTALLED=true
    fi
else
    echo "pacman not available; please make sure you are running Arch Linux or an Arch-based distro."
fi

if command -v yay > /dev/null 2>&1; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] yay -S --noconfirm --needed ${AURPKGS[*]}"
    else
        yay -S --noconfirm --needed "${AURPKGS[@]}"
        ALL_INSTALLED=true
    fi
else
    echo "yay not available, please install yay to proceed with AUR packages."
fi

## Add user to necessary groups
if [ "$ALL_INSTALLED" = true ]; then
    echo "**** Adding user '$USER' to necessary groups..."
    GROUPS=(
        "docker"
        "plugdev"
    )

    for group in "${GROUPS[@]}"; do
        echo " - Adding user '$USER' to group '$group'"
        run_sudo usermod -aG "$group" "$USER"
    done
else
    echo "Not all packages were installed; skipping group membership changes."
fi

## Enable services
if [ "$ALL_INSTALLED" = true ]; then
    echo "**** Enabling services..."
    SERVICES=(
        "firewalld.service"
        "cups.service"
        "docker.service"
        "bluetooth.service"
        "com.system76.PowerDaemon.service"
        "com.system76.Scheduler.service"
        "system76-firmware-daemon.service"
        "system76.service"
        "nvidia-powerd.service"
        "ollama.service"
        "pkgfile-update.timer"
        "reflector.service"
        "reflector.timer"
    )

    for svc in "${SERVICES[@]}"; do
        echo " - Enabling $svc"
        run_sudo systemctl enable "$svc"
    done

    systemctl --user enable openrazer-daemon.service
else
    echo "Not all packages were installed; skipping service enable."
fi

## Add local systems to host file (idempotent)
echo "**** Adding local systems to /etc/hosts..."
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
    echo "**** Configuring systemd-boot entries to include: splash quiet"
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
            # Avoid truncating the original entry by writing modified content to a
            # root-owned temporary file, then atomically moving it into place. Use
            # `sudo awk | sudo tee` so the temp file is created with root ownership
            # (this also addresses shellcheck SC2024 about redirects under sudo).
            tmpfile="/tmp/$(basename "$f").tmp.$ts"
            if sudo awk -v add="${tokens[*]}" '
                BEGIN { split(add, a, " ") }
                /^options/ {
                    for (i in a) if ($0 !~ "\\<" a[i] "\\>") $0 = $0 " " a[i]
                }
                { print }
            ' "$f" | sudo tee "$tmpfile" > /dev/null; then
                run_sudo mv "$tmpfile" "$f"
                echo " - updated $f (backup: $f.bak.$ts)"
                filesChanged=true
            else
                echo " - ERROR: failed to update $f"
                [ -e "$tmpfile" ] && sudo rm -f "$tmpfile"
            fi
        fi
    done
else
    echo "/boot/loader/entries not found; skipping systemd-boot splash/quiet configuration"
fi

if [ "$filesChanged" = true ]; then
    echo "**** Running mkinitcpio for updated initramfs images"
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
            echo "Cloned to /tmp/LinuxProfileFiles. I will not run the repository's restore_files.sh automatically. Inspect and run it manually if desired."
        fi
    fi
fi
