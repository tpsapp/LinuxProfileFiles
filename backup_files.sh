#!/bin/bash

# bash files
cp ~/.bashrc src/
cp ~/.bash_aliases src/
cp ~/.bash_functions src/
cp ~/.bash_logout src/
cp ~/.bash_profile src/
cp ~/.profile src/

# dircolor files
cp ~/.dir_colors src/

# git files
cp ~/.gitconfig src/

# nano files
cp ~/.nanorc src/

# script files
cp ~/.local/bin/*.sh src/.local/bin/

# bg images
cp ~/Pictures/Wallpapers/*.* src/Pictures/Wallpapers/

# vim files
cp ~/.vimrc src/

# X11 files
cp ~/.Xresources src/

# Dolphin files
cp ~/.config/dolphinrc src/.config/

# Kate files
cp ~/.config/katerc src/.config/

# Starship files
cp ~/.config/starship.toml src/.config