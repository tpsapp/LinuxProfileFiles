#!/bin/bash

# bash files
cp src/.bashrc ~/
cp src/.bash_aliases ~/
cp src/.bash_functions ~/
cp src/.bash_logout ~/
cp src/.bash_profile ~/
cp src/.profile ~/

# dircolor files
cp src/.dir_colors ~/

# git files
cp src/.gitconfig ~/

# nano files
cp src/.nanorc ~/

# vim files
cp src/.vimrc ~/

# X11 files
cp src/.Xresources ~/

# Dolphin files
cp src/.config/dolphinrc ~/.config/

# Kate files
cp src/.config/katerc ~/.config/

# Starship files
cp src/.config/starship.toml ~/.config

# script files
# check if ~/.local/bin exists, if not create it
if ! [ -d ~/.local/bin ]; then
    mkdir -p ~/.local/bin
fi
# copy all files from src/.local/bin to ~/.local/bin
cp src/.local/bin/* ~/.local/bin/

# bg images
# check if ~/Pictures/Wallpapers exists, if not create it
if ! [ -d ~/Pictures/Wallpapers ]; then
    mkdir -p ~/Pictures/Wallpapers
fi
# copy all files from src/Pictures/Wallpapers to ~/Pictures/Wallpapers
cp src/Pictures/Wallpapers/*.* ~/Pictures/Wallpapers

# avatar image
cp src/Pictures/avatar.jpg ~/Pictures/

# ssh files
# check if ~/.ssh exists, if not create it
if ! [ -d ~/.ssh ]; then
    mkdir -p ~/.ssh
fi
# copy all files from src/.ssh to ~/.ssh
cp src/.ssh/* ~/.ssh/