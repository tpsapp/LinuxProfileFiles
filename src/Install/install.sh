#!/bin/bash

# This is a script to install the base applications for Arch Linux for my personal use.

# Update system
sudo pacman -Syu --noconfirm

# Install yay from AUR
sudo pacman -S vim git go --noconfirm
git clone https://aur.archlinux.org/yay-git.git
cd yay-git
makepkg -si --noconfirm
cd ..
rm -rf yay-git

# Install base applications
sudo pacman -S plasma-meta kde-graphics-meta kde-network-meta kde-utilities-meta kde-sdk-meta kde-system-meta thunderbird firewalld cups hplip networkmanager-openvpn openssh cups-filters cups-pdf systray-x-kde inetutils zip unzip p7zip unrar unarj exfatprogs ntfs-3g dosfstools packagekit-qt6 libreoffice-fresh plymouth intel-ucode pkgfile nerd-fonts starship bash-completion lesspipe nano plymouth-kcm adobe-source-code-pro-fonts github-cli nmap nikto hexchat steam system76-scheduler system76-firmware php gimp vlc system-config-printer google-chrome docker docker-compose docker-rootless-extras docker-tray visual-studio-code-bin blesh 1password 1password-cli github-desktop firmware-manager vim-plug system76-dkms system76-driver system76-power --noconfirm

# Enable and start services
sudo systemctl enable firewalld cups docker bluetooth com.system76.PowerDaemon com.system76.Scheduler system76-firmware-daemon system76 pkgfile-update.timer --now