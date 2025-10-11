#!/bin/bash
set -ex

# This is a script to install the base applications for Arch Linux for my personal use.

# Test if there is a network connection
echo "Checking network connection..."
if ! ping -c 1 archlinux.org &> /dev/null; then
    echo "No network connection. Please connect to the internet and try again."
    exit 1
fi

# Update system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install necessary tools
echo "Installing necessary tools..."
sudo pacman -S vim git go pacman-contrib --noconfirm --needed

# Install yay from AUR
if ! [ -f /usr/bin/yay ]; then
    echo "Installing yay from AUR..."
    git clone https://aur.archlinux.org/yay-git.git
    cd yay-git
    makepkg -si --noconfirm
    cd ..
    rm -rf yay-git
fi

# Rank 10 fastest pacman mirrors
echo "Ranking 10 fastest pacman mirrors..."
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sudo rankmirrors -w -n 10 /etc/pacman.d/mirrorlist.backup | sudo tee /etc/pacman.d/mirrorlist

# Install base applications
echo "Installing base applications..."
yay -S thunderbird firewalld cups hplip networkmanager-openvpn openssh cups-filters cups-pdf systray-x-kde inetutils zip unzip p7zip unrar unarj exfatprogs ntfs-3g dosfstools packagekit-qt6 libreoffice-fresh plymouth intel-ucode pkgfile nerd-fonts starship bash-completion lesspipe nano plymouth-kcm adobe-source-code-pro-fonts github-cli nmap nikto hexchat steam system76-scheduler system76-firmware php gimp vlc system-config-printer docker docker-compose docker-rootless-extras docker-tray visual-studio-code-bin blesh 1password 1password-cli github-desktop firmware-manager vim-plug system76-dkms system76-driver system76-power reflector atuin openrazer-driver-dkms openrazer-daemon libopenrazer razergenie input-remapper-bin --noconfirm --needed

# Enable and start services
echo "Enabling and starting services..."
sudo systemctl enable firewalld cups docker bluetooth com.system76.PowerDaemon com.system76.Scheduler system76-firmware-daemon system76 pkgfile-update.timer reflector.service reflector.timer --now

# Add local systems to host file
echo "Adding local systems to /etc/hosts..."
echo "192.168.0.7 white-dwarf" | sudo tee -a /etc/hosts
echo "192.168.0.88 red-dwarf" | sudo tee -a /etc/hosts
echo "192.168.0.134 sappnas" | sudo tee -a /etc/hosts

# Add only 'splash' and 'quiet' to the kernel command line for systemd-boot
# entries so the plymouth splash can be enabled. Back up each entry first and
# skip entries that already contain either token.
if [ -d /boot/loader/entries ]; then
    filesChanged=false
    echo "Configuring systemd-boot entries to include: splash quiet"
    for f in /boot/loader/entries/*.conf; do
        [ -e "$f" ] || continue

        # If the options line already contains splash or quiet, skip
        if grep -Eq "^options.*\b(splash|quiet)\b" "$f"; then
            echo " - $f already contains splash/quiet; skipping"
            continue
        fi

        ts=$(date +%Y%m%d%H%M%S)
        sudo cp "$f" "$f.bak.$ts"

        # Append 'splash quiet' to the options line only if both are missing
        sudo awk -v add=" splash quiet" \
            '/^options/ { if ($0 !~ /splash/ && $0 !~ /quiet/) $0 = $0 add } { print }' "$f" \
            | sudo tee "$f" > /dev/null

        echo " - updated $f (backup: $f.bak.$ts)"
        filesChanged=true
    done
else
    echo "/boot/loader/entries not found; skipping systemd-boot splash/quiet configuration"
fi

if [ "$filesChanged" = true ]; then
    echo "Running mkinitcpio for updated initramfs images"
    sudo mkinitcpio -P
fi