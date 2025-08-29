#!/bin/bash

# This is a script to install the base applications for Arch Linux for my personal use.

# Test if there is a network connection
if ! ping -c 1 archlinux.org &> /dev/null; then
    echo "No network connection. Please connect to the internet and try again."
    exit 1
fi

# Update system
sudo pacman -Syu --noconfirm

# Install necessary tools
sudo pacman -S vim git go pacman-contrib --noconfirm

# Install yay from AUR
git clone https://aur.archlinux.org/yay-git.git
cd yay-git
makepkg -si --noconfirm
cd ..
rm -rf yay-git

# Rank 10 fastest pacman mirrors
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sudo rankmirrors -n 10 /etc/pacman.d/mirrorlist.backup | sudo tee /etc/pacman.d/mirrorlist

# Install base applications
yay -S plasma-meta kde-graphics-meta kde-network-meta kde-utilities-meta kde-sdk-meta kde-system-meta thunderbird firewalld cups hplip networkmanager-openvpn openssh cups-filters cups-pdf systray-x-kde inetutils zip unzip p7zip unrar unarj exfatprogs ntfs-3g dosfstools packagekit-qt6 libreoffice-fresh plymouth intel-ucode pkgfile nerd-fonts starship bash-completion lesspipe nano plymouth-kcm adobe-source-code-pro-fonts github-cli nmap nikto hexchat steam system76-scheduler system76-firmware php gimp vlc system-config-printer google-chrome docker docker-compose docker-rootless-extras docker-tray visual-studio-code-bin blesh 1password 1password-cli github-desktop firmware-manager vim-plug system76-dkms system76-driver system76-power reflector --noconfirm

# Enable and start services
sudo systemctl enable firewalld cups docker bluetooth com.system76.PowerDaemon com.system76.Scheduler system76-firmware-daemon system76 pkgfile-update.timer reflector.service reflector.timer --now

# Add local systems to host file
echo "192.168.0.7 white-dwarf" | sudo tee -a /etc/hosts
echo "192.168.0.88 red-dwarf" | sudo tee -a /etc/hosts
echo "192.168.0.134 sappnas" | sudo tee -a /etc/hosts